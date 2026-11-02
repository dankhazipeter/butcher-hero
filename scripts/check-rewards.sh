#!/bin/sh
# Offline only: no screen capture, game input, server or live-log writes.
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
export PYTHONDONTWRITEBYTECODE=1
command -v tesseract >/dev/null || { printf 'Missing OCR engine: install with brew install tesseract\n' >&2; exit 1; }
swift test --filter '(Reward(Corpus|InputGeometry|Capture)?|Crystal|EventEnd)Tests'
python3 -m unittest discover -s tests -p 'test_reward_dashboard.py'
python3 -m unittest discover -s tests -p 'test_game_control.py'
python3 -m unittest discover -s tests -p 'test_stat_sessions.py'
python3 -m unittest discover -s tests -p 'test_git_test_gate.py'
python3 -m unittest discover -s tests -p 'test_free_supervisor.py'
python3 -m unittest discover -s tests -p 'test_local_app.py' -v
python3 -m unittest discover -s tests -p 'test_geode_probe.py'
node --test tests/reward_format.test.cjs tests/reward_status.test.cjs tests/reward_animation.test.cjs tests/reward_i18n.test.cjs
node --check dashboard/app.js
node --check dashboard/format.js
node --check dashboard/status.js
node --check dashboard/animation.js
node --check dashboard/i18n.js
node --check dashboard/locales/hu.js
node --check dashboard/locales/en.js
printf '\nAll reward recognition and statistics checks passed.\n'
