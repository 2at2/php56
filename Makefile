# Makefile configuration
.DEFAULT_GOAL := help
.PHONY: help build push

build: ## Build
    @docker build --force-rm --no-cache --tag strebul/php56:latest .

push: ## Push
    @docker push strebul/php56:latest

help:
    @grep --extended-regexp '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'