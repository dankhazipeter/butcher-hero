#!/bin/sh
set -eu
reward_project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$reward_project_dir"
reward_binary="$reward_project_dir/.build/release/ButcherHeroAutomation"
test -x "$reward_binary" || { echo 'Előbb: swift build -c release --product ButcherHeroAutomation'; exit 1; }
mkdir -p data/free-rewards
# Keep the supervisor attached to the persistent execution session. A detached
# nohup child can be cleaned up when an automation tool's short command ends.
exec python3 "$reward_project_dir/scripts/supervise-free-rewards.py" "$@"
