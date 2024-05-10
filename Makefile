#!make

include .env
export $(shell sed 's/=.*//' .env)

SNAPSHOT ?= latest

all: precheck volume up

.PHONY: log    

precheck:
	@if [ ! -f "./.env" ]; then echo "⚠️ .env doesn't exists."; exit 1; fi

canrun: precheck
	@if [ ! -f "./php-fpm.d/zz-docker.conf" ]; then echo "⚠️ Missing configuration, run make config"; exit 1; fi
	@if [ ! -f "./mail/helo_access" ]; then echo "⚠️ Missing configuration, run make config"; exit 1; fi
	@if [ ! -f "./ngnix/conf.d/default.conf" ]; then echo "⚠️ Missing configuration, run make config"; exit 1; fi

volume: canrun
	docker volume create ${NAME}-mariadb-volume
	
cleanup: down
	docker volume rm ${NAME}-mariadb-volume
	@./bin/installmariadb
	
up: canrun
	docker-compose up -d

down:
	docker-compose down

restart: down up

restore: down cleanup all
	docker exec ${NAME}-cronjob bash -c "/usr/cbin/resticrestore ${SNAPSHOT}"
	@sleep 5
	docker exec ${NAME}-mariadb bash -c "/var/www/database/restore"
	docker restart ${NAME}-mariadb

snapshot:
	docker exec ${NAME}-cronjob bash -c "/usr/cbin/resticbackup user"

logs:
	docker compose logs --follow

config: SHELL:=/bin/bash
config: precheck 
	@./bin/installstructure 
	@echo 
	@echo "🛠️ 💻 Started 'make config' | ${DOMAIN}" >> ./log/make/config.log
	@echo "⚙️ Starting config for ${DOMAIN}"
	@echo "..."
	@./bin/installphpfpm >> ./log/make/config.log
	@./bin/installheloaccess >> ./log/make/config.log
	@./bin/installngnix >> ./log/make/config.log
	@./bin/installmariadb >> ./log/make/config.log
	@echo "✅ ${DOMAIN} is configured, see log/make/config.log"
	@echo "🛠️ ✅ DONE - 'make config' | ${DOMAIN}" >> ./log/make/config.log

