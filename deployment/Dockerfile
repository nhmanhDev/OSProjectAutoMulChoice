# Sử dụng image Python 3.10 làm base
FROM python:3.10

# Cài đặt các phụ thuộc hệ thống cần thiết
RUN apt-get update && apt-get install -y \
    poppler-utils \
    libgl1 \
    libglib2.0-0 \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# RUN apt-get update 
# RUN apt-get -y install python3

# Cập nhật pip để tránh cảnh báo (tùy chọn)
RUN pip install --upgrade pip

# Sao chép file requirements.txt và cài đặt các thư viện
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Sao chép các file Python và file trọng số
COPY app/ ./app/
COPY weight.keras ./weight.keras
COPY requirements.txt ./requirements.txt
RUN ls -l /src/weight.keras  # Add this line to check if the file exists

# Copy React build (build trước khi docker build bằng: cd frontend && npm run build)
# Nếu frontend/dist tồn tại, FastAPI sẽ dùng nó; nếu không, dùng static cũ
COPY favicon.ico ./favicon.ico
# Copy cả hai, FastAPI sẽ ưu tiên frontend/dist nếu có
COPY frontend/ ./frontend/
# Copy static nếu tồn tại (sẽ fail nếu không có, nhưng có thể bỏ qua nếu không cần)
COPY static/ ./static/

# Sao chép thư mục data và tools
COPY data/ ./data/
# Copy tools nếu tồn tại
COPY tools/ ./tools/


# Mở cổng 8000 để truy cập vào ứng dụng FastAPI
EXPOSE 8000

# Chạy ứng dụng FastAPI với uvicorn
CMD ["uvicorn", "app.user_interface:app", "--host", "0.0.0.0", "--port", "8000"]
# CMD ["uvicorn", "user_interface:app", "--reload"]
