.PHONY: setup test test-vision

# Run once after cloning; also included automatically by `make test`.
setup:
	./scripts/install-git-hooks.sh

test: setup
	./scripts/check-rewards.sh

test-vision: setup
	swift test --filter RewardCorpusTests
