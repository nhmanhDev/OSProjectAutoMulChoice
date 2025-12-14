from fastapi import FastAPI, UploadFile, File
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse, RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
import tempfile
import os
import uuid
import sys
from pathlib import Path

# Xử lý import để có thể chạy từ cả root và từ trong app/
# Thêm parent directory vào path nếu chạy từ app/
if __name__ == "__main__" or os.path.basename(os.getcwd()) == "app":
    # Chạy từ trong app/, thêm parent vào path
    parent_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    if parent_dir not in sys.path:
        sys.path.insert(0, parent_dir)
    # Dùng relative import
    from main import process_exam_sheet
else:
    # Chạy như module từ root
    from app.main import process_exam_sheet

from pdf2image import convert_from_bytes
from PIL import Image
import io
import traceback

app = FastAPI()

# Cấu hình CORS để frontend có thể gọi API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Trong production nên giới hạn origins cụ thể
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Tạo thư mục 'data/results' và 'static' nếu chưa tồn tại
# Xác định paths dựa trên vị trí file này
import pathlib
BASE_DIR = pathlib.Path(__file__).parent.parent  # Lên 1 level từ app/ về root
RESULTS_DIR = str(BASE_DIR / "data" / "results")
STATIC_DIR = str(BASE_DIR / "static")
FRONTEND_DIST_DIR = str(BASE_DIR / "frontend" / "dist")

# Tạo thư mục nếu chưa tồn tại
os.makedirs(RESULTS_DIR, exist_ok=True)
os.makedirs(STATIC_DIR, exist_ok=True)

@app.get("/health")
async def health_check():
    """Health check endpoint for Docker"""
    return {"status": "healthy"}

