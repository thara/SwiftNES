
.PHONY: run nestest help

.DEFAULT_GOAL := run

run:  ## Run emulator
	@mkdir -p .log
	@rm -f .log/debug.log
	@swift run > .log/debug.log

nestest:  ## Run nestest
	@mkdir -p .log
	@rm -f .log/nestest.log
	@swift run -Xswiftc -Dnestest > .log/nestest.log

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'