# To get the current directory in Linux, Mac or Windows
current-dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SHELL = /bin/sh
RUN_PHP := docker-compose exec php
COMPOSER = $(RUN_PHP) composer
PHP_CS_FIXER = $(RUN_PHP) tools/php-cs-fixer/vendor/bin/php-cs-fixer
PHPUNIT = $(RUN_PHP) bin/phpunit

## Default rule to display help
.DEFAULT_GOAL:=help
help:
	@echo "Available rules:"
	@echo
	@sed -n -e '/^## /s/## //p' -e '/^## /s/## //p' -e '/^## /s/## //p' $(MAKEFILE_LIST)

DOCKER := $(shell command -v docker 2> /dev/null)
DOCKER_COMPOSE := $(shell command -v docker-compose 2> /dev/null)

ifndef DOCKER
$(error Docker is not available. Please install Docker)
endif

ifndef DOCKER_COMPOSE
$(error Docker Compose is not available. Please install Docker Compose)
endif

## Start the application
start:
	@docker-compose up -d

## Restart the application
restart: stop start

## Stop the application
stop:
	@docker-compose down

rebuild:
	@docker-compose up -d --build

ssh:
	@docker-compose exec php sh

.PHONY: build
build: composer/install

composer/install: ACTION=install --ignore-platform-reqs
composer/update: ACTION=update
composer/require:
ifdef module
	$(COMPOSER) require $(module)
else
	$(error module is undefined. Use make composer/require module=<module-name>)
endif

composer composer/install composer/update:
	$(COMPOSER) $(ACTION)

entity:
	./bin/console make:entity

stan:
	$(RUN_PHP) vendor/bin/phpstan analyse --memory-limit=1g

tools/php-cs-fixer/vendor/bin/php-cs-fixer:
	$(RUN_PHP) composer install --working-dir tools/php-cs-fixer

cs: tools/php-cs-fixer/vendor/bin/php-cs-fixer
	$(PHP_CS_FIXER) fix --allow-risky=yes --dry-run -v --diff

cs-fix: tools/php-cs-fixer/vendor/bin/php-cs-fixer
	$(PHP_CS_FIXER) fix -v

cs-fix-risky: tools/php-cs-fixer/vendor/bin/php-cs-fixer
	$(RUN_PHP) tools/php-cs-fixer/vendor/bin/php-cs-fixer fix -v --allow-risky=yes

test:
	$(PHPUNIT) --cache-result-file=var/cache/phpunit/.phpunit.cache