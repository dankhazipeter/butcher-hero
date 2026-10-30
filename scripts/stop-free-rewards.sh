#!/bin/sh
set -eu
reward_project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$reward_project_dir"
if [ -f data/free-rewards/supervisor.json ]; then
    supervisor_pid=$(/usr/bin/plutil -extract pid raw -o - data/free-rewards/supervisor.json)
    case "$supervisor_pid" in
        ''|*[!0-9]*) ;;
        *)
            supervisor_command=$(/bin/ps -p "$supervisor_pid" -o command= 2>/dev/null || true)
            case "$supervisor_command" in
                *"$reward_project_dir/scripts/supervise-free-rewards.py"*)
                    kill -TERM "$supervisor_pid"
                    echo 'A felügyelő és a jutalomfigyelő leállítását kértem; nem indulnak vissza.'
                    exit 0;;
            esac;;
    esac
fi
test -f data/free-rewards/state.json || { echo 'Nincs futó jutalomfigyelő.'; exit 0; }
reward_pid=$(/usr/bin/plutil -extract pid raw -o - data/free-rewards/state.json)
case "$reward_pid" in ''|*[!0-9]*) echo 'Érvénytelen PID'; exit 1;; esac
reward_command=$(/bin/ps -p "$reward_pid" -o command= 2>/dev/null || true)
case "$reward_command" in
    *ButcherHeroAutomation*watch-free*) kill -INT "$reward_pid"; echo 'A jutalomfigyelő leállítását kértem.';;
    *) echo 'Nincs futó jutalomfigyelő.';;
esac
