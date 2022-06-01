#!/bin/bash
APP=${PWD##*/} 
APP_FILE=${APP}.spl
APP_LOCATION=/tmp/${APP_FILE}
source .env
echo "Creating ${APP_FILE}"
tar --disable-copyfile -cf ${APP_FILE} -s /^app/$APP/ app/*
echo "Uploading ${APP_FILE} ..."
docker cp $APP_FILE so1:$APP_LOCATION
echo "Asking Splunk to remove old ${APP} ..."
curl -s -X DELETE -k -u admin:$SPLUNK_PASSWORD https://$SPLUNK_HOST:8089/services/apps/local/$APP
echo "Asking Splunk to install ${APP_FILE} ..."
curl -s -X POST -k -u admin:$SPLUNK_PASSWORD https://$SPLUNK_HOST:8089/services/apps/local \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d "name=${APP_LOCATION}&update=True&filename=True"
echo "Restaritng"
curl -s -X POST -k -u admin:$SPLUNK_PASSWORD https://$SPLUNK_HOST:8089/services/server/control/restart 
echo "Done."
#