"""Exercise real hooks against a disposable Git repository, never the project index."""
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

PROJECT = Path(__file__).resolve().parents[1]


class GitTestGateTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="butcher-gate-test-")
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.git("init", "-b", "main")
        self.git("config", "user.name", "Fixture Author")
        self.git("config", "user.email", "fixture@example.invalid")
        self.git("config", "core.hooksPath", ".githooks")
        for relative in ["scripts/git-test-gate.py", ".githooks/pre-commit", ".githooks/pre-push"]:
            target = self.root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(PROJECT / relative, target)
        # A deterministic fast stand-in tests snapshot/exit handling; real package
        # tests are executed by the project's own commit and push hooks separately.
        (self.root / "scripts/check-rewards.sh").write_text(
            '#!/bin/sh\nset -eu\ntest "$(cat fixture.txt)" = valid\n', encoding="utf-8")
        (self.root / "fixture.txt").write_text("valid\n", encoding="utf-8")
        self.git("add", ".")

    def git(self, *args, check=True):
        return subprocess.run(["git", *args], cwd=self.root, text=True,
                              capture_output=True, check=check)

    def hook(self, name, data=""):
        return subprocess.run([str(self.root / ".githooks" / name)], cwd=self.root,
                              input=data, text=True, capture_output=True)

    def test_commit_checks_index_not_unstaged_work_and_blocks_bad_readings(self):
        (self.root / "fixture.txt").write_text("invalid\n", encoding="utf-8")
        good = self.git("commit", "-m", "valid staged snapshot", check=False)
        self.assertEqual(good.returncode, 0, good.stdout + good.stderr)
        self.git("add", "fixture.txt")
        head = self.git("rev-parse", "HEAD").stdout
        bad = self.git("commit", "-m", "must be blocked", check=False)
        self.assertNotEqual(bad.returncode, 0)
        self.assertIn("BLOCKED", bad.stderr)
        self.assertEqual(self.git("rev-parse", "HEAD").stdout, head)

    def test_push_checks_pushed_commit_not_worktree_and_propagates_failure(self):
        self.git("commit", "-m", "valid initial fixture")
        good_oid = self.git("rev-parse", "HEAD").stdout.strip()
        (self.root / "fixture.txt").write_text("invalid\n", encoding="utf-8")
        zeros = "0" * len(good_oid)
        good = self.hook("pre-push", f"refs/heads/main {good_oid} refs/heads/main {zeros}\n")
        self.assertEqual(good.returncode, 0, good.stdout + good.stderr)
        # Plumbing builds a bad fixture commit without changing the real project
        # or bypassing its hooks. The push hook must reject this object's tree.
        self.git("add", "fixture.txt")
        tree = self.git("write-tree").stdout.strip()
        bad_oid = self.git("commit-tree", tree, "-p", good_oid, "-m", "bad fixture").stdout.strip()
        bad = self.hook("pre-push", f"refs/heads/main {bad_oid} refs/heads/main {good_oid}\n")
        self.assertNotEqual(bad.returncode, 0)
        self.assertIn("BLOCKED", bad.stderr)
        deletion = self.hook("pre-push", f"(delete) {zeros} refs/heads/old {good_oid}\n")
        self.assertEqual(deletion.returncode, 0)

    def test_missing_runner_and_malformed_push_input_fail_closed(self):
        self.git("rm", "--cached", "scripts/check-rewards.sh")
        missing = self.hook("pre-commit")
        self.assertNotEqual(missing.returncode, 0)
        self.assertIn("BLOCKED", missing.stderr)
        malformed = self.hook("pre-push", "invalid input\n")
        self.assertNotEqual(malformed.returncode, 0)


if __name__ == "__main__":
    unittest.main()
