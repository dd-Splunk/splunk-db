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
MYSQL_DATABASE=splunkdb
MYSQL_USER=splunk
MYSQL_PASSWORD=splunk
MYSQL_ROOT_PASSWORD=mysql-password
endef
export MY_ENV

up:
	echo "Powering up"
	./start-environment.sh

down:
	echo "Powering down"
	docker compose down

env:
	echo "$$MY_ENV" | op inject -f > .env

data:
	./init-data.sh

clean:
	docker compose down -v
