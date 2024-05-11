#!make

include .env
export $(shell sed 's/=.*//' .env)

SNAPSHOT ?= latest

all: precheck volume up

.PHONY: log    

precheck:
	@if [ ! -f "./.env" ]; then echo "⚠️ .env doesn't exists."; exit 1; fi

canrun: precheck
	@if [ ! -f "./configs/php-fpm.d/zz-docker.conf" ]; then echo "⚠️ Missing configuration, run make config"; exit 1; fi
	@if [ ! -f "./configs/mail/helo_access" ]; then echo "⚠️ Missing configuration, run make config"; exit 1; fi
	@if [ ! -f "./configs/nginx/conf.d/default.conf" ]; then echo "⚠️ Missing configuration, run make config"; exit 1; fi

volume: canrun
	docker volume create ${NAME}-mariadb-volume
	
cleanup: down
	docker volume rm ${NAME}-mariadb-volume
	@./bin/lib/installmariadb
	
up: canrun
	docker-compose up -d

down:
	docker-compose down

restart: down up

restore: down cleanup all
	docker exec ${NAME}-cronjob bash -c "/usr/cbin/restics3restore ${SNAPSHOT}"
	@sleep 5
	docker exec ${NAME}-mariadb bash -c "/var/www/database/restore"
	docker restart ${NAME}-mariadb

restoredb: down cleanup all
	@sleep 5
	docker exec ${NAME}-mariadb bash -c "/var/www/database/restore"
	docker restart ${NAME}-mariadb

snapshot:
	docker exec ${NAME}-cronjob bash -c "/usr/cbin/restics3backup user"

logs:
	docker compose logs --follow

config: SHELL:=/bin/bash
config: precheck 
	@chmod +x ./bin/install*
	@./bin/installstructure 
