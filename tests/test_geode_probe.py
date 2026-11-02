"""Offline contract tests. Never run a successful live-input invocation."""
import fcntl
import pathlib
import subprocess
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
SOURCE = ROOT / "scripts/probe-geode-click.swift"


class GeodeProbeTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temporary = tempfile.TemporaryDirectory(prefix="butcher-geode-probe-")
        cls.directory = pathlib.Path(cls.temporary.name)
        cls.binary = cls.directory / "probe-geode-click"
        subprocess.run(["swiftc", str(SOURCE), "-o", str(cls.binary)], check=True,
                       capture_output=True, text=True, timeout=60)

    @classmethod
    def tearDownClass(cls):
        cls.temporary.cleanup()

    def run_probe(self, *args):
        return subprocess.run([str(self.binary), *args], cwd=self.directory,
                              capture_output=True, text=True, timeout=5)

    def test_help_and_missing_arguments_exit_before_application_access(self):
        for args in [(), ("--help",), ("cg",)]:
            result = self.run_probe(*args)
            self.assertEqual(result.returncode, 2)
            self.assertIn("--hud-confirmed", result.stdout)

    def test_invalid_modes_and_extra_arguments_cannot_send_input(self):
        for args in [("invalid", "--hud-confirmed"), ("cg", "--wrong"),
                     ("cg", "--hud-confirmed", "extra")]:
            self.assertEqual(self.run_probe(*args).returncode, 2)

    def test_busy_capture_lock_blocks_every_mode_before_game_lookup(self):
        directory = self.directory / "docs/runs"
        directory.mkdir(parents=True, exist_ok=True)
        with (directory / ".live-capture.lock").open("a") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            for mode in ["cg", "cg-move", "appkit"]:
                result = self.run_probe(mode, "--hud-confirmed")
                self.assertEqual(result.returncode, 1)
                self.assertIn("Collector active/unavailable lock; no input", result.stderr)

    def test_source_has_only_fixed_game_geode_target_and_no_global_fallback(self):
        source = SOURCE.read_text()
        for required in ["com.multicastgames.butcher", "0.945", "0.510", ".privateState",
                         "down.postToPid(pid)", "up.postToPid(pid)",
                         "signal(SIGINT,SIG_IGN)", "signal(SIGTERM,SIG_IGN)"]:
            self.assertIn(required, source)
        for forbidden in [".activate(", "CGWarpMouseCursorPosition(", ".post(tap:",
                          "RewardVision", "watch-free", "Process("]:
            self.assertNotIn(forbidden, source)


if __name__ == "__main__":
    unittest.main()
