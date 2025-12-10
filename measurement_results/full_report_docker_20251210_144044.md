# Báo Cáo Đo Lường Hiệu Năng - docker
**Thời gian:** Wed Dec 10 14:40:44 +07 2025
**Mode:** docker

---

## 1. Thời Gian Khởi Động

=== Đo thời gian khởi động dịch vụ - Mode: docker ===
Thời gian bắt đầu: Wed Dec 10 14:40:44 +07 2025
Timestamp: 20251210_144044

--- Đo thời gian khởi động Docker Container ---
Dừng containers hiện tại (nếu có)...
1. Đo thời gian build Docker image...
#10 2.351       Successfully uninstalled pip-23.0.1
#10 2.923 Successfully installed pip-25.3
#12 268.1 Successfully built imutils
#12 292.5 Successfully installed absl-py-2.3.1 annotated-doc-0.0.4 annotated-types-0.7.0 anyio-4.12.0 astunparse-1.6.3 certifi-2025.11.12 charset_normalizer-3.4.4 click-8.3.1 contourpy-1.3.2 cycler-0.12.1 et-xmlfile-2.0.0 exceptiongroup-1.3.1 fastapi-0.124.0 flatbuffers-25.9.23 fonttools-4.61.0 gast-0.7.0 google_pasta-0.2.0 grpcio-1.76.0 h11-0.16.0 h5py-3.15.1 idna-3.11 imutils-0.5.4 keras-3.12.0 kiwisolver-1.4.9 libclang-18.1.1 markdown-3.10 markdown-it-py-4.0.0 markupsafe-3.0.3 matplotlib-3.10.7 mdurl-0.1.2 ml_dtypes-0.5.4 namex-0.1.0 numpy-2.2.6 opencv-python-4.12.0.88 openpyxl-3.1.5 opt_einsum-3.4.0 optree-0.18.0 packaging-25.0 pandas-2.3.3 pdf2image-1.17.0 pillow-12.0.0 protobuf-6.33.2 pydantic-2.12.5 pydantic-core-2.41.5 pygments-2.19.2 pyparsing-3.2.5 python-dateutil-2.9.0.post0 python-multipart-0.0.20 pytz-2025.2 requests-2.32.5 rich-14.2.0 six-1.17.0 starlette-0.50.0 tensorboard-2.20.0 tensorboard-data-server-0.7.2 tensorflow-2.20.0 termcolor-3.2.0 typing-inspection-0.4.2 typing_extensions-4.15.0 tzdata-2025.2 urllib3-2.6.1 uvicorn-0.38.0 werkzeug-3.1.4 wrapt-2.0.1
Thời gian build: 387.724171584 giây (387724 ms)

2. Đo thời gian start container...
 Container exam-grading-nginx  Created
 Container exam-grading-app  Starting
 Container exam-grading-app  Started
 Container exam-grading-nginx  Starting
 Container exam-grading-nginx  Started
Thời gian start: 5.616303912 giây (5616 ms)

Đợi containers khởi động...
3. Đo thời gian từ start đến khi service ready...
Service ready sau: .136137250 giây (136 ms)

4. Đo thời gian stop container...
 Container exam-grading-app  Removed
 Network automated-multiple-choice-exam-grading_exam-grading-network  Removing
 Network automated-multiple-choice-exam-grading_exam-grading-network  Removed
Thời gian stop: 1.784222759 giây (1784 ms)

=== TỔNG KẾT ===
Build time:     387.724171584 giây (387724 ms)
Start time:     5.616303912 giây (5616 ms)
Ready time:     .136137250 giây (136 ms)
Stop time:      1.784222759 giây (1784 ms)
Tổng (build + start + ready): 393.476612746 giây (393476 ms)

=== KẾT QUẢ ===
File text: measurement_results/startup_time_docker_20251210_144044.txt
File CSV:  measurement_results/startup_time_docker_20251210_144044.csv
Thời gian kết thúc: Wed Dec 10 14:47:30 +07 2025

---

## 2. Dung Lượng Đĩa

=== Đo dung lượng đĩa sử dụng - Mode: docker ===
Thời gian: Wed Dec 10 14:47:30 +07 2025

--- Dung lượng Docker Image và Container ---

1. Kích thước Docker Images:
REPOSITORY                                   TAG         SIZE
automated-multiple-choice-exam-grading-app   latest      5.42GB
nginx                                        alpine      79.8MB
nhmanhdev/exam-grading-update                v2.0        5.34GB
cassandra                                    4.1.7       536MB
nvcr.io/nvidia/tritonserver                  24.09-py3   26.2GB

