.PHONY: bootstrap-macosx
bootstrap-macosx:  ## Bootstrap for macOSX
	@brew install glfw3

.PHONY: run
run:  ## Run SwiftNES
	@swift run -Xswiftc -I/usr/local/include -Xlinker -L/usr/local/lib

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
