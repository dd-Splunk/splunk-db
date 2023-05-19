.SILENT:
SHELL = bash

.env:
	echo "Create env from template"
	DB_P=`openssl rand -hex 8` envsubst < tpl.env | op inject -f > .env

env: .env

sql: env
	echo "Create SQL initialization files"
	./init-sql.sh

up: sql
	echo "Powering up"
	./up.sh

down:
	echo "Powering down"
	docker compose down

clean:
	echo "Powering down and removing volumes"
	docker compose down -v
	rm -rf .env

spl:
	echo "Downloading latest app version from container"
	./get-spl.sh

all:

.PHONY:	all env clean test
