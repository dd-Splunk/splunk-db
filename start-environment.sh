#!/bin/bash
source .env
# Bring up the environment
docker compose up -d

# Check Splunk availability
REGEX="<sessionKey>(.+)<\/sessionKey>"

until [[ "$(curl -k -s -u admin:$SPLUNK_PASSWORD https://localhost:8089/services/auth/login -d username=admin -d password=$SPLUNK_PASSWORD)" =~ $REGEX ]]; do
  echo -n '.'
  sleep 10
done
# https://stackoverflow.com/questions/1891797/capturing-groups-from-a-grep-regex
sessionKey=${BASH_REMATCH[1]}
echo ""

# Now that Splunk is up
# Wait DB Connect to startup
REGEX="\[\]"
until [[ "$(curl -k -s -u admin:$SPLUNK_PASSWORD https://localhost:8089/servicesNS/nobody/splunk_app_db_connect/db_connect/dbxproxy/identities)" =~ $REGEX ]]; do
  echo -n '.'
  sleep 10
done
echo ""

# DB Connect is up
# https://answers.splunk.com/answers/516111/splunk-db-connect-v3-automated-programmatic-creati.html
# Create identity
curl -k -s -X POST -H "Authorization: Bearer $sessionKey" \
https://localhost:8089/servicesNS/nobody/splunk_app_db_connect/db_connect/dbxproxy/identities \
-d "{\"name\":\"splunk-id\",\"username\":\"$MYSQL_USER\",\"password\":\"$MYSQL_PASSWORD\"}"
echo ""
# Create a connection
curl -k -s -X POST -H "Authorization: Bearer $sessionKey" \
https://localhost:8089/servicesNS/nobody/splunk_app_db_connect/db_connect/dbxproxy/connections \
-d "{\"name\":\"$MYSQL_DATABASE\", \"connection_type\":\"mysql\",  \
\"host\":\"db\", \"database\":\"$MYSQL_DATABASE\", \"identity\":\"splunk-id\", \
\"port\":\"3306\", \"timezone\":\"Europe/Brussels\"}"
