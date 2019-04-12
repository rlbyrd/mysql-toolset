#!/bin/bash
# rsync 101.
rsync -avz --delete --exclude= --exclude=remotehost.com:/the/remote/directory/ /the/local/dir