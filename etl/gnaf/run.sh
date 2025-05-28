set -eu

DB_USER=$1
DB_PASS=$2

CONNSTR="postgresql://$DB_USER:$DB_PASS@0.0.0.0:1234/postgres"

# sh get.sh

# python copy_sql.py > .tmp/copy.sql

# psql $CONNSTR < drop_tables.sql

# psql $CONNSTR < .tmp/tables.sql
# psql $CONNSTR < .tmp/copy.sql
# psql $CONNSTR < .tmp/fk.sql

psql $CONNSTR < gnaf_transforms.sql