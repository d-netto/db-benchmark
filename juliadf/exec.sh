#!/bin/bash

num_threads=$1

# execute benchmark script
echo "N_threads Benchmark_id GC_time[s](avg) GC_time[s](sd) Total_time[s](avg) Total_time[s](sd) GC_fraction(avg) GC_fraction[s](sd)" &&
if [ $num_threads -lt 4 ] 
then
  taskset -c 1-3 julia -t $num_threads ./juliadf/groupby-juliadf.jl
else
  julia -t $num_threads ./juliadf/groupby-juliadf.jl
fi