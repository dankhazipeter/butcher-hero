#!/bin/sh
set -eu
reward_project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$reward_project_dir"
test -f data/free-rewards/state.json || { echo 'Nincs futó jutalomfigyelő.'; exit 0; }
reward_pid=$(/usr/bin/plutil -extract pid raw -o - data/free-rewards/state.json)
case "$reward_pid" in ''|*[!0-9]*) echo 'Érvénytelen PID'; exit 1;; esac
reward_command=$(/bin/ps -p "$reward_pid" -o command= 2>/dev/null || true)
case "$reward_command" in
    *ButcherHeroAutomation*watch-free*) kill -INT "$reward_pid"; echo 'A jutalomfigyelő leállítását kértem.';;
    *) echo 'Nincs futó jutalomfigyelő.';;
esac
