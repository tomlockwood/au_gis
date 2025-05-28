set -eu

DB_USER=$1
DB_PASS=$2

sh setup.sh

cd ./meshblocks
sh run.sh $DB_USER $DB_PASS
cd ..

