import json
from pathlib import Path
import tempfile
import threading
import unittest
from unittest.mock import patch
from urllib.error import HTTPError
from urllib.request import Request, urlopen

from dashboard.server import Journal, aggregate, amount, make_server, parse_time, time_window, watcher_state


def event(kind, second, claim="one", value="578", reward_kind="cutting_defense"):
    return {"event": kind, "timestamp": f"2026-10-30T10:00:{second:02}.000Z",
            "claimID": claim, "runID": "fixture", "schemaVersion": 1,
            "reward": {"kind": reward_kind, "amount": value, "rawAmount": value}}


class DashboardTests(unittest.TestCase):
    def test_loopback_server_binding_never_uses_reverse_dns(self):
        # HTTPServer's default server_bind calls getfqdn, which can wait on
        # external resolver configuration even for a numeric loopback address.
        with patch("socket.getfqdn", side_effect=AssertionError("Unexpected reverse DNS lookup")):
            server = make_server(self.root, 0)
        self.addCleanup(server.server_close)
        self.assertEqual(server.server_address[0], "127.0.0.1")
        self.assertEqual(server.server_name, "127.0.0.1")
        self.assertEqual(server.server_port, server.server_address[1])

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="butcher-dashboard-test-")
        self.root = Path(self.temp.name)
        self.path = self.root / "data/free-rewards/events.jsonl"
        self.path.parent.mkdir(parents=True)

    def tearDown(self):
        self.temp.cleanup()

    def write(self, rows):
        self.path.write_text("".join(json.dumps(row) + "\n" for row in rows))

    def result(self, query=None):
        events, bad, exists = Journal(self.path).snapshot()
        return aggregate(events, bad, exists, query or {"range": ["all"]}, parse_time("2026-10-30T11:00:00Z"))

    def test_retry_counts_once_pending_excluded_correction_and_all_eight_types(self):
        self.write([event("click_sent", 0), event("click_sent", 2), event("claim_confirmed_ui", 4),
                    event("click_sent", 5, "pending"), event("click_sent", 7, "pending"),
                    event("reward_corrected", 8, value="591")])
        result = self.result()
        self.assertEqual(result["clickAttempts"], 4)
        self.assertEqual(result["confirmedClaims"], 1)
        self.assertEqual(result["pendingClaims"], 1)
        self.assertEqual(len(result["kinds"]), 8)
        self.assertEqual(next(row["total"] for row in result["kinds"] if row["kind"] == "cutting_defense"), "591")
        self.assertEqual(result["series"]["cutting_defense"][-1]["value"], "591")

    def test_validation_and_diagnostic_events_never_count_as_claims_or_replace_sent_reward(self):
        self.write([event("click_intent", 0, value="999", reward_kind="unknown"),
                    event("preclick_rejected", 1, value="999", reward_kind="unknown"),
                    event("candidate_lost", 2, value="999", reward_kind="unknown"),
                    event("click_validated", 3, value="18300", reward_kind="hp")])
        self.assertEqual(self.result()["confirmedClaims"], 0)
        self.assertEqual(self.result()["clickAttempts"], 0)
        self.write([event("click_validated", 3, value="18300", reward_kind="hp"),
                    event("click_sent", 4, value="18300", reward_kind="hp"),
                    event("claim_confirmed_ui", 6, value="18300", reward_kind="hp")])
        result=self.result()
        self.assertEqual(result["confirmedClaims"], 1)
        self.assertEqual(result["clickAttempts"], 1)
        self.assertEqual(result["series"]["hp"][-1]["value"], "18300")

    def test_final_attempt_time_and_confirmation_after_range_end(self):
        self.write([event("click_sent", 0), event("click_sent", 2), event("claim_confirmed_ui", 4)])
        early = self.result({"from": ["2026-10-30T10:00:00Z"], "to": ["2026-10-30T10:00:01Z"]})
        self.assertEqual(early["confirmedClaims"], 0)
        self.assertEqual(early["clickAttempts"], 1)
        final = self.result({"from": ["2026-10-30T10:00:02Z"], "to": ["2026-10-30T10:00:03Z"]})
        self.assertEqual(final["confirmedClaims"], 1)

    def test_unknown_or_bad_amount_never_in_total(self):
        self.write([event("click_sent", 0, value="18K"), event("claim_confirmed_ui", 1, value="18K"),
                    event("click_sent", 2, "unknown", "18000", "unknown"),
                    event("claim_confirmed_ui", 3, "unknown", "18000", "unknown")])
        result = self.result()
        self.assertEqual(result["unknownConfirmed"], 2)
        self.assertTrue(all(row["total"] == "0" for row in result["kinds"]))
        self.assertEqual(amount("18000"), 18000)
        self.assertIsNone(amount("Infinity"))

    def test_append_partial_invalid_line_and_truncation(self):
        self.write([event("click_sent", 0)])
        reader = Journal(self.path)
        self.assertEqual(len(reader.snapshot()[0]), 1)
        line = json.dumps(event("claim_confirmed_ui", 2)).encode()
        with self.path.open("ab") as output:
            output.write(line[:20])
        self.assertEqual(len(reader.snapshot()[0]), 1)
        with self.path.open("ab") as output:
            output.write(line[20:] + b"\nnot json\n")
        events, bad, _ = reader.snapshot()
        self.assertEqual(len(events), 2)
        self.assertEqual(bad, 1)
        self.path.write_text("")
        self.assertEqual(reader.snapshot(), ([], 0, True))

    def test_missing_file_and_atomic_replacement(self):
        reader = Journal(self.path)
        self.assertEqual(reader.snapshot(), ([], 0, False))
        self.write([event("click_sent", 0)])
        self.assertEqual(len(reader.snapshot()[0]), 1)
        replacement = self.path.with_suffix(".new")
        replacement.write_text(json.dumps(event("watcher_started", 3)) + "\n")
        replacement.replace(self.path)
        self.assertEqual(reader.snapshot()[0][0]["event"], "watcher_started")

    def test_explicit_bucharest_day_boundary_and_latest_run(self):
        now = parse_time("2026-10-30T11:00:00Z")
        _, start, _ = time_window({"range": ["today"], "timezone": ["Europe/Bucharest"]}, [], now)
        self.assertEqual(start, parse_time("2026-10-29T22:00:00Z"))
        _, custom, _ = time_window({"from": ["2026-10-30T12:00"], "timezone": ["Europe/Bucharest"]}, [], now)
        self.assertEqual(custom, parse_time("2026-10-30T10:00:00Z"))
        self.write([event("watcher_started", 0), event("click_sent", 2), event("claim_confirmed_ui", 4),
                    event("watcher_started", 10), event("click_sent", 12, "new"),
                    event("claim_confirmed_ui", 14, "new")])
        self.assertEqual(self.result({"range": ["run"]})["confirmedClaims"], 1)
        with self.assertRaises(ValueError):
            time_window({"range": ["nonsense"]}, [], now)

    def test_exact_fractional_totals(self):
        self.write([event("click_sent", 1, "a", "0.1", "regeneration"),
                    event("claim_confirmed_ui", 2, "a"),
                    event("click_sent", 3, "b", "0.2", "regeneration"),
                    event("claim_confirmed_ui", 4, "b")])
        result = self.result()
        self.assertEqual(next(row["total"] for row in result["kinds"] if row["kind"] == "regeneration"), "0.3")

    def test_browser_zone_controls_midnight_and_custom_inputs_not_utc_journal(self):
        now=parse_time("2026-10-31T12:00:00Z")
        for zone, midnight, custom in (
            ("Europe/Budapest", "2026-10-30T23:00:00Z", "2026-10-31T08:15:00Z"),
            ("Europe/Bucharest", "2026-10-30T22:00:00Z", "2026-10-31T07:15:00Z"),
            ("America/New_York", "2026-10-31T04:00:00Z", "2026-10-31T13:15:00Z"),
        ):
            self.assertEqual(time_window({"range":["today"],"timezone":[zone]},[],now)[1],parse_time(midnight))
            self.assertEqual(time_window({"from":["2026-10-31T09:15"],"to":["2026-10-31T15:00"],"timezone":[zone]},[],now)[1],parse_time(custom))
            result=self.result({"range":["all"],"timezone":[zone]})
            self.assertEqual(result["timezone"],zone)
            self.assertEqual(time_window({"from":["2026-10-31T09:15Z"],"timezone":[zone]},[],now)[1],parse_time("2026-10-31T09:15Z"))
        self.assertEqual(parse_time("2026-10-31T09:15"),parse_time("2026-10-31T09:15Z"))
        self.assertEqual(self.result()["timezone"],"UTC","API requests without a browser zone have a neutral default")

    def test_budapest_dst_days_and_nonexistent_local_custom_time(self):
        for now, midnight in (("2026-03-29T12:00Z","2026-03-28T23:00Z"),("2026-10-25T12:00Z","2026-10-24T22:00Z")):
            self.assertEqual(time_window({"range":["today"],"timezone":["Europe/Budapest"]},[],parse_time(now))[1],parse_time(midnight))
        with self.assertRaises(ValueError):
            time_window({"from":["2026-03-29T02:30"],"timezone":["Europe/Budapest"]},[],parse_time("2026-03-29T12:00Z"))

    def test_invalid_or_duplicate_timezone_is_rejected(self):
        for values in (["Not/A_Zone"],["../../etc/passwd"],["Europe/Budapest","UTC"],[""]):
            with self.assertRaises(ValueError):
                self.result({"range":["all"],"timezone":values})

    def test_new_fixed_run_does_not_mix_legacy_data(self):
        run = event("watcher_started", 10)
        run["message"] = "left event Free only; vision3"
        self.write([event("click_sent", 0, "old", "8.3", "hp"),
                    event("claim_confirmed_ui", 2, "old"),run,
                    event("click_sent", 12, "new", "18300", "hp"),
                    event("claim_confirmed_ui", 14, "new")])
        current = self.result({"range": ["run"]})
        self.assertEqual(current["confirmedClaims"], 1)
        self.assertEqual(current["kinds"][0]["total"], "18300")
        self.assertFalse(current["historicalDataWarning"])
        self.assertTrue(self.result({"range": ["all"]})["historicalDataWarning"])

    def test_collection_chart_counts_claims_not_amounts(self):
        self.write([event("click_sent", 0, "big", "18300", "hp"),
                    event("claim_confirmed_ui", 1, "big"),
                    event("click_sent", 2, "small", "0.5", "regeneration"),
                    event("claim_confirmed_ui", 3, "small"),
                    event("click_sent", 4, "missing", None, "cutting_damage"),
                    event("claim_confirmed_ui", 5, "missing"),
                    event("click_sent", 6, "unknown", "999999", "unknown"),
                    event("claim_confirmed_ui", 7, "unknown"),
                    event("click_sent", 8, "pending", "18300", "hp")])
        result = self.result()
        self.assertEqual(result["collectionCounts"]["hp"], 1)
        self.assertEqual(result["collectionCounts"]["regeneration"], 1)
        self.assertEqual(result["collectionCounts"]["cutting_damage"], 1, "Known type still counts when amount is missing")
        self.assertEqual(result["collectionSeries"]["hp"][-1]["count"], 1)
        self.assertEqual(result["collectionSeries"]["regeneration"][-1]["count"], 1)
        self.assertEqual(result["unclassifiedClaims"], 1)
        self.assertEqual(sum(result["collectionCounts"].values()), result["confirmedClaims"]-result["unclassifiedClaims"])
        self.assertEqual(len(result["collectionSeries"]), 8)

    def test_collection_chart_retry_time_window_and_corrected_kind(self):
        self.write([event("click_sent", 0, reward_kind="unknown"),
                    event("click_sent", 2, reward_kind="unknown"),
                    event("claim_confirmed_ui", 4),
                    event("reward_corrected", 6, reward_kind="hp", value="18300")])
        early = self.result({"from": ["2026-10-30T10:00:00Z"], "to": ["2026-10-30T10:00:01Z"]})
        self.assertEqual(sum(early["collectionCounts"].values()), 0)
        final = self.result({"from": ["2026-10-30T10:00:02Z"], "to": ["2026-10-30T10:00:03Z"]})
        self.assertEqual(final["collectionCounts"]["hp"], 1)
        self.assertEqual(final["collectionSeries"]["hp"][-1]["count"], 1)
        self.assertEqual(final["unclassifiedClaims"], 0)

    def test_empty_collection_chart_has_zero_integer_series(self):
        result = self.result()
        self.assertEqual(result["unclassifiedClaims"], 0)
        self.assertTrue(all(count == 0 for count in result["collectionCounts"].values()))
        for series in result["collectionSeries"].values():
            self.assertTrue(all(point["count"] == 0 and isinstance(point["count"], int) for point in series))

    def test_technical_resume_clears_stale_capture_error_not_collection_range(self):
        start = event("watcher_started", 0)
        start["message"] = "left event Free only; vision3"
        old_error = event("observation_error", 5)
        old_error["message"] = "old process error"
        resume = event("watcher_resumed", 10)
        rows = [start,event("click_sent", 2),event("claim_confirmed_ui", 4),old_error,resume]
        self.write(rows)
        result = self.result({"range": ["run"]})
        self.assertIsNone(result["observationError"])
        self.assertEqual(result["confirmedClaims"], 1)
        self.assertEqual(result["range"]["from"], "2026-10-30T10:00:00.000Z")
        new_error = event("observation_error", 12)
        new_error["message"] = "new process error"
        self.write(rows + [new_error])
        self.assertEqual(self.result()["observationError"], "new process error")

    def test_current_run_survives_stop_resume_game_event_and_midnight(self):
        rows = [event("watcher_started", 0), event("click_sent", 2),
                event("claim_confirmed_ui", 4), event("watcher_stopped", 10)]
        for kind in ("watcher_resumed", "event_dismissed_ui", "crystal_completed_ui"):
            row = event(kind, 0)
            row["timestamp"] = "2026-10-31T02:00:00Z"
            row["runID"] = "new-physical-process"
            rows.append(row)
        self.write(rows)
        events, bad, exists = Journal(self.path).snapshot()
        now = parse_time("2026-10-31T03:00:00Z")
        result = aggregate(events, bad, exists, {"range": ["run"]}, now)
        self.assertEqual(result["range"]["from"], "2026-10-30T10:00:00.000Z")
        self.assertEqual(result["confirmedClaims"], 1)
        self.assertEqual(aggregate(events, bad, exists, {"range": ["today"]}, now)["confirmedClaims"], 0)

    def test_new_session_resets_run_view_but_preserves_all_time_history(self):
        self.write([event("watcher_started", 0), event("click_sent", 2),
                    event("claim_confirmed_ui", 4), event("watcher_started", 20)])
        self.assertEqual(self.result({"range": ["run"]})["confirmedClaims"], 0)
        self.assertEqual(self.result({"range": ["run"]})["range"]["from"], "2026-10-30T10:00:20.000Z")
        self.assertEqual(self.result({"range": ["all"]})["confirmedClaims"], 1)

    def test_run_without_start_marker_falls_back_to_retained_log_beginning(self):
        self.write([event("click_sent", 2), event("claim_confirmed_ui", 4), event("watcher_resumed", 10)])
        result = self.result({"range": ["run"]})
        self.assertEqual(result["range"]["from"], "2026-10-30T10:00:02.000Z")
        self.assertEqual(result["confirmedClaims"], 1)

    def test_watcher_status_checks_worker_liveness_and_preserves_frame_age(self):
        path=self.path.with_name("state.json")
        path.write_text(json.dumps({"pid":123,"running":True,"lastCheckedAt":"2026-10-30T10:00:00Z","waitingForMouseRelease":True}))
        now=parse_time("2026-10-30T10:00:12Z")
        with patch("dashboard.server.os.kill"):
            state=watcher_state(path,now)
        self.assertTrue(state["stateKnown"])
        self.assertTrue(state["running"])
        self.assertEqual(state["frameAgeSeconds"],12)
        self.assertTrue(state["waitingForMouseRelease"])
        with patch("dashboard.server.os.kill",side_effect=ProcessLookupError):
            self.assertFalse(watcher_state(path,now)["running"])
        with patch("dashboard.server.os.kill",side_effect=PermissionError):
            self.assertFalse(watcher_state(path,now)["stateKnown"])

    def test_watcher_missing_invalid_starting_and_stopped_states(self):
        path=self.path.with_name("state.json")
        now=parse_time("2026-10-30T10:00:12Z")
        self.assertFalse(watcher_state(path,now)["stateKnown"])
        for content in ["not json", "[]", '{}', '{"pid":true,"running":true}', '{"pid":99999999999999999,"running":true}']:
            path.write_text(content)
            self.assertFalse(watcher_state(path,now)["stateKnown"],content)
        path.write_text(json.dumps({"pid":123,"running":True}))
        with patch("dashboard.server.os.kill"):
            state=watcher_state(path,now)
        self.assertTrue(state["running"])
        self.assertIsNone(state["lastCheckedAt"])
        path.write_text(json.dumps({"pid":123,"running":False}))
        with patch("dashboard.server.os.kill"):
            self.assertFalse(watcher_state(path,now)["running"])

    def test_http_read_only_restricted_paths_host_and_live_append(self):
        self.write([event("click_sent", 0)])
        static=self.root / "dashboard"
        static.mkdir()
        (static / "status.js").write_text("/* collector status fixture */")
        (static / "animation.js").write_text("/* animation fixture */")
        (static / "i18n.js").write_text("/* i18n fixture */")
        (static / "locales").mkdir()
        for language in ("hu", "en"):
            (static / "locales" / (language + ".js")).write_text("/* locale fixture */")
        (static / "vendor").mkdir()
        (static / "vendor/countUp.umd.js").write_text("/* countup fixture */")
        server = make_server(self.root, 0)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        base = f"http://127.0.0.1:{server.server_port}"
        try:
            with urlopen(base + "/status.js") as response:
                self.assertTrue(response.headers["Content-Type"].startswith("text/javascript"))
                self.assertEqual(response.read(),b"/* collector status fixture */")
            for name in ("animation.js", "i18n.js", "locales/hu.js", "locales/en.js", "vendor/countUp.umd.js"):
                with urlopen(base + "/" + name) as response:
                    self.assertTrue(response.headers["Content-Type"].startswith("text/javascript"))
                    self.assertIn(b"fixture", response.read())
            with urlopen(base + "/api/rewards?range=all") as response:
                self.assertEqual(json.load(response)["confirmedClaims"], 0)
            with self.path.open("a") as output:
                output.write(json.dumps(event("claim_confirmed_ui", 2)) + "\n")
            with urlopen(base + "/api/rewards?range=all") as response:
                self.assertEqual(json.load(response)["confirmedClaims"], 1)
            with urlopen(base + "/api/rewards?range=all&timezone=Europe%2FBudapest") as response:
                self.assertEqual(json.load(response)["timezone"],"Europe/Budapest")
            with self.assertRaises(HTTPError) as error:
                urlopen(base + "/api/rewards?timezone=Not%2FA_Zone")
            self.assertEqual(error.exception.code,400)
            error.exception.close()
            with self.assertRaises(HTTPError) as error:
                urlopen(base + "/api/rewards?timezone=")
            self.assertEqual(error.exception.code,400)
            error.exception.close()
            for path in ("/../AGENTS.md", "/data/free-rewards/events.jsonl", "/locales/../../AGENTS.md", "/locales/en.js/..", "/locales/README.md", "/locales/zz.js"):
                with self.assertRaises(HTTPError) as error:
                    urlopen(base + path)
                self.assertEqual(error.exception.code, 404)
                error.exception.close()
            with self.assertRaises(HTTPError) as error:
                urlopen(Request(base + "/health", headers={"Host": "evil.example"}))
            self.assertEqual(error.exception.code, 403)
            error.exception.close()
            with self.assertRaises(HTTPError) as error:
                urlopen(Request(base + "/health", headers={"Origin": "https://evil.example"}))
            self.assertEqual(error.exception.code, 403)
            error.exception.close()
            with self.assertRaises(HTTPError) as error:
                urlopen(Request(base + "/api/rewards", data=b"{}", method="POST"))
            self.assertEqual(error.exception.code, 405)
            error.exception.close()
        finally:
            server.shutdown()
            server.server_close()
            thread.join()


if __name__ == "__main__":
    unittest.main()
