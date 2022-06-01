CREATE DATABASE mydb;
USE mydb;
GRANT ALL PRIVILEGES ON mydb.* TO 'splunk'@'localhost';

CREATE TABLE mytable
(
id INTEGER AUTO_INCREMENT,
name TEXT,
PRIMARY KEY (id)
) COMMENT='this is my test table';
