#!/bin/bash
conn=" --db-driver=mysql --mysql-host=127.0.0.1 --mysql-db=sbtest --mysql-user=sbtest --mysql-password=sbtest "
sysbench --test=./oltp.lua --mysql-table-engine=InnoDB --oltp-table-size=1000000 $conn prepare
sysbench --report-interval=1 --num-threads=8 --max-requests=0  --max-time=120 --test=./oltp.lua --oltp-table-size=1000000 $conn --oltp-test-mode=complex --oltp-point-selects=0 --oltp-simple-ranges=0 --oltp-sum-ranges=0 --oltp-order-ranges=0 --oltp-distinct-ranges=0 --oltp-index-updates=1 --oltp-non-index-updates=0  run | tee -a sysbench_mysql.txt
