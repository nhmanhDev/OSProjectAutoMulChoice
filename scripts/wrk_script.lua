-- Script Lua cho wrk để đo latency chi tiết hơn

init = function(args)
    local r = {}
    local depth = tonumber(args[1]) or 1
    for i=1,depth do
        r[i] = 0
    end
    request_depth = r
end

request = function()
    return wrk.format("GET", "/")
end

response = function(status, headers, body)
    if status == 200 then
        -- Có thể thêm logic xử lý response ở đây
    end
end

done = function(summary, latency, requests)
    io.write("------------------------------\n")
    io.write(string.format("Requests/sec: %.2f\n", summary.requests.persec))
    io.write(string.format("Transfer/sec: %.2fKB\n", summary.bytes.persec / 1024))
    io.write("------------------------------\n")
    io.write("Latency percentiles:\n")
    io.write(string.format("  p50: %.2fms\n", latency:percentile(50) / 1000))
    io.write(string.format("  p75: %.2fms\n", latency:percentile(75) / 1000))
    io.write(string.format("  p90: %.2fms\n", latency:percentile(90) / 1000))
    io.write(string.format("  p99: %.2fms\n", latency:percentile(99) / 1000))
    io.write(string.format("  p99.9: %.2fms\n", latency:percentile(99.9) / 1000))
end

