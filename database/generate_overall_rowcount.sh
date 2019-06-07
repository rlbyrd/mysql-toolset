
#SCHEMA="${2}"

STARTIME=`date`

echo "Starting rowcount update at $STARTIME"

# fivetran database
DBASE="fivetran"
SCHEMALIST="greenhouse hubspot jira mandrill marketo"
# Truncate rollup table
echo "Deleting from rollup table for ${DBASE}  schema..."
PGPASSWORD=xxxxxxxxxxxxxxxxxx psql -t -h  redshiftFQDN -p 5439 -Uexampleroot -d${DBASE} -n -q -c "TRUNCATE TABLE admin.overall_rowcount;"


# Iterate through schemata
for SCHEMA in ${SCHEMALIST}
do

	TABLES=`PGPASSWORD=xxxxxxxxxxxxxxxxxx psql -t -h  redshiftFQDN -p 5439 -Uexampleroot -d${DBASE} -n -q -c "select table_name from information_schema.tables where table_schema='${SCHEMA}' and table_type='BASE TABLE' ORDER BY table_name;"`

	for TAB in $TABLES
	do
		echo ">>> Working on ${DBASE}.${SCHEMA}.${TAB}..."

		TABLINE=`PGPASSWORD=xxxxxxxxxxxxxxxxxx psql -t -h  redshiftFQDN -p 5439 -Uexampleroot -n -q -d${DBASE} -c "insert into admin.overall_rowcount select '${SCHEMA}','$TAB',count(*) from ${SCHEMA}.${TAB}"`
	done
done
echo "*** All done with database ${DBASE}."



# eng_metrics database
DBASE="eng_metrics"
SCHEMALIST="jira"
# Truncate rollup table
echo "Deleting from rollup table for ${DBASE}  schema..."
PGPASSWORD=xxxxxxxxxxxxxxxxxx psql -t -h  redshiftFQDN -p 5439 -Uexampleroot -d${DBASE} -n -q -c "TRUNCATE TABLE admin.overall_rowcount;"

# Iterate through schemata
for SCHEMA in ${SCHEMALIST}
do
	TABLES=`PGPASSWORD=xxxxxxxxxxxxxxxxxx psql -t -h  redshiftFQDN -p 5439 -Uexampleroot -d${DBASE} -n -q -c "select table_name from information_schema.tables where table_schema='${SCHEMA}' and table_type='BASE TABLE' ORDER BY table_name;"`

	for TAB in $TABLES
	do
		echo ">>> Working on ${DBASE}.${SCHEMA}.${TAB}..."

		TABLINE=`PGPASSWORD=xxxxxxxxxxxxxxxxxx psql -t -h  redshiftFQDN -p 5439 -Uexampleroot -n -q -d${DBASE} -c "insert into admin.overall_rowcount select '${SCHEMA}','$TAB',count(*) from ${SCHEMA}.${TAB}"`
	done
done
echo "*** All done with database ${DBASE}."




# warehouse database
DBASE="warehouse"

SCHEMALIST="adwords_master adwords_owner aircall analysis_ready bing_ads common data_staging etl_testing facebook_ads finance google_adwords google_analytics high_risk housekeeping hubspot looker mailing marketo owner_portal_prod phones property_nexus prospect public rates reporting reporting_prod s3_files secure secure_scrubbed segment segment_marketo split_io_production splitio example example_gps_service example_prod example_units_svc_prod"
# Truncate rollup table
echo "Deleting from rollup table for ${DBASE}  schema..."
PGPASSWORD=xxxxxxxxxxxxxxxxxx psql -t -h  redshiftFQDN -p 5439 -Uexampleroot -d${DBASE} -n -q -c "TRUNCATE TABLE admin.overall_rowcount;"

# Iterate through schemata
for SCHEMA in ${SCHEMALIST}
do

	TABLES=`PGPASSWORD=xxxxxxxxxxxxxxxxxx psql -t -h  redshiftFQDN -p 5439 -Uexampleroot -d${DBASE} -n -q -c "select table_name from information_schema.tables where table_schema='${SCHEMA}' and table_type='BASE TABLE' ORDER BY table_name;"`

	for TAB in $TABLES
	do
		echo ">>> Working on ${DBASE}.${SCHEMA}.${TAB}..."

		TABLINE=`PGPASSWORD=xxxxxxxxxxxxxxxxxx psql -t -h  redshiftFQDN -p 5439 -Uexampleroot -n -q -d${DBASE} -c "insert into admin.overall_rowcount select '${SCHEMA}','$TAB',count(*) from ${SCHEMA}.${TAB}"`
	done
done
echo "*** All done with database ${DBASE}."

ENDTIME=`date`

echo "All done with every damned thing."
echo "Startime was: $STARTIME"
echo "Endtime was : $ENDTIME"




