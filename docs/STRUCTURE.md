# Cấu trúc Project

## Tổng quan

Project đã được tổ chức lại với cấu trúc rõ ràng, dễ quản lý.

## Cấu trúc Folder

```
Automated-Multiple-Choice-Exam-Grading/
│
├── app/                          # Backend Application
│   ├── __init__.py
│   ├── main.py                   # Xử lý chính: process_exam_sheet()
│   ├── model_answer.py           # CNN model cho nhận diện đáp án
│   ├── process_answer.py         # Xử lý và nhận diện đáp án
│   ├── process_sbd_mdt.py        # Xử lý SBD (Số báo danh) và MDT (Mã đề thi)
│   └── user_interface.py        # FastAPI server và API endpoints
│
├── frontend/                      # React Frontend
│   ├── src/                      # Source code
│   │   ├── pages/                # Các trang
│   │   ├── components/           # Components
│   │   └── ...
│   ├── dist/                     # Build output (sau npm run build)
│   ├── package.json
│   └── vite.config.ts
│
├── data/                         # Data Files
│   ├── Exam/                     # Ảnh bài thi mẫu
│   ├── AnswerKey/                # File đáp án Excel
│   └── results/                  # Kết quả chấm điểm (ảnh đã chú thích)
│
├── scripts/                      # Measurement & Testing Scripts
│   ├── measure_startup_time.sh
│   ├── measure_disk_usage.sh
│   ├── measure_resource_usage.sh
│   ├── measure_throughput.sh
│   ├── run_all_measurements.sh
│   ├── wrk_script.lua
│   └── measurement_results/      # Kết quả đo lường
│
├── tools/                        # Utility Tools
│   └── create_dataset/           # Scripts tạo dataset cho training
│       ├── data_for_CNN.py
│       ├── dataset_forCNN.py
│       └── dataset/              # Dataset images
│
├── deployment/                   # Deployment Configuration
│   ├── Dockerfile                # Docker image config
│   ├── docker-compose.yml        # Docker Compose config
│   └── nginx.conf                # Nginx reverse proxy config
│
├── docs/                         # Documentation
│   ├── README.md                 # Main README (moved from root)
│   ├── README_FRONTEND.md        # Frontend guide
│   ├── STRUCTURE.md              # This file
│   └── wiki/                     # Wiki documentation
│       ├── WIKI.md
│       ├── DEPLOYMENT_AND_MEASUREMENT_GUIDE.md
│       └── ...
│
├── static/                       # Static files (fallback UI)
│   └── index.html                # Old HTML interface
│
├── requirements.txt              # Python dependencies
├── weight.keras                  # Trained CNN model weights
└── favicon.ico                   # Favicon
```

## Quy tắc tổ chức

### 1. **app/** - Backend Code
- Tất cả Python code xử lý logic
- FastAPI server
- Model và processing functions

### 2. **frontend/** - Frontend Code
- React application
- Source code trong `src/`
- Build output trong `dist/`

### 3. **data/** - Data Files
- Input: `Exam/`, `AnswerKey/`
- Output: `results/`

### 4. **scripts/** - Scripts
- Measurement scripts
- Testing scripts
- Results trong `measurement_results/`

### 5. **tools/** - Utility Tools
- Dataset creation
- Training tools
- Helper scripts

### 6. **deployment/** - Deployment
- Docker configs
- Nginx config
- Docker Compose

### 7. **docs/** - Documentation
- README files
- Wiki
- Guides

## Lưu ý

- **Paths trong code**: Tất cả paths trong Python code đều relative từ working directory (`/src` trong Docker)
- **Docker**: Build context là root, Dockerfile trong `deployment/`
- **Static files**: `static/` giữ làm fallback nếu không build frontend

