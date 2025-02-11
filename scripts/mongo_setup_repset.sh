#!/bin/bash

echo "************************************************************"
echo "Setting up replica set"
echo "************************************************************"

if [ "$PORT" == "" ]; then
  PORT=27017
fi

mongo admin --port $PORT --eval "help" > /dev/null 2>&1
RET=$?

while [[ RET -ne 0 ]]; do
  echo "Waiting for MongoDB to start..."
  mongo admin --port $PORT --eval "help" > /dev/null 2>&1
  RET=$?
  sleep 1
done

# configure replica set
credentials="-u $MONGO_ROOT_USER -p $MONGO_ROOT_PASSWORD"
if [ "$NO_AUTH" == "true" ]; then
  credentials=""
fi

mongo admin --port $PORT $credentials --eval "rs.initiate($MONGO_CONF_REPSET);"
RSSTATUS=$(mongo admin --port $PORT $credentials --eval "rs.status().ok")
RET=$(echo "$RSSTATUS" | sed -n 3p)

while [ "$RET" != "1" ]; do
  echo "Waiting for MongoDB cluster to be initiated..."
  sleep 1
  mongo admin --port $PORT $credentials --eval "rs.initiate($MONGO_CONF_REPSET);"
  RSSTATUS=$(mongo admin --port $PORT $credentials --eval "rs.status().ok")
  RET=$(echo "$RSSTATUS" | sed -n 3p)
done