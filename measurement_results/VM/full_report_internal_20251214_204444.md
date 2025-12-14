# Báo Cáo Đo Lường Hiệu Năng Từ BÊN TRONG - vm
**Thời gian:** Sun Dec 14 20:44:44 SEAST 2025
**Mode:** vm
**Ghi chú:** Tất cả measurements được thực hiện từ BÊN TRONG vm

---

## 1. Thời Gian Khởi Động (Từ Bên Trong)

=== Đo thời gian khởi động từ BÊN TRONG - Mode: vm ===
Thời gian bắt đầu: Sun Dec 14 20:44:44 SEAST 2025

--- Đo thời gian khởi động từ BÊN TRONG VM ---

Dừng service hiện tại (nếu có)...
Warning: Permanently added '[127.0.0.1]:2222' (ED25519) to the list of known hosts.
sudo: a terminal is required to read the password; either use the -S option to read from standard input or configure an askpass helper
sudo: a password is required
1. Đo thời gian start service...
Warning: Permanently added '[127.0.0.1]:2222' (ED25519) to the list of known hosts.
sudo: a terminal is required to read the password; either use the -S option to read from standard input or configure an askpass helper
sudo: a password is required
Thời gian start service: 0.452366 giây (452 ms)

2. Đợi service sẵn sàng (từ bên trong VM)...
Warning: Permanently added '[127.0.0.1]:2222' (ED25519) to the list of known hosts.
Service ready sau: 0.527035 giây (527 ms)

=== TỔNG KẾT ===
Start time: 0.452366 giây (452 ms)
Ready time: 0.527035 giây (527 ms)

Kết quả đã được lưu vào:
  - Text: /c/Users/nhman/OneDrive/Desktop/NLHDH/Update-Automated-Multiple-Choice-Exam-Grading/measurement_results/VM/startup_time_internal_20251214_204444.txt
  - CSV: /c/Users/nhman/OneDrive/Desktop/NLHDH/Update-Automated-Multiple-Choice-Exam-Grading/measurement_results/VM/startup_time_internal_20251214_204444.csv
Thời gian kết thúc: Sun Dec 14 20:44:49 SEAST 2025

---

## 2. Dung Lượng Đĩa (Từ Bên Trong)

=== Đo dung lượng đĩa từ BÊN TRONG - Mode: vm ===
Thời gian: Sun Dec 14 20:44:49 SEAST 2025

--- Dung lượng đĩa từ BÊN TRONG VM ---

1. Disk usage tổng thể (từ bên trong VM):
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           795M  1.7M  793M   1% /run
/dev/sda3        24G   20G  3.6G  85% /
tmpfs           3.9G   37M  3.9G   1% /dev/shm
tmpfs           5.0M  4.0K  5.0M   1% /run/lock
/dev/sda2       512M  6.1M  506M   2% /boot/efi
tmpfs           795M  120K  795M   1% /run/user/1000
/dev/sr0         51M   51M     0 100% /media/sysadmin/VBox_GAs_7.2.4

2. Dung lượng thư mục ứng dụng:
Warning: Permanently added '[127.0.0.1]:2222' (ED25519) to the list of known hosts.
40K	/home/sysadmin/.local/lib/python3.10/site-packages/tensorflow/core/example
Warning: Permanently added '[127.0.0.1]:2222' (ED25519) to the list of known hosts.
0	/home/sysadmin/.local/lib/python3.10/site-packages/tensorflow/core/example/__init__.py
4.0K	/home/sysadmin/.local/lib/python3.10/site-packages/tensorflow/core/example/example_parser_configuration_pb2.py
4.0K	/home/sysadmin/.local/lib/python3.10/site-packages/tensorflow/core/example/example_pb2.py
8.0K	/home/sysadmin/.local/lib/python3.10/site-packages/tensorflow/core/example/feature_pb2.py
20K	/home/sysadmin/.local/lib/python3.10/site-packages/tensorflow/core/example/__pycache__

3. Dung lượng root filesystem:
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda3        24G   20G  3.6G  85% /

