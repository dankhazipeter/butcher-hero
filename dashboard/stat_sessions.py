"""Explicit dashboard session boundaries; never edit the collector journal."""
import fcntl
import json
import os
from pathlib import Path
import tempfile
import threading
from datetime import datetime, timezone
from uuid import uuid4


class SessionError(Exception):
    def __init__(self, code, status=503):
        self.code, self.status = code, status
        super().__init__(code)


class StatSessions:
    def __init__(self, root):
        self.path = Path(root) / "data/free-rewards/stat-session.json"
        self.lock = threading.Lock()

    def marker(self):
        try:
            value = json.loads(self.path.read_text(encoding="utf-8"))
            at = datetime.fromisoformat(value["startedAt"].replace("Z", "+00:00"))
            if (value.get("schemaVersion") != 1 or at.tzinfo is None
                    or not isinstance(value["id"], str) or not value["id"]
                    or not isinstance(value["previousID"], str)):
                raise ValueError("Invalid boundary")
            return {"id": value["id"], "startedAt": value["startedAt"],
                    "source": "dashboard", "at": at, "previousID": value["previousID"]}
        except FileNotFoundError:
            return None
        except (OSError, ValueError, TypeError, KeyError, AttributeError) as error:
            raise SessionError("session_unavailable") from error

    def current(self, events):
        starts = [row for row in events if row["event"] == "watcher_started"]
        at = starts[-1]["at"] if starts else min((row["at"] for row in events), default=None)
        iso = at.astimezone(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z") if at else None
        current = {"id": "watcher:" + iso if iso else "empty", "startedAt": iso,
                   "source": "watcher" if starts else "journal", "at": at}
        manual = self.marker()
        if manual and (at is None or manual["at"] >= at):
            current = manual
        return current

    def start(self, expected, snapshot, now):
        # Compare-and-set plus replay of the immediately preceding request:
        # two tabs / duplicate HTTP deliveries cannot advance the boundary twice.
        with self.lock:
            try:
                self.path.parent.mkdir(parents=True, exist_ok=True)
                with self.path.with_suffix(".lock").open("a") as lock:
                    fcntl.flock(lock, fcntl.LOCK_EX)
                    current = self.current(snapshot())
                    if current.get("previousID") == expected:
                        return current
                    if current["id"] != expected:
                        raise SessionError("session_changed", 409)
                    if current["at"] is not None and now < current["at"]:
                        raise SessionError("session_clock_error", 409)
                    value = {"schemaVersion": 1, "id": uuid4().hex, "previousID": expected,
                             "startedAt": now.astimezone(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")}
                    fd, name = tempfile.mkstemp(prefix=".stat-session-", dir=self.path.parent)
                    try:
                        with os.fdopen(fd, "w", encoding="utf-8") as target:
                            json.dump(value, target)
                            target.flush()
                            os.fsync(target.fileno())
                        os.replace(name, self.path)
                    finally:
                        if os.path.exists(name):
                            os.unlink(name)
                    return self.current(snapshot())
            except OSError as error:
                raise SessionError("session_unavailable") from error


def public_session(session):
    return {key: session[key] for key in ("id", "startedAt", "source")}
