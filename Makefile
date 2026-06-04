SHELL := /usr/bin/env bash

.DEFAULT_GOAL := help
.PHONY: help pack lint clean

help: ## Show this help
	@awk 'BEGIN{FS=":.*##"} /^[a-zA-Z_-]+:.*##/ {printf "  %-8s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

pack: ## Build the offline bundle (needs internet)
	./pack.sh

lint: ## Run shellcheck + validate the config JSON
	shellcheck pack.sh opencode-offline
	jq empty templates/opencode.json

clean: ## Remove build outputs
	rm -rf opencode-offline.tar.gz opencode-offline-bundle
