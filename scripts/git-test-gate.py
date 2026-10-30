#!/usr/bin/env python3
"""Test the exact staged/pushed tree, never an unrelated working directory."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile


def git(*args):
    return subprocess.check_output(["git", *args], text=True).strip()


def check_tree(revision):
    tree = git("rev-parse", "--verify", f"{revision}^{{tree}}")
    print(f"Reward test gate: exact Git tree {tree[:12]}", flush=True)
    with tempfile.TemporaryDirectory(prefix="butcher-reward-gate-") as directory:
        root = Path(directory)
        archive = root / "snapshot.tar"
        with archive.open("wb") as output:
            subprocess.run(["git", "archive", "--format=tar", tree], stdout=output, check=True)
        snapshot = root / "snapshot"
        snapshot.mkdir()
        subprocess.run(["tar", "-xf", str(archive), "-C", str(snapshot)], check=True)
        # Hooks export repository/index variables; do not leak them into the snapshot.
        env = {key: value for key, value in os.environ.items() if not key.startswith("GIT_")}
        env["PYTHONDONTWRITEBYTECODE"] = "1"
        subprocess.run(["/bin/sh", "scripts/check-rewards.sh"], cwd=snapshot, env=env, check=True)


def main():
    if sys.argv[1:] == ["--index"]:
        tree = git("write-tree")
        check_tree(tree)
        if git("write-tree") != tree:
            raise RuntimeError("The staged snapshot changed during testing. Retry the commit.")
    elif sys.argv[1:] == ["--push"]:
        revisions = set()
        for line in sys.stdin:
            local_ref, local_oid, remote_ref, remote_oid = line.split()
            if set(local_oid) == {"0"}:  # Deleting a remote ref has no new code to test.
                continue
            revision = git("rev-parse", "--verify", f"{local_oid}^{{commit}}")
            if revision not in revisions:
                check_tree(revision)
                revisions.add(revision)
    else:
        raise RuntimeError("Use --index or --push (Git pre-push input on stdin).")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, RuntimeError, subprocess.CalledProcessError) as error:
        print(f"Reward test gate BLOCKED commit/push: {error}", file=sys.stderr)
        sys.exit(1)