Kết quả đã được lưu vào: /c/Users/nhman/OneDrive/Desktop/NLHDH/Update-Automated-Multiple-Choice-Exam-Grading/measurement_results/VM/disk_usage_internal_20251214_204449.txt

---

## 3. Sử Dụng Tài Nguyên Khi Idle (Từ Bên Trong)

=== Đo mức sử dụng RAM và CPU từ BÊN TRONG - Mode: vm ===
Thời gian đo: 60 giây
Thời gian bắt đầu: Sun Dec 14 20:44:58 SEAST 2025

--- Đo tài nguyên từ BÊN TRONG VM ---

SSH connection: vm-ubuntu
Đang đo từ BÊN TRONG VM trong 60 giây...
Timestamp,CPU %,Memory (MB),Memory %
2025-12-14 20:44:59,7.1,2616,32.94
2025-12-14 20:45:01,13.4,2615,32.93
2025-12-14 20:45:04,30.9,2616,32.94
2025-12-14 20:45:07,5.1,2618,32.97
2025-12-14 20:45:10,10.8,2616,32.94
2025-12-14 20:45:13,27.8,2618,32.97
2025-12-14 20:45:15,15.9,2605,32.80
2025-12-14 20:45:18,9.9,2578,32.46
2025-12-14 20:45:21,14.1,2555,32.17
2025-12-14 20:45:23,11.9,2547,32.07
2025-12-14 20:45:26,10.9,2519,31.72
2025-12-14 20:45:29,14.1,2526,31.81
2025-12-14 20:45:32,10.1,2514,31.66
2025-12-14 20:45:34,6.7,2443,30.76
2025-12-14 20:45:36,22.4,2442,30.75
2025-12-14 20:45:39,9.4,2441,30.74
2025-12-14 20:45:41,65.2,2468,31.08
2025-12-14 20:45:44,16.1,2464,31.03
2025-12-14 20:45:46,19.3,2465,31.04
2025-12-14 20:45:49,8.3,2464,31.03
2025-12-14 20:45:51,9.1,2465,31.04
2025-12-14 20:45:53,2.9,2463,31.02
2025-12-14 20:45:56,9.5,2463,31.02
2025-12-14 20:45:58,6.5,2465,31.04

Kết quả đã được lưu vào:
  - Text: /c/Users/nhman/OneDrive/Desktop/NLHDH/Update-Automated-Multiple-Choice-Exam-Grading/measurement_results/VM/resource_usage_internal_20251214_204458.txt
  - CSV: /c/Users/nhman/OneDrive/Desktop/NLHDH/Update-Automated-Multiple-Choice-Exam-Grading/measurement_results/VM/resource_usage_internal_20251214_204458.csv
Thời gian kết thúc: Sun Dec 14 20:46:01 SEAST 2025

---

## 4. Thông Lượng (Throughput) - Từ Bên Trong

=== Đo thông lượng từ BÊN TRONG - Mode: vm ===
Tool: ab
Concurrent requests: 10
Total requests: 1000
Thời gian bắt đầu: Sun Dec 14 20:46:01 SEAST 2025

Testing URL: http://localhost/ (từ bên trong)

--- Chạy Apache Bench từ BÊN TRONG VM ---

Warning: Permanently added '[127.0.0.1]:2222' (ED25519) to the list of known hosts.
Warning: Permanently added '[127.0.0.1]:2222' (ED25519) to the list of known hosts.
This is ApacheBench, Version 2.3 <$Revision: 1879490 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient)
Completed 100 requests
Completed 200 requests
Completed 300 requests
Completed 400 requests
Completed 500 requests
Completed 600 requests
Completed 700 requests
Completed 800 requests
Completed 900 requests
Completed 1000 requests
Finished 1000 requests


Server Software:        nginx/1.18.0
Server Hostname:        localhost
Server Port:            80

Document Path:          /
Document Length:        438 bytes

