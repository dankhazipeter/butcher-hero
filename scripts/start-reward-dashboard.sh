#!/bin/sh
set -eu
reward_dashboard_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$reward_dashboard_dir"
exec python3 dashboard/server.py "$@"
