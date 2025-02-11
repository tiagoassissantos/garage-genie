#!/bin/bash
service postgresql start
# Wait until Postgres is ready
until pg_isready -q; do
  echo "Waiting for Postgres..."
  sleep 1
done
psql -c "ALTER USER postgres PASSWORD 'postgres';"
#service postgresql stop