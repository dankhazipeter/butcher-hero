"""Offline launcher tests: fake services only, never capture or click the game."""
import importlib.util
import json
import os
from pathlib import Path
import shutil
import signal
import socket
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import Mock, patch

SOURCE = Path(__file__).resolve().parents[1] / "scripts/butcher-hero.py"
SPEC = importlib.util.spec_from_file_location("local_app", SOURCE)
app = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(app)


class LocalAppTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="butcher launcher test ")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        (self.root / "scripts").mkdir()
        shutil.copy2(SOURCE, self.root / "scripts/butcher-hero.py")

    def prepare_requirements(self):
        binary = self.root / ".build/release/ButcherHeroAutomation"
        binary.parent.mkdir(parents=True)
        binary.write_text("#!/bin/sh\nexit 99\n")  # MUST never be invoked by these tests.
        binary.chmod(0o755)
        (binary.parent / "ButcherHeroBot_RewardAutomationCore.bundle").mkdir()

    def test_plain_make_still_only_sets_up_hooks_never_starts_collection(self):
        preview = subprocess.check_output(["make", "-n"], cwd=SOURCE.parent.parent, text=True)
        self.assertIn("install-git-hooks.sh", preview)
        self.assertNotIn("butcher-hero.py start", preview)

    def test_missing_build_refuses_without_spawning(self):
        with patch.object(app.subprocess, "Popen") as spawn:
            with self.assertRaisesRegex(RuntimeError, "release build"):
                app.start(self.root)
            spawn.assert_not_called()

    def test_missing_english_model_refuses_without_starting(self):
        self.prepare_requirements()
        with patch.object(app.shutil, "which", return_value="fixture-tesseract"), \
                patch.object(app.subprocess, "check_output", return_value="deu\n"), \
                self.assertRaisesRegex(RuntimeError, "English"):
            app.preflight(self.root, 8765)

    def test_active_legacy_collector_refuses_without_takeover(self):
        self.prepare_requirements()
        path = self.root / "data/free-rewards/supervisor.lock"
        path.parent.mkdir(parents=True)
        with path.open("a") as owner:
            app.fcntl.flock(owner, app.fcntl.LOCK_EX | app.fcntl.LOCK_NB)
            with patch.object(app.shutil, "which", return_value="fixture"), \
                    patch.object(app.subprocess, "check_output", return_value="eng\n"), \
                    self.assertRaisesRegex(RuntimeError, "already running"):
                app.preflight(self.root, 8765)

    def test_occupied_port_is_not_killed_or_reused(self):
        self.prepare_requirements()
        with socket.socket() as server:
            server.bind(("127.0.0.1", 0))
            server.listen()
            with patch.object(app.shutil, "which", return_value="fixture"), \
                    patch.object(app.subprocess, "check_output", return_value="eng\n"), \
                    self.assertRaisesRegex(RuntimeError, "occupied"):
                app.preflight(self.root, server.getsockname()[1])

    def test_recently_closed_http_port_does_not_block_immediate_restart(self):
        self.prepare_requirements()
        with socket.socket() as server:
            server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            server.bind(("127.0.0.1", 0))
            port = server.getsockname()[1]
            server.listen()
            with socket.create_connection(("127.0.0.1", port)) as client:
                connection, _ = server.accept()
                connection.close()  # Server owns TIME_WAIT, just like the real HTTP server.
                self.assertEqual(client.recv(1), b"")
        with patch.object(app.shutil, "which", return_value="fixture"), \
                patch.object(app.subprocess, "check_output", return_value="eng\n"):
            app.preflight(self.root, port)

    def test_stop_never_signals_stale_unlocked_state(self):
        directory = self.root / "data/local-app"
        directory.mkdir(parents=True)
        app.write_json(directory / "state.json", {"pid": os.getpid(), "running": True})
        with patch.object(app.os, "kill") as kill:
            self.assertEqual(app.stop(self.root), 0)
            kill.assert_not_called()

    def test_stop_refuses_unverifiable_owner(self):
        with patch.object(app, "is_locked", return_value=True), \
                patch.object(app.os, "kill") as kill, \
                self.assertRaisesRegex(RuntimeError, "Cannot verify"):
            app.stop(self.root)
        kill.assert_not_called()

    def test_identity_requires_same_start_time_command_and_checkout(self):
        state = {"pid": 7, "entrypoint": "scripts/butcher-hero.py",
                 "workingDirectory": str(self.root),
                 "identity": "fixture-start python3 scripts/butcher-hero.py start"}
        with patch.object(app, "process_identity", return_value=state["identity"]):
            self.assertTrue(app.is_owned_manager(self.root, state))
            self.assertFalse(app.is_owned_manager(self.root / "other", state))
        with patch.object(app, "process_identity", return_value="new start time same PID"):
            self.assertFalse(app.is_owned_manager(self.root, state))

    def test_installer_is_idempotent_and_preserves_other_commands(self):
        directory = self.root / "bin"
        app.install(self.root, directory)
        app.install(self.root, directory)
        self.assertEqual((directory / "butcher-hero").resolve(), self.root.resolve() / "scripts/butcher-hero.py")
        (directory / "butcher-hero").unlink()
        (directory / "butcher-hero").write_text("user-owned")
        with self.assertRaisesRegex(RuntimeError, "overwrite"):
            app.install(self.root, directory)
        self.assertEqual((directory / "butcher-hero").read_text(), "user-owned")

    def test_closed_output_cannot_break_cleanup_reporting(self):
        with patch("builtins.print", side_effect=BrokenPipeError):
            app.report("stopping")

    def test_no_screen_is_not_reported_as_successful_collection(self):
        with patch.object(app, "read_json", return_value={"pid": 7, "running": True}), \
                patch.object(app, "process_identity", return_value="fixture"):
            self.assertIn("waiting for first", app.collector_progress(self.root))

    def test_recycled_pid_and_invalid_pid_are_not_signalled(self):
        for pid in (True, -7, "123", 0, 2**40):
            self.assertIsNone(app.process_identity(pid))
        state = {"pid": 7, "entrypoint": "scripts/butcher-hero.py",
                 "workingDirectory": str(self.root),
                 "identity": "old python3 scripts/butcher-hero.py start"}
        with patch.object(app, "is_locked", return_value=True), \
                patch.object(app, "read_json", return_value=state), \
                patch.object(app, "process_identity", return_value="new process"), \
                patch.object(app.os, "kill") as kill, \
                self.assertRaisesRegex(RuntimeError, "Cannot verify"):
            app.stop(self.root)
        kill.assert_not_called()

    def test_dashboard_failure_prevents_collector_launch_and_cleans_up(self):
        dashboard = Mock(pid=777)
        with patch.object(app, "preflight"), \
                patch.object(app, "process_identity", return_value="fixture"), \
                patch.object(app.subprocess, "Popen", return_value=dashboard) as spawn, \
                patch.object(app, "wait_dashboard", side_effect=RuntimeError("fixture failure")), \
                patch.object(app, "stop_children") as cleanup:
            with self.assertRaisesRegex(RuntimeError, "fixture failure"):
                app.start(self.root)
        self.assertEqual(spawn.call_count, 1)
        cleanup.assert_called_once_with([dashboard])
        self.assertFalse(app.read_json(self.root / "data/local-app/state.json")["running"])

    def test_default_resumes_and_explicit_new_run_does_not(self):
        for new_run in (False, True):
            dash, worker = Mock(pid=777), Mock(pid=778, returncode=1)
            dash.poll.return_value = None
            worker.poll.return_value = 1
            with patch.object(app, "preflight"), patch.object(app, "wait_dashboard"), \
                    patch.object(app, "process_identity", return_value="fixture"), \
                    patch.object(app.subprocess, "Popen", side_effect=[dash, worker]) as spawn, \
                    patch.object(app, "stop_children") as cleanup:
                with self.assertRaisesRegex(RuntimeError, "supervisor exited"):
                    app.start(self.root, new_run=new_run)
            self.assertEqual("--resume-run" in spawn.call_args_list[1].args[0], not new_run)
            self.assertTrue(all(call.kwargs["start_new_session"] for call in spawn.call_args_list))
            cleanup.assert_called_once_with([dash, worker])


