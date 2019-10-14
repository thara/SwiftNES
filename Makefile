.PHONY: run nestest help

.DEFAULT_GOAL := run

ROM = Tests/SwiftNESTests/fixtures/helloworld/sample1.nes
NESTEST_ROM = nestest.nes

lint:  ## Run lint
	@swiftlint autocorrect -- && swiftlint

run:  ## Run emulator
	@mkdir -p .log
	@rm -f .log/debug.log
	@swift run -c release SwiftNESMain run ${ROM}

nestest:  ## Run nestest
	@mkdir -p .log
	@rm -f .log/nestest.log
	@swift run -c release -Xswiftc -Dnestest SwiftNESMain nestest ${NESTEST_ROM} > .log/nestest.log

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
