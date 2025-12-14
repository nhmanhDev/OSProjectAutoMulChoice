# X-Exam Grader - Hệ thống chấm điểm bài thi trắc nghiệm tự động

Hệ thống chấm điểm bài thi trắc nghiệm sử dụng AI và xử lý ảnh.

## Cấu trúc Project

```
├── app/                    # Backend Python code
│   ├── main.py            # Xử lý chính
│   ├── model_answer.py    # CNN model
│   ├── process_answer.py  # Xử lý đáp án
│   ├── process_sbd_mdt.py # Xử lý SBD và MDT
│   └── user_interface.py   # FastAPI server
│
├── frontend/              # React frontend
│   ├── src/               # Source code
│   └── dist/              # Build output (sau npm run build)
│
├── data/                  # Data files
│   ├── Exam/              # Ảnh bài thi mẫu
│   ├── AnswerKey/         # File đáp án
│   └── results/           # Kết quả chấm điểm
│
├── scripts/               # Measurement scripts
│   ├── measure_*.sh       # Scripts đo lường
│   └── measurement_results/ # Kết quả đo lường
│
├── tools/                 # Utility tools
│   └── create_dataset/    # Tạo dataset cho training
│
├── deployment/            # Deployment configs
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── nginx.conf
│
├── docs/                  # Documentation
│   ├── README.md          # Main README
│   ├── README_FRONTEND.md # Frontend guide
│   └── wiki/              # Wiki documentation
│
├── static/                # Static files (fallback)
├── requirements.txt       # Python dependencies
└── weight.keras           # Trained model weights
```

## Quick Start

### 1. Cài đặt dependencies

```bash
# Backend
pip install -r requirements.txt

# Frontend
cd frontend
npm install
npm run build
cd ..
```

### 2. Chạy với Docker

```bash
cd deployment
docker compose up
```

### 3. Chạy local development

```bash
# Backend
cd app
python user_interface.py

# Frontend (terminal khác)
cd frontend
npm run dev
```

## Xem thêm

- [Frontend Guide](docs/README_FRONTEND.md) - Hướng dẫn frontend
- [Wiki](docs/wiki/WIKI.md) - Tài liệu đầy đủ
- [Deployment Guide](docs/wiki/DEPLOYMENT_AND_MEASUREMENT_GUIDE.md) - Hướng dẫn deploy

