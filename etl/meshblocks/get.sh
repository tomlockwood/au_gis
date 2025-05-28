set -eu

mkdir -p .tmp

cd .tmp

wget https://www.abs.gov.au/statistics/standards/australian-statistical-geography-standard-asgs-edition-3/jul2021-jun2026/access-and-downloads/digital-boundary-files/MB_2021_AUST_SHP_GDA2020.zip

unzip -o MB_2021_AUST_SHP_GDA2020.zip

# The shapefile name convention is not consistent so every new
# zip may need a new name here.
shp2pgsql -D -d -I MB_2021_AUST_GDA2020.shp all_meshblocks > meshblock.sql
