#!/usr/bin/env python3
"""Supervise only our Free collector; never launch/close/control the game itself."""
import argparse
from datetime import datetime, timezone
import fcntl
import json
import os
from pathlib import Path
import signal
import subprocess
import time


class ProgressMonitor:
    def __init__(self, started, timeout=30, startup_grace=45):
        self.started = started
        self.last_progress = started
        self.last_stamp = None
        self.timeout = timeout
        self.startup_grace = startup_grace

    def stalled(self, state, child_pid, now):
        stamp = state.get("lastCheckedAt") if state.get("pid") == child_pid else None
        if stamp and stamp != self.last_stamp:
            self.last_stamp = stamp
            self.last_progress = now
        grace = self.startup_grace if self.last_stamp is None else self.timeout
        return now - self.last_progress >= grace


def read_state(path):
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
        return value if isinstance(value, dict) else {}
    except (OSError, ValueError):
        return {}


def terminate_child(child, grace=5):
    if child is None or child.poll() is not None:
        return
    child.send_signal(signal.SIGINT)
    try:
        child.wait(timeout=grace)
    except subprocess.TimeoutExpired:
        # Signals are cooperative in Swift; a stuck Vision/XPC call may not return.
        child.kill()
        child.wait(timeout=grace)


def should_restart(exit_code, stalled, stop_requested):
    return not stop_requested and (stalled or exit_code != 0)


def supervise(root, resume=False):
    directory = root / "data/free-rewards"
    directory.mkdir(parents=True, exist_ok=True)
    stopping = False
    child = None

    def stop(signum, frame):
        nonlocal stopping
        stopping = True

    for sig in (signal.SIGINT, signal.SIGTERM):
        signal.signal(sig, stop)

    with (directory / "supervisor.lock").open("a") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise SystemExit("A Free collector supervisor is already running.")

        def status(event, message=""):
            record = {"pid": os.getpid(), "childPID": child.pid if child else None,
                      "running": not stopping, "event": event, "message": message,
                      "timestamp": datetime.now(timezone.utc).isoformat()}
            temporary = directory / "supervisor.tmp"
            temporary.write_text(json.dumps(record), encoding="utf-8")
            temporary.replace(directory / "supervisor.json")
            with (directory / "supervisor-events.jsonl").open("a", encoding="utf-8") as events:
                events.write(json.dumps(record) + "\n")
            print(f"Free supervisor: {event} {message}", flush=True)

        try:
            while not stopping:
                command = [str(root / ".build/release/ButcherHeroAutomation"),
                           "watch-free", "--interval", "1"]
                if resume:
                    command.append("--resume-run")
                child = subprocess.Popen(command, cwd=root)
                monitor = ProgressMonitor(time.monotonic())
                stalled = False
                status("worker_started")
                while not stopping and child.poll() is None:
                    state = read_state(directory / "state.json")
                    if monitor.stalled(state, child.pid, time.monotonic()):
                        stalled = True
                        status("worker_stalled", "No fresh successful observation; restarting our worker only.")
                        terminate_child(child)
                        break
                    time.sleep(1)
                if stopping:
                    break
                code = child.poll()
                # An explicitly signalled collector exits cleanly: respect STOP.
                if not should_restart(code, stalled, stopping):
                    stopping = True
                    status("worker_stopped", "Clean worker STOP; no automatic restart.")
                    break
                status("worker_restart", f"Previous exit status: {code}; collection period preserved.")
                resume = True
                for _ in range(5):
                    if stopping:
                        break
                    time.sleep(1)
        finally:
            stopping = True
            terminate_child(child)
            status("supervisor_stopped")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--resume-run", action="store_true")
    options = parser.parse_args()
    supervise(Path(__file__).resolve().parents[1], resume=options.resume_run)