Concurrency Level:      10
Time taken for tests:   0.094 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      680000 bytes
HTML transferred:       438000 bytes
Requests per second:    10631.85 [#/sec] (mean)
Time per request:       0.941 [ms] (mean)
Time per request:       0.094 [ms] (mean, across all concurrent requests)
Transfer rate:          7060.21 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.2      0       2
Processing:     0    1   0.6      0       8
Waiting:        0    0   0.5      0       7
Total:          0    1   0.6      1       8
WARNING: The median and mean for the processing time are not within a normal deviation
        These results are probably not that reliable.

Percentage of the requests served within a certain time (ms)
  50%      1
  66%      1
  75%      1
  80%      1
  90%      2
  95%      2
  98%      3
  99%      3
 100%      8 (longest request)

Kết quả đã được lưu vào: /c/Users/nhman/OneDrive/Desktop/NLHDH/Update-Automated-Multiple-Choice-Exam-Grading/measurement_results/VM/throughput_internal_ab_20251214_204601.txt
Thời gian kết thúc: Sun Dec 14 20:46:02 SEAST 2025

---

## 5. Sử Dụng Tài Nguyên Khi Có Tải (Từ Bên Trong)

=== Đo mức sử dụng RAM và CPU từ BÊN TRONG - Mode: vm ===
Thời gian đo: 60 giây
Thời gian bắt đầu: Sun Dec 14 20:46:03 SEAST 2025

--- Đo tài nguyên từ BÊN TRONG VM ---

SSH connection: vm-ubuntu
Đang đo từ BÊN TRONG VM trong 60 giây...
Timestamp,CPU %,Memory (MB),Memory %
2025-12-14 20:46:03,48.2,2468,31.08
2025-12-14 20:46:06,16.7,2459,30.97
2025-12-14 20:46:09,7.4,2459,30.97
2025-12-14 20:46:12,11,2462,31.00
2025-12-14 20:46:15,11.7,2462,31.00
2025-12-14 20:46:17,13.1,2459,30.97
2025-12-14 20:46:20,18.5,2459,30.97
2025-12-14 20:46:23,8.6,2465,31.04
2025-12-14 20:46:25,14.3,2463,31.02
2025-12-14 20:46:28,6.5,2463,31.02
2025-12-14 20:46:31,14.3,2464,31.03
2025-12-14 20:46:34,38.2,2464,31.03
2025-12-14 20:46:37,21.3,2462,31.00
2025-12-14 20:46:40,12.5,2461,30.99
2025-12-14 20:46:43,15,2462,31.00
2025-12-14 20:46:46,14.7,2460,30.98
2025-12-14 20:46:48,15.3,2461,30.99
2025-12-14 20:46:51,29.3,2462,31.00
2025-12-14 20:46:54,15,2463,31.02
2025-12-14 20:46:58,17.7,2462,31.00
2025-12-14 20:47:02,8.5,2459,30.97

Kết quả đã được lưu vào:
  - Text: /c/Users/nhman/OneDrive/Desktop/NLHDH/Update-Automated-Multiple-Choice-Exam-Grading/measurement_results/VM/resource_usage_internal_20251214_204603.txt
  - CSV: /c/Users/nhman/OneDrive/Desktop/NLHDH/Update-Automated-Multiple-Choice-Exam-Grading/measurement_results/VM/resource_usage_internal_20251214_204603.csv
Thời gian kết thúc: Sun Dec 14 20:47:05 SEAST 2025

---

## Tổng Kết

Báo cáo này bao gồm các phép đo từ BÊN TRONG vm:
1. Thời gian khởi động dịch vụ (từ bên trong)
2. Dung lượng đĩa sử dụng (từ bên trong)
3. Mức sử dụng RAM và CPU khi idle (từ bên trong)
4. Thông lượng (requests/giây) - từ bên trong
5. Mức sử dụng RAM và CPU khi có tải (từ bên trong)

Tất cả các file chi tiết được lưu trong thư mục: `/c/Users/nhman/OneDrive/Desktop/NLHDH/Update-Automated-Multiple-Choice-Exam-Grading/measurement_results/VM/`

**Thời gian hoàn thành:** Sun Dec 14 20:47:05 SEAST 2025
