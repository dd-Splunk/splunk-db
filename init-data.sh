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
