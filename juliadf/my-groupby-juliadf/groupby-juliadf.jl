#!/usr/bin/env julia

using BenchmarkTools
using DataFrames
using CSV
using Statistics
using Printf

include("$(pwd())/_helpers/helpers.jl");
include("utils.jl")

const WS = " "
const N_THREADS = Threads.nthreads()

const WARMUP_OUTER_ROUNDS = 1
const MIN_OUTER_ROUNDS = 5
const INNER_ROUNDS = 20

# benchmark runs until std(gctimes) / mean(gctimes) > SD_MEAN_TOL
const SD_MEAN_TOL = 0.45

db_as_df = CSV.read(ARGS[1], DataFrame);

struct BenchTask{C}
    # map task?
    combine_task::C
end

bench_tasks_vec = [
                   BenchTask(x -> combine(groupby(x, [:id1, :id2]), :v1 => sum∘skipmissing => :v1)),
                   BenchTask(x -> combine(groupby(x, :id3), :v1 => sum∘skipmissing => :v1, :v3 => mean∘skipmissing => :v3)),
                   BenchTask(x -> combine(groupby(x, :id4), :v1 => mean∘skipmissing => :v1, :v2 => mean∘skipmissing => :v2, :v3 => mean∘skipmissing => :v3)),
                   BenchTask(x -> combine(groupby(x, [:id4, :id5]), :v3 => median∘skipmissing => :median_v3, :v3 => std∘skipmissing => :sd_v3)),
                   BenchTask(x -> combine(groupby(x, :id3), [:v1, :v2] => ((v1, v2) -> maximum(skipmissing(v1))-minimum(skipmissing(v2))) => :range_v1_v2)),
                   BenchTask(x -> combine(groupby(dropmissing(x, :v3), :id6), :v3 => (x -> partialsort!(x, 1:min(2, length(x)), rev=false)) => :largest2_v3)),
                   BenchTask(x -> combine(groupby(x, [:id2, :id4]), [:v1, :v2] => ((v1,v2) -> cor2(v1, v2)^2) => :r2)),
                   BenchTask(x -> combine(groupby(x, [:id1, :id2, :id3, :id4, :id5, :id6]), :v3 => sum∘skipmissing => :v3, :v3 => length => :count))
                   ]

function run_benchmarks() 
    for (bench_num, bt) in enumerate(bench_tasks_vec)
        gctimes = []
        times = []

        i = 1
        
        while true
            stat = @timed begin
                for j in 1:INNER_ROUNDS
                    bt.combine_task(db_as_df)
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

        print_report(times, gctimes, bench_num)
    end
end

run_benchmarks()

exit();
