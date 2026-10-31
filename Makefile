.PHONY: setup test test-vision start stop status install-cli
.DEFAULT_GOAL := setup

PORT ?= 8765

# Foreground: Ctrl+C stops both owned services; existing statistics continue.
start:
	python3 scripts/butcher-hero.py start --port $(PORT)

stop:
	python3 scripts/butcher-hero.py stop

status:
	python3 scripts/butcher-hero.py status

# Optional user-local command, without editing PATH or shell startup files.
install-cli:
	python3 scripts/butcher-hero.py install

# Run once after cloning; also included automatically by `make test`.
setup:
	./scripts/install-git-hooks.sh

test: setup
	./scripts/check-rewards.sh

test-vision: setup
	swift test --filter RewardCorpusTests
