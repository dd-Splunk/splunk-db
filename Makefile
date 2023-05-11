.SILENT:
SHELL = bash

.env:
	echo "Create env from template"
	SPL_P=Splunk4Me DB_P=`openssl rand -base64 16` envsubst < tpl.env | op inject -f > .env

env: .env


csv: env
	echo "Create csv with demo data"
	source .venv/bin/activate && python init-csv.py

sql: csv
	echo "Create SQL initialization files"
	source .venv/bin/activate && ./init-sql.sh

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