2. Chi tiết kích thước từng image:
  automated-multiple-choice-exam-grading-app:latest: 1.3GiB
  nginx:alpine: 22MiB
  nhmanhdev/exam-grading-update:v2.0: 1.4GiB
  cassandra:4.1.7: 149MiB
  nvcr.io/nvidia/tritonserver:24.09-py3: 8.6GiB

3. Kích thước Container (đang chạy):
NAMES     SIZE

4. Tổng dung lượng Docker sử dụng:
Images space usage:

REPOSITORY                                   TAG         IMAGE ID       CREATED              SIZE      SHARED SIZE   UNIQUE SIZE   CONTAINERS
automated-multiple-choice-exam-grading-app   latest      fe275fcaa552   About a minute ago   5.42GB    0B            5.422GB       0
nginx                                        alpine      b3c656d55d7a   6 weeks ago          79.8MB    0B            79.81MB       0
nhmanhdev/exam-grading-update                v2.0        31a18713fd79   8 months ago         5.34GB    0B            5.342GB       0
cassandra                                    4.1.7       17850cb6e5f9   14 months ago        536MB     0B            536.5MB       0
nvcr.io/nvidia/tritonserver                  24.09-py3   70db67008ce8   14 months ago        26.2GB    0B            26.22GB       0

Containers space usage:

CONTAINER ID   IMAGE     COMMAND   LOCAL VOLUMES   SIZE      CREATED   STATUS    NAMES

Local Volumes space usage:

VOLUME NAME                                                        LINKS     SIZE
3a166c3264e68ecdbdd982c4fb6d59786191c38d0856ae051759011b90660bcf   0         0B
74a080a2e02c845b87f130137d228c4d080ee50a8e134f5bf9d55e511e896f42   0         96B
97ff9b8d3362a782abf3253dbaacae49372f80dc7ae453889f34d687d42e2a4a   0         0B
ea77a8fee8543bb0500232aee0cf07bfb83fea7f1e6cd79e6a3e70e171265fb2   0         0B
ee5bb142f94e820d2839c403897f3f79db2782cd017079941ccfae4ebe565ffb   0         229.7MB
118acd598842cee021bb0f3931e78d444cea3464b90cbbbdafa7f529542ae543   0         96B
628dbcf7aef1797aa9d05b49750fa56c10d8124c3ed33ecac1843043abc0d75a   0         0B
6847a6ef55d4df7af16e1cf85a397df8210a12572562b6ff12b0048bd39079c8   0         67.11MB
b8ca1b224bf58d2a1b32656df90327b9f4e3b49f516c3372efe903eeabc4b25f   0         457B
be089f0d1b0ab806214814fd3bc6ff1346414071c2b9b47f4cadd84363b9fa05   0         96B

Build cache usage: 15.65GB

