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

restore: down 
	@chmod +x ./bin/install*
	@./bin/installfullrestore
	
restoredb: down cleanup all
	@echo "🧭 Waiting 20s for DB to be ready"
	@sleep 20
	@docker exec ${NAME}-mariadb bash -c "/var/www/database/restore"
	@docker restart ${NAME}-mariadb

snapshot:
	docker exec ${NAME}-cronjob bash -c "/usr/cbin/restics3backup user"

logs:
	docker compose logs --follow

config: SHELL:=/bin/bash
config: precheck 
	@ufw allow from any to any proto tcp port 7844 comment "Cloudfalre ZeroTrust Tunnels tcp/7844"
	@ufw allow from any to any proto udp port 7844 comment "Cloudfalre ZeroTrust Tunnels udp/7844"
	@chmod +x ./bin/install*
	@./bin/installstructure 

teleport: snapshot
	@chmod +x ./bin/install*
	@./bin/installteleport 
