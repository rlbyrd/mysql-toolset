par=" --num-threads=4 --test=fileio --file-total-size=4G --file-test-mode=rndwr --file-num=4 "
sysbench $par prepare
sysbench $par --file-extra-flags=direct --report-interval=1 --max-requests=0 --max-time=300 run
sysbench $par cleanup
