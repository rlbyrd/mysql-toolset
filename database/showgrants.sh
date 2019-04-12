#!/bin/bash 
#
# showgrants.sh
# Byrd, Richard L - 31 August 2003
# stupid simple.  Trolls through all extant users, gets their grants, and spits everything in a format suitable for sourcing
# into another database instance to duplicate all users and their grants.  Does not give a hoot if the schema/tables exist,
# nor does it check.  Assumes you have a ~/.my.cnf for login credentials; if not, edit the two mysql lines in the script
# to include your username and password.  Script expects one param: the hostname.  Assumes port 3306.
#

/bin/rm /tmp/grnt.tmp /tmp/grnt2.tmp 2> /dev/null


( 
 mysql -h$1  --batch --skip-column-names -e "SELECT user, host FROM user" mysql 
) | while read user host 
do 
  echo "# $user @ $host" >>/tmp/grnt.tmp
  mysql -h$1  --batch --skip-column-names -e"SHOW GRANTS FOR '$user'@'$host';" >> /tmp/grnt2.tmp 2>/dev/null
done

cat /tmp/grnt2.tmp | sed -e 's/$/;/'

/bin/rm /tmp/grnt.tmp /tmp/grnt2.tmp 2> /dev/null
