#!/bin/bash

now=`date +"%Y%m%d-%H%M%S"`
logfile=`echo optimize_table_${now}.log`

exec > >(tee -a ${logfile} ) 2>&1

# This next if block should be changed to be a simple 'which pt-online-schema-change' or a 
# 'locate pt-online-schema-change' instead of the dumb version below

if [ -x "/usr/bin/pt-online-schema-change" ]
then
	cmd="/usr/bin/pt-online-schema-change"
elif [ -x "/opt/mysql/pt/bin/pt-online-schema-change" ]
then
	cmd="/opt/mysql/pt/bin/pt-online-schema-change"
else
	cmd=""
fi

if [ "${cmd}" == "" ]
then
	echo " "
	echo "The pt-online-schema-change executable is not available.  Please ensure it exists either in /usr/bin or /opt/mysql/pt/bin."
	echo " "
	exit 1
fi

if [ "$2" == "" ]
then
	echo " "
	echo "optimize_table: Securely optimize MySQL tables."
	echo " "
	echo "USAGE:"
#	echo "optimize_table <table> <otherParam1> <otherParam2> ... <otherParam6>"
	echo "optimize_table <max_rows> <fragmentation_threshhold>"
	echo " "
#	echo "Schema is optional; the first two parameters are requred."
	echo " "
	exit 2
fi

#table_to_optimize="$1"
#other_params="$2 $3 $4 $5 $6 $7"

max_rows="$1"
frag_pct="$2"

counter=0

qry="SELECT   CONCAT_WS(     '|',     table_schema,     TABLE_NAME,     table_rows,     DATA_LENGTH,     INDEX_LENGTH,     DATA_FREE,     (       ROUND(         data_free / (data_length + index_length) * 100,         1       )     )    ),ROUND(         data_free / (data_length + index_length) * 100,         1) frag_pct,data_length+index_length totsize FROM   information_schema.tables WHERE data_length + index_length > 0   AND DATA_FREE > 0   AND table_schema NOT IN (     'mysql',     'information_schema',     'performance_schema'   ) AND (ROUND(data_free / (data_length + index_length) * 100,1))>=${frag_pct} AND table_rows < ${max_rows} ORDER BY frag_pct DESC,   table_schema,   table_name;  "
alltables=`mysql -B -N -hlocalhost -e"$qry"  | cut -f1`

while read -r row 
do
	counter=$((counter+1))
#	echo $counter
	schema[$counter]=`echo $row | cut -f1 -d"|"`
	table[$counter]=`echo $row | cut -f2 -d"|"`
	numrows[$counter]=`echo $row | cut -f4 -d"|"`
	fragpct[$counter]=`echo $row | cut -f7 -d"|"`
	totsize[$counter]=`echo $row | cut -f8 -d"|"`
	
done <<< "$alltables"


echo " "
echo "----------------------------------------------------------------------------------------"
echo "List of tables to be defragmented using these parameters:"
echo "Max rows: ${max_rows}, Fragmentation threshold: ${frag_pct}%"
echo "----------------------------------------------------------------------------------------"

#echo  $counter


if [ "${schema[1]}" == "" ]
then
	echo "No tables meet the criteria."
	echo " "
	exit 0
fi


for ((cnt=1; cnt <= $counter ; cnt++))
do
	echo "${schema[${cnt}]}.${table[${cnt}]} (${numrows[${cnt}]} rows, ${fragpct[${cnt}]}%) ${totsize[${cnt}]} total bytes"
done

echo "----------------------------------------------------------------------------------------"
echo "Strike [RETURN] to proceed or ctrl-C to break"
head -1


for ((cnt=1; cnt <= $counter ; cnt++))
do
	to_execute="${cmd} --chunk-time=5 --progress=time,5 --alter-foreign-keys-method=drop_swap --max-load=Threads_connected:500 --execute --alter ENGINE=INNODB D=${schema[${cnt}]},t=${table[${cnt}]},h=localhost"
	$to_execute
	mysql -e "ALTER TABLE ${schema[${cnt}]}.${table[${cnt}]} row_format=Compact;" 
done	
