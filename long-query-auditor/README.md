## Quit hogging the bathroom, dang ye
This contains the code for both the MySQL and Redshift versions of the query auditor, hacked from longqueries.sh (a manual process) located in the root folder of data-tools.

## What these do

*longqueries.sh* is a simple processlist analyser for MySQL.  It takes a minimum of two and at most three command line parameters:

longqueries.sh [fqdn] [seconds] [kill]

fqdn is the FQDN or IP of the instance to be monitored, and seconds indicates the number of seconds a query has to be active before it is considered long-running.

The optional third parameter, the word "kill", will cause offending queries to be killed.  When left out, a list of long queries is returned if any are found.  If no queries meet the criterion, then nothing is returned.

*rs_query_auditor_global.pl* is the Redshift version.  This version collates all nasty queries into one email and warns the DE team.

*rs_query_auditor_byuser.pl* does the same thing, but sends its barbaric yawps to the owners of the query.