CACHE ID       CACHE TYPE     SIZE      CREATED              LAST USED        USAGE     SHARED
te9hjhpv4l2h   regular        117MB     2 months ago         2 months ago     1         false
17hvndnbu28b   regular        6.23MB    2 months ago         2 months ago     1         false
w6ndg5vxtgtt   regular        62.7MB    2 months ago         2 months ago     1         false
j9b93p04luzy   regular        8.29kB    2 months ago         2 months ago     1         false
173yayo9ed3a   source.local   8.19kB    2 months ago         2 months ago     1         false
hv8p4evi6s9s   regular        13.5kB    2 months ago         2 months ago     1         false
ke4cvkd7lo3v   regular        44.8MB    2 months ago         2 months ago     1         false
y5ytl8lyqm06   source.local   8.19kB    2 months ago         2 months ago     1         false
8lr6mxrnxq3k   regular        16.6kB    2 months ago         2 months ago     1         false
xbsru8zybtp2   source.local   4.1kB     2 months ago         2 months ago     1         false
yeccxlhqxrwc   regular        12.8MB    6 weeks ago          6 weeks ago      1         true
x4ecaalcuax7   regular        7.25MB    6 weeks ago          6 weeks ago      1         false
53cmz9rq8qo6   regular        8.82kB    6 weeks ago          6 weeks ago      1         false
p8gvf3dw8ki4   regular        13.2kB    6 weeks ago          6 weeks ago      1         false
vy6rt9ack1ay   regular        12.7kB    6 weeks ago          6 weeks ago      1         false
vseepjn9utvs   regular        13.5kB    6 weeks ago          6 weeks ago      1         false
ac2mekd68dso   regular        17.8kB    6 weeks ago          6 weeks ago      1         false
s7d4oxqo8u8m   regular        59.6MB    6 weeks ago          6 weeks ago      1         false
qluklbzi93lt   regular        21.6kB    6 weeks ago          6 weeks ago      1         false
8xsrcorn9a1o   regular        96kB      6 weeks ago          6 weeks ago      1         false
tq9pqpq1qm1y   regular        78.9MB    6 weeks ago          6 weeks ago      1         false
04jc8mt1effv   regular        8.22kB    6 weeks ago          6 weeks ago      3         false
ftzmurjfctj5   source.local   8.19kB    6 weeks ago          6 weeks ago      4         false
1jo6cme7uuck   regular        8.22kB    6 weeks ago          6 weeks ago      1         false
gx865ycx6md6   regular        47.9kB    6 weeks ago          6 weeks ago      1         false
83qv7lmdm3zb   source.local   8.19kB    6 weeks ago          6 weeks ago      4         false
wlsxy6dzna39   regular        78.9MB    6 weeks ago          6 weeks ago      1         false
9i774f5vekki   source.local   39.5MB    6 weeks ago          6 weeks ago      4         false
nybi5xfw3cfd   regular        117MB     2 weeks ago          2 weeks ago      1         false
iyi9qwbqeveg   regular        6.23MB    2 weeks ago          2 weeks ago      1         false
sxbi4vphu4u7   regular        59.5MB    2 weeks ago          2 weeks ago      1         false
twbx3nwopojp   regular        7.35MB    2 weeks ago          2 weeks ago      1         true
y0qmrf2nq2k1   regular        3.64MB    2 weeks ago          2 weeks ago      1         false
e31tq9j5kkqu   regular        8.82kB    2 weeks ago          2 weeks ago      1         true
wwgjk4rf8y9c   regular        162MB     2 weeks ago          2 weeks ago      1         false
36udjs34wrpm   regular        13.2kB    2 weeks ago          2 weeks ago      1         true
7lkbh7fyhj1q   regular        6.73MB    2 weeks ago          2 weeks ago      1         false
icy68l81rcq6   regular        12.7kB    2 weeks ago          2 weeks ago      1         true
o02szxfon5vx   regular        13.5kB    2 weeks ago          2 weeks ago      1         true
seof5vdftug3   regular        17.8kB    2 weeks ago          2 weeks ago      1         true
vmzh48g05kis   regular        59.6MB    2 weeks ago          2 weeks ago      1         true
90udo5gfdar8   regular        140MB     2 weeks ago          2 weeks ago      1         false
q01c5yhtctd8   regular        20.9kB    2 weeks ago          2 weeks ago      1         false
qyzoxmfs4xud   regular        115MB     2 weeks ago          2 weeks ago      1         false
6bs7ftzgksnl   regular        8.19kB    2 weeks ago          2 weeks ago      1         false
n5k9p6i2b5ng   source.local   4.1kB     2 weeks ago          2 weeks ago      1         false
uqtordzwhela   source.local   8.19kB    2 weeks ago          2 weeks ago      1         false
up8hvrctrlhc   source.local   114MB     2 weeks ago          2 weeks ago      1         false
2upbgmvc3de3   regular        115kB     2 weeks ago          2 weeks ago      1         false
lgbd1c1n68w9   regular        12.3kB    2 weeks ago          2 weeks ago      1         false
m2roofhq01so   regular        16.6kB    2 weeks ago          2 weeks ago      1         false
uwnj0x8y5wbl   source.local   86kB      2 weeks ago          2 weeks ago      1         false
o9jfb22ymqi6   regular        8.19kB    2 weeks ago          2 weeks ago      1         false
tyibkm7sajmh   regular        347MB     2 weeks ago          2 weeks ago      1         false
3871me92mnnz   source.local   8.19kB    2 weeks ago          2 weeks ago      1         false
w1ifqq5htppf   source.local   4.1kB     2 weeks ago          2 weeks ago      1         false
duxwczrv3mtw   regular        117MB     2 weeks ago          2 weeks ago      1         false
wxdzuqud6txd   regular        172MB     2 weeks ago          2 weeks ago      1         false
bz43mstgdh57   regular        6.23MB    2 weeks ago          2 weeks ago      1         false
xo0mgxmlzra9   regular        6.73MB    2 weeks ago          2 weeks ago      1         false
dtqetwf7cue1   regular        62.7MB    2 weeks ago          2 weeks ago      1         false
lh9vbm56hasc   regular        20.9kB    2 weeks ago          2 weeks ago      1         false
nrtxj7e0pvn3   source.local   8.19kB    2 weeks ago          2 weeks ago      1         false
c63s4egx5wo1   regular        8.29kB    2 weeks ago          2 weeks ago      1         false
2rjm72fxr7mv   source.local   94.2kB    2 weeks ago          2 weeks ago      1         false
vu8z03yl6shs   regular        12.7kB    2 weeks ago          2 weeks ago      1         false
guo8uoe1peo3   regular        333MB     2 weeks ago          2 weeks ago      1         false
meizwuo7p55p   regular        99.3kB    2 weeks ago          2 weeks ago      1         false
7txjy3sj97km   regular        16.6kB    2 weeks ago          2 weeks ago      1         false
xugsv6a6j88c   regular        12.5kB    2 weeks ago          2 weeks ago      1         false
7wkcwvi6o53a   regular        829MB     2 weeks ago          2 weeks ago      1         false
fqhyj3vp3rco   regular        106kB     2 weeks ago          2 weeks ago      1         false
h5rgke4wcmqm   source.local   8.19kB    2 weeks ago          2 weeks ago      1         false
83vx0ve0vfdv   source.local   102kB     2 weeks ago          2 weeks ago      1         false
l6un5prel25j   source.local   4.1kB     2 weeks ago          2 weeks ago      1         false
6py5ltidz1up   regular        8.29kB    2 weeks ago          2 weeks ago      1         false
t12w2bxmdtic   regular        183MB     10 days ago          10 days ago      1         false
mnncy7d7er9g   regular        90.6MB    10 days ago          10 days ago      1         false
5pwf3udybb30   regular        270MB     10 days ago          10 days ago      1         false
rzzvhuy8h430   regular        930MB     10 days ago          10 days ago      1         false
xsmatvnbmb7w   regular        25.9MB    10 days ago          10 days ago      1         false
oh8nepq91xfi   regular        82.7MB    10 days ago          10 days ago      1         false
soj8qcdni51y   regular        12.6kB    10 days ago          10 days ago      1         false
qzlnw9yasd0g   regular        14kB      10 days ago          10 days ago      1         false
3dv2nu0eh3gk   regular        993kB     10 days ago          10 days ago      1         false
t2u0lax1mskj   regular        418MB     10 days ago          10 days ago      1         false
3weyckzvi0mf   regular        23.7MB    10 days ago          10 days ago      1         false
obv1gyp391a3   regular        18kB      10 days ago          10 days ago      1         false
qwflfnzwvevh   regular        23.4kB    10 days ago          10 days ago      1         false
o4e2lr42xqcc   regular        23.5kB    10 days ago          10 days ago      1         false
1b53q5fhgfyv   regular        6.81MB    10 days ago          10 days ago      1         false
twme0nq1n68y   regular        11.3MB    10 days ago          10 days ago      1         false
4imm6iqvt3lc   regular        16.6kB    10 days ago          10 days ago      4         false
b3qgao7elt7w   regular        8.22kB    10 days ago          10 days ago      1         false
vj7evzwzojjc   regular        8.29kB    10 days ago          10 days ago      1         false
wt21avjuc34n   regular        581MB     10 days ago          10 days ago      1         false
noktxw8o6jsh   regular        23.7kB    10 days ago          10 days ago      1         false
qmx305qql0hr   regular        28.9kB    10 days ago          10 days ago      1         false
yeqetr7bn15q   regular        14.8MB    10 days ago          10 days ago      1         false
wv9stqdx4q61   regular        148kB     10 days ago          10 days ago      1         false
jyvxu3k3r7su   regular        12.4kB    10 days ago          2 days ago       2         false
g00zmg1fk73j   regular        183MB     3 hours ago          3 hours ago      1         false
qptp2ygduvdy   regular        90.6MB    3 hours ago          3 hours ago      1         false
v8rpfp94rqz8   regular        270MB     3 hours ago          3 hours ago      1         false
vstcinx9m505   regular        930MB     3 hours ago          3 hours ago      1         false
xsxv20oejrzg   regular        25.9MB    3 hours ago          3 hours ago      1         false
yjh18f76k90j   regular        82.7MB    3 hours ago          3 hours ago      1         false
5lyvdezvrwvv   regular        6.81MB    2 hours ago          2 hours ago      1         false
jo63amuq9i9t   regular        418MB     2 hours ago          2 hours ago      1         false
kov6ganik4ij   regular        12.4kB    2 hours ago          2 hours ago      1         false
sns34kgwc32f   regular        23.5kB    2 hours ago          2 hours ago      1         false
mq5l7rjzy93g   regular        23.7kB    2 hours ago          2 hours ago      1         false
v3nm3tdb5bd6   regular        18kB      2 hours ago          2 hours ago      1         false
ulfb635p3fxd   regular        12.6kB    2 hours ago          2 hours ago      1         false
8az8mx9t8nva   regular        581MB     2 hours ago          2 hours ago      1         false
5ncjjq28df9h   regular        14kB      2 hours ago          2 hours ago      1         false
xf0lioym769y   regular        11.3MB    2 hours ago          2 hours ago      1         false
ygbk8ersagxv   regular        993kB     2 hours ago          2 hours ago      1         false
p1xgydxbrwdc   regular        14.8MB    2 hours ago          2 hours ago      1         false
oba91u6qqood   regular        148kB     2 hours ago          2 hours ago      1         false
4ailldk1y8hg   regular        8.28kB    2 hours ago          2 hours ago      1         false
rp8cr12pxu89   regular        23.4kB    2 hours ago          2 hours ago      1         false
mapyjsumiv0u   regular        8.22kB    2 hours ago          2 hours ago      1         false
jxhlngqua3lw   regular        28.9kB    2 hours ago          2 hours ago      1         false
ixhlz99ehm6j   regular        23.7MB    2 hours ago          2 hours ago      2         false
m28lgbmc7pbd   source.local   19.9MB    10 days ago          2 hours ago      7         false
bm0qljlgzbsz   regular        23.7kB    2 hours ago          2 hours ago      1         false
9q886uz5fger   regular        6.81MB    2 hours ago          2 hours ago      1         false
xtbttzzu5xne   source.local   8.19kB    10 days ago          2 hours ago      7         false
oj6ccby0nr81   regular        3.36GB    2 hours ago          2 hours ago      1         false
zjbjaw0dudok   regular        23.4kB    2 hours ago          2 hours ago      1         false
n2p0nhyrx6ex   regular        18kB      2 hours ago          2 hours ago      1         false
jcqfks8e76l1   regular        8.22kB    2 hours ago          2 hours ago      1         false
rbh9ka9fuqnp   regular        993kB     2 hours ago          2 hours ago      1         false
p0u3pl9920v9   regular        28.9kB    2 hours ago          2 hours ago      1         false
iar8ycwvrb9k   source.local   8.19kB    10 days ago          2 hours ago      7         false
4v6spgsu05z0   regular        148kB     2 hours ago          2 hours ago      1         false
pwi94xw72ch9   regular        14.8MB    2 hours ago          2 hours ago      1         false
kdwhqqwqap1k   regular        12.6kB    2 hours ago          2 hours ago      1         false
ap53ndfuhlny   regular        11.3MB    2 hours ago          2 hours ago      1         false
tsmvjsvwammj   regular        23.5kB    2 hours ago          2 hours ago      1         false
3bo752pd8xda   regular        14kB      2 hours ago          2 hours ago      1         false
xgx2ua19farv   regular        12.4kB    2 hours ago          2 hours ago      1         false
lmyqr9g6mwe2   regular        18kB      About a minute ago   12 seconds ago   1         false
v1givpue4hjx   regular        418MB     6 minutes ago        12 seconds ago   1         false
el55vjrr06me   regular        14kB      About a minute ago   12 seconds ago   1         false
qkupr4k2bkl7   regular        3.36GB    About a minute ago   12 seconds ago   1         false
jr774dn5s1et   regular        23.5kB    About a minute ago   12 seconds ago   1         false
p9zxf97w9mtx   regular        12.6kB    6 minutes ago        12 seconds ago   1         false
820jcd88se2p   regular        8.22kB    About a minute ago   12 seconds ago   1         false
nxsqghimcujo   regular        993kB     About a minute ago   12 seconds ago   1         false
pcxzbvv01vd9   source.local   19.9MB    6 minutes ago        12 seconds ago   1         false
35s9turv9lp7   regular        12.4kB    About a minute ago   12 seconds ago   1         false
wxl868fw2trk   regular        11.3MB    About a minute ago   12 seconds ago   1         false
ju61gxqpdnqw   regular        148kB     About a minute ago   12 seconds ago   1         false
3qtm9ftln5r9   regular        16.6kB    3 hours ago          12 seconds ago   2         false
ffg3r8oc70mr   source.local   8.19kB    6 minutes ago        12 seconds ago   1         false
3m3ibipi9v4m   regular        23.7MB    6 minutes ago        12 seconds ago   1         false
i4swqjojf9ex   source.local   8.19kB    6 minutes ago        12 seconds ago   1         false
swkev2i7ew3w   regular        14.8MB    About a minute ago   12 seconds ago   1         false
6vpy0qv30ml6   regular        23.7kB    About a minute ago   12 seconds ago   1         false
te8s0kfqr8t4   regular        6.81MB    About a minute ago   12 seconds ago   1         false
m0cdxrrde2ja   regular        28.9kB    About a minute ago   12 seconds ago   1         false
yhyek431ioj4   regular        8.29kB    6 minutes ago        12 seconds ago   1         false
nuddms57ed58   regular        23.4kB    About a minute ago   12 seconds ago   1         false

