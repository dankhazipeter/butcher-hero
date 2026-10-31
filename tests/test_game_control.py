"""Offline native-probe and HTTP launch contract; never opens the real game."""
import json
from pathlib import Path
import subprocess
import tempfile
import threading
import unittest
from types import SimpleNamespace
from unittest.mock import Mock, patch
from urllib.request import urlopen
from http_test_support import post_once

from dashboard.game_control import BUNDLE_ID, GameControl, GameControlError
from dashboard.server import make_server


class GameControlTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="butcher-game-test-")
        self.root = Path(self.temp.name)
        self.control = GameControl(self.root)
        self.control.binary.parent.mkdir(parents=True)
        self.control.binary.touch()
        self.stopped = dict(known=True, installed=True, running=False, hidden=False, windowVisible=False)

    def tearDown(self):
        self.temp.cleanup()

    def test_probe_is_fixed_metadata_command_cached_and_returns_copies(self):
        with patch("dashboard.game_control.subprocess.run", return_value=SimpleNamespace(stdout=json.dumps(self.stopped))) as run:
            with patch("dashboard.game_control.time.monotonic", return_value=100):
                state = self.control.snapshot()
                state["running"] = True
                self.assertFalse(self.control.snapshot()["running"])
                self.assertEqual(run.call_count, 1)
                run.assert_called_with([str(self.control.binary), "game-status"], capture_output=True, text=True, timeout=3, check=True)
            with patch("dashboard.game_control.time.monotonic", return_value=106):
                self.control.snapshot()
                self.assertEqual(run.call_count, 2)
                self.control.snapshot(force=True)
                self.assertEqual(run.call_count, 3)

    def test_probe_failures_and_malformed_data_are_unknown_not_stopped(self):
        for value in ("no json", "[]", '{"known":false}', json.dumps(dict(self.stopped, running=0)), json.dumps(dict(self.stopped, windowVisible="yes"))):
            with self.subTest(value=value), patch("dashboard.game_control.subprocess.run", return_value=SimpleNamespace(stdout=value)):
                result = self.control.snapshot(force=True)
                self.assertFalse(result["known"])
                self.assertIsNone(result["running"])
        for error in (OSError(), subprocess.TimeoutExpired("probe", 3), subprocess.CalledProcessError(1, "probe")):
            with patch("dashboard.game_control.subprocess.run", side_effect=error):
                self.assertFalse(self.control.snapshot(force=True)["known"])
        self.control.binary.unlink()
        with patch("dashboard.game_control.subprocess.run") as run:
            self.assertFalse(self.control.snapshot(force=True)["known"])
            run.assert_not_called()

    def test_launch_is_fixed_target_and_requested_not_observed_running(self):
        with patch.object(self.control, "snapshot", return_value=self.stopped) as snapshot, patch("dashboard.game_control.subprocess.run") as run:
            self.control._cache = dict(self.stopped)
            self.assertEqual(self.control.launch(), "requested")
            snapshot.assert_called_once_with(force=True)
            run.assert_called_once_with(["/usr/bin/open", "-b", BUNDLE_ID], capture_output=True, timeout=3, check=True)
            self.assertIsNone(self.control._cache)
            with self.assertRaises(GameControlError) as error:
                self.control.launch()
            self.assertEqual((error.exception.code, error.exception.status), ("launch_cooldown", 429))
            self.assertEqual(run.call_count, 1)

    def test_running_missing_unknown_and_failed_launch_never_claim_success(self):
        with patch("dashboard.game_control.subprocess.run") as run:
            for state, code in ((dict(self.stopped, known=False), "probe_unavailable"), (dict(self.stopped, installed=False), "not_installed")):
                with patch.object(self.control, "snapshot", return_value=state), self.assertRaises(GameControlError) as error:
                    self.control.launch()
                self.assertEqual(error.exception.code, code)
            with patch.object(self.control, "snapshot", return_value=dict(self.stopped, running=True)):
                self.assertEqual(self.control.launch(), "already_running")
            run.assert_not_called()
        with patch.object(self.control, "snapshot", return_value=self.stopped), patch("dashboard.game_control.subprocess.run", side_effect=OSError()), self.assertRaises(GameControlError) as error:
            self.control.launch()
        self.assertEqual(error.exception.code, "launch_failed")


class GameLaunchHTTPTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="butcher-launch-http-test-")
        self.game = Mock()
        self.game.snapshot.return_value = dict(known=True, installed=True, running=False, hidden=False, windowVisible=False)
        self.game.launch.return_value = "requested"
        self.server = make_server(Path(self.temp.name), 0, game_control=self.game)
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.base = f"http://127.0.0.1:{self.server.server_port}"
        with urlopen(self.base + "/api/rewards") as response:
            self.token = json.load(response)["gameLaunchToken"]
            self.assertEqual(response.headers["X-Frame-Options"], "DENY")
            self.assertIn("frame-ancestors 'none'", response.headers["Content-Security-Policy"])

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()
        self.temp.cleanup()

    def request(self, body=b"{}", headers=None, path="/api/game/launch"):
        values = {"Origin": self.base, "Content-Type": "application/json", "X-Game-Launch-Token": self.token, "Sec-Fetch-Site": "same-origin"}
        for key, value in (headers or {}).items():
            if value is None:
                values.pop(key, None)
            else:
                values[key] = value
        return post_once(self.base, path, values, body)

    def test_only_explicit_authenticated_post_launches_and_stats_stay_read_only(self):
        self.game.launch.assert_not_called()
        self.assertEqual(self.request(path="/api/rewards")[0], 405)
        self.assertEqual(self.request(), (200, {"status": "requested"}))
        self.game.launch.assert_called_once_with()
        self.game.launch.return_value = "already_running"
        self.assertEqual(self.request(), (200, {"status": "already_running"}))

    def test_origin_host_site_and_token_are_required(self):
        for headers in ({"Origin": None}, {"Origin": "https://evil.example"}, {"Origin": f"http://localhost:{self.server.server_port}"}, {"Host": "evil.example"}, {"Sec-Fetch-Site": "cross-site"}, {"X-Game-Launch-Token": None}, {"X-Game-Launch-Token": "wrong"}, {"X-Game-Launch-Token": "é"}):
            with self.subTest(headers=headers):
                self.assertEqual(self.request(headers=headers)[0], 403)
        self.game.launch.assert_not_called()

    def test_body_accepts_no_arbitrary_arguments_and_errors_are_structured(self):
        for body in (b"", b"[]", b"null", b"invalid", b'{"app":"other"}', b" " * 129):
            with self.subTest(body=body):
                self.assertEqual(self.request(body=body)[0], 400)
        self.assertEqual(self.request(headers={"Content-Type": "text/plain"})[0], 400)
        self.assertEqual(self.request(headers={"Transfer-Encoding": "chunked"})[0], 400)
        self.game.launch.assert_not_called()
        self.game.launch.side_effect = GameControlError("not_installed", 409)
        self.assertEqual(self.request(), (409, {"error": "not_installed"}))


if __name__ == "__main__":
    unittest.main()
