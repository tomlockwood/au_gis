\echo '***CREATE VIEW***'

DROP MATERIALIZED VIEW IF EXISTS ADDRESS_VIEW CASCADE;

CREATE MATERIALIZED VIEW ADDRESS_VIEW AS
SELECT
AD.ADDRESS_DETAIL_PID as ADDRESS_DETAIL_PID,
AMB.MB_2021_PID as MB_2021_PID,
AD.STREET_LOCALITY_PID as STREET_LOCALITY_PID,
AD.LOCALITY_PID as LOCALITY_PID,
AD.BUILDING_NAME as BUILDING_NAME,
AD.LOT_NUMBER_PREFIX as LOT_NUMBER_PREFIX,
AD.LOT_NUMBER as LOT_NUMBER,
AD.LOT_NUMBER_SUFFIX as LOT_NUMBER_SUFFIX,
FTA.NAME as FLAT_TYPE,
AD.FLAT_NUMBER_PREFIX as FLAT_NUMBER_PREFIX,
AD.FLAT_NUMBER as FLAT_NUMBER,
AD.FLAT_NUMBER_SUFFIX as FLAT_NUMBER_SUFFIX,
LTA.NAME as LEVEL_TYPE,
AD.LEVEL_NUMBER_PREFIX as LEVEL_NUMBER_PREFIX,
AD.LEVEL_NUMBER as LEVEL_NUMBER,
AD.LEVEL_NUMBER_SUFFIX as LEVEL_NUMBER_SUFFIX,
AD.NUMBER_FIRST_PREFIX as NUMBER_FIRST_PREFIX,
AD.NUMBER_FIRST as NUMBER_FIRST,
AD.NUMBER_FIRST_SUFFIX as NUMBER_FIRST_SUFFIX,
AD.NUMBER_LAST_PREFIX as NUMBER_LAST_PREFIX,
AD.NUMBER_LAST as NUMBER_LAST,
AD.NUMBER_LAST_SUFFIX as NUMBER_LAST_SUFFIX,
SL.STREET_NAME as STREET_NAME,
SL.STREET_CLASS_CODE as STREET_CLASS_CODE,
SCA.NAME as STREET_CLASS_TYPE,
SL.STREET_TYPE_CODE as STREET_TYPE_CODE,
SL.STREET_SUFFIX_CODE as STREET_SUFFIX_CODE,
SSA.NAME as STREET_SUFFIX_TYPE,
L.LOCALITY_NAME as LOCALITY_NAME,
ST.STATE_ABBREVIATION as STATE_ABBREVIATION,
AD.POSTCODE as POSTCODE,
ADG.LATITUDE as LATITUDE,
ADG.LONGITUDE as LONGITUDE,
GTA.NAME as GEOCODE_TYPE,
AD.CONFIDENCE as CONFIDENCE,
AD.ALIAS_PRINCIPAL as ALIAS_PRINCIPAL,
AD.PRIMARY_SECONDARY as PRIMARY_SECONDARY,
AD.LEGAL_PARCEL_ID as LEGAL_PARCEL_ID,
AD.DATE_CREATED as DATE_CREATED,
ROW_NUMBER() OVER (
ORDER BY STREET_NAME, STREET_TYPE_CODE, NUMBER_FIRST_PREFIX NULLS FIRST, NUMBER_FIRST NULLS FIRST, NUMBER_FIRST_SUFFIX NULLS FIRST, NUMBER_LAST_PREFIX NULLS FIRST, NUMBER_LAST NULLS FIRST, NUMBER_LAST_SUFFIX NULLS FIRST, FLAT_NUMBER_PREFIX NULLS FIRST, FLAT_NUMBER NULLS FIRST, FLAT_NUMBER_SUFFIX NULLS FIRST
) as ADDR_ORDER
FROM
ADDRESS_DETAIL AD 
LEFT JOIN FLAT_TYPE_AUT FTA ON AD.FLAT_TYPE_CODE=FTA.CODE
LEFT JOIN LEVEL_TYPE_AUT LTA ON AD.LEVEL_TYPE_CODE=LTA.CODE
JOIN STREET_LOCALITY SL ON AD.STREET_LOCALITY_PID=SL.STREET_LOCALITY_PID
LEFT JOIN STREET_SUFFIX_AUT SSA ON SL.STREET_SUFFIX_CODE=SSA.CODE
LEFT JOIN STREET_CLASS_AUT SCA ON SL.STREET_CLASS_CODE=SCA.CODE 
LEFT JOIN STREET_TYPE_AUT STA ON SL.STREET_TYPE_CODE=STA.CODE
JOIN LOCALITY L ON AD.LOCALITY_PID = L.LOCALITY_PID
JOIN ADDRESS_DEFAULT_GEOCODE ADG ON AD.ADDRESS_DETAIL_PID=ADG.ADDRESS_DETAIL_PID
LEFT JOIN GEOCODE_TYPE_AUT GTA ON ADG.GEOCODE_TYPE_CODE=GTA.CODE
LEFT JOIN GEOCODED_LEVEL_TYPE_AUT GLTA ON AD.LEVEL_GEOCODED_CODE=GLTA.CODE
JOIN STATE ST ON L.STATE_PID=ST.STATE_PID
LEFT JOIN ADDRESS_MESH_BLOCK_2021 AMB ON AD.ADDRESS_DETAIL_PID=AMB.ADDRESS_DETAIL_PID
WHERE 
AD.CONFIDENCE > -1 AND NUMBER_FIRST IS NOT NULL;

