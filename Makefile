.PHONY: bootstrap-macosx
bootstrap-macosx:  ## Bootstrap for macOSX
	@brew install glfw3

.PHONY: build
build-osx:  ## Build SwiftNES for macOSX
	@swift build -Xswiftc -I/usr/local/include -Xlinker -L/usr/local/lib

.PHONY: run
run-osx:  ## Run SwiftNES for macOSX
	@swift run -Xswiftc -I/usr/local/include -Xlinker -L/usr/local/lib

.PHONY: test
test-osx:  ## Run tests for macOSX
	@swift test -Xswiftc -I/usr/local/include -Xlinker -L/usr/local/lib

.PHONY: ci-test
ci-test:  ## Run tests for CI
	@swift test -v -Xswiftc "-j1"

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
