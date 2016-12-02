#!/bin/bash

if [ "$PORT" == "" ]; then
  PORT=27017
fi

mongo admin --port $PORT --eval "help" > /dev/null 2>&1
RET=$?

if [ RET == 0 ]; then
  echo "Mongod already running on this port"
else
  echo "Removing Mongo lock file"
  rm /data/db/mongod.lock
  rm /data/db/WiredTiger.lock
  rm /data/configdb/mongod.lock
  rm /data/configdb/WiredTiger.lock
fi