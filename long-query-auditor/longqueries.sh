#################################################################################
#
# Hacked together sometime in the early 2000s by RLB
# Enhanced and refactored, oh, about 100 times since then.
# It ain't elegant nor is it particularly graceful, but it works.
#
#################################################################################

instance=$1
maxtime=$2
action=$3

if [ "$maxtime" == "" ]; then
	echo -e "Usage: \n  longqueries.sh <fqdn> <maxtime> <action>\n\n  If action is blank, return a list.  If action is "kill", kill long queries."
	exit 0
fi

mysql -h${instance} -B -e"show processlist" | grep Query | egrep -v SQL_NO_CACHE | cut -f1,6,7,8,3 -s | sed 's/*/xx/g' >chklongs
chklongs=$(cat chklongs)

killcount=0

while read chk; do
	thisid=$(echo "$chk" | awk 'BEGIN {FS="\t"};{print $1}')
	thisrt=$(echo "$chk" | awk 'BEGIN {FS="\t"};{print $3}')
	thisstat=$(echo "$chk" | awk 'BEGIN {FS="\t"};{print $4}')
	thisq=$(echo "$chk" | awk 'BEGIN {FS="\t"};{print $5}')
	thish1=$(echo "$chk" | awk 'BEGIN {FS="\t"};{print $2}')
	thishost=$(echo "$thish1" | cut -f1 -d".")

	if [ "$thisrt" -gt "$maxtime" ]; then
		echo "$thisid | $thisrt | $thishost | $thisstat | $thisq "
		if [ "$action" == "kill" ]; then
			echo "Killing: $thisid "
			logline=$(echo "$thisid ($thisrt secs): $thisq")
			mysql -h${instance} -e"kill $thisid;"
			fulllog=$(echo "$fulllog\n$logline")
		fi
	fi
done <chklongs

if [ "$action" == "kill" ]; then
	echo "--------------------------------------------------" >>/var/log/longqueries.log
	date >>/var/log/longqueries.log

	echo -e "$fulllog" >>/var/log/longqueries.log
fi
exit

for chk in $chklongs; do
	echo "[ $chk ]"
	thisid=$(echo $chk | cut -f1 -d" ")
	thisrt=$(echo $chk | cut -f2)
done
exit

mysql -h${instance} -B -e"show processlist" | grep Sleep | cut -f1 -s >/tmp/plist.tmp

procs=$(cat /tmp/plist.tmp)

for i in $procs; do
	echo "$thishost: $i"
	mysql -h${instance} -e"kill $i;"
done