class LocalAppProcessTests(unittest.TestCase):
    """Real processes, but an isolated fake project, HTTP server and worker."""
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="butcher process test ")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        for directory in ("scripts", "dashboard", "bin", ".build/release/ButcherHeroBot_RewardAutomationCore.bundle"):
            (self.root / directory).mkdir(parents=True)
        shutil.copy2(SOURCE, self.root / "scripts/butcher-hero.py")
        executable = self.root / ".build/release/ButcherHeroAutomation"
        executable.write_text("#!/bin/sh\nexit 99\n")
        executable.chmod(0o755)
        ocr = self.root / "bin/tesseract"
        ocr.write_text("#!/bin/sh\nprintf 'eng\\n'\n")
        ocr.chmod(0o755)
        (self.root / "dashboard/server.py").write_text('''
from http.server import BaseHTTPRequestHandler, HTTPServer
import sys
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200); self.end_headers()
        self.wfile.write(b'{"app":"butcher-reward-dashboard"}')
    def log_message(self, *args): pass
HTTPServer(("127.0.0.1", int(sys.argv[2])), Handler).serve_forever()
''')
        (self.root / "scripts/supervise-free-rewards.py").write_text('''
import subprocess, sys, time
child = subprocess.Popen([sys.executable, "-c", "import time; time.sleep(60)"])
print("fixture worker", child.pid, flush=True)
time.sleep(60)
''')
        with socket.socket() as probe:
            probe.bind(("127.0.0.1", 0))
            self.port = probe.getsockname()[1]
        self.environment = {**os.environ, "PATH": str(self.root / "bin") + os.pathsep + os.environ["PATH"]}
        self.output = tempfile.TemporaryFile(mode="w+")
        self.addCleanup(self.output.close)
        self.process = subprocess.Popen(
            [sys.executable, str(self.root / "scripts/butcher-hero.py"), "start", "--port", str(self.port)],
            cwd="/", env=self.environment, stdout=self.output, stderr=self.output)
        self.addCleanup(self.cleanup_process)
        deadline = time.monotonic() + 6
        while time.monotonic() < deadline:
            self.state = app.read_json(self.root / "data/local-app/state.json")
            if self.state.get("supervisorPID"):
                break
            if self.process.poll() is not None:
                self.output.seek(0)
                self.fail(self.output.read())
            time.sleep(0.02)
        else:
            self.fail("fixture launcher did not become ready")

    def cleanup_process(self):
        if self.process.poll() is None:
            self.process.terminate()
            try:
                self.process.wait(timeout=15)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.process.wait(timeout=2)

    def assert_services_gone(self):
        self.assertFalse(app.read_json(self.root / "data/local-app/state.json")["running"])
        for key in ("dashboardPID", "supervisorPID"):
            with self.assertRaises(ProcessLookupError):
                os.kill(self.state[key], 0)
            with self.assertRaises(ProcessLookupError):
                os.killpg(self.state[key], 0)

    def test_ctrl_c_stops_both_services_and_descendants(self):
        self.process.send_signal(signal.SIGINT)
        self.assertEqual(self.process.wait(timeout=15), 0)
        self.assert_services_gone()

    def test_external_stop_from_another_directory_and_duplicate_rejection(self):
        command = [sys.executable, str(self.root / "scripts/butcher-hero.py")]
        duplicate = subprocess.run(command + ["start", "--port", str(self.port)],
                                   cwd="/", env=self.environment, capture_output=True, text=True, timeout=5)
        self.assertEqual(duplicate.returncode, 1)
        self.assertIn("already running", duplicate.stderr)
        stopped = subprocess.run(command + ["stop"], cwd="/", env=self.environment,
                                 capture_output=True, text=True, timeout=18)
        self.assertEqual(stopped.returncode, 0, stopped.stderr)
        self.assertEqual(self.process.wait(timeout=3), 0)
        self.assert_services_gone()

    def test_dashboard_exit_cannot_leave_collector_orphaned(self):
        os.kill(self.state["dashboardPID"], signal.SIGTERM)
        self.assertEqual(self.process.wait(timeout=15), 1)
        self.assert_services_gone()

    def test_user_local_symlink_works_from_another_directory(self):
        installed = self.root / "bin/butcher-hero"
        installed.symlink_to(self.root / "scripts/butcher-hero.py")
        checked = subprocess.run([str(installed), "status"], cwd="/", env=self.environment,
                                 capture_output=True, text=True, timeout=5)
        self.assertEqual(checked.returncode, 0, checked.stderr)
        self.assertIn("launcher RUNNING", checked.stdout)
        stopped = subprocess.run([str(installed), "stop"], cwd="/", env=self.environment,
                                 capture_output=True, text=True, timeout=18)
        self.assertEqual(stopped.returncode, 0, stopped.stderr)
        self.assertEqual(self.process.wait(timeout=3), 0)
        self.assert_services_gone()


if __name__ == "__main__":
    unittest.main()
