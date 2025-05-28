set -eu

CURRENT_URL="https://data.gov.au/data/dataset/19432f89-dc3a-4ef3-b943-5326ef1dbecc/resource/33b7d2a1-a246-4853-beb9-167699bfa91c/download/g-naf_feb25_allstates_gda2020_psv_1018.zip"

mkdir -p .tmp

cd .tmp

if [ ! -f gnaf.zip ]; then
    wget -O gnaf.zip $CURRENT_URL
fi

unzip -o gnaf.zip

mv G-NAF/Extras/GNAF_TableCreation_Scripts/create_tables_ansi.sql tables.sql
mv G-NAF/Extras/GNAF_TableCreation_Scripts/add_fk_constraints.sql fk.sql

mkdir -p authority_code

mv G-NAF/G-NAF\ FEBRUARY\ 2025/Authority\ Code/* authority_code/

mkdir -p standard

mv G-NAF/G-NAF\ FEBRUARY\ 2025/Standard/* standard/