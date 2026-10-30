#!/bin/sh
# Offline only: no screen capture, game input, server or live-log writes.
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
export PYTHONDONTWRITEBYTECODE=1
swift test --filter 'Reward(Corpus)?Tests'
python3 -m unittest discover -s tests -p 'test_reward_dashboard.py'
python3 -m unittest discover -s tests -p 'test_git_test_gate.py'
python3 -m unittest discover -s tests -p 'test_free_supervisor.py'
node --test tests/reward_format.test.cjs
node --check dashboard/app.js
node --check dashboard/format.js
printf '\nAll reward recognition and statistics checks passed.\n'
