function cor2(x, y)
    nm = @. !ismissing(x) & !ismissing(y)
    return count(nm) < 2 ? NaN : cor(view(x, nm), view(y, nm))
end

function print_report(times, gctimes, bench_num)
    print(N_THREADS, WS, bench_num, WS, mean(gctimes), WS, std(gctimes), WS)
    print(mean(times), WS, std(times), WS)
    print(mean(gctimes ./ times), WS, std(gctimes ./ times), WS)
    println()
end
