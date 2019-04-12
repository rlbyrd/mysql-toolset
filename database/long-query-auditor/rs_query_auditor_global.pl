#!/usr/bin/perl 
#
# richard.byrd@vacasa.com
# Dec 2018
# v0.86
#
# This is the Redshift version of the long_queries.sh script for MariaDB.
#
# Assumptions:  
# - The Redshift password is stored in the environment variable PGPASSWORD
# - The warning threshhold in seconds is passed on the command line
# - A psql CLI is in the path
#
# There are multiple iterations of this script; this one sends an email.  One is for command line display, yet another posts to a Slack channel.
#
# THIS IS A DEVELOPING PROJECT.
#
# This version actually emails only the members noted in $ADDRESSLIST below and collates all offending queries into one email.
#
# Suitable for adding to cron every xx minutes.

$ADDRESSLIST="richard.byrd\@vacasa.com,mark.butler\@vacasa.com,devender.kaur\@vacasa.com,chris.ryan=\@vacasa.com";

$NUMSECS=$ARGV[0];

#$TIMERQUERY="select pid, duration/1000000 as seconds, trim(user_name) as user,substring (query,1,200) as querytxt from stv_recents where status = 'Running' and seconds >=NUMSECS order by seconds desc;";
$TIMERQUERY="select pid, duration/1000000 as seconds, trim(user_name) as user,a.username_vc,substring(query,1,400) as querytxt from stv_recents join admin.vacasa_user_map a on a.username_rs=user_name where status = 'Running' and seconds >=NUMSECS and querytxt NOT LIKE '%VACUUM%' and querytxt NOT LIKE '%vacuum%' order by seconds desc;";

$TIMERQUERY=~s/NUMSECS/$NUMSECS/;

#print $TIMERQUERY;
$QUERYLIST=`echo "$TIMERQUERY" | PGPASSWORD=<redacted> psql -h  warehouse.vacasa.services -p 5439 -Uvacasaroot -dwarehouse -q -A -t -R 'XXXXX'`;


@QUERYROWS=split(/XXXXX/,"$QUERYLIST");
$QUERYCOUNT=0;

#    print "CURRENT REDSHIFT QUERIES THAT HAVE BEEN RUNNING FOR > $NUMSECS SECONDS:\n";
#    print "(Format is <RSuser>|<vacasaEmail>|<PID>|<secondsRunning>, then query on next line)\n";
#    print "---------------------------------------------------------------------------------------------------\n";

    $TOTALQUERIES=scalar(@QUERYROWS);
#    print "[$TOTALQUERIES]";

    open ($fh,'>','/tmp/rsemail.tmp');
    print $fh "Warning:  There are $TOTALQUERIES queries executing within the Redshift cluster that have been active for more than $NUMSECS seconds. These may need to be terminated.  Details are below:\n";

foreach (@QUERYROWS) {
    ($PID,$SECS,$USER,$EMAILADDR,$QUERYTEXT)=split(/\|/,"$_");
#    print "$USER|$EMAILADDR\@vacasa.com|$PID|$SECS\n$QUERYTEXT\n\n";
    print $fh "---------------------------------------------------------------------------------------------------\n";
    $QUERYCOUNT++;
    
    print $fh "PID: $PID\n";
    print $fh "Execution time: $SECS seconds\n";
    print $fh "Username: $USER\n";
    print $fh "First 400 bytes of query:\n";
    print $fh "$QUERYTEXT\n";
    
}
#    print $fh "```";
    close $fh;

    if ($TOTALQUERIES > 0 ) {
    $syscmd="mail -s'Redshift query WARNING' $ADDRESSLIST < /tmp/rsemail.tmp";
#    $syscmd="mail -s'Redshift query WARNING' w2m2y2p1r3y2j8a3\@vacasa.slack.com < /tmp/rsemail.tmp";
    system($syscmd);
    }


print "$TOTALQUERIES queries over $NUMSECS runtime.\n";
