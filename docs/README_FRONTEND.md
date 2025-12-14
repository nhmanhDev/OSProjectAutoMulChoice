# Hướng dẫn tích hợp Frontend React

## Tổng quan

Hệ thống đã được tích hợp với React frontend từ UI Design. Frontend được build và serve qua FastAPI.

## Cấu trúc

```
frontend/
  src/              # Source code React
  dist/             # Build output (sau khi chạy npm run build)
  package.json
  vite.config.ts
```

## Build Frontend

### 1. Cài đặt dependencies
```bash
cd frontend
npm install
```

### 2. Build production
```bash
npm run build
```

Sau khi build, files sẽ được tạo trong `frontend/dist/`

### 3. Chạy development (tùy chọn)
```bash
npm run dev
```

## Tích hợp với FastAPI

FastAPI tự động detect và serve:
- **Ưu tiên**: `frontend/dist/` (nếu tồn tại)
- **Fallback**: `static/` (giao diện cũ)

## API Endpoints

Frontend gọi API:
- `POST /upload-image` - Upload ảnh bài thi và đáp án, trả về kết quả chấm điểm

## Docker Build

Trước khi build Docker image, cần build React frontend:

```bash
# Build frontend
cd frontend
npm install
npm run build

# Quay lại root và build Docker
cd ..
docker compose build
```

## Các trang

- `/` - Trang chủ
- `/cham-diem` - Chấm điểm bài thi
- `/ket-qua` - Xem kết quả chi tiết
- `/lich-su` - Lịch sử chấm điểm
- `/gioi-thieu` - Giới thiệu

## Lưu ý

- Đảm bảo build frontend trước khi deploy
- Nếu không build frontend, hệ thống sẽ dùng giao diện cũ từ `static/`
- API trả về dữ liệu theo format:
  ```json
  {
    "status": "success",
    "sbd": "...",
    "mdt": "...",
    "correct_answers": 100,
    "total_questions": 120,
    "final_score": 8.33,
    "score": 8.33,
    "percentage": 83.3,
    "details": [...],
    "annotated_image_url": "/results/..."
  }
  ```

