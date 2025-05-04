DROP TABLE IF EXISTS meshblocks;

CREATE TABLE meshblocks (
    id varchar(11),
    category varchar(30),
    sa1_id varchar(11),
    geom geometry,
    geom_json json GENERATED ALWAYS AS (ST_AsGeoJSON(geom, 6)::json) STORED
);

INSERT INTO meshblocks (id, category, sa1_id, geom) SELECT mb_code21, mb_cat21, sa1_code21, geom FROM all_meshblocks;

CREATE INDEX ON meshblocks USING GIST (geom);