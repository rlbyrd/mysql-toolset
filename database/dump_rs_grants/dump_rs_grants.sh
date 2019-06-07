cd /usr/local/cron/dump_rs_grants
PGPASSWORD=xxxxxxxxx psql -h  redshiftFQDN -p 5439 -Uexampleroot -dwarehouse < dump_rs_grants.sql > current_rs_grants.txt




