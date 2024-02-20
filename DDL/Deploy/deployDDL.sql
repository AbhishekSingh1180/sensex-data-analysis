CREATE DATABASE IF NOT EXISTS FINANCE_DB; --DATABASE
CREATE SCHEMA IF NOT EXISTS FINANCE_DB.DW_APPL; --APPLICATION SCHEMA
CREATE SCHEMA IF NOT EXISTS FINANCE_DB.DW_STAGE; --STAGE SCHEMA
CREATE SCHEMA IF NOT EXISTS FINANCE_DB.DW_TGT; --FINAL SCHEMA


CREATE STAGE IF NOT EXISTS FINANCE_DB.DW_APPL.SENSEX_API_DATA_STAGE; --STAGE FOR SENSEX CSV

CREATE TABLE IF NOT EXISTS FINANCE_DB.DW_STAGE.SENSEX_STAGE_DATA -- STAGE TABLE TO COLLECT RAW DATA
(   
    TIMESTAMP varchar,
    OPEN varchar,
    CLOSE varchar,
    HIGH varchar,
    LOW varchar,
    VOLUME varchar
);

CREATE STREAM IF NOT EXISTS FINANCE_DB.DW_APPL.SENSEX_STAGE_DATA_STREAM ON TABLE FINANCE_DB.DW_STAGE.SENSEX_STAGE_DATA APPEND_ONLY = TRUE;

CREATE TABLE IF NOT EXISTS FINANCE_DB.DW_TGT.SENSEX_DATA -- TARGET TABLE
(
    INDEX varchar(6) default 'Sensex',
    SYMBOL varchar(6) default '^BSESN',
    TIMESTAMP TIMESTAMP_NTZ(9),
    OPEN NUMBER(10,2),
    CLOSE NUMBER(10,2),
    HIGH NUMBER(10,2),
    LOW NUMBER(10,2),
    VOLUME NUMBER(10)
);
-- deploy test 1