@app.post("/upload-image")
async def upload_files(image: UploadFile = File(...), answer_key: UploadFile = File(...)):
    """Xử lý ảnh bài thi và file đáp án tải lên, trả về kết quả và URL ảnh chú thích."""
    print(f"Received upload request: image={image.filename}, answer_key={answer_key.filename}")
    with tempfile.TemporaryDirectory() as temp_dir:
        try:
            print(f"Working directory: {os.getcwd()}")
            print(f"RESULTS_DIR: {RESULTS_DIR}, exists: {os.path.exists(RESULTS_DIR)}")
            # Đọc dữ liệu file ảnh vào bộ nhớ
            image_content = await image.read()
            file_extension = image.filename.split('.')[-1].lower()

            # Đường dẫn file tạm thời cho ảnh JPG
            image_path = os.path.join(temp_dir, "image.jpg")

            # Xử lý theo định dạng file
            if file_extension in ["jpg", "jpeg"]:
                # Nếu là JPG, lưu trực tiếp
                with open(image_path, "wb") as f:
                    f.write(image_content)
            elif file_extension == "png":
                # Nếu là PNG, chuyển sang JPG
                img = Image.open(io.BytesIO(image_content))
                img = img.convert("RGB")
                img.save(image_path, "JPEG")
            elif file_extension == "pdf":
                # Nếu là PDF, chuyển sang JPG
                try:
                    pages = convert_from_bytes(image_content)
                    if not pages:
                        raise ValueError("File PDF rỗng hoặc không thể đọc.")
                    pages[0].save(image_path, "JPEG")  # Lưu trang đầu tiên
                except Exception as pdf_error:
                    raise ValueError(f"Lỗi khi chuyển PDF sang JPG: {str(pdf_error)}")
            else:
                raise ValueError("Định dạng file không hỗ trợ. Chỉ hỗ trợ JPG, PNG, PDF.")

            # Lưu file đáp án vào file tạm thời
            answer_key_path = os.path.join(temp_dir, "answer_key.xlsx")
            with open(answer_key_path, "wb") as f:
                f.write(await answer_key.read())

            # Tạo tên file duy nhất cho ảnh chú thích
            output_image_name = f"result_{uuid.uuid4().hex}.jpg"
            output_image_path = os.path.join(RESULTS_DIR, output_image_name)

            # Gọi hàm xử lý từ main.py
            print(f"Calling process_exam_sheet with: image={image_path}, answer_key={answer_key_path}, output={output_image_path}")
            results = process_exam_sheet(image_path, answer_key_path, output_image_path)
            print(f"Process result: status={results.get('status')}")

            # Chuẩn bị phản hồi JSON
            # URL ảnh phải là absolute path hoặc relative từ root
            annotated_image_url = f"/results/{output_image_name}"
            print(f"Annotated image saved to: {output_image_path}")
            print(f"Annotated image URL: {annotated_image_url}")
            print(f"File exists: {os.path.exists(output_image_path)}")
            
            response = {
                "status": results["status"],
                "annotated_image_url": annotated_image_url
            }
            if results["status"] == "success":
                # Sử dụng cùng hàm read_answer_key như trong main.py để đảm bảo format giống nhau
                # Import theo cùng cách như process_exam_sheet
                if os.path.basename(os.getcwd()) == "app" or __name__ == "__main__":
                    from main import read_answer_key
                else:
                    from app.main import read_answer_key
                answer_key_dict = read_answer_key(answer_key_path)
                
                # Lấy student answers từ results nếu có
                student_answers = results.get("student_answers", {})
                print(f"Student answers received: {len(student_answers)} questions")
                if student_answers:
                    sample = dict(list(student_answers.items())[:5])
                    print(f"Sample student answers: {sample}")
                
                # Log sample answer key để debug
                sample_answer_key = dict(list(answer_key_dict.items())[:5])
                print(f"Sample answer key: {sample_answer_key}")
                
                # Tính lại điểm để đảm bảo đúng (giống logic trong main.py)
                recalculated_score = 0
                mismatch_count = 0
                mismatch_examples = []
                
                for question_num in range(1, results["total_questions"] + 1):
                    student_answer_list = student_answers.get(question_num, [])
                    correct_answer = answer_key_dict.get(question_num, "")
                    
                    # Normalize để so sánh (strip whitespace, uppercase)
                    student_answer_str = str(student_answer_list[0]).strip().upper() if len(student_answer_list) == 1 else ""
                    correct_answer_str = str(correct_answer).strip().upper() if correct_answer else ""
                    
                    # Chỉ tính điểm nếu có đúng 1 đáp án và đáp án đó đúng
                    if len(student_answer_list) == 1 and student_answer_str == correct_answer_str:
                        recalculated_score += 1
                    elif len(student_answer_list) == 1:
                        # Log mismatch để debug
                        mismatch_count += 1
                        if len(mismatch_examples) < 5:
                            mismatch_examples.append({
                                "q": question_num,
                                "student": student_answer_str,
                                "correct": correct_answer_str,
                                "raw_student": student_answer_list[0],
                                "raw_correct": correct_answer
                            })
                
                print(f"Original score: {results['correct_answers']}, Recalculated: {recalculated_score}")
                print(f"Mismatches found: {mismatch_count}")
                if mismatch_examples:
                    print(f"Mismatch examples: {mismatch_examples}")
                
                # Tạo danh sách chi tiết từng câu hỏi
                details = []
                for question_num in range(1, results["total_questions"] + 1):
                    student_answer_list = student_answers.get(question_num, [])
                    # student_answers format: {question_num: [list of answers]}
                    # Nếu có nhiều hơn 1 đáp án, lấy đáp án đầu tiên
                    # Nếu không có đáp án, để trống
                    student_answer = student_answer_list[0] if isinstance(student_answer_list, list) and len(student_answer_list) > 0 else ""
                    correct_answer = answer_key_dict.get(question_num, "")
                    
                    # Normalize để so sánh
                    student_answer_str = str(student_answer).strip().upper() if student_answer else ""
                    correct_answer_str = str(correct_answer).strip().upper() if correct_answer else ""
                    
                    # Tính is_correct giống logic trong calculate_score
                    is_correct = len(student_answer_list) == 1 and student_answer_str == correct_answer_str
                    
                    details.append({
                        "question": question_num,
                        "studentAnswer": student_answer,
                        "correctAnswer": correct_answer,
                        "isCorrect": is_correct
                    })
                
                # Sử dụng điểm đã tính lại
                final_correct_answers = recalculated_score
                
                incorrect_answers = results["total_questions"] - final_correct_answers
                final_score_recalculated = final_correct_answers * 10 / results["total_questions"] if results["total_questions"] > 0 else 0
                percentage = (final_correct_answers / results["total_questions"] * 100) if results["total_questions"] > 0 else 0
                
                response.update({
                    "sbd": results["sbd"],
                    "mdt": results["mdt"],
                    "correct_answers": final_correct_answers,
                    "incorrect_answers": incorrect_answers,
                    "total_questions": results["total_questions"],
                    "final_score": round(final_score_recalculated, 2),
                    "score": round(final_score_recalculated, 2),
                    "percentage": round(percentage, 1),
                    "details": details
                })
            else:
                response["error"] = results["message"]

            return JSONResponse(content=response)

        except Exception as e:
            # Log lỗi chi tiết để debug
            error_trace = traceback.format_exc()
            print(f"Error in upload_files: {str(e)}")
            print(f"Traceback: {error_trace}")
            return JSONResponse(
                content={
                    "status": "error",
                    "error": str(e),
                    "traceback": error_trace if os.getenv("DEBUG") else None
                },
                status_code=500
            )

# Mount /results trước để không bị override bởi frontend mount
app.mount("/results", StaticFiles(directory=RESULTS_DIR), name="results")

# Serve React build files từ root
# Ưu tiên serve từ frontend/dist nếu có (React build), nếu không thì dùng static cũ
frontend_build_path = pathlib.Path(FRONTEND_DIST_DIR)
static_path = pathlib.Path(STATIC_DIR)

# Mount static files cho assets (JS, CSS, images, etc.)
if frontend_build_path.exists():
    # Serve React build từ root - mount assets trước
    assets_dir = frontend_build_path / "assets"
    if assets_dir.exists():
        app.mount("/assets", StaticFiles(directory=str(assets_dir)), name="assets")
    
    # Serve toàn bộ frontend/dist từ root (sau cùng để catch-all cho React Router)
    app.mount("/", StaticFiles(directory=str(frontend_build_path), html=True), name="frontend")
elif static_path.exists():
    # Fallback to old static
    app.mount("/", StaticFiles(directory=str(static_path), html=True), name="static")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)