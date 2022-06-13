.SILENT:

define MY_ENV
# Splunk stuff
SPLUNK_HOST=localhost
SPLUNK_PASSWORD=Splunk4Me
#
# User Credentials retrieved from 1Password under the splunk.okta.com key
#
SPLUNKBASE_USERNAME={{op://Splunk/splunk.okta.com/username}}@splunk.com
SPLUNKBASE_PASSWORD={{op://Splunk/splunk.okta.com/password}}
# MySQL stuff
DATA_DIR=./data
MYSQL_DATABASE=splunkdb
MYSQL_USER=splunk
MYSQL_PASSWORD=splunk
MYSQL_ROOT_PASSWORD=mysql-password
endef
export MY_ENV

env: .env
	echo "Create .env"
	echo "$$MY_ENV" | op inject -f > .env
data: env
	python init-data.py
sql: data
	./init-sql.sh
up: sql
	echo "Powering up"
	./start-environment.sh
down:
	echo "Powering down"
	docker compose down
clean:
	docker compose down -v
