# VARIABLES
# ====================

composer = composer

env := dev
env-flag = --env $(env)

bin = bin
console = $(bin)/console
phpunit = $(bin)/phpunit

cache = var/cache/$(env)

.DEFAULT_GOAL := help


## -- General --

## Show this help
.PHONY: help
help:
	@awk '{ \
			if ($$0 ~ /^.PHONY: [a-zA-Z\-\_0-9]+$$/) { \
				helpCommand = substr($$0, index($$0, ":") + 2); \
				if (helpMessage) { \
					printf "\033[36m%-20s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^[a-zA-Z\-\_0-9.]+:/) { \
				helpCommand = substr($$0, 0, index($$0, ":")); \
				if (helpMessage) { \
					printf "\033[36m%-20s\033[0m %s\n", \
						helpCommand, helpMessage; \
					helpMessage = ""; \
				} \
			} else if ($$0 ~ /^##/) { \
				if (helpMessage) { \
					helpMessage = helpMessage"\n                     "substr($$0, 3); \
				} else { \
					helpMessage = substr($$0, 3); \
				} \
			} else { \
				if (helpMessage) { \
					print "\n                     "helpMessage"\n" \
				} \
				helpMessage = ""; \
			} \
		}' \
		$(MAKEFILE_LIST)


## Install dependencies
.PHONY: install
install: vendor

vendor: composer.lock
	$(composer) install

composer.lock: composer.json
	$(composer) update


## -- Cache --

## Clear the cache and regenerate compiled container
.PHONY: clear
clear: install
	$(console) cache:clear

## Delete the cache
.PHONY: hard-clear
hard-clear:
	rm -r $(cache)


## -- Maker --

## Make a controller
.PHONY: controller
controller: install
	$(console) make:controller --no-template

## Make a migration
.PHONY: migration
migration: install
	$(console) make:migration

## Make a fixture
.PHONY: fixture
fixture: install
	$(console) make:fixtures

## Make a command
.PHONY: command
command: install
	$(console) make:command

## Make a voter
.PHONY: voter
	$(console) make:voter

## Make an entity
.PHONY: entity
entity: install
	$(console) make:entity


## -- Database --

## Create the database
.PHONY: create-database
create-database: install
	$(console) doctrine:database:create $(env-flag)

## Drop the database
.PHONY: drop-database
drop-database: install
	$(console) doctrine:database:drop $(env-flag)

## Migrate migrations
.PHONY: migrate
migrate: install
	$(console) doctrine:migrations:migrate $(env-flag)

## Rollup the latest migration
.PHONY: rollup
rollup: install
	$(console) doctrine:migrations:migrate prev $(env-flag)