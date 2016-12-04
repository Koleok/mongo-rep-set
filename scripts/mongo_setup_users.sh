#!/bin/bash

if [ "$PORT" == "" ]; then
  PORT=27017
fi

mongodb_setup_cmd="mongod --port $PORT --storageEngine wiredTiger"

if [ "$CONFIGSERVER" == "true" ]; then
  mongodb_setup_cmd="$mongodb_setup_cmd --configsvr"
fi

$mongodb_setup_cmd &

fg

mongo admin --port $PORT --eval "help" > /dev/null 2>&1
RET=$?

while [[ RET -ne 0 ]]; do
  echo "Waiting for MongoDB to start..."
  mongo admin --port $PORT --eval "help" > /dev/null 2>&1
  RET=$?
  sleep 1
done

echo "************************************************************"
echo "Setting up users..."
echo "************************************************************"

# create root user
mongo admin --port $PORT --eval "db.createUser({user: '$MONGO_ROOT_USER', pwd: '$MONGO_ROOT_PASSWORD', roles:[{ role: 'root', db: 'admin' }]});"

# create oplogger user
mongo admin --port $PORT --eval "db.isMaster();db.createUser({user:'oplogger',pwd:'password',roles:[{role: 'read', db: 'local'}]})"

echo "************************************************************"
echo "Shutting down"
echo "************************************************************"
mongo admin --port $PORT --eval "db.shutdownServer();"

sleep 3