5. Kích thước Volumes:
  3a166c3264e68ecdbdd982c4fb6d59786191c38d0856ae051759011b90660bcf: 
  74a080a2e02c845b87f130137d228c4d080ee50a8e134f5bf9d55e511e896f42: 
  97ff9b8d3362a782abf3253dbaacae49372f80dc7ae453889f34d687d42e2a4a: 
  118acd598842cee021bb0f3931e78d444cea3464b90cbbbdafa7f529542ae543: 
  628dbcf7aef1797aa9d05b49750fa56c10d8124c3ed33ecac1843043abc0d75a: 
  6847a6ef55d4df7af16e1cf85a397df8210a12572562b6ff12b0048bd39079c8: 
  b8ca1b224bf58d2a1b32656df90327b9f4e3b49f516c3372efe903eeabc4b25f: 
  be089f0d1b0ab806214814fd3bc6ff1346414071c2b9b47f4cadd84363b9fa05: 
  ea77a8fee8543bb0500232aee0cf07bfb83fea7f1e6cd79e6a3e70e171265fb2: 
  ee5bb142f94e820d2839c403897f3f79db2782cd017079941ccfae4ebe565ffb: 

6. Kích thước thư mục dự án:
48M	.
0	results/
40K	scripts/
92K	measurement_results/
108K	AnswerKey/
108K	wiki/
492K	static/
916K	create_dataset/
7.2M	Exam/

