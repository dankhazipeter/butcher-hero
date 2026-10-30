#!/usr/bin/env python3
"""Read-only, loopback-only live view of the Free reward journal. No dependencies."""
from __future__ import annotations

import argparse
import json
import math
import os
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from decimal import Decimal, InvalidOperation, localcontext
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import re
import threading
from urllib.parse import parse_qs, urlsplit
from zoneinfo import ZoneInfo

ROOT = Path(__file__).resolve().parents[1]
ZONE = ZoneInfo("Europe/Bucharest")
UTC = timezone.utc
KINDS = {
    "hp": "Health",
    "regeneration": "Health Regen",
    "piercing_damage": "Pierce Damage",
    "cutting_damage": "Cut Damage",
    "smash_damage": "Smash Damage",
    "piercing_defense": "Pierce Defense",
    "cutting_defense": "Cut Defense",
    "smash_defense": "Smash Defense",
}


def stamp(value: datetime) -> str:
    return value.astimezone(UTC).isoformat(timespec="milliseconds").replace("+00:00", "Z")


def parse_time(value: str) -> datetime:
    parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=ZONE)
    return parsed.astimezone(UTC)


def amount(value) -> Decimal | None:
    if not isinstance(value, str) or not re.fullmatch(r"\d{1,40}(?:\.\d{1,30})?", value):
        return None
    try:
        result = Decimal(value)
        return result if result.is_finite() and result > 0 else None
    except InvalidOperation:
        return None


class Journal:
    """Read only appended complete lines; discard raw OCR data from the cache."""
    def __init__(self, path: Path):
        self.path = path
        self.lock = threading.Lock()
        self.identity = None
        self.offset = 0
        self.partial = b""
        self.events = []
        self.malformed = 0

    def snapshot(self):
        with self.lock:
            try:
                with self.path.open("rb") as source:
                    stat = os.fstat(source.fileno())
                    identity = (stat.st_dev, stat.st_ino)
                    if identity != self.identity or stat.st_size < self.offset:
                        self.identity = identity
                        self.offset = 0
                        self.partial = b""
                        self.events = []
                        self.malformed = 0
                    source.seek(self.offset)
                    data = source.read()
                    self.offset = source.tell()
            except FileNotFoundError:
                self.identity = None
                self.offset = 0
                self.partial = b""
                self.events = []
                self.malformed = 0
                return [], 0, False
            lines = (self.partial + data).split(b"\n")
            self.partial = lines.pop()
            for line in lines:
                if not line.strip():
                    continue
                try:
                    event = json.loads(line)
                    if not isinstance(event, dict) or not isinstance(event.get("event"), str):
                        raise ValueError("Invalid event")
                    at = parse_time(event["timestamp"])
                    reward = event.get("reward") or {}
                    if not isinstance(reward, dict):
                        raise ValueError("Invalid reward")
                    self.events.append({
                        "event": event["event"], "at": at,
                        "claimID": event.get("claimID"), "runID": event.get("runID"),
                        "reward": {key: reward.get(key) for key in ("kind", "amount", "rawAmount")},
                        "message": event.get("message"),
                    })
                except (ValueError, TypeError, KeyError, UnicodeError, AttributeError):
                    self.malformed += 1
            return list(self.events), self.malformed, True


def time_window(query: dict, events: list, now: datetime):
    mode = query.get("range", ["run"])[0]
    end = parse_time(query["to"][0]) if query.get("to") else now
    if query.get("from"):
        start = parse_time(query["from"][0])
        mode = "custom"
    elif mode == "today":
        start = now.astimezone(ZONE).replace(hour=0, minute=0, second=0, microsecond=0).astimezone(UTC)
    elif mode == "hour":
        start = now - timedelta(hours=1)
    elif mode == "day":
        start = now - timedelta(hours=24)
    elif mode == "all":
        start = min((event["at"] for event in events), default=now)
    elif mode == "run":
        starts = [event["at"] for event in events if event["event"] == "watcher_started"]
        start = starts[-1] if starts else min((event["at"] for event in events), default=now)
    else:
        raise ValueError("Ismeretlen időszak.")
    if start > end:
        raise ValueError("A kezdőidő nem lehet későbbi a végidőnél.")
    return mode, start, end


