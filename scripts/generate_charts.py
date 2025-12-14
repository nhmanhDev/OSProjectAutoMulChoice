#!/usr/bin/env python3
"""
Script để generate biểu đồ so sánh từ dữ liệu đo lường
Sử dụng: python3 scripts/generate_charts.py [docker|vm|both] [report_file]
"""

import sys
import os
import json
import csv
import re
from pathlib import Path
from datetime import datetime

try:
    import matplotlib
    matplotlib.use('Agg')  # Non-interactive backend
    import matplotlib.pyplot as plt
    import numpy as np
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    print("⚠️  matplotlib chưa được cài đặt. Cài đặt: pip install matplotlib numpy")
    print("   Hoặc sẽ tạo HTML chart với Chart.js")

def parse_startup_time_csv(csv_file):
    """Parse startup time CSV file"""
    data = {}
    if not os.path.exists(csv_file):
        return data
    
    with open(csv_file, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            metric = row.get('metric', '').strip()
            if metric:
                data[metric] = {
                    'seconds': float(row.get('time_seconds', 0)),
                    'milliseconds': float(row.get('time_milliseconds', 0))
                }
    return data

def parse_resource_usage_csv(csv_file):
    """Parse resource usage CSV file"""
    cpu_values = []
    mem_values = []
    mem_perc_values = []
    
    if not os.path.exists(csv_file):
        return {'cpu': cpu_values, 'memory_mb': mem_values, 'memory_percent': mem_perc_values}
    
    with open(csv_file, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            try:
                cpu = float(row.get('cpu_percent', 0))
                mem = float(row.get('memory_mb', 0))
                mem_perc = float(row.get('memory_percent', 0))
                if cpu > 0:
                    cpu_values.append(cpu)
                if mem > 0:
                    mem_values.append(mem)
                if mem_perc > 0:
                    mem_perc_values.append(mem_perc)
            except (ValueError, KeyError):
                continue
    
    return {
        'cpu': cpu_values,
        'memory_mb': mem_values,
        'memory_percent': mem_perc_values
    }

def parse_throughput_txt(txt_file):
    """Parse throughput text file"""
    data = {
        'requests_per_second': 0,
        'time_per_request_ms': 0,
        'total_time_seconds': 0,
        'complete_requests': 0,
        'failed_requests': 0
    }
    
    if not os.path.exists(txt_file):
        return data
    
    with open(txt_file, 'r') as f:
        content = f.read()
        
        # Extract requests per second
        rps_match = re.search(r'Requests per second:\s+([\d.]+)', content)
        if rps_match:
            data['requests_per_second'] = float(rps_match.group(1))
        
        # Extract time per request
        tpr_match = re.search(r'Time per request:\s+([\d.]+)\s+\[ms\]', content)
        if tpr_match:
            data['time_per_request_ms'] = float(tpr_match.group(1))
        
        # Extract total time
        tt_match = re.search(r'Time taken for tests:\s+([\d.]+)\s+seconds', content)
        if tt_match:
            data['total_time_seconds'] = float(tt_match.group(1))
        
        # Extract complete requests
        cr_match = re.search(r'Complete requests:\s+(\d+)', content)
        if cr_match:
            data['complete_requests'] = int(cr_match.group(1))
        
        # Extract failed requests
        fr_match = re.search(r'Failed requests:\s+(\d+)', content)
        if fr_match:
            data['failed_requests'] = int(fr_match.group(1))
    
    return data

def parse_disk_usage_txt(txt_file):
    """Parse disk usage text file"""
    data = {
        'total_size_gb': 0,
        'used_size_gb': 0,
        'app_size_mb': 0
    }
    
    if not os.path.exists(txt_file):
        return data
    
    with open(txt_file, 'r') as f:
        content = f.read()
        
        # Extract app directory size
        app_match = re.search(r'(\d+(?:\.\d+)?)([KMGT]?)\s+/home/.*?OSProjectAutoMulChoice', content)
        if app_match:
            size = float(app_match.group(1))
            unit = app_match.group(2)
            if unit == 'G':
                data['app_size_mb'] = size * 1024
            elif unit == 'M':
                data['app_size_mb'] = size
            elif unit == 'K':
                data['app_size_mb'] = size / 1024
    
    return data

def calculate_stats(values):
    """Calculate statistics from a list of values"""
    if not values:
        return {'min': 0, 'max': 0, 'avg': 0, 'median': 0}
    
    sorted_vals = sorted(values)
    return {
        'min': min(values),
        'max': max(values),
        'avg': sum(values) / len(values),
        'median': sorted_vals[len(sorted_vals) // 2]
    }

def generate_html_charts(data_docker, data_vm, output_file):
    """Generate HTML file with Chart.js charts"""
    html_content = f"""<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Biểu Đồ So Sánh Hiệu Năng - Docker vs VM</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        body {{
            font-family: Arial, sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }}
        .chart-container {{
            background: white;
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        h1 {{
            color: #333;
            text-align: center;
        }}
        h2 {{
            color: #555;
            border-bottom: 2px solid #2196F3;
            padding-bottom: 10px;
        }}
        canvas {{
            max-height: 400px;
        }}
    </style>
</head>
<body>
    <h1>Biểu Đồ So Sánh Hiệu Năng: Docker vs VM</h1>
    <p style="text-align: center; color: #666;">Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
    
    <!-- Startup Time Chart -->
    <div class="chart-container">
        <h2>1. Thời Gian Khởi Động (ms)</h2>
        <canvas id="startupChart"></canvas>
    </div>
    
    <!-- Disk Usage Chart -->
    <div class="chart-container">
        <h2>2. Dung Lượng Đĩa (MB)</h2>
        <canvas id="diskChart"></canvas>
    </div>
    
    <!-- CPU Usage Chart -->
    <div class="chart-container">
        <h2>3. CPU Usage - Idle vs Under Load (%)</h2>
        <canvas id="cpuChart"></canvas>
    </div>
    
    <!-- Memory Usage Chart -->
    <div class="chart-container">
        <h2>4. Memory Usage - Idle vs Under Load (MB)</h2>
        <canvas id="memoryChart"></canvas>
    </div>
    
    <!-- Throughput Chart -->
    <div class="chart-container">
        <h2>5. Thông Lượng (Requests/Second)</h2>
        <canvas id="throughputChart"></canvas>
    </div>
    
    <script>
        const dockerData = {json.dumps(data_docker)};
        const vmData = {json.dumps(data_vm)};
        
        // Startup Time Chart
        new Chart(document.getElementById('startupChart'), {{
            type: 'bar',
            data: {{
                labels: ['Service Start', 'Ready Time', 'Total'],
                datasets: [{{
                    label: 'Docker (ms)',
                    data: [
                        dockerData.startup?.service_start?.milliseconds || 0,
                        dockerData.startup?.ready?.milliseconds || 0,
                        (dockerData.startup?.service_start?.milliseconds || 0) + (dockerData.startup?.ready?.milliseconds || 0)
                    ],
                    backgroundColor: 'rgba(33, 150, 243, 0.7)',
                    borderColor: 'rgba(33, 150, 243, 1)',
                    borderWidth: 1
                }}, {{
                    label: 'VM (ms)',
                    data: [
                        vmData.startup?.service_start?.milliseconds || 0,
                        vmData.startup?.ready?.milliseconds || 0,
                        (vmData.startup?.service_start?.milliseconds || 0) + (vmData.startup?.ready?.milliseconds || 0)
                    ],
                    backgroundColor: 'rgba(76, 175, 80, 0.7)',
                    borderColor: 'rgba(76, 175, 80, 1)',
                    borderWidth: 1
                }}]
            }},
            options: {{
                responsive: true,
                scales: {{
                    y: {{
                        beginAtZero: true,
                        title: {{
                            display: true,
                            text: 'Thời gian (ms)'
                        }}
                    }}
                }}
            }}
        }});
        
        // Disk Usage Chart
        new Chart(document.getElementById('diskChart'), {{
            type: 'bar',
            data: {{
                labels: ['Docker', 'VM'],
                datasets: [{{
                    label: 'Dung lượng ứng dụng (MB)',
                    data: [
                        dockerData.disk?.app_size_mb || 0,
                        vmData.disk?.app_size_mb || 0
                    ],
                    backgroundColor: ['rgba(33, 150, 243, 0.7)', 'rgba(76, 175, 80, 0.7)'],
                    borderColor: ['rgba(33, 150, 243, 1)', 'rgba(76, 175, 80, 1)'],
                    borderWidth: 1
                }}]
            }},
            options: {{
                responsive: true,
                scales: {{
                    y: {{
                        beginAtZero: true,
                        title: {{
                            display: true,
                            text: 'Dung lượng (MB)'
                        }}
                    }}
                }}
            }}
        }});
        
        // CPU Usage Chart
        new Chart(document.getElementById('cpuChart'), {{
            type: 'bar',
            data: {{
                labels: ['Docker Idle', 'Docker Load', 'VM Idle', 'VM Load'],
                datasets: [{{
                    label: 'CPU Usage Trung Bình (%)',
                    data: [
                        dockerData.resources_idle?.cpu?.avg || 0,
                        dockerData.resources_load?.cpu?.avg || 0,
                        vmData.resources_idle?.cpu?.avg || 0,
                        vmData.resources_load?.cpu?.avg || 0
                    ],
                    backgroundColor: [
                        'rgba(33, 150, 243, 0.7)',
                        'rgba(33, 150, 243, 0.9)',
                        'rgba(76, 175, 80, 0.7)',
                        'rgba(76, 175, 80, 0.9)'
                    ],
                    borderColor: [
                        'rgba(33, 150, 243, 1)',
                        'rgba(33, 150, 243, 1)',
                        'rgba(76, 175, 80, 1)',
                        'rgba(76, 175, 80, 1)'
                    ],
                    borderWidth: 1
                }}]
            }},
            options: {{
                responsive: true,
                scales: {{
                    y: {{
                        beginAtZero: true,
                        title: {{
                            display: true,
                            text: 'CPU Usage (%)'
                        }}
                    }}
                }}
            }}
        }});
        
        // Memory Usage Chart
        new Chart(document.getElementById('memoryChart'), {{
            type: 'bar',
            data: {{
                labels: ['Docker Idle', 'Docker Load', 'VM Idle', 'VM Load'],
                datasets: [{{
                    label: 'Memory Usage Trung Bình (MB)',
                    data: [
                        dockerData.resources_idle?.memory_mb?.avg || 0,
                        dockerData.resources_load?.memory_mb?.avg || 0,
                        vmData.resources_idle?.memory_mb?.avg || 0,
                        vmData.resources_load?.memory_mb?.avg || 0
                    ],
                    backgroundColor: [
                        'rgba(33, 150, 243, 0.7)',
                        'rgba(33, 150, 243, 0.9)',
                        'rgba(76, 175, 80, 0.7)',
                        'rgba(76, 175, 80, 0.9)'
                    ],
                    borderColor: [
                        'rgba(33, 150, 243, 1)',
                        'rgba(33, 150, 243, 1)',
                        'rgba(76, 175, 80, 1)',
                        'rgba(76, 175, 80, 1)'
                    ],
                    borderWidth: 1
                }}]
            }},
            options: {{
                responsive: true,
                scales: {{
                    y: {{
                        beginAtZero: true,
                        title: {{
                            display: true,
                            text: 'Memory (MB)'
                        }}
                    }}
                }}
            }}
        }});
        
        // Throughput Chart
        new Chart(document.getElementById('throughputChart'), {{
            type: 'bar',
            data: {{
                labels: ['Docker', 'VM'],
                datasets: [{{
                    label: 'Requests per Second',
                    data: [
                        dockerData.throughput?.requests_per_second || 0,
                        vmData.throughput?.requests_per_second || 0
                    ],
                    backgroundColor: ['rgba(33, 150, 243, 0.7)', 'rgba(76, 175, 80, 0.7)'],
                    borderColor: ['rgba(33, 150, 243, 1)', 'rgba(76, 175, 80, 1)'],
                    borderWidth: 1
                }}]
            }},
            options: {{
                responsive: true,
                scales: {{
                    y: {{
                        beginAtZero: true,
                        title: {{
                            display: true,
                            text: 'Requests/Second'
                        }}
                    }}
                }}
            }}
        }});
    </script>
</body>
</html>
"""
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(html_content)
    
    print(f"✅ Đã tạo HTML charts: {output_file}")

def generate_matplotlib_charts(data_docker, data_vm, output_dir):
    """Generate matplotlib charts"""
    if not HAS_MATPLOTLIB:
        return
    
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))
    fig.suptitle('Biểu Đồ So Sánh Hiệu Năng: Docker vs VM', fontsize=16, fontweight='bold')
    
    # 1. Startup Time
    ax = axes[0, 0]
    categories = ['Service Start', 'Ready Time']
    docker_vals = [
        data_docker.get('startup', {}).get('service_start', {}).get('milliseconds', 0),
        data_docker.get('startup', {}).get('ready', {}).get('milliseconds', 0)
    ]
    vm_vals = [
        data_vm.get('startup', {}).get('service_start', {}).get('milliseconds', 0),
        data_vm.get('startup', {}).get('ready', {}).get('milliseconds', 0)
    ]
    x = np.arange(len(categories))
    width = 0.35
    ax.bar(x - width/2, docker_vals, width, label='Docker', color='#2196F3')
    ax.bar(x + width/2, vm_vals, width, label='VM', color='#4CAF50')
    ax.set_ylabel('Thời gian (ms)')
    ax.set_title('Thời Gian Khởi Động')
    ax.set_xticks(x)
    ax.set_xticklabels(categories)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # 2. Disk Usage
    ax = axes[0, 1]
    docker_disk = data_docker.get('disk', {}).get('app_size_mb', 0)
    vm_disk = data_vm.get('disk', {}).get('app_size_mb', 0)
    ax.bar(['Docker', 'VM'], [docker_disk, vm_disk], color=['#2196F3', '#4CAF50'])
    ax.set_ylabel('Dung lượng (MB)')
    ax.set_title('Dung Lượng Đĩa')
    ax.grid(True, alpha=0.3)
    
    # 3. CPU Usage
    ax = axes[0, 2]
    cpu_data = [
        data_docker.get('resources_idle', {}).get('cpu', {}).get('avg', 0),
        data_docker.get('resources_load', {}).get('cpu', {}).get('avg', 0),
        data_vm.get('resources_idle', {}).get('cpu', {}).get('avg', 0),
        data_vm.get('resources_load', {}).get('cpu', {}).get('avg', 0)
    ]
    ax.bar(['Docker\nIdle', 'Docker\nLoad', 'VM\nIdle', 'VM\nLoad'], cpu_data, 
           color=['#2196F3', '#1976D2', '#4CAF50', '#388E3C'])
    ax.set_ylabel('CPU Usage (%)')
    ax.set_title('CPU Usage - Idle vs Load')
    ax.grid(True, alpha=0.3)
    
    # 4. Memory Usage
    ax = axes[1, 0]
    mem_data = [
        data_docker.get('resources_idle', {}).get('memory_mb', {}).get('avg', 0),
        data_docker.get('resources_load', {}).get('memory_mb', {}).get('avg', 0),
        data_vm.get('resources_idle', {}).get('memory_mb', {}).get('avg', 0),
        data_vm.get('resources_load', {}).get('memory_mb', {}).get('avg', 0)
    ]
    ax.bar(['Docker\nIdle', 'Docker\nLoad', 'VM\nIdle', 'VM\nLoad'], mem_data,
           color=['#2196F3', '#1976D2', '#4CAF50', '#388E3C'])
    ax.set_ylabel('Memory (MB)')
    ax.set_title('Memory Usage - Idle vs Load')
    ax.grid(True, alpha=0.3)
    
    # 5. Throughput
    ax = axes[1, 1]
    docker_rps = data_docker.get('throughput', {}).get('requests_per_second', 0)
    vm_rps = data_vm.get('throughput', {}).get('requests_per_second', 0)
    ax.bar(['Docker', 'VM'], [docker_rps, vm_rps], color=['#2196F3', '#4CAF50'])
    ax.set_ylabel('Requests/Second')
    ax.set_title('Thông Lượng (Throughput)')
    ax.grid(True, alpha=0.3)
    
    # 6. CPU Time Series (if available)
    ax = axes[1, 2]
    ax.text(0.5, 0.5, 'CPU Time Series\n(Line Chart)', 
            ha='center', va='center', fontsize=12)
    ax.set_title('CPU Usage Over Time')
    ax.axis('off')
    
    plt.tight_layout()
    output_file = os.path.join(output_dir, 'comparison_charts.png')
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    print(f"✅ Đã tạo matplotlib charts: {output_file}")

def collect_data_from_reports(results_dir, mode):
    """Collect data from measurement results"""
    data = {
        'startup': {},
        'disk': {},
        'resources_idle': {},
        'resources_load': {},
        'throughput': {}
    }
    
    # Find latest files for this mode
    startup_files = sorted(Path(results_dir).glob(f'startup_time_{mode}_*.csv'))
    disk_files = sorted(Path(results_dir).glob(f'disk_usage_{mode}_*.txt'))
    resource_idle_files = sorted(Path(results_dir).glob(f'resource_usage_{mode}_*.csv'))
    throughput_files = sorted(Path(results_dir).glob(f'throughput_{mode}_*.txt'))
    
    # Parse startup time
    if startup_files:
        data['startup'] = parse_startup_time_csv(str(startup_files[-1]))
    
    # Parse disk usage
    if disk_files:
        data['disk'] = parse_disk_usage_txt(str(disk_files[-1]))
    
    # Parse resource usage (idle and load)
    if len(resource_idle_files) >= 1:
        idle_data = parse_resource_usage_csv(str(resource_idle_files[0]))
        data['resources_idle'] = {
            'cpu': calculate_stats(idle_data['cpu']),
            'memory_mb': calculate_stats(idle_data['memory_mb']),
            'memory_percent': calculate_stats(idle_data['memory_percent'])
        }
    
    if len(resource_idle_files) >= 2:
        load_data = parse_resource_usage_csv(str(resource_idle_files[1]))
        data['resources_load'] = {
            'cpu': calculate_stats(load_data['cpu']),
            'memory_mb': calculate_stats(load_data['memory_mb']),
            'memory_percent': calculate_stats(load_data['memory_percent'])
        }
    
    # Parse throughput
    if throughput_files:
        data['throughput'] = parse_throughput_txt(str(throughput_files[-1]))
    
    return data

def main():
    if len(sys.argv) < 2:
        print("Sử dụng: python3 scripts/generate_charts.py [docker|vm|both]")
        sys.exit(1)
    
    mode = sys.argv[1].lower()
    results_dir = "measurement_results"
    output_dir = results_dir
    
    data_docker = {}
    data_vm = {}
    
    if mode in ['docker', 'both']:
        data_docker = collect_data_from_reports(results_dir, 'docker')
        print(f"✅ Đã thu thập dữ liệu Docker")
    
    if mode in ['vm', 'both']:
        data_vm = collect_data_from_reports(results_dir, 'vm')
        print(f"✅ Đã thu thập dữ liệu VM")
    
    if mode == 'both' and data_docker and data_vm:
        # Generate comparison charts
        html_file = os.path.join(output_dir, 'comparison_charts.html')
        generate_html_charts(data_docker, data_vm, html_file)
        
        if HAS_MATPLOTLIB:
            generate_matplotlib_charts(data_docker, data_vm, output_dir)
    elif mode == 'docker' and data_docker:
        print("⚠️  Chỉ có dữ liệu Docker. Cần chạy cả VM để so sánh.")
    elif mode == 'vm' and data_vm:
        print("⚠️  Chỉ có dữ liệu VM. Cần chạy cả Docker để so sánh.")
    else:
        print("❌ Không tìm thấy dữ liệu. Vui lòng chạy measurements trước.")
        sys.exit(1)

if __name__ == '__main__':
    main()