Kết quả đã được lưu vào: measurement_results/disk_usage_docker_20251210_144730.txt

---

## 3. Sử Dụng Tài Nguyên Khi Idle

=== Đo mức sử dụng RAM và CPU - Mode: docker ===
Thời gian đo: 60 giây
Thời gian bắt đầu: Wed Dec 10 14:47:33 +07 2025

--- Đo tài nguyên Docker Container ---

Khởi động container...
 Network automated-multiple-choice-exam-grading_exam-grading-network  Creating
 Network automated-multiple-choice-exam-grading_exam-grading-network  Created
 Container exam-grading-app  Creating
 Container exam-grading-app  Created
 Container exam-grading-nginx  Creating
 Container exam-grading-nginx  Created
 Container exam-grading-app  Starting
 Container exam-grading-app  Started
 Container exam-grading-nginx  Starting
 Container exam-grading-nginx  Started
Đang đo trong 60 giây...
Timestamp,Container,CPU %,Memory (MB),Memory %
2025-12-10 14:47:44,exam-grading-app,0.24,240,1.51
2025-12-10 14:47:44,exam-grading-nginx,0.00,9.992,0.06
2025-12-10 14:47:49,exam-grading-app,0.17,240,1.51
2025-12-10 14:47:49,exam-grading-nginx,0.00,9.992,0.06
2025-12-10 14:47:53,exam-grading-app,0.20,240,1.51
2025-12-10 14:47:53,exam-grading-nginx,0.00,9.992,0.06
2025-12-10 14:48:01,exam-grading-app,0.23,240,1.51
2025-12-10 14:48:01,exam-grading-nginx,0.00,9.992,0.06
2025-12-10 14:48:06,exam-grading-app,0.23,240,1.51
2025-12-10 14:48:06,exam-grading-nginx,0.00,9.984,0.06
2025-12-10 14:48:11,exam-grading-app,2.80,240,1.51
2025-12-10 14:48:11,exam-grading-nginx,0.00,9.984,0.06
2025-12-10 14:48:15,exam-grading-app,0.22,240,1.51
2025-12-10 14:48:15,exam-grading-nginx,0.00,9.984,0.06
2025-12-10 14:48:20,exam-grading-app,0.26,240,1.51
2025-12-10 14:48:20,exam-grading-nginx,0.00,9.984,0.06
2025-12-10 14:48:25,exam-grading-app,0.26,240,1.51
2025-12-10 14:48:25,exam-grading-nginx,0.00,9.984,0.06
2025-12-10 14:48:33,exam-grading-app,0.22,240,1.51
2025-12-10 14:48:33,exam-grading-nginx,0.00,9.984,0.06
2025-12-10 14:48:37,exam-grading-app,0.26,240,1.51
2025-12-10 14:48:37,exam-grading-nginx,0.00,10.1,0.06
2025-12-10 14:48:42,exam-grading-app,0.29,240,1.51
2025-12-10 14:48:42,exam-grading-nginx,0.00,9.988,0.06