\echo '***CREATE ADDRESS STRING FUNCTION***'

CREATE OR REPLACE FUNCTION format_address(adv address_view) 
RETURNS TABLE(suburb_str text, street_str text, building_str text, number_str text, address_str text) AS $$
DECLARE
	number_str text;
	building_str text;
	street_str text;
	suburb_str text;
	address_str text;
BEGIN
	number_str = '';
	building_str = '';
	street_str = '';
	suburb_str = '';
	address_str = '';

	IF adv.flat_type IS NOT NULL THEN number_str = number_str || adv.flat_type || ' '; END IF;

	IF adv.flat_number_prefix IS NOT NULL THEN number_str = number_str || adv.flat_number_prefix; END IF;
	IF adv.flat_number IS NOT NULL THEN number_str = number_str || adv.flat_number; END IF;
	IF adv.flat_number_suffix IS NOT NULL THEN number_str = number_str || adv.flat_number_suffix; END IF;
	IF adv.flat_number IS NOT NULL THEN number_str = number_str || ' / '; END IF;

	IF adv.level_type IS NOT NULL THEN number_str = number_str || adv.level_type || ' '; END IF;

	IF adv.level_number_prefix IS NOT NULL THEN number_str = number_str || adv.level_number_prefix; END IF;
	IF adv.level_number IS NOT NULL THEN number_str = number_str || adv.level_number || ', '; END IF;
	IF adv.level_number_suffix IS NOT NULL THEN number_str = number_str || adv.level_number_suffix; END IF;

	IF adv.number_first_prefix IS NOT NULL THEN building_str = building_str || adv.number_first_prefix; END IF;
	IF adv.number_first IS NOT NULL THEN building_str = building_str || adv.number_first; END IF;
	IF adv.number_first_suffix IS NOT NULL THEN building_str = building_str || adv.number_first_suffix; END IF;

	IF adv.number_last IS NOT NULL THEN building_str = building_str || '-'; END IF;	
	IF adv.number_last_prefix IS NOT NULL THEN building_str = building_str || adv.number_last_prefix; END IF;
	IF adv.number_last IS NOT NULL THEN building_str = building_str || adv.number_last; END IF;
	IF adv.number_last_suffix IS NOT NULL THEN building_str = building_str || adv.number_last_suffix; END IF;

	number_str = number_str || building_str;

	IF adv.street_name IS NOT NULL THEN street_str = street_str || adv.street_name || ' '; END IF;
	IF adv.street_type_code IS NOT NULL THEN street_str = street_str || adv.street_type_code; END IF;
	IF adv.street_suffix_type IS NOT NULL THEN street_str = street_str || ' ' || adv.street_suffix_type; END IF;

	IF adv.locality_name IS NOT NULL THEN suburb_str = suburb_str || adv.locality_name || ' '; END IF;
	IF adv.state_abbreviation IS NOT NULL THEN suburb_str = suburb_str || adv.state_abbreviation || ', '; END IF;
	IF adv.postcode IS NOT NULL THEN suburb_str = suburb_str || adv.postcode; END IF;

	IF number_str != '' THEN address_str = number_str || ' '; END IF;
	IF street_str != '' THEN address_str = address_str || street_str || ', '; END IF;
	IF suburb_str != '' THEN address_str = address_str || suburb_str; END IF;

	RETURN QUERY
	SELECT suburb_str, street_str, building_str, number_str, address_str;
END;
$$ LANGUAGE plpgsql;

DROP TABLE IF EXISTS address_lookup CASCADE;

CREATE TABLE address_lookup (
    longitude numeric(11,8),
    latitude numeric(10,8),
	meshblock varchar(15),
    address_detail_pid varchar(15),
    addr_order int,
    suburb_str varchar(250),
    street_str varchar(250),
    building_str varchar(250),
    number_str varchar(250),
    address_str varchar(1000)
);

INSERT INTO address_lookup (longitude, latitude, meshblock, address_detail_pid,
addr_order, suburb_str, street_str, building_str, number_str, address_str)
SELECT av.longitude, av.latitude, av.mb_2021_pid, av.address_detail_pid, 
av.addr_order, (format_address(av.*)).* 
FROM address_view av;

CREATE INDEX ON address_lookup USING GIST 
(ST_Makepoint(longitude,latitude));

CREATE INDEX ON address_lookup (meshblock);

CREATE OR REPLACE FUNCTION doors(swlng numeric,swlat numeric,nelng numeric,nelat numeric) 
RETURNS TABLE(
    longitude numeric(11,8),
    latitude numeric(10,8),
	meshblock varchar(15),
    address_detail_pid varchar(15),
    addr_order int,
    suburb_str varchar(250),
    street_str varchar(250),
    building_str varchar(250),
    number_str varchar(250),
    address_str varchar(1000)
) AS
$$ SELECT * FROM address_lookup al
WHERE ST_MakeEnvelope($1,$2,$3,$4) ~ ST_MakePoint(al.longitude, al.latitude)
$$ LANGUAGE SQL SECURITY DEFINER;