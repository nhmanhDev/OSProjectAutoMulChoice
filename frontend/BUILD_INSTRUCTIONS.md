# Hướng dẫn Build Frontend React

## Yêu cầu
- Node.js 18+ 
- npm hoặc yarn

## Các bước build

### 1. Cài đặt dependencies
```bash
cd frontend
npm install
```

### 2. Build production
```bash
npm run build
```

Sau khi build, các file sẽ được tạo trong thư mục `frontend/dist/`

### 3. Chạy development server (tùy chọn)
```bash
npm run dev
```

Development server sẽ chạy tại `http://localhost:3000`

## Lưu ý

- Sau khi build, FastAPI sẽ tự động serve files từ `frontend/dist/` nếu thư mục này tồn tại
- Nếu không có `frontend/dist/`, hệ thống sẽ fallback về `static/` (giao diện cũ)
- Đảm bảo build trước khi deploy với Docker

## Cấu trúc sau khi build

```
frontend/
  dist/          # Files đã build (được serve bởi FastAPI)
  src/           # Source code
  package.json
  vite.config.ts
```

