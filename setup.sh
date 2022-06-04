#!/bin/bash
#
# Create .env file with credentials
#
echo "
SPLUNK_HOST=localhost
SPLUNK_PASSWORD=Splunk4Me
SA_PASSWORD=mssql1Ipw
MYSQL_DATABASE=splunkdb
# So you don't have to use root, but you can if you like
MYSQL_USER=splunk
MYSQL_PASSWORD=splunk
# Password for root access
MYSQL_ROOT_PASSWORD=mysql-password
#
# Credentials retrieved from 1Password under the splunk.okta.com key
#
SPLUNKBASE_USERNAME={{op://Splunk/splunk.okta.com/username}}@splunk.com
SPLUNKBASE_PASSWORD={{op://Splunk/splunk.okta.com/password}}" | op inject -f > .env
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
echo "CREATE DATABASE $MYSQL_DATABASE;
    USE $MYSQL_DATABASE;
    "  > $SQL

# Create Schema
for f in `ls $CSV_DIR/*.csv`;
do
    csvsql -i mysql -d ',' $f >> $SQL
    table=${f##*/}
    table=${table%.csv}
    echo "LOAD DATA INFILE '${f:1}' INTO TABLE \`$table\`
    FIELDS TERMINATED BY ','
    ENCLOSED BY '\"'
    LINES TERMINATED BY '\\\n'
    IGNORE 1 ROWS;
    " >> $SQL

done
