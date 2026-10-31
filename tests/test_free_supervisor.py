import importlib.util
from pathlib import Path
import signal
import subprocess
import tempfile
import unittest
from unittest.mock import Mock, patch

SPEC = importlib.util.spec_from_file_location("free_supervisor",
    Path(__file__).resolve().parents[1] / "scripts/supervise-free-rewards.py")
supervisor = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(supervisor)


class FreeSupervisorTests(unittest.TestCase):
    def test_startup_grace_then_missing_frames_restarts(self):
        monitor = supervisor.ProgressMonitor(100)
        self.assertFalse(monitor.stalled({}, 7, 144))
        self.assertTrue(monitor.stalled({}, 7, 145))

    def test_fresh_frames_keep_worker_healthy(self):
        monitor = supervisor.ProgressMonitor(100)
        for now in range(101, 300):
            self.assertFalse(monitor.stalled({"pid": 7, "lastCheckedAt": str(now)}, 7, now))

    def test_alive_process_with_frozen_success_time_is_not_healthy(self):
        monitor = supervisor.ProgressMonitor(100)
        state = {"pid": 7, "lastCheckedAt": "fixed", "running": True}
        self.assertFalse(monitor.stalled(state, 7, 101))
        self.assertFalse(monitor.stalled(state, 7, 130))
        self.assertTrue(monitor.stalled(state, 7, 131))

    def test_other_process_or_error_activity_does_not_count_as_progress(self):
        monitor = supervisor.ProgressMonitor(100)
        self.assertTrue(monitor.stalled({"pid": 8, "lastCheckedAt": "fresh"}, 7, 145))
        monitor = supervisor.ProgressMonitor(100)
        self.assertTrue(monitor.stalled({"pid": 7, "event": "observation_error"}, 7, 145))

    def test_graceful_stop_does_not_force_kill(self):
        child = Mock()
        child.poll.return_value = None
        supervisor.terminate_child(child)
        child.send_signal.assert_called_once_with(signal.SIGINT)
        child.kill.assert_not_called()

    def test_hung_child_is_killed_after_bounded_grace(self):
        child = Mock()
        child.poll.return_value = None
        child.wait.side_effect = [subprocess.TimeoutExpired("fixture", 5), 0]
        supervisor.terminate_child(child)
        child.kill.assert_called_once()

    def test_exited_child_is_not_signalled(self):
        child = Mock()
        child.poll.return_value = 0
        supervisor.terminate_child(child)
        child.send_signal.assert_not_called()

    def test_user_stop_never_restarts_even_after_stall(self):
        for code in (0, 1, -9, None):
            self.assertFalse(supervisor.should_restart(code, True, True))
        self.assertFalse(supervisor.should_restart(0, False, False))

    def test_own_stall_recovery_and_unexpected_crash_restart(self):
        self.assertTrue(supervisor.should_restart(0, True, False))
        self.assertTrue(supervisor.should_restart(1, False, False))

    def test_crystal_operator_recovery_is_only_passed_to_first_worker(self):
        failed, stopped = Mock(pid=123), Mock(pid=124)
        failed.poll.return_value = 1
        stopped.poll.return_value = 0
        with tempfile.TemporaryDirectory(prefix="crystal-supervisor-test-") as directory, \
                patch.object(supervisor.subprocess, "Popen", side_effect=[failed, stopped]) as start, \
                patch.object(supervisor.signal, "signal"), patch.object(supervisor.time, "sleep"):
            supervisor.supervise(Path(directory), resume=True, recover_crystal=True)
        commands = [call.args[0] for call in start.call_args_list]
        self.assertEqual(len(commands), 2)
        self.assertIn("--recover-crystal", commands[0])
        self.assertNotIn("--recover-crystal", commands[1])
        self.assertTrue(all("--resume-run" in command for command in commands))


if __name__ == "__main__":
    unittest.main()
