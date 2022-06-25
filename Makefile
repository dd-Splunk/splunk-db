.SILENT:
SHELL = bash

env: .env
	echo "Create env from template"
	SPL_P=Splunk4Me SQL_P=`openssl rand -base64 16` SQL_RP=`openssl rand -base64 16` envsubst < tpl.env | op inject -f > .env
csv: env
	echo "Create csv"
	source .venv/bin/activate && python init-csv.py

sql: csv
	source .venv/bin/activate && ./init-sql.sh
up: sql
	echo "Powering up"
	./up.sh
down:
	echo "Powering down"
	docker compose down
clean:
	docker compose down -v
