"""Fixed-target macOS status probe and explicit, same-origin game-launch action."""
from __future__ import annotations

from datetime import datetime, timezone
import json
from pathlib import Path
import subprocess
import threading
import time

BUNDLE_ID = "com.multicastgames.butcher"


class GameControlError(Exception):
    def __init__(self, code, status=503):
        super().__init__(code)
        self.code, self.status = code, status


class GameControl:
    def __init__(self, root: Path):
        self.binary = root / ".build/release/ButcherHeroAutomation"
        self._lock = threading.Lock()
        self._launch_lock = threading.Lock()
        self._cache = None
        self._cached_at = float("-inf")
        self._last_launch = float("-inf")

    def snapshot(self, force=False):
        with self._lock:
            if not force and self._cache is not None and time.monotonic() - self._cached_at < 5:
                return dict(self._cache)
            stamp = datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
            result = {"known": False, "installed": None, "running": None,
                      "hidden": None, "windowVisible": None, "checkedAt": stamp}
            try:
                if not self.binary.is_file():
                    raise ValueError("Missing native helper")
                process = subprocess.run([str(self.binary), "game-status"], capture_output=True,
                                         text=True, timeout=3, check=True)
                native = json.loads(process.stdout)
                if not isinstance(native, dict) or native.get("known") is not True:
                    raise ValueError("Unknown native status")
                if not all(type(native.get(key)) is bool for key in ("installed", "running", "hidden")):
                    raise ValueError("Invalid native status")
                if native.get("windowVisible") is not None and type(native["windowVisible"]) is not bool:
                    raise ValueError("Invalid window status")
                result.update({key: native.get(key) for key in ("known", "installed", "running", "hidden", "windowVisible")})
            except (OSError, ValueError, subprocess.SubprocessError):
                # Failure to query is not evidence that the game has stopped.
                pass
            self._cache, self._cached_at = result, time.monotonic()
            return dict(result)

    def launch(self):
        with self._launch_lock:
            state = self.snapshot(force=True)
            if state["known"] is not True:
                raise GameControlError("probe_unavailable")
            if state["running"]:
                return "already_running"  # no focus change or duplicate open
            if not state["installed"]:
                raise GameControlError("not_installed", 409)
            now = time.monotonic()
            if now - self._last_launch < 10:
                raise GameControlError("launch_cooldown", 429)
            self._last_launch = now
            try:
                subprocess.run(["/usr/bin/open", "-b", BUNDLE_ID], capture_output=True,
                               timeout=3, check=True)
            except (OSError, subprocess.SubprocessError) as error:
                raise GameControlError("launch_failed") from error
            with self._lock:
                self._cache = None
            # open returning successfully means requested, not yet observed running.
            return "requested"
