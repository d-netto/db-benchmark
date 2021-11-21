using BenchmarkTools

const NUM_TRAJECTORIES = 10000
const MAX_SIZE = 100000

stat = @timed for i in 1:NUM_TRAJECTORIES
	sum(randn(MAX_SIZE))
end

const WS = " "

print(Threads.nthreads(), WS, stat.gctime, WS); flush(stdout);
print(stat.time, WS); flush(stdout);
print(stat.gctime / stat.time); flush(stdout);
println(); flush(stdout);