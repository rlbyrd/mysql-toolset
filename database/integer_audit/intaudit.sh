#!/bin/bash
# does a maxvalue for integers audit on the server specified in $1
# expects tables to exist in dbaudit schemata as specified in the inmax_create_script.sql

# Preferred login creds
DBUSER="xxxxx"
DBPASS="yyyyy"

# Make sure the hallway is clean

/bin/rm /tmp/ia_*


# Default to stage if no host given
AUDITHOST="${1}"

if [ "${AUDITHOST}" == "" ]
then
	AUDITHOST="stage-db"
fi



echo "TRUNCATE TABLE dbaudit.intaudit;" > /tmp/ia_insert.sql

FILENAME="/tmp/ia_audit.sql"
(

#read -r -d '' getints_sql <<EOF
cat <<-EOF
SELECT
  CONCAT ("INSERT INTO dbaudit.intaudit (table_schema,table_name,column_name,data_type,column_type,is_nullable,extra) VALUES ('",
  table_schema,
  "','",
  table_name,
  "','",
  column_name,
  "','",
  data_type,
  "','",
  column_type,
  "','",
  is_nullable,
  "','",
  extra,
  "');") FROM information_schema.columns WHERE data_type LIKE "%int" AND table_schema NOT IN ("mysql","performance_schema","information_schema") 
  ORDER BY table_schema,
  table_name,
  data_type,
  column_name;
EOF
) > $FILENAME




#echo ${getints_sql} > /tmp/ia_audit.sql


cat /tmp/ia_audit.sql | sshpass -p $DBPASS mysql -h$AUDITHOST -u$DBUSER -N -B -p >>/tmp/ia_insert.sql

cat /tmp/ia_insert.sql|sshpass -p $DBPASS mysql -h127.0.0.1 -u$DBUSER dbaudit -p

### All integer columns for instance are now in the dbaudit.intaudit table.
### Update maxvals for each column

FILENAME="/tmp/ia_maxval.sql"
(
cat <<-EOF
UPDATE
  intaudit i
  INNER JOIN intmax m
    ON i.data_type = m.data_type
    AND i.is_signed = m.is_signed SET i.maxval = m.maxval;
EOF
) > $FILENAME

cat /tmp/ia_maxval.sql|sshpass -p $DBPASS mysql -h127.0.0.1 -u$DBUSER dbaudit -p

### Now to traverse and collect current maximum values in use

FILENAME="/tmp/ia_local.sql"
(
cat <<-EOF
SELECT CONCAT(intaudit_id,"|SELECT MAX(\`",column_name,"\`) FROM \`",table_schema,"\`.\`",table_name,"\`;") stmnt FROM intaudit;
EOF
) > $FILENAME


cat /tmp/ia_local.sql|sshpass -p $DBPASS mysql -N -B -h127.0.0.1 -u$DBUSER dbaudit -p > /tmp/ia_remote.sql

echo "Pausing...edit /tmp/ia_remote.sql for changes."
head -1


while read STMT
do
#	echo "[ $STMT ]"
	THISID=`echo "$STMT" | cut -f1 -d'|'`
	THISSTMT=`echo "$STMT" | cut -f2 -d'|'`
	echo "$THISID *** $THISSTMT"
	THISMAXVAL=`echo "${THISSTMT}" | sshpass -p $DBPASS mysql -N -B -h$AUDITHOST -u$DBUSER -p` 
	UPDATESTMT="UPDATE dbaudit.intaudit set currentmaxval=${THISMAXVAL} WHERE intaudit_id=$THISID;"
	echo "$UPDATESTMT" >> /tmp/ia_localupdate.sql
done < /tmp/ia_remote.sql

### Now, update the local reference table

cat /tmp/ia_localupdate.sql | sshpass -p $DBPASS mysql -N -B -h127.0.0.1 -u$DBUSER dbaudit -p












