#!/bin/bash
#
#

FILESPEC=${1}
DAYS=${2}

if [ "${DAYS}" == "" ]
then
    echo -e "USAGE:\n\n $0 <filespec> <numDays>\n\nFinds and deletes files matching filespec older than numDays old.\n\n"
    exit 1
fi

echo "find ${FILESPEC} -mtime +${DAYS} -exec rm {} \;"