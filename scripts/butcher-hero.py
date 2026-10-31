#!/usr/bin/env python3
"""Explicit foreground launcher for this checkout's collector and dashboard."""
import argparse
from datetime import datetime, timezone
import fcntl
import json
import os
from pathlib import Path
import shutil
import shlex
import signal
import socket
import subprocess
import sys
import time
from urllib.error import URLError
from urllib.request import build_opener, ProxyHandler

ROOT = Path(__file__).resolve().parents[1]


def report(message):
    try:
        print(message, flush=True)
    except OSError:
        # A closed Terminal/pipe must not interrupt cleanup of our children.
        pass


def read_json(path):
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
        return value if isinstance(value, dict) else {}
    except (OSError, ValueError):
        return {}


def write_json(path, value):
    temporary = path.with_suffix(".tmp")
    temporary.write_text(json.dumps(value), encoding="utf-8")
    temporary.replace(path)


def process_identity(pid):
    if type(pid) is not int or not 0 < pid <= 2**31 - 1:
        return None
    try:
        return subprocess.check_output(
            ["/bin/ps", "-ww", "-p", str(pid), "-o", "lstart=,command="],
            text=True, stderr=subprocess.DEVNULL, timeout=2,
            env={**os.environ, "LC_ALL": "C", "TZ": "UTC"}).strip() or None
    except (OSError, subprocess.SubprocessError):
        return None


def is_owned_manager(root, state):
    entry = state.get("entrypoint")
    identity = state.get("identity")
    working = state.get("workingDirectory")
    if (not isinstance(entry, str) or not isinstance(working, str)
            or not isinstance(identity, str) or not identity):
        return False
    if (Path(working) / entry).resolve() != root.resolve() / "scripts/butcher-hero.py":
        return False
    return (entry + " start" in identity
            and process_identity(state.get("pid")) == identity)


def is_locked(path):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a") as handle:
        try:
            fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return True
        return False


def preflight(root, port):
    binary = root / ".build/release/ButcherHeroAutomation"
    if not binary.is_file() or not os.access(binary, os.X_OK):
        raise RuntimeError("Missing release build: swift build -c release --product ButcherHeroAutomation")
    bundle = binary.parent / "ButcherHeroBot_RewardAutomationCore.bundle"
    if not bundle.is_dir():
        raise RuntimeError("Missing Swift resource bundle; rebuild the release product first.")
    tesseract = shutil.which("tesseract")
    if not tesseract:
        raise RuntimeError("Missing Tesseract: brew install tesseract")
    languages = subprocess.check_output([tesseract, "--list-langs"], text=True,
                                        stderr=subprocess.STDOUT, timeout=5)
    if "eng" not in languages.splitlines():
        raise RuntimeError("Tesseract's English (eng) model is missing.")
    for name in ("data/free-rewards/supervisor.lock", "docs/runs/.live-capture.lock"):
        if is_locked(root / name):
            raise RuntimeError("A collector is already running. Stop its own terminal/supervisor first; no takeover.")
    with socket.socket() as probe:
        # Match HTTPServer's reuse policy: TIME_WAIT from our prior dashboard
        # must not look like a live port owner during a quick stop/start.
        probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            probe.bind(("127.0.0.1", port))
        except OSError as error:
            raise RuntimeError(f"Port {port} is occupied/unavailable; stop its owner or use --port 8766.") from error


def wait_dashboard(child, port, stopping, timeout=8):
    deadline = time.monotonic() + timeout
    opener = build_opener(ProxyHandler({}))  # Loopback must not use a system HTTP proxy.
    while time.monotonic() < deadline and not stopping():
        if child.poll() is not None:
            raise RuntimeError("Dashboard exited before becoming ready; collector was not started.")
        try:
            with opener.open(f"http://127.0.0.1:{port}/health", timeout=0.5) as response:
                body = json.load(response)
                if isinstance(body, dict) and body.get("app") == "butcher-reward-dashboard":
                    if child.poll() is None:
                        return
        except (OSError, ValueError, URLError):
            pass
        time.sleep(0.1)
    raise RuntimeError("Dashboard did not become ready (or startup was stopped); collector was not started.")


