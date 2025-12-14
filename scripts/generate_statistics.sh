#!/bin/bash

# Script để generate thống kê tổng hợp từ CSV files
# Sử dụng: bash scripts/generate_statistics.sh [docker|vm] [type]
# type: startup|resource_idle|resource_load|throughput|disk

MODE=${1:-docker}
TYPE=${2:-all}
RESULTS_DIR="measurement_results"

if [ "$TYPE" = "all" ] || [ "$TYPE" = "resource_idle" ] || [ "$TYPE" = "resource_load" ]; then
    # Tìm file resource usage mới nhất
    if [ "$TYPE" = "resource_idle" ]; then
        CSV_FILE=$(ls -t ${RESULTS_DIR}/resource_usage_${MODE}_*.csv 2>/dev/null | head -1)
        LABEL="Idle"
    elif [ "$TYPE" = "resource_load" ]; then
        CSV_FILE=$(ls -t ${RESULTS_DIR}/resource_usage_${MODE}_*.csv 2>/dev/null | tail -1)
        LABEL="Under Load"
    else
        CSV_FILE=$(ls -t ${RESULTS_DIR}/resource_usage_${MODE}_*.csv 2>/dev/null | head -1)
        LABEL="Idle"
    fi
    
    if [ -n "$CSV_FILE" ] && [ -f "$CSV_FILE" ]; then
        echo "=== Thống kê Resource Usage - ${MODE} (${LABEL}) ==="
        echo ""
        
        # Tính toán thống kê CPU
        echo "CPU Usage (%):"
        awk -F',' 'NR>1 && $2!="" && $2!="cpu_percent" {
            cpu[++idx]=$2
            sum_cpu+=$2
            count++
        }
        END {
            if (count > 0) {
                # Sort array
                n = asort(cpu, sorted_cpu)
                min = sorted_cpu[1]
                max = sorted_cpu[n]
                avg = sum_cpu / count
                if (n % 2 == 0) {
                    median = (sorted_cpu[n/2] + sorted_cpu[n/2+1]) / 2
                } else {
                    median = sorted_cpu[(n+1)/2]
                }
                printf "  Min:    %.2f%%\n", min
                printf "  Max:    %.2f%%\n", max
                printf "  Avg:    %.2f%%\n", avg
                printf "  Median: %.2f%%\n", median
            }
        }' "$CSV_FILE"
        
        echo ""
        echo "Memory Usage (MB):"
        awk -F',' 'NR>1 && $3!="" && $3!="memory_mb" {
            mem[++idx]=$3
            sum_mem+=$3
            count++
        }
        END {
            if (count > 0) {
                n = asort(mem, sorted_mem)
                min = sorted_mem[1]
                max = sorted_mem[n]
                avg = sum_mem / count
                if (n % 2 == 0) {
                    median = (sorted_mem[n/2] + sorted_mem[n/2+1]) / 2
                } else {
                    median = sorted_mem[(n+1)/2]
                }
                printf "  Min:    %.2f MB\n", min
                printf "  Max:    %.2f MB\n", max
                printf "  Avg:    %.2f MB\n", avg
                printf "  Median: %.2f MB\n", median
            }
        }' "$CSV_FILE"
        
        echo ""
        echo "Memory Usage (%):"
        awk -F',' 'NR>1 && $4!="" && $4!="memory_percent" {
            mem_p[++idx]=$4
            sum_mem_p+=$4
            count++
        }
        END {
            if (count > 0) {
                n = asort(mem_p, sorted_mem_p)
                min = sorted_mem_p[1]
                max = sorted_mem_p[n]
                avg = sum_mem_p / count
                if (n % 2 == 0) {
                    median = (sorted_mem_p[n/2] + sorted_mem_p[n/2+1]) / 2
                } else {
                    median = sorted_mem_p[(n+1)/2]
                }
                printf "  Min:    %.2f%%\n", min
                printf "  Max:    %.2f%%\n", max
                printf "  Avg:    %.2f%%\n", avg
                printf "  Median: %.2f%%\n", median
            }
        }' "$CSV_FILE"
    fi
fi

if [ "$TYPE" = "all" ] || [ "$TYPE" = "throughput" ]; then
    TXT_FILE=$(ls -t ${RESULTS_DIR}/throughput_${MODE}_*.txt 2>/dev/null | head -1)
    
    if [ -n "$TXT_FILE" ] && [ -f "$TXT_FILE" ]; then
        echo ""
        echo "=== Thống kê Throughput - ${MODE} ==="
        echo ""
        
        # Extract từ file text
        RPS=$(grep "Requests per second" "$TXT_FILE" | awk '{print $4}')
        TPR=$(grep "Time per request" "$TXT_FILE" | head -1 | awk '{print $4}')
        TOTAL_TIME=$(grep "Time taken for tests" "$TXT_FILE" | awk '{print $5}')
        COMPLETE=$(grep "Complete requests" "$TXT_FILE" | awk '{print $3}')
        FAILED=$(grep "Failed requests" "$TXT_FILE" | awk '{print $3}')
        
        echo "Requests per second: ${RPS}"
        echo "Time per request:    ${TPR} ms"
        echo "Total time:          ${TOTAL_TIME} seconds"
        echo "Complete requests:   ${COMPLETE}"
        echo "Failed requests:     ${FAILED}"
    fi
fi

if [ "$TYPE" = "all" ] || [ "$TYPE" = "startup" ]; then
    CSV_FILE=$(ls -t ${RESULTS_DIR}/startup_time_${MODE}_*.csv 2>/dev/null | head -1)
    
    if [ -n "$CSV_FILE" ] && [ -f "$CSV_FILE" ]; then
        echo ""
        echo "=== Thống kê Startup Time - ${MODE} ==="
        echo ""
        
        awk -F',' 'NR>1 {
            metric = $1
            seconds = $2
            ms = $3
            if (metric == "service_start") {
                printf "Service Start: %.3f giây (%.0f ms)\n", seconds, ms
            } else if (metric == "ready") {
                printf "Ready Time:    %.3f giây (%.0f ms)\n", seconds, ms
            } else if (metric == "total") {
                printf "Total Time:    %.3f giây (%.0f ms)\n", seconds, ms
            }
        }' "$CSV_FILE"
    fi
fi

