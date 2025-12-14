# Troubleshooting - Xử lý lỗi

## Lỗi "Đã xảy ra lỗi khi gửi yêu cầu"

### Nguyên nhân có thể:

1. **Backend chưa chạy**
   - Kiểm tra: Backend FastAPI có đang chạy không?
   - Giải pháp: Chạy backend trước:
     ```bash
     cd app
     python user_interface.py
     ```
     Hoặc:
     ```bash
     uvicorn app.user_interface:app --reload --host 0.0.0.0 --port 8000
     ```

2. **CORS Error**
   - Đã thêm CORS middleware, nhưng nếu vẫn lỗi, kiểm tra:
     - Frontend đang chạy ở port nào?
     - Backend đang chạy ở port nào?
   - Giải pháp: Đảm bảo CORS đã được cấu hình trong `app/user_interface.py`

3. **Paths không đúng**
   - Khi chạy local, paths có thể khác với Docker
   - Giải pháp: Đã fix paths tự động detect từ vị trí file

4. **Import errors**
   - Kiểm tra: Có lỗi import trong console/terminal không?
   - Giải pháp: Đảm bảo chạy từ root directory hoặc cài đặt đúng dependencies

### Cách debug:

1. **Kiểm tra Console (Browser)**
   - Mở Developer Tools (F12)
   - Xem tab Console và Network
   - Kiểm tra request `/upload-image` có được gửi không?
   - Xem response từ server

2. **Kiểm tra Backend Logs**
   - Xem terminal nơi chạy FastAPI
   - Tìm các dòng log bắt đầu bằng "Received upload request", "Error in upload_files"
   - Traceback sẽ hiển thị lỗi cụ thể

3. **Test API trực tiếp**
   ```bash
   # Test với curl
   curl -X POST http://localhost:8000/upload-image \
     -F "image=@data/Exam/Test10diem.jpg" \
     -F "answer_key=@data/AnswerKey/FullC.xlsx"
   ```

### Các lỗi thường gặp:

#### 1. ModuleNotFoundError
```
ModuleNotFoundError: No module named 'main'
```
**Giải pháp**: Chạy từ root directory:
```bash
# Từ root
uvicorn app.user_interface:app --reload
```

#### 2. FileNotFoundError
```
FileNotFoundError: [Errno 2] No such file or directory: 'data/results/...'
```
**Giải pháp**: Đã tự động tạo thư mục, nhưng nếu vẫn lỗi, tạo thủ công:
```bash
mkdir -p data/results
```

#### 3. Weight file not found
```
FileNotFoundError: weight.keras
```
**Giải pháp**: Đảm bảo `weight.keras` ở root directory

#### 4. CORS Error trong browser
```
Access to fetch at 'http://localhost:8000/upload-image' from origin 'http://localhost:3000' has been blocked by CORS policy
```
**Giải pháp**: Đã thêm CORS middleware, restart backend

## Kiểm tra nhanh

1. Backend đang chạy? → `curl http://localhost:8000/`
2. Frontend đang chạy? → Mở `http://localhost:3000`
3. API accessible? → Kiểm tra Network tab trong DevTools
4. Paths đúng? → Xem logs trong terminal backend

