#!/bin/bash
# wait-for-postgres.sh
RETRIES=5

until psql -l > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do 
  echo "Waiting for postgres server to start, $((RETRIES)) remaining attempts..." RETRIES=$((RETRIES-=1)) 
  sleep 1 
done