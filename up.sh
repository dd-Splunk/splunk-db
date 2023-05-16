#!/bin/bash
source .env
# Bring up the environment
docker compose up -d

echo "Wait for Splunk availability"

REGEX="<sessionKey>(.+)<\/sessionKey>"
until [ $(docker inspect --format='{{.State.Health.Status}}' so1) = healthy ]
do
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
-d "{\"name\":\"$DB_USER\",\"username\":\"$DB_USER\",\"password\":\"$DB_PASSWORD\"}"
echo ""
# Create a connection
curl -k -s -X POST  -u admin:$SPLUNK_PASSWORD \
https://$SPLUNK_HOST:8089/servicesNS/nobody/splunk_app_db_connect/db_connect/dbxproxy/connections \
-d "{\"name\":\"$DB_NAME\", \"connection_type\":\"mysql\",  \
\"host\":\"db\", \"database\":\"$DB_NAME\", \"identity\":\"$DB_USER\", \
\"port\":\"3306\", \"timezone\":\"$TZ\"}"
echo ""

# Splunk 9.x and above, disable "risky warning" for dbxquery
curl -k -s -X POST  -u admin:$SPLUNK_PASSWORD \
https://$SPLUNK_HOST:8089/servicesNS/nobody/splunk_app_db_connect/configs/conf-commands/dbxquery \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'is_risky=false'