def aggregate(events, malformed, log_exists, query, now):
    mode, start, end = time_window(query, events, now)
    clicks, corrections, confirmed = {}, {}, set()
    attempts = 0
    for event in events:
        claim = event["claimID"]
        if not isinstance(claim, str):
            continue
        if event["event"] == "click_sent":
            clicks[claim] = event
            attempts += int(start <= event["at"] < end)
        elif event["event"] == "claim_confirmed_ui":
            confirmed.add(claim)
        elif event["event"] == "reward_corrected":
            corrections[claim] = event["reward"]
    selected = [(claim, event) for claim, event in clicks.items() if start <= event["at"] < end]
    selected.sort(key=lambda item: item[1]["at"])
    totals = {kind: Decimal(0) for kind in KINDS}
    counts = dict.fromkeys(KINDS, 0)
    points = {kind: [] for kind in KINDS}
    collection_counts = dict.fromkeys(KINDS, 0)
    collection_points = {kind: [] for kind in KINDS}
    recent, unknown, unclassified = [], 0, 0
    for claim, event in selected:
        reward = corrections.get(claim, event["reward"])
        kind, value = reward.get("kind"), amount(reward.get("amount"))
        success = claim in confirmed
        if success:
            if kind in KINDS:
                collection_counts[kind] += 1
                collection_points[kind].append(event["at"])
            else:
                unclassified += 1
        if success and kind in KINDS and value is not None:
            totals[kind] += value
            counts[kind] += 1
            points[kind].append((event["at"], value))
        elif success:
            unknown += 1
        recent.append({"claimID": claim, "at": stamp(event["at"]),
                       "kind": kind, "label": KINDS.get(kind, "Ismeretlen típus"),
                       "amount": str(value) if value is not None else None,
                       "confirmed": success})
    # At most ~96 buckets per kind, even over a long history. No units are mixed.
    span = max(1, (end - start).total_seconds())
    step = next((size for size in (60, 300, 900, 1800, 3600, 21600, 86400, 604800)
                 if span / size <= 96), math.ceil(span / 96))
    series = {}
    for kind, values in points.items():
        buckets = defaultdict(lambda: Decimal(0))
        for at, value in values:
            index = int((at - start).total_seconds() // step)
            buckets[index] += value
        running = Decimal(0)
        samples = [{"at": stamp(start), "value": "0"}]
        for index in sorted(buckets):
            running += buckets[index]
            at = min(end, start + timedelta(seconds=(index + 1) * step))
            samples.append({"at": stamp(at), "value": str(running)})
        samples.append({"at": stamp(end), "value": str(running)})
        series[kind] = samples
    collection_series = {}
    for kind, times in collection_points.items():
        buckets = defaultdict(int)
        for at in times:
            buckets[int((at - start).total_seconds() // step)] += 1
        running = 0
        samples = [{"at": stamp(start), "count": 0}]
        for index in sorted(buckets):
            running += buckets[index]
            at = min(end, start + timedelta(seconds=(index + 1) * step))
            samples.append({"at": stamp(at), "count": running})
        samples.append({"at": stamp(end), "count": running})
        collection_series[kind] = samples
    # Capture health belongs to the physical watcher, not the logical collection
    # session. A technical resume must not keep the old process's stale error.
    errors = [event for event in events if event["event"] in
              ("observation_error", "capture_recovered", "watcher_started", "watcher_resumed")]
    latest_error = errors[-1] if errors and errors[-1]["event"] == "observation_error" else None
    runs = [event for event in events if event["event"] == "watcher_started"]
    current_quality = bool(runs and "vision3" in (runs[-1]["message"] or "") and start >= runs[-1]["at"])
    return {
        "app": "butcher-reward-dashboard", "timezone": "Europe/Bucharest", "generatedAt": stamp(now),
        "range": {"mode": mode, "from": stamp(start), "to": stamp(end), "bucketSeconds": step},
        "logExists": log_exists, "malformedLines": malformed,
        "confirmedClaims": sum(claim in confirmed for claim, _ in selected),
        "pendingClaims": sum(claim not in confirmed for claim, _ in selected),
        "unknownConfirmed": unknown, "clickAttempts": attempts,
        "kinds": [{"kind": kind, "label": label, "total": str(totals[kind]), "count": counts[kind]}
                  for kind, label in KINDS.items()],
        "series": series, "recent": list(reversed(recent[-100:])),
        "collectionCounts": collection_counts, "collectionSeries": collection_series,
        "unclassifiedClaims": unclassified,
        "lastConfirmedAt": next((row["at"] for row in reversed(recent) if row["confirmed"]), None),
        "observationError": latest_error["message"] if latest_error else None,
        "historicalDataWarning": bool(selected) and not current_quality,
    }


def watcher_state(path: Path, now: datetime):
    try:
        state = json.loads(path.read_text())
        if not isinstance(state, dict) or not isinstance(state.get("running"), bool):
            raise ValueError("Missing collector state")
        pid = state.get("pid")
        alive = False
        known = True
        if type(pid) is int and 0 < pid <= 2**31 - 1:
            try:
                os.kill(pid, 0)
                alive = True
            except ProcessLookupError:
                pass
            except PermissionError:
                known = False
        elif state["running"]:
            known = False
        checked = state.get("lastCheckedAt")
        age = max(0, (now - parse_time(checked)).total_seconds()) if checked else None
        return {"stateKnown": known, "processAlive": alive,
                "running": bool(state.get("running") and alive),
                "waitingForMouseRelease": bool(state.get("waitingForMouseRelease")),
                "lastCheckedAt": checked, "frameAgeSeconds": age,
                "pendingClaimID": state.get("pendingClaimID")}
    except (OSError, ValueError, TypeError, AttributeError):
        return {"stateKnown": False, "processAlive": False,
                "running": False, "waitingForMouseRelease": False, "lastCheckedAt": None,
                "frameAgeSeconds": None, "pendingClaimID": None}


def make_server(root: Path, port: int):
    journal = Journal(root / "data/free-rewards/events.jsonl")
    static = root / "dashboard"
    # UI-only cutouts. Recognition templates are deliberately untouched.
    icons = static / "icons"

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *args):
            pass

        def send_bytes(self, status, data, mime, cache="no-store"):
            self.send_response(status)
            self.send_header("Content-Type", mime)
            self.send_header("Content-Length", str(len(data)))
            self.send_header("Cache-Control", cache)
            self.send_header("X-Content-Type-Options", "nosniff")
            self.send_header("Referrer-Policy", "no-referrer")
            self.send_header("Content-Security-Policy", "default-src 'self'; script-src 'self'; style-src 'self'; connect-src 'self'; img-src 'self'; base-uri 'none'; form-action 'none'")
            self.end_headers()
            try:
                self.wfile.write(data)
            except (BrokenPipeError, ConnectionResetError):
                pass

        def send_json(self, status, payload):
            self.send_bytes(status, json.dumps(payload, ensure_ascii=False).encode(), "application/json; charset=utf-8")

        def do_GET(self):
            allowed = {f"127.0.0.1:{self.server.server_port}", f"localhost:{self.server.server_port}"}
            if self.headers.get("Host") not in allowed:
                self.send_json(403, {"error": "Csak helyi címről érhető el."})
                return
            origin = self.headers.get("Origin")
            if origin and origin not in {"http://" + host for host in allowed}:
                self.send_json(403, {"error": "Idegen webhely nem olvashatja a naplót."})
                return
            url = urlsplit(self.path)
            try:
                if url.path == "/health":
                    self.send_json(200, {"app": "butcher-reward-dashboard", "readOnly": True})
                elif url.path == "/api/rewards":
                    now = datetime.now(UTC)
                    events, malformed, exists = journal.snapshot()
                    with localcontext() as context:
                        context.prec = 90
                        payload = aggregate(events, malformed, exists, parse_qs(url.query), now)
                    payload["watcher"] = watcher_state(root / "data/free-rewards/state.json", now)
                    self.send_json(200, payload)
                elif re.fullmatch(r"/locales/[a-z]{2}(?:-[A-Z]{2})?\.js", url.path):
                    path = static / url.path.lstrip("/")
                    if path.is_file():
                        self.send_bytes(200, path.read_bytes(), "text/javascript; charset=utf-8")
                    else:
                        self.send_json(404, {"error": "Unknown language"})
                elif url.path in ("/", "/app.js", "/format.js", "/status.js", "/animation.js", "/i18n.js", "/vendor/countUp.umd.js", "/style.css"):
                    name = {"/": "index.html", "/app.js": "app.js", "/format.js": "format.js", "/status.js": "status.js", "/animation.js": "animation.js", "/i18n.js": "i18n.js", "/vendor/countUp.umd.js": "vendor/countUp.umd.js", "/style.css": "style.css"}[url.path]
                    mime = "text/html" if name=="index.html" else "text/css" if name=="style.css" else "text/javascript"
                    self.send_bytes(200, (static / name).read_bytes(), mime + "; charset=utf-8")
                elif url.path.startswith("/icons/") and url.path[7:] in {kind + ".png" for kind in KINDS}:
                    self.send_bytes(200, (icons / url.path[7:]).read_bytes(), "image/png", "private, max-age=3600")
                else:
                    self.send_json(404, {"error": "Nincs ilyen oldal."})
            except (ValueError, OverflowError) as error:
                self.send_json(400, {"error": "Hibás időszak: " + str(error)})
            except OSError:
                self.send_json(503, {"error": "A helyi adatfájl most nem olvasható."})

        def do_POST(self):
            self.send_json(405, {"error": "Ez a nézet csak olvas; játékot és naplót nem módosít."})

    server = ThreadingHTTPServer(("127.0.0.1", port), Handler)
    server.daemon_threads = True
    return server


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()
    server = make_server(ROOT, args.port)
    print(f"Élő jutalomnapló: http://127.0.0.1:{server.server_port}/ — csak olvasás; Ctrl+C: leállítás", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
