#!/bin/bash
source .env
#
# Create Lookup tables for simulation
#
# python init-data.py
#
# Create MySQL initilization files from generated data
#

echo "DATA: $DATA_DIR"

cat <<EOF > ./mysql-conf/my.cnf
# To allow loading data from the app directory
[mysqld]
secure_file_priv="${DATA_DIR:1}"
EOF

SQL="./init-sql/create-db.sql"
# Create DB
echo "USE $MYSQL_DATABASE;
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"  > $SQL

# Create Schema
for f in `ls $DATA_DIR/*.csv`;
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
