#
#
# Create MySQL initilization file
#
CSV_DIR=./app/lookups
SQL="./init-sql/create-db.sql"
DB="splunkdb"
# Create DB
echo "
CREATE DATABASE $DB;
USE $DB;
" | envsubst  > $SQL

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

cat $SQL
