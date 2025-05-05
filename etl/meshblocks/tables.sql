DROP TABLE IF EXISTS meshblocks;

CREATE TABLE meshblocks (
    id varchar(11) PRIMARY KEY,
    category varchar(30),
    sa1_id varchar(11),
    geom geometry,
    geom_json json
);

INSERT INTO meshblocks (id, category, sa1_id, geom) SELECT mb_code21, mb_cat21, sa1_code21, geom FROM all_meshblocks;

UPDATE meshblocks SET geom_json = ST_AsGeoJSON(subquery.*, maxdecimaldigits => 6, id_column => 'id')::json
FROM (SELECT id, category, sa1_id, geom FROM meshblocks) as subquery
WHERE meshblocks.id = subquery.id;

CREATE INDEX ON meshblocks USING GIST (geom);