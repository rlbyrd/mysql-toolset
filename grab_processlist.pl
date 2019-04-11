#!/usr/bin/perl
# Richard L. Byrd, written sometime in the early 2000s and improved bit by bit over the next 20 years
#
# 2016-01-27: While originally written to take a configfile input on the CLI (--configfile=xxxxx.cfg) I've hacked
# that out of this version.  The only CLI parameteres required are host, username, password.  Hardcoded warning to
# 70% and critical to 85%.  Expects dbhost, dbuser, dbpass on the command line in that order.  See below for details.
# This little guy, at periodic intervals, connects to the MySQL instance of your choosing grabs and parses the processlist,
# and sticks that sucker in  wee table for incident diagnosis reference.
#
# It expects the following table to be created on the local MySQL instance:
#
# CREATE TABLE `processlist_audit` (
#   `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
#   `db_host` varchar(128) NOT NULL,
#   `pid` bigint(20) unsigned NOT NULL,
#   `user` varchar(64) NOT NULL,
#   `origin_host` varchar(128) NOT NULL,
#   `db` varchar(64) NOT NULL,
#   `command` varchar(255) DEFAULT NULL,
#   `exec_time` int(11) NOT NULL,
#   `state` varchar(255) NOT NULL DEFAULT '',
#   `info` text DEFAULT NULL,
#   `progress` varchar(32) NOT NULL,
#   `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
#   PRIMARY KEY (`id`),
#   KEY `idx_user` (`user`),
#   KEY `idx_db` (`db`),
#   KEY `idx_created` (`created_at`),
#   KEY `idx_pid` (`pid`)
# ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

$DBHOST=$ARGV[0];
$DBUSER=$ARGV[1];
$DBPASS=$ARGV[2];



while ( 1 == 1 ) {

system("sshpass -p$DBPASS mysql -u$DBUSER -p -h$DBHOST -B -e'show full processlist;' | egrep -v 'Sleep|Progress|rdsrepladmin|processlist' >/tmp/plist.txt");

open(PLIST, "/tmp/plist.txt") || die "Error: $!\n";
@lines = <PLIST>;

open($PSQL, ">/tmp/plist.sql") || die "Error: $!\n";

foreach $line (@lines) {
	chomp($line);
	($pid,$user,$origin_host,$db,$command,$exec_time,$state,$info,$progress)=split("\t",$line);
	$info=~s/"/'/g;
	$insert="INSERT INTO dbaudit.processlist_audit (db_host,pid,user,origin_host,db,command,exec_time,state,info,progress) VALUES (\"production\",\"$pid\",\"$user\",\"$origin_host\",\"$db\",\"$command\",\"$exec_time\",\"$state\",\"$info\",\"$progress\");";
	
	print $PSQL "$insert\n";

}

close $PSQL;

system("sshpass -p$DBPASS mysql -u$DBUSER -p -hlocalhost < /tmp/plist.sql");

unlink "/tmp/plist.txt";
unlink "/tmp/plisit.sql";

sleep 20;

}

