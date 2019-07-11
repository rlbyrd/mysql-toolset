sysbench --test=oltp --oltp-table-size=1000000 --db-driver=mysql --mysql-db=sbtest --mysql-user=sbtest --mysql-password=sbtest prepare
head -1
sysbench --test=oltp --oltp-table-size=1000000 --db-driver=mysql --mysql-db=sbtest --mysql-user=sbtest --mysql-password=sbtest --max-time=60 --oltp-read-only=on --max-requests=0 --num-threads=8 run
