#!/bin/bash
#
# Create .env file with credentials
#
echo "
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
" | op inject -f > .env
#
# Create Lookup tables for simulation
#
python init-data.py
#
# Create MySQL initilization file from generated data
#
source .env
CSV_DIR="./app/lookups"
SQL="./init-sql/create-db.sql"
# Create DB
echo "USE $MYSQL_DATABASE;
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"  > $SQL

# Create Schema
for f in `ls $CSV_DIR/*.csv`;
do
    csvsql -i mysql -d ',' $f >> $SQL
    table=${f##*/}
    table=${table%.csv}
    echo "LOAD DATA INFILE '${f:1}' INTO TABLE \`$table\`
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\\n'
    IGNORE 1 ROWS;" >> $SQL
done

# Bring up the environment
docker compose up -d

# Check Splunk availability
until [ "$(curl -k -u admin:$SPLUNK_PASSWORD --silent --fail --connect-timeout 1 -I https://localhost:8089/servicesNS/nobody/splunk_app_db_connect/db_connect/dbxproxy/identities  )" ];
do
  echo --- Splunk is starting, please wait...
  sleep 10
done
# Wait DBX to startup
sleep 60
#
# Now that Splunk is up
# Setup DB Connect
#
# Create identity
curl -k -X POST -u admin:$SPLUNK_PASSWORD \
https://localhost:8089/servicesNS/nobody/splunk_app_db_connect/db_connect/dbxproxy/identities \
-d "{\"name\":\"splunk-id\",\"username\":\"$MYSQL_USER\",\"password\":\"$MYSQL_PASSWORD\"}"

# Create a connection

curl -k -X POST -u admin:$SPLUNK_PASSWORD \
https://localhost:8089/servicesNS/nobody/splunk_app_db_connect/db_connect/dbxproxy/connections \
-d "{\"name\":\"$MYSQL_DATABASE\", \"connection_type\":\"mysql\",  \
\"host\":\"db\", \"database\":\"$MYSQL_DATABASE\", \"identity\":\"splunk-id\", \
\"port\":\"3306\", \"timezone\":\"Europe/Brussels\"}"