def stop_children(children, grace=10):
    # Each Popen below creates a new session: these groups contain only our
    # services and their descendants, never the user's Terminal or game.
    for child in reversed(children):
        try:
            os.killpg(child.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
    deadline = time.monotonic() + grace
    for child in reversed(children):
        try:
            child.wait(timeout=max(0.01, deadline - time.monotonic()))
        except subprocess.TimeoutExpired:
            pass
    # Also reap descendants if their service leader exited unexpectedly.
    for child in reversed(children):
        try:
            os.killpg(child.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        child.wait(timeout=2)


def collector_progress(root):
    state = read_json(root / "data/free-rewards/state.json")
    if not state.get("running") or process_identity(state.get("pid")) is None:
        return "collector starting/restarting (not confirmed collecting)"
    try:
        checked = datetime.fromisoformat(state["lastCheckedAt"].replace("Z", "+00:00"))
        age = (datetime.now(timezone.utc) - checked).total_seconds()
        if not 0 <= age <= 10:
            return f"NO fresh successful screen check ({age:.0f}s old)"
    except (KeyError, TypeError, ValueError):
        return "waiting for first successful game screen (game closed, permissions, or capture unavailable)"
    if state.get("waitingForMouseRelease"):
        return "fresh screen; waiting for mouse release"
    return f"fresh screen ({age:.1f}s); crystal={state.get('crystalPhase', 'unknown')}"


def start(root, port=8765, new_run=False):
    directory = root / "data/local-app"
    directory.mkdir(parents=True, exist_ok=True)
    stopping = False
    children = []
    state = {}
    previous_handlers = {}

    def request_stop(signum, frame):
        nonlocal stopping
        stopping = True

    with (directory / "runner.lock").open("a") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise RuntimeError("This checkout's combined launcher is already running. Use status or stop.") from error
        preflight(root, port)
        for sig in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
            previous_handlers[sig] = signal.signal(sig, request_stop)
        try:
            state = {"pid": os.getpid(), "identity": process_identity(os.getpid()),
                     "entrypoint": sys.argv[0], "workingDirectory": str(Path.cwd()), "running": True,
                     "port": port, "startedAt": datetime.now(timezone.utc).isoformat()}
            write_json(directory / "state.json", state)
            report("[Butcher Hero] Starting dashboard; the game is not launched and no purchase is made.")
            dashboard = subprocess.Popen([sys.executable, "-u", str(root / "dashboard/server.py"),
                                           "--port", str(port)], cwd=root, start_new_session=True)
            children.append(dashboard)
            wait_dashboard(dashboard, port, lambda: stopping)
            if stopping:
                return 0
            command = [sys.executable, "-u", str(root / "scripts/supervise-free-rewards.py")]
            if not new_run:
                command.append("--resume-run")
            worker = subprocess.Popen(command, cwd=root, start_new_session=True)
            children.append(worker)
            state.update(dashboardPID=dashboard.pid, supervisorPID=worker.pid)
            write_json(directory / "state.json", state)
            report(f"[Butcher Hero] http://127.0.0.1:{port}/ | {'NEW run' if new_run else 'existing run continued'} | Ctrl+C: stop BOTH services")
            next_report = 0
            while not stopping:
                for label, child in (("dashboard", dashboard), ("supervisor", worker)):
                    if child.poll() is not None:
                        raise RuntimeError(f"{label} exited ({child.returncode}); shutting down our other service.")
                now = time.monotonic()
                if now >= next_report:
                    report("[Butcher Hero] " + collector_progress(root))
                    next_report = now + 10
                time.sleep(0.25)
            return 0
        finally:
            report("[Butcher Hero] Stopping our collector, supervisor and dashboard...")
            try:
                stop_children(children)
            finally:
                if state:
                    state["running"] = False
                    write_json(directory / "state.json", state)
                for sig, handler in previous_handlers.items():
                    signal.signal(sig, handler)
            report("[Butcher Hero] Stopped. Journals and statistics preserved.")


def stop(root, timeout=15):
    directory = root / "data/local-app"
    if not is_locked(directory / "runner.lock"):
        print("Combined launcher is not running; no process signalled.")
        return 0
    state = read_json(directory / "state.json")
    if not is_owned_manager(root, state):
        raise RuntimeError("Cannot verify the runner's PID/command/start time. Stop it with Ctrl+C in its terminal.")
    os.kill(state["pid"], signal.SIGTERM)
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if not is_locked(directory / "runner.lock"):
            print("Combined launcher and its owned services stopped.")
            return 0
        time.sleep(0.1)
    raise RuntimeError("Stop requested, but shutdown is not yet confirmed. Check its terminal.")


def status(root):
    directory = root / "data/local-app"
    state = read_json(directory / "state.json")
    if is_locked(directory / "runner.lock") and is_owned_manager(root, state):
        print(f"Combined launcher RUNNING; http://127.0.0.1:{state['port']}/")
        print(collector_progress(root))
    else:
        print("Combined launcher NOT RUNNING. Separately started legacy services are not managed here.")
    return 0


def install(root, directory):
    target = directory.expanduser().absolute() / "butcher-hero"
    source = root.resolve() / "scripts/butcher-hero.py"
    if target.exists() or target.is_symlink():
        if not target.is_symlink() or target.resolve() != source:
            raise RuntimeError(f"Refusing to overwrite existing command: {target}")
    else:
        target.parent.mkdir(parents=True, exist_ok=True)
        target.symlink_to(source)
    quoted = shlex.quote(str(target))
    print(f"Installed {target}\nRun: {quoted} start\nStop: {quoted} stop")
    if str(target.parent) not in os.environ.get("PATH", "").split(os.pathsep):
        print(f"For the short command in this terminal, add its folder to PATH:\nexport PATH={shlex.quote(str(target.parent))}:\"$PATH\"\nNo shell startup file was changed.")
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    begin = commands.add_parser("start", help="Run dashboard and collector in this foreground terminal")
    begin.add_argument("--port", type=int, default=8765)
    begin.add_argument("--new-run", action="store_true", help="Explicitly start a new logical statistics run")
    commands.add_parser("stop", help="Stop only this checkout's combined launcher and its services")
    commands.add_parser("status", help="Report combined launcher and fresh collector progress")
    setup = commands.add_parser("install", help="Install an optional user-local command; never edits shell configuration")
    setup.add_argument("--bin-dir", type=Path, default=Path.home() / ".local/bin")
    args = parser.parse_args()
    if args.command == "start" and not 1 <= args.port <= 65535:
        parser.error("port must be between 1 and 65535")
    try:
        if args.command == "start":
            return start(ROOT, args.port, args.new_run)
        if args.command == "stop":
            return stop(ROOT)
        if args.command == "status":
            return status(ROOT)
        return install(ROOT, args.bin_dir)
    except (RuntimeError, OSError, subprocess.SubprocessError) as error:
        print(f"[Butcher Hero] ERROR: {error}", file=sys.stderr, flush=True)
        return 1


if __name__ == "__main__":
    sys.exit(main())
