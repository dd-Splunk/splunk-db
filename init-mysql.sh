#
CSV_DIR=./app/lookups
SQL="./init-sql/create-db.sql"
DB="splunk-db"
echo "
CREATE DATABASE $DB;
USE $DB;
GRANT ALL PRIVILEGES ON $DB.* TO 'splunk'@'localhost';" | envsubst  > $SQL

for f in `ls $CSV_DIR/*.csv`;
do
    csvsql -i mysql -d ',' $f >> $SQL
done

cat $SQL
