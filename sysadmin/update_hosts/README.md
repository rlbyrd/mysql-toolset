## Hide-and-seek with AWS
So the thing is that on every reboot/reset, RDS instances are not guaranteed to keep the same internal IP.  This is very, very annoying.

## What these do
This little guy reads your update.dat file (in the same directory) which has lines like this:

local-name|actual name|FQDN

...and iterates through it, doing nslookups on the symbolic names and recreating you a purty /etc/hosts file with your shorthand names.  Should be executed (via cron) every night sometimes after the instance/EC2 resets/rebuilds, but _before_ you usually start work.