CREATE DATABASE splunk-db;
USE splunk-db;
GRANT ALL PRIVILEGES ON splunk-db.* TO 'splunk'@'localhost';
CREATE TABLE `dc-svc` (
	host VARCHAR(12) NOT NULL,
	app VARCHAR(17) NOT NULL,
	status VARCHAR(2) NOT NULL
);
CREATE TABLE dc (
	dc_name VARCHAR(12) NOT NULL
);
CREATE TABLE `send-receive` (
	sender VARCHAR(13) NOT NULL,
	receiver VARCHAR(13) NOT NULL,
	bytes DECIMAL(38, 0) NOT NULL
);
CREATE TABLE services (
	service_name VARCHAR(17) NOT NULL
);
CREATE TABLE users (
	username VARCHAR(13) NOT NULL
);
CREATE TABLE webmail (
	host VARCHAR(37) NOT NULL,
	status VARCHAR(6) NOT NULL
);
