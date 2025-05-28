set -eu

DB_USER=$1
DB_PASS=$2

CONNSTR="postgresql://$DB_USER:$DB_PASS@0.0.0.0:1234/postgres"

sh get.sh

psql $CONNSTR < tables.sql
psql $CONNSTR < .tmp/meshblock.sql

