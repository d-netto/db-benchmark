#!/usr/bin/env julia

using BenchmarkTools
using DataFrames;
using CSV;
using Statistics; # mean function
using Printf;

include("$(pwd())/_helpers/helpers.jl");

data_name = "G1_1e7_1e2_0_0";

src_grp = string("data/", data_name, ".csv");
x = CSV.read(src_grp, DataFrame);

struct BenchTask{N, C}
    task_name::N
    combine_task::C
end

function cor2(x, y) ## 73647e5a81d4b643c51bd784b3c8af04144cfaf6
    nm = @. !ismissing(x) & !ismissing(y)
    return count(nm) < 2 ? NaN : cor(view(x, nm), view(y, nm))
end

bench_tasks_vec = [
                   BenchTask("sum v1 by id1:id2", x -> combine(groupby(x, [:id1, :id2]), :v1 => sum∘skipmissing => :v1)),
                   BenchTask("sum v1 mean v3 by id3", x -> combine(groupby(x, :id3), :v1 => sum∘skipmissing => :v1, :v3 => mean∘skipmissing => :v3)),
                   BenchTask("mean v1:v3 by id4", x -> combine(groupby(x, :id4), :v1 => mean∘skipmissing => :v1, :v2 => mean∘skipmissing => :v2, :v3 => mean∘skipmissing => :v3)),
                   BenchTask("median v3 sd v3 by id4 id5", x -> combine(groupby(x, [:id4, :id5]), :v3 => median∘skipmissing => :median_v3, :v3 => std∘skipmissing => :sd_v3)),
                   BenchTask("max v1 - min v2 by id3", x -> combine(groupby(x, :id3), [:v1, :v2] => ((v1, v2) -> maximum(skipmissing(v1))-minimum(skipmissing(v2))) => :range_v1_v2)),
                   BenchTask("largest two v3 by id6", x -> combine(groupby(dropmissing(x, :v3), :id6), :v3 => (x -> partialsort!(x, 1:min(2, length(x)), rev=false)) => :largest2_v3)),
                   BenchTask("regression v1 v2 by id2 id4", x -> combine(groupby(x, [:id2, :id4]), [:v1, :v2] => ((v1,v2) -> cor2(v1, v2)^2) => :r2)),
                   BenchTask("sum v3 count by id1:id6", x -> combine(groupby(x, [:id1, :id2, :id3, :id4, :id5, :id6]), :v3 => sum∘skipmissing => :v3, :v3 => length => :count))
                   ]

const WS = " "

const N_THREADS = Threads.nthreads()

const WARMUP_OUTER_ROUNDS = 1

const MIN_OUTER_ROUNDS = 5
const INNER_ROUNDS = 2

const SD_MEAN_TOL = 0.45

for (bench_num, bt) in enumerate(bench_tasks_vec)

    GC.gc(); GC.gc(); GC.gc(); GC.gc();

    gctimes = []
    times = []

    i = 1
    
    while true
        stat = @timed begin
            @inbounds for j in 1:INNER_ROUNDS
                bt.combine_task(x)
            end
        end

        if i > WARMUP_OUTER_ROUNDS
            push!(gctimes, stat.gctime / INNER_ROUNDS)
            push!(times, stat.time / INNER_ROUNDS)
        end

        if i > WARMUP_OUTER_ROUNDS + 1
            sd_mean_ratio = std(gctimes)/ mean(gctimes)
            sd_mean_ratio <= SD_MEAN_TOL && i > MIN_OUTER_ROUNDS && break
        end

        i += 1
    end

    print(N_THREADS, WS, bench_num, WS, mean(gctimes), WS, std(gctimes), WS); flush(stdout);
    print(mean(times), WS, std(times), WS); flush(stdout);
    print(mean(gctimes ./ times), WS, std(gctimes ./ times), WS); flush(stdout);
    println(); flush(stdout);
end

exit();
