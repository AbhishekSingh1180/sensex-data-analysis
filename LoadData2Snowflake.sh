# Snowflake connection parameters
SNF_DATABASE="FINANCE_DB"
SNF_STAGE_SCHEMA="DW_STAGE"
SNF_APPL_SCHEMA="DW_APPL"
SNF_TGT_SCHEMA="DW_TGT"
SNF_STAGE="SENSEX_API_DATA_STAGE"
SNF_STAGE_TABLE_STREAM="SENSEX_STAGE_DATA_STREAM" 
SNF_STAGE_TABLE="SENSEX_STAGE_DATA"
SNF_TGT_TABLE="SENSEX_DATA"

# SNF_ACCOUNT="$1"
# SNF_USERNAME="$2"
# SNF_PASSWORD="$3"
# SNF_WAREHOUSE="COMPUTE_WH"

FILE_PATH=$(find data -maxdepth 1 -type f)

EXECUTE_SQL_SCRIPT="execute.sql" 

#UPLOAD FILE FROM LOCAL DIR TO SNOWFLAKE STAGE
echo "PUT file://$FILE_PATH @$SNF_DATABASE.$SNF_APPL_SCHEMA.$SNF_STAGE;" > $EXECUTE_SQL_SCRIPT

#COPY FILE FROM SNOWFLAKE STAGE TO STAGE TABLE
echo "COPY INTO $SNF_DATABASE.$SNF_STAGE_SCHEMA.$SNF_STAGE_TABLE \
FROM @$SNF_DATABASE.$SNF_APPL_SCHEMA.$SNF_STAGE \
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1) ON_ERROR = 'CONTINUE';" \
>> $EXECUTE_SQL_SCRIPT

#LOAD DATA FROM STAGE TABLE TO TGT TABLE
echo "MERGE INTO $SNF_DATABASE.$SNF_TGT_SCHEMA.$SNF_TGT_TABLE TGT \
USING $SNF_DATABASE.$SNF_APPL_SCHEMA.$SNF_STAGE_TABLE_STREAM SRC \
ON TGT.TIMESTAMP = SRC.TIMESTAMP AND \
TGT.OPEN = SRC.OPEN AND \
TGT.CLOSE = SRC.CLOSE AND \
TGT.HIGH = SRC.HIGH AND \
TGT.LOW = SRC.LOW AND \
TGT.VOLUME = SRC.VOLUME \
WHEN NOT MATCHED THEN INSERT VALUES \
('Sensex', '^BSESN', SRC.TIMESTAMP, SRC.OPEN, SRC.CLOSE, SRC.HIGH, SRC.LOW, SRC.VOLUME);" \
>> $EXECUTE_SQL_SCRIPT

#EXECUTE SCRIPT

# ~/bin/snowsql -a $SNF_ACCOUNT -u $SNF_USERNAME --variable db_key=$SNF_PASSWORD -f $EXECUTE_SQL_SCRIPT
# ~/bin/snowsql -f $EXECUTE_SQL_SCRIPT

#CLEAN UP
# rm -rf $EXECUTE_SQL_SCRIPT
# rm -rf data