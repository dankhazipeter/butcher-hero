"""Offline session-boundary tests; isolated journals and no game control."""
from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
import tempfile
import threading
import unittest
from unittest.mock import Mock, patch
from urllib.error import HTTPError
from urllib.request import Request, build_opener, ProxyHandler

from dashboard.server import Journal, aggregate, make_server, parse_time
from dashboard.stat_sessions import StatSessions, SessionError


class StatSessionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="butcher-stat-session-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.path = self.root / "data/free-rewards/events.jsonl"
        self.path.parent.mkdir(parents=True)
        self.rows = [
            {"event": "watcher_started", "timestamp": "2026-10-31T10:00:00Z"},
            {"event": "click_sent", "timestamp": "2026-10-31T10:01:00Z", "claimID": "old", "reward": {"kind": "hp", "amount": "18100"}},
            {"event": "claim_confirmed_ui", "timestamp": "2026-10-31T10:01:02Z", "claimID": "old"},
        ]
        self.write()
        self.journal = Journal(self.path)
        self.sessions = StatSessions(self.root)
        self.now = parse_time("2026-10-31T10:10:00Z")

    def write(self):
        self.path.write_text("".join(json.dumps(row) + "\n" for row in self.rows))

    def events(self):
        return self.journal.snapshot()[0]

    def start(self, expected=None):
        return self.sessions.start(expected or self.sessions.current(self.events())["id"], self.events, self.now)

    def result(self, mode, at=None):
        return aggregate(self.events(), 0, True, {"range": [mode]}, at or self.now, self.sessions.current(self.events())["at"])

    def test_reading_does_not_create_boundary_or_modify_journal(self):
        before = self.path.read_bytes()
        self.assertEqual(self.sessions.current(self.events())["source"], "watcher")
        self.assertFalse(self.sessions.path.exists())
        self.assertEqual(self.result("run")["confirmedClaims"], 1)
        self.assertEqual(self.path.read_bytes(), before)

    def test_reset_only_changes_run_other_ranges_and_journal_remain_intact(self):
        before = self.path.read_bytes()
        other = {mode: self.result(mode) for mode in ("today", "hour", "day", "all")}
        self.start()
        self.assertEqual(self.result("run")["confirmedClaims"], 0)
        self.assertTrue(all(row["total"] == "0" for row in self.result("run")["kinds"]))
        for mode, value in other.items():
            self.assertEqual(self.result(mode), value, mode)
        self.assertEqual(self.path.read_bytes(), before)
        self.assertFalse((self.root / "data/free-rewards/state.json").exists())

    def test_boundary_persists_and_resume_preserves_it_new_watcher_start_supersedes_it(self):
        created = self.start()
        self.rows.append({"event": "watcher_resumed", "timestamp": "2026-10-31T10:11:00Z"})
        self.write()
        self.assertEqual(StatSessions(self.root).current(self.events())["id"], created["id"])
        self.rows.append({"event": "watcher_started", "timestamp": "2026-10-31T10:12:00Z"})
        self.write()
        self.assertEqual(self.sessions.current(self.events())["source"], "watcher")
        self.assertEqual(self.sessions.current(self.events())["at"], parse_time("2026-10-31T10:12:00Z"))

    def test_inflight_old_click_confirmed_after_boundary_is_not_new_run_reward(self):
        self.rows += [{"event": "click_sent", "timestamp": "2026-10-31T10:09:59Z", "claimID": "inflight", "reward": {"kind": "hp", "amount": "18100"}}]
        self.write()
        self.start()
        self.rows += [
            {"event": "claim_confirmed_ui", "timestamp": "2026-10-31T10:10:02Z", "claimID": "inflight"},
            {"event": "click_sent", "timestamp": "2026-10-31T10:10:03Z", "claimID": "new", "reward": {"kind": "hp", "amount": "18600"}},
            {"event": "claim_confirmed_ui", "timestamp": "2026-10-31T10:10:04Z", "claimID": "new"},
        ]
        self.write()
        later = parse_time("2026-10-31T10:11:00Z")
        self.assertEqual(self.result("run", later)["confirmedClaims"], 1)
        self.assertEqual(self.result("all", later)["confirmedClaims"], 3)
        self.assertEqual(self.result("run", later)["kinds"][0]["total"], "18600")

    def test_duplicate_deliveries_across_instances_create_one_boundary(self):
        expected = self.sessions.current(self.events())["id"]
        with ThreadPoolExecutor(max_workers=4) as pool:
            created = list(pool.map(lambda _: StatSessions(self.root).start(expected, self.events, self.now), range(8)))
        self.assertEqual(len({row["id"] for row in created}), 1)
        before = self.sessions.path.read_bytes()
        self.assertEqual(self.start(expected)["id"], created[0]["id"])
        self.assertEqual(self.sessions.path.read_bytes(), before)

    def test_stale_tab_cannot_overwrite_newer_session(self):
        original = self.sessions.current(self.events())["id"]
        self.start()
        self.start()
        before = self.sessions.path.read_bytes()
        with self.assertRaises(SessionError) as error:
            self.start(original)
        self.assertEqual(error.exception.status, 409)
        self.assertEqual(self.sessions.path.read_bytes(), before)

    def test_corrupt_metadata_or_write_failure_never_silently_resets(self):
        self.sessions.path.write_text("bad data")
        with self.assertRaises(SessionError):
            self.sessions.current(self.events())
        with self.assertRaises(SessionError):
            self.start("empty")
        self.assertEqual(self.sessions.path.read_text(), "bad data")
        self.sessions.path.unlink()
        with patch("dashboard.stat_sessions.os.replace", side_effect=OSError("disk failure")), self.assertRaises(SessionError):
            self.start()
        self.assertFalse(self.sessions.path.exists())
        self.assertEqual(list(self.path.parent.glob(".stat-session-*")), [])


class StatSessionHTTPTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="butcher-stat-http-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.game = Mock()
        self.game.snapshot.return_value = {"known": False}
        self.server = make_server(self.root, 0, game_control=self.game)
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.addCleanup(self.close_server)
        self.base = f"http://127.0.0.1:{self.server.server_port}"
        self.opener = build_opener(ProxyHandler({}))
        self.initial = self.get()

    def close_server(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()

    def get(self):
        with self.opener.open(self.base + "/api/rewards?range=all", timeout=3) as response:
            return json.load(response)

    def post(self, body=None, headers=None):
        body = json.dumps({"expectedSessionID": self.initial["currentSession"]["id"]}).encode() if body is None else body
        values = {"Origin": self.base, "Content-Type": "application/json", "X-Statistics-Session-Token": self.initial["statisticsSessionToken"], "Sec-Fetch-Site": "same-origin"}
        for key, value in (headers or {}).items():
            if value is None:
                values.pop(key, None)
            else:
                values[key] = value
        try:
            response = self.opener.open(Request(self.base + "/api/statistics/session", data=body, headers=values), timeout=3)
        except HTTPError as error:
            response = error
        with response:
            return response.code, json.load(response)

    def test_only_explicit_post_creates_session_persists_and_replays(self):
        path = self.root / "data/free-rewards/stat-session.json"
        self.assertFalse(path.exists())
        status, result = self.post()
        self.assertEqual((status, result["status"]), (200, "started"))
        self.assertEqual(self.get()["currentSession"], result["currentSession"])
        self.assertEqual(self.post()[1], result)
        self.game.launch.assert_not_called()
        self.assertFalse((path.parent / "events.jsonl").exists())
        self.assertFalse((path.parent / "state.json").exists())

    def test_requires_same_origin_host_site_and_its_own_token(self):
        for headers in ({"Origin": None}, {"Origin": "https://evil.example"}, {"Host": "evil.example"},
                        {"Sec-Fetch-Site": "cross-site"}, {"X-Statistics-Session-Token": None},
                        {"X-Statistics-Session-Token": self.initial["gameLaunchToken"]},
                        {"X-Statistics-Session-Token": "é"}):
            with self.subTest(headers=headers):
                self.assertEqual(self.post(headers=headers)[0], 403)
        self.assertFalse((self.root / "data/free-rewards/stat-session.json").exists())

    def test_rejects_missing_or_arbitrary_body_fields_and_unsafe_transport(self):
        for body in (b"", b"{}", b"[]", b"invalid", b'{"expectedSessionID":false}',
                     b'{"expectedSessionID":""}', b'{"expectedSessionID":"empty","delete":true}', b" " * 257):
            with self.subTest(body=body):
                self.assertEqual(self.post(body=body)[0], 400)
        self.assertEqual(self.post(headers={"Content-Type": "text/plain"})[0], 400)
        self.assertEqual(self.post(headers={"Transfer-Encoding": "chunked"})[0], 400)
        self.assertFalse((self.root / "data/free-rewards/stat-session.json").exists())


if __name__ == "__main__":
    unittest.main()
