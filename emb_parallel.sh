rm -f bench_diffeq.csv && touch bench_diffeq.csv
(echo "N_threads Benchmark_id GC_time[ns](avg) Total_time[ns](avg) GC_fraction(avg)" &&
for num_threads in {1..4}
do
   ../julia/julia -t $num_threads emb_parallel.jl
done)
