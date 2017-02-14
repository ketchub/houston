export COMPOSE_PROJECT_NAME = ketch
export PORT_HTTPS_WEBUI ?= 4433
export PORT_HTTPS_API ?= 4434
export NODE_ENV = development

SHELL = /bin/bash

.PHONY: start
start: api-setup webui-setup jobqueue-setup
	@docker-compose -f _docker/docker-compose.yml up -d
	@docker-compose -f _docker/docker-compose.yml logs -f; true && \
	make stop

.PHONY: stop
stop:
	@docker-compose -f _docker/docker-compose.yml down
	@echo Shutdown OK

################################################################################
# API
################################################################################
.PHONY: api-setup
api-setup: export RUN_COMMAND = npm install
api-setup: export SERVICE_NAME = api
api-setup:
ifneq ($(wildcard ./api/node_modules/.*),)
	@echo API Setup OK
else
	@echo Installing API
	@make compose-exec
endif

.PHONY: api-recreate-db
api-recreate-db: export RUN_COMMAND = node ./bin/db.js
api-recreate-db: export SERVICE_NAME = api
api-recreate-db:
	@make compose-exec

.PHONY: api-seed-db
api-seed-db: export RUN_COMMAND = node ./bin/db-seeder.js
api-seed-db: export SERVICE_NAME = api
api-seed-db:
	@make compose-exec

.PHONY: api-db-reset
api-db-reset:
	@make api-recreate-db
	@make api-seed-db

.PHONY: api-clean-seeds
api-clean-seeds:
	rm -rf ./api/config/seeds/trip/*
	rm -rf ./api/config/seeds/account/*

.PHONY: api-test
api-test: export RUN_COMMAND = ./node_modules/.bin/mocha
api-test: export SERVICE_NAME = api
api-test:
	@make compose-exec

.PHONY: api-ssh
api-ssh: export RUN_COMMAND = /bin/sh
api-ssh: export SERVICE_NAME = api
api-ssh:
	@make compose-exec

################################################################################
# JobQueue
################################################################################
.PHONY: jobqueue-setup
jobqueue-setup: export RUN_COMMAND = npm install
jobqueue-setup: export SERVICE_NAME = jobqueue
jobqueue-setup:
ifneq ($(wildcard ./jobqueue/node_modules/.*),)
	@echo JobQueue Setup OK
else
	@echo Installing JobQueue
	@make compose-exec
endif

.PHONY: jobqueue-test
jobqueue-test: export RUN_COMMAND = ./node_modules/.bin/mocha
jobqueue-test: export SERVICE_NAME = jobqueue
jobqueue-test:
	@make compose-exec

.PHONY: jobqueue-ssh
jobqueue-ssh: export RUN_COMMAND = /bin/sh
jobqueue-ssh: export SERVICE_NAME = jobqueue
jobqueue-ssh:
	@make compose-exec

################################################################################
# WebUI
################################################################################
.PHONY: webui-setup
webui-setup: export RUN_COMMAND = npm install
webui-setup: export SERVICE_NAME = webui
webui-setup:
ifneq ($(wildcard ./api/node_modules/.*),)
	@echo WebUI Setup OK
else
	@echo Installing WebUI
	@make compose-exec
endif

.PHONY: webui-build-production
webui-build-production: export RUN_COMMAND = npm run-script build-production
webui-build-production: export SERVICE_NAME = webui
webui-build-production: webui-setup
	@make compose-exec

.PHONY: webui-test
webui-test: export RUN_COMMAND = npm run-script test-node
webui-test: export SERVICE_NAME = webui
webui-test:
	@make compose-exec

.PHONY: webui-ssh
webui-ssh: export RUN_COMMAND = /bin/sh
webui-ssh: export SERVICE_NAME = webui
webui-ssh:
	@make compose-exec

################################################################################
# Helpers
################################################################################
.PHONY: compose-exec
compose-exec:
	@docker-compose -f _docker/docker-compose.yml run --no-deps --rm \
		$(SERVICE_NAME) \
		$(RUN_COMMAND)

.PHONY: inspect-compose-config
inspect-compose-config:
	docker-compose -f _docker/docker-compose.yml config
