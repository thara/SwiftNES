.PHONY: run nestest help

.DEFAULT_GOAL := run

ROM = Tests/SwiftNESTests/fixtures/helloworld/sample1.nes
NESTEST_ROM = roms/nes-test-roms/other/nestest.nes

.PHONY: fmt
fmt:  ## Run Format
	@swift run swift-format format -r -i Sources/ Tests/

.PHONY: lint
lint:  ## Run lint
	@swiftlint --fix -- && swiftlint

.PHONY: debug
debug:  ## Debug emulator
	@swift run -c debug SwiftNESMain run ${ROM}

.PHONY: run
run:  ## Run emulator
	@mkdir -p .log
	@rm -f .log/debug.log
	@swift run -c release SwiftNESMain run ${ROM}

.PHONY: nestest
nestest:  ## Run nestest
	@mkdir -p .log
	@rm -f .log/nestest.log
	@swift run -c debug -Xswiftc -Dnestest SwiftNESMain nestest ${NESTEST_ROM} > .log/nestest.log

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
