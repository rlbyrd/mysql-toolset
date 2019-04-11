cd /usr/local/cron/dump_rs_grants
PGPASSWORD=xxxxxxxxx psql -h  warehouse.vacasa.services -p 5439 -Uvacasaroot -dwarehouse < dump_rs_grants.sql > current_rs_grants.txt




