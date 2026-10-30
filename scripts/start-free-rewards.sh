#!/bin/sh
set -eu
reward_project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$reward_project_dir"
reward_binary="$reward_project_dir/.build/release/ButcherHeroAutomation"
test -x "$reward_binary" || { echo 'Előbb: swift build -c release --product ButcherHeroAutomation'; exit 1; }
mkdir -p data/free-rewards
nohup "$reward_binary" watch-free --interval 1 >> data/free-rewards/watcher.log 2>&1 &
reward_pid=$!
sleep 1
if kill -0 "$reward_pid" 2>/dev/null; then
    echo "A Free-jutalom figyelő fut (PID $reward_pid). Napló: data/free-rewards/events.jsonl"
else
    tail -8 data/free-rewards/watcher.log
    exit 1
fi
