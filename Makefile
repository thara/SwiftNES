.PHONY: run nestest help

.DEFAULT_GOAL := run

ROM = Tests/SwiftNESTests/fixtures/helloworld/sample1.nes
NESTEST_ROM = nestest.nes

lint:  ## Run lint
	@swiftlint autocorrect -- && swiftlint

build:  ## Build
	@swift build -Xlinker -L/usr/local/lib

debug:  ## Debug Run emulator
	@swift run -c debug -Xlinker -L/usr/local/lib SwiftNESMain run ${ROM}

run:  ## Run emulator
	@mkdir -p .log
	@rm -f .log/debug.log
	@swift run -c release -Xlinker -L/usr/local/lib SwiftNESMain run ${ROM}

nestest:  ## Run nestest
	@mkdir -p .log
	@rm -f .log/nestest.log
	@swift run -c release -Xlinker -L/usr/local/lib -Xswiftc -Dnestest SwiftNESMain nestest ${NESTEST_ROM} > .log/nestest.log

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
