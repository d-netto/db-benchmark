rm -f bench_diffeq.csv && touch bench_diffeq.csv
(echo "N_threads Benchmark_id GC_time[ns](avg) Total_time[ns](avg) GC_fraction(avg)" &&
for num_threads in {1..6} 
do
   ../julia/julia -t $num_threads diffeq_test.jl
done)
