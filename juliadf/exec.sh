#!/bin/bash

min_num_threads=$1
max_num_threads=$2
echo "MIN_THREADS=$min_num_threads"
echo "MAX_THREADS=$max_num_threads"

echo "N_threads Benchmark_id GC_time[s](avg) GC_time[s](sd) Total_time[s](avg) Total_time[s](sd) GC_fraction(avg) GC_fraction(sd)"
for ((i = $min_num_threads; i <= $max_num_threads; i++))
do
   ../julia/julia -t$i ./juliadf/groupby-juliadf.jl
   echo "--------"
done
