#!/bin/bash

plotfn=nx-log.log
TS=$(date +"%F-%H-%M-%S")
run_series_report=run_series_report_${TS}.csv

for th in 1 4 16 32 64 80
do
    for a in `seq 0 2 20`  # size
    do
	b=$((1 << $a))
	nbyte=$(($b * 1024))
	rpt=$((1000 * 1000 * 1000 * 10)) # 10GB
	rpt=$(( ($rpt+$nbyte-1)/$nbyte )) # iters
	rpt=$(( ($rpt+$th-1)/$th )) # per thread
	rm -f junk2
	head -c $nbyte $1 > junk2;
	ls -l junk2;
	numactl -N 0 ./compdecomp_th junk2 $th $rpt
    done
done  > $plotfn 2>&1

echo "comdecom,thread#,data size,bandwidth(GB/s)" > ${run_series_report}
for i in 1 4 16 32 64 80; do
    grep "Total compress" $plotfn | grep "threads $i," | awk '{print "compress,"$11 $7 $5 }' >> ${run_series_report}
done
for i in 1 4 16 32 64 80; do
    grep "Total uncompress" $plotfn | grep "threads $i," | awk '{print "uncompress,"$11 $7 $5 }' >> ${run_series_report}
done
