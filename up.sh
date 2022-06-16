#!/bin/bash
source .env
# Bring up the environment
docker compose up -d

echo "Wait for Splunk availability"

REGEX="<sessionKey>(.+)<\/sessionKey>"
until [[ "$(curl -k -s -u admin:$SPLUNK_PASSWORD https://$SPLUNK_HOST:8089/services/auth/login -d username=admin -d password=$SPLUNK_PASSWORD)" =~ $REGEX ]]; do
  echo -n '.'
  sleep 10
done
# https://stackoverflow.com/questions/1891797/capturing-groups-from-a-grep-regex
sessionKey=${BASH_REMATCH[1]}

# Now that Splunk is up
echo -e "\nWait for DB Connect to startup"
http_status=""
until [[ $http_status -eq 200 ]]; do
  sleep 10
  http_status=$(curl -k -s -o /dev/null -w "%{http_code}" -u admin:$SPLUNK_PASSWORD  https://$SPLUNK_HOST:8089/servicesNS/nobody/splunk_app_db_connect/db_connect/dbxproxy/identities)
  echo "Status: $http_status"
done

# DB Connect is up
# https://answers.splunk.com/answers/516111/splunk-db-connect-v3-automated-programmatic-creati.html
# Create identity
curl -k -s -X POST  -u admin:$SPLUNK_PASSWORD  \
https://$SPLUNK_HOST:8089/servicesNS/nobody/splunk_app_db_connect/db_connect/dbxproxy/identities \
-d "{\"name\":\"$MYSQL_USER\",\"username\":\"$MYSQL_USER\",\"password\":\"$MYSQL_PASSWORD\"}"
echo ""
# Create a connection
curl -k -s -X POST  -u admin:$SPLUNK_PASSWORD \
https://$SPLUNK_HOST:8089/servicesNS/nobody/splunk_app_db_connect/db_connect/dbxproxy/connections \
-d "{\"name\":\"$MYSQL_DATABASE\", \"connection_type\":\"mysql\",  \
\"host\":\"db\", \"database\":\"$MYSQL_DATABASE\", \"identity\":\"$MYSQL_USER\", \
\"port\":\"3306\", \"timezone\":\"Europe/Brussels\"}"
echo ""
