#!/usr/bin/perl 
#
# richard.byrd@example.com
# Dec 2018
# v0.86
#
# This is the Redshift version of the long_queries.sh script for MariaDB.
#
# Features to be added include auto killin', posting to DataDog, etc.  This is still rough, but handled gently,
# it works.  The goal was to get it in place before the Christmas break so it could get burned in for post-holiday 
# heavy load.  NO ERROR CHECKING YET.
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
# This version actually emails the owner of the query (with some exceptions noted below) based on the user mapping in the
# warehouse.admin.example_user_map table.

$NUMSECS=$ARGV[0];

#$TIMERQUERY="select pid, duration/1000000 as seconds, trim(user_name) as user,substring (query,1,200) as querytxt from stv_recents where status = 'Running' and seconds >=NUMSECS order by seconds desc;";
$TIMERQUERY="select pid, duration/1000000 as seconds, trim(user_name) as user,a.username_vc,substring(query,1,400) as querytxt from stv_recents join admin.example_user_map a on a.username_rs=user_name where status = 'Running' and seconds >=NUMSECS order by seconds desc;";

$TIMERQUERY=~s/NUMSECS/$NUMSECS/;

#print $TIMERQUERY;
$QUERYLIST=`echo "$TIMERQUERY" | PGPASSWORD=<redacted> psql -h  redshiftFQDN -p 5439 -Uexampleroot -dwarehouse -q -A -t -R 'XXXXX'`;


@QUERYROWS=split(/XXXXX/,"$QUERYLIST");
$QUERYCOUNT=0;

    print "CURRENT REDSHIFT QUERIES THAT HAVE BEEN RUNNING FOR > $NUMSECS SECONDS:\n";
    print "(Format is <RSuser>|<exampleEmail>|<PID>|<secondsRunning>, then query on next line)\n";
    print "---------------------------------------------------------------------------------------------------\n";

foreach (@QUERYROWS) {
    ($PID,$SECS,$USER,$EMAILADDR,$QUERYTEXT)=split(/\|/,"$_");
    
    if ("$USER" eq "exampleroot") {
        $EMAILADDR="richard.byrd";
    }
    
    print "$USER|$EMAILADDR\@example.com|$PID|$SECS\n$QUERYTEXT\n\n";
    print "---------------------------------------------------------------------------------------------------\n";
    $QUERYCOUNT++;
    
    open ($fh,'>','/tmp/rsemail_auditor.tmp');
    print $fh "Warning:  You currently have a query executing within the Redshift cluster that has been active for more than $NUMSECS seconds.  If this query continues, it may be terminated.  Details are below:\n\n";
    print $fh "PID: $PID\n";
    print $fh "Execution time: $SECS seconds\n";
    print $fh "Username: $USER\n";
    print $fh "First 400 bytes of query:\n\n";
    print $fh "$QUERYTEXT";
    close $fh;
    

    if ("$EMAILADDR" ne "richard.byrd") {
        $syscmd="mail -s'Redshift query WARNING' $EMAILADDR\@example.com < /tmp/rsemail_auditor.tmp";
        system($syscmd);
    }
}

print "<$QUERYCOUNT total queries over $NUMSECS runtime.>\n\n";