--- Thống kê tổng hợp ---

Container: exam-grading-app

Container: exam-grading-nginx

Kết quả đã được lưu vào:
  - Text: measurement_results/resource_usage_docker_20251210_144733.txt
  - CSV: measurement_results/resource_usage_docker_20251210_144733.csv
Thời gian kết thúc: Wed Dec 10 14:48:47 +07 2025

---

## 4. Thông Lượng (Throughput)

=== Đo thông lượng (Throughput) - Mode: docker ===
Tool: ab
Concurrent requests: 10
Total requests: 1000
Thời gian bắt đầu: Wed Dec 10 14:48:47 +07 2025

Testing URL: http://localhost/

--- Chạy Apache Bench (ab) ---

Warm-up: 10 requests...
Chạy test chính...
This is ApacheBench, Version 2.3 <$Revision: 1903618 $>
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


Server Software:        nginx/1.29.3
Server Hostname:        localhost
Server Port:            80

Document Path:          /
Document Length:        0 bytes

Concurrency Level:      10
Time taken for tests:   0.547 seconds
Complete requests:      1000
Failed requests:        0
Non-2xx responses:      1000
Total transferred:      162000 bytes
HTML transferred:       0 bytes
Requests per second:    1829.82 [#/sec] (mean)
Time per request:       5.465 [ms] (mean)
Time per request:       0.547 [ms] (mean, across all concurrent requests)
Transfer rate:          289.48 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       0
Processing:     2    5   1.4      5      14
Waiting:        2    5   1.4      5      14
Total:          2    5   1.4      5      14

Percentage of the requests served within a certain time (ms)
  50%      5
  66%      5
  75%      6
  80%      6
  90%      7
  95%      8
  98%      9
  99%     10
 100%     14 (longest request)

Chi tiết đã được lưu vào: measurement_results/ab_docker_20251210_144847.tsv

--- Đo tài nguyên trong khi test ---
90d761e371c4,0.00%,10.94MiB / 15.47GiB
d4d8b2ad99d4,0.23%,240.3MiB / 15.47GiB
90d761e371c4,0.00%,10.89MiB / 15.47GiB
d4d8b2ad99d4,0.18%,240.3MiB / 15.47GiB
90d761e371c4,0.00%,10.89MiB / 15.47GiB
d4d8b2ad99d4,0.25%,240.3MiB / 15.47GiB
90d761e371c4,0.00%,10.89MiB / 15.47GiB
d4d8b2ad99d4,0.26%,240.3MiB / 15.47GiB
90d761e371c4,0.00%,10.89MiB / 15.47GiB
d4d8b2ad99d4,0.21%,240.3MiB / 15.47GiB
90d761e371c4,0.00%,10.89MiB / 15.47GiB
d4d8b2ad99d4,0.24%,240.3MiB / 15.47GiB
90d761e371c4,0.00%,10.89MiB / 15.47GiB
d4d8b2ad99d4,0.23%,240.3MiB / 15.47GiB
90d761e371c4,0.00%,10.89MiB / 15.47GiB
d4d8b2ad99d4,2.60%,240.4MiB / 15.47GiB
90d761e371c4,0.00%,10.89MiB / 15.47GiB
d4d8b2ad99d4,0.26%,240.3MiB / 15.47GiB
90d761e371c4,0.00%,10.89MiB / 15.47GiB
d4d8b2ad99d4,0.24%,240.3MiB / 15.47GiB
90d761e371c4,0.00%,10.89MiB / 15.47GiB
d4d8b2ad99d4,0.24%,240.3MiB / 15.47GiB
90d761e371c4,0.00%,10.89MiB / 15.47GiB
d4d8b2ad99d4,0.25%,240.3MiB / 15.47GiB
90d761e371c4,0.00%,10.89MiB / 15.47GiB
d4d8b2ad99d4,0.26%,240.3MiB / 15.47GiB
90d761e371c4,0.00%,10.89MiB / 15.47GiB
d4d8b2ad99d4,0.27%,240.3MiB / 15.47GiB
90d761e371c4,1.62%,11.12MiB / 15.47GiB
d4d8b2ad99d4,0.24%,240.3MiB / 15.47GiB
90d761e371c4,0.00%,10.89MiB / 15.47GiB
d4d8b2ad99d4,0.26%,240.3MiB / 15.47GiB

Kết quả đã được lưu vào: measurement_results/throughput_docker_ab_20251210_144847.txt
Thời gian kết thúc: Wed Dec 10 14:49:50 +07 2025

---

## 5. Sử Dụng Tài Nguyên Khi Có Tải

=== Đo mức sử dụng RAM và CPU - Mode: docker ===
Thời gian đo: 60 giây
Thời gian bắt đầu: Wed Dec 10 14:49:50 +07 2025

--- Đo tài nguyên Docker Container ---

Đang đo trong 60 giây...
Timestamp,Container,CPU %,Memory (MB),Memory %
2025-12-10 14:49:50,exam-grading-app,0.99,240.3,1.52
2025-12-10 14:49:50,exam-grading-nginx,61.42,14.15,0.09
2025-12-10 14:49:55,exam-grading-app,0.21,242.2,1.53
2025-12-10 14:49:55,exam-grading-nginx,0.00,11.68,0.07
2025-12-10 14:50:00,exam-grading-app,0.24,242.2,1.53
2025-12-10 14:50:00,exam-grading-nginx,0.00,11.68,0.07
2025-12-10 14:50:07,exam-grading-app,0.24,242.2,1.53
2025-12-10 14:50:07,exam-grading-nginx,0.00,11.68,0.07
2025-12-10 14:50:12,exam-grading-app,0.26,242.2,1.53
2025-12-10 14:50:12,exam-grading-nginx,0.00,11.68,0.07
2025-12-10 14:50:17,exam-grading-app,0.25,242.2,1.53
2025-12-10 14:50:17,exam-grading-nginx,0.00,11.68,0.07
2025-12-10 14:50:22,exam-grading-app,2.44,242.3,1.53
2025-12-10 14:50:22,exam-grading-nginx,0.00,11.68,0.07
2025-12-10 14:50:27,exam-grading-app,0.21,242.2,1.53
2025-12-10 14:50:27,exam-grading-nginx,0.00,11.68,0.07
2025-12-10 14:50:32,exam-grading-app,0.35,242.2,1.53
2025-12-10 14:50:32,exam-grading-nginx,0.00,11.68,0.07
2025-12-10 14:50:36,exam-grading-app,0.24,242.2,1.53
2025-12-10 14:50:36,exam-grading-nginx,0.00,11.68,0.07
2025-12-10 14:50:44,exam-grading-app,0.19,242.2,1.53
2025-12-10 14:50:44,exam-grading-nginx,0.00,11.68,0.07
2025-12-10 14:50:48,exam-grading-app,0.27,242.2,1.53
2025-12-10 14:50:48,exam-grading-nginx,0.00,11.75,0.07

--- Thống kê tổng hợp ---

Container: exam-grading-app

Container: exam-grading-nginx

Kết quả đã được lưu vào:
  - Text: measurement_results/resource_usage_docker_20251210_144950.txt
  - CSV: measurement_results/resource_usage_docker_20251210_144950.csv
Thời gian kết thúc: Wed Dec 10 14:50:54 +07 2025

---

## Tổng Kết

Báo cáo này bao gồm các phép đo:
1. Thời gian khởi động dịch vụ
2. Dung lượng đĩa sử dụng
3. Mức sử dụng RAM và CPU khi idle
4. Thông lượng (requests/giây)
5. Mức sử dụng RAM và CPU khi có tải

Tất cả các file chi tiết được lưu trong thư mục: `measurement_results/`

**Thời gian hoàn thành:** Wed Dec 10 14:50:54 +07 2025
