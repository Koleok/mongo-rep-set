#!/bin/bash

if [ "$PORT" == "" ]; then
  PORT=27017
fi

credentials="-u $MONGO_ROOT_USER -p $MONGO_ROOT_PASSWORD"
if [ "$NO_AUTH" == "true" ]; then
  credentials=""
fi

RSSTATUS=$(mongo admin --port $PORT $credentials --eval "rs.status().ok")
RET=$(echo "$RSSTATUS" | sed -n 3p)

while [ "$RET" != "1" ]; do
  echo "Waiting for MongoDB cluster to be initiated..."

  RSSTATE=$(mongo admin --port $PORT $credentials --eval "rs.status().stateStr")
  RET2=$(echo "$RSSTATE" | sed -n 3p)
  echo $RET2
  if [ "$RET2" == "REMOVED"  ]; then
    echo "Waiting for MongoDB cluster to be reconfigured..."
    mongo admin --port $PORT $credentials --eval "rs.reconfig(rs.conf(), {force: true})"
  fi

  sleep 1
  RSSTATUS=$(mongo admin --port $PORT $credentials --eval "rs.status().ok")
  RET=$(echo "$RSSTATUS" | sed -n 3p)
done