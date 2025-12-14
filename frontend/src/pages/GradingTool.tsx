import React, { useState } from 'react';
import { useNavigate } from 'react-router';
import { Upload, FileText, CheckCircle2, XCircle, Sparkles, ArrowRight } from 'lucide-react';
import { PieChart, Pie, Cell, ResponsiveContainer, Legend } from 'recharts';

export default function GradingTool() {
  const navigate = useNavigate();
  const [examImage, setExamImage] = useState<File | null>(null);
  const [answerKey, setAnswerKey] = useState<File | null>(null);
  const [isProcessing, setIsProcessing] = useState(false);
  const [results, setResults] = useState<any>(null);

  const handleExamUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setExamImage(e.target.files[0]);
    }
  };

  const handleAnswerKeyUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setAnswerKey(e.target.files[0]);
    }
  };

  const handleGrade = async () => {
    if (!examImage || !answerKey) {
      alert('Vui lòng tải lên cả ảnh bài thi và đáp án!');
      return;
    }

    setIsProcessing(true);

    try {
      // Tạo FormData để gửi file
      const formData = new FormData();
      formData.append('image', examImage);
      formData.append('answer_key', answerKey);

      // Gọi API
      const response = await fetch('/upload-image', {
        method: 'POST',
        body: formData,
      });

      // Kiểm tra response status
      if (!response.ok) {
        const errorText = await response.text();
        let errorData;
        try {
          errorData = JSON.parse(errorText);
        } catch {
          errorData = { error: errorText || `HTTP ${response.status}: ${response.statusText}` };
        }
        throw new Error(errorData.error || `Server error: ${response.status}`);
      }

      const data = await response.json();

      if (data.status === 'success') {
        // Chuyển đổi dữ liệu từ API sang format mà UI cần
        const formattedResults = {
          totalQuestions: data.total_questions,
          correctAnswers: data.correct_answers,
          incorrectAnswers: data.incorrect_answers,
          score: parseFloat(data.score).toFixed(2),
          percentage: parseFloat(data.percentage).toFixed(1),
          details: data.details || [],
          sbd: data.sbd,
          mdt: data.mdt,
          annotatedImageUrl: data.annotated_image_url
        };

        setResults(formattedResults);
      } else {
        alert(`Lỗi: ${data.error || 'Không thể xử lý bài thi'}`);
        setResults(null);
      }
    } catch (error) {
      console.error('Error:', error);
      const errorMessage = error instanceof Error ? error.message : 'Đã xảy ra lỗi khi gửi yêu cầu. Vui lòng thử lại.';
      alert(`Lỗi: ${errorMessage}`);
      setResults(null);
    } finally {
      setIsProcessing(false);
    }
  };

  const chartData = results ? [
    { name: 'Đúng', value: results.correctAnswers, color: '#10B981' },
    { name: 'Sai', value: results.incorrectAnswers, color: '#EF4444' }
  ] : [];

  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="max-w-7xl mx-auto px-6">
        {/* Header */}
        <div className="mb-12 text-center">
          <div className="inline-flex items-center gap-2 px-4 py-2 bg-blue-100 text-[#2196F3] rounded-full mb-4">
            <Sparkles className="w-4 h-4" />
            <span className="text-sm font-medium">Công nghệ AI</span>
          </div>
          <h1 className="text-4xl text-gray-900 mb-4">Chấm điểm bài thi trắc nghiệm</h1>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            Tải lên ảnh bài thi và đáp án để bắt đầu chấm điểm tự động
          </p>
        </div>

        <div className="grid lg:grid-cols-2 gap-8">
          {/* Left Column - Upload Section */}
          <div className="space-y-6">
            {/* Exam Upload */}
            <div className="bg-white rounded-2xl p-8 shadow-sm border-2 border-gray-100">
              <div className="flex items-center gap-3 mb-6">
                <div className="w-10 h-10 rounded-xl bg-blue-100 flex items-center justify-center">
                  <FileText className="w-5 h-5 text-[#2196F3]" />
                </div>
                <div>
                  <h3 className="text-xl text-gray-900">Ảnh bài thi</h3>
                  <p className="text-sm text-gray-600">Tải lên ảnh phiếu trả lời của học sinh</p>
                </div>
              </div>

              <label className="block">
                <div className="border-2 border-dashed border-gray-300 rounded-xl p-8 text-center hover:border-[#2196F3] hover:bg-blue-50 transition-all cursor-pointer group">
                  <input
                    type="file"
                    className="hidden"
                    accept="image/*"
                    onChange={handleExamUpload}
                  />
                  <Upload className="w-12 h-12 text-gray-400 mx-auto mb-4 group-hover:text-[#2196F3]" />
                  {examImage ? (
                    <div>
                      <p className="text-gray-900 mb-1">{examImage.name}</p>
                      <p className="text-sm text-green-600">✓ Đã tải lên thành công</p>
                    </div>
                  ) : (
                    <div>
                      <p className="text-gray-900 mb-1">Kéo thả file hoặc nhấp để chọn</p>
                      <p className="text-sm text-gray-500">PNG, JPG tối đa 10MB</p>
                    </div>
                  )}
                </div>
              </label>
            </div>

            {/* Answer Key Upload */}
            <div className="bg-white rounded-2xl p-8 shadow-sm border-2 border-gray-100">
              <div className="flex items-center gap-3 mb-6">
                <div className="w-10 h-10 rounded-xl bg-green-100 flex items-center justify-center">
                  <CheckCircle2 className="w-5 h-5 text-green-600" />
                </div>
                <div>
                  <h3 className="text-xl text-gray-900">Đáp án chuẩn</h3>
                  <p className="text-sm text-gray-600">Tải lên file đáp án để so sánh</p>
                </div>
              </div>

              <label className="block">
                <div className="border-2 border-dashed border-gray-300 rounded-xl p-8 text-center hover:border-green-500 hover:bg-green-50 transition-all cursor-pointer group">
                  <input
                    type="file"
                    className="hidden"
                    accept=".xlsx,.xls"
                    onChange={handleAnswerKeyUpload}
                  />
                  <Upload className="w-12 h-12 text-gray-400 mx-auto mb-4 group-hover:text-green-600" />
                  {answerKey ? (
                    <div>
                      <p className="text-gray-900 mb-1">{answerKey.name}</p>
                      <p className="text-sm text-green-600">✓ Đã tải lên thành công</p>
                    </div>
                  ) : (
                    <div>
                      <p className="text-gray-900 mb-1">Kéo thả file hoặc nhấp để chọn</p>
                      <p className="text-sm text-gray-500">XLSX, XLS tối đa 5MB</p>
                    </div>
                  )}
                </div>
              </label>
            </div>

            {/* Grade Button */}
            <button
              onClick={handleGrade}
              disabled={!examImage || !answerKey || isProcessing}
              className="w-full py-4 bg-[#2196F3] text-white rounded-xl hover:bg-[#1976D2] transition-all disabled:opacity-50 disabled:cursor-not-allowed shadow-lg hover:shadow-xl flex items-center justify-center gap-2"
            >
              {isProcessing ? (
                <>
                  <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                  <span>Đang xử lý bằng AI...</span>
                </>
              ) : (
                <>
                  <span>Chấm điểm ngay</span>
                  <ArrowRight className="w-5 h-5" />
                </>
              )}
            </button>
          </div>

          {/* Right Column - Results Section */}
          <div className="bg-white rounded-2xl p-8 shadow-sm border-2 border-gray-100">
            <h3 className="text-xl text-gray-900 mb-6">Kết quả chấm điểm</h3>

            {!results && !isProcessing && (
              <div className="h-full min-h-[400px] flex items-center justify-center">
                <div className="text-center">
                  <div className="w-20 h-20 rounded-full bg-gray-100 flex items-center justify-center mx-auto mb-4">
                    <FileText className="w-10 h-10 text-gray-400" />
                  </div>
                  <p className="text-gray-600 mb-2">Chưa có kết quả</p>
                  <p className="text-sm text-gray-500">Tải lên file và nhấn "Chấm điểm ngay"</p>
                </div>
              </div>
            )}

            {isProcessing && (
              <div className="h-full min-h-[400px] flex items-center justify-center">
                <div className="text-center">
                  <div className="w-20 h-20 rounded-full bg-blue-100 flex items-center justify-center mx-auto mb-4 animate-pulse">
                    <Sparkles className="w-10 h-10 text-[#2196F3]" />
                  </div>
                  <p className="text-gray-900 mb-2">Đang phân tích bằng AI...</p>
                  <p className="text-sm text-gray-500">Vui lòng đợi trong giây lát</p>
                </div>
              </div>
            )}

            {results && !isProcessing && (
              <div className="space-y-6">
                {/* Annotated Image */}
                {results.annotatedImageUrl && (
                  <div className="bg-gray-50 rounded-xl p-4">
                    <h4 className="text-lg text-gray-900 mb-3">Ảnh bài thi đã chấm</h4>
                    <div className="relative rounded-lg overflow-hidden border-2 border-gray-200">
                      <img
                        src={results.annotatedImageUrl}
                        alt="Kết quả chấm điểm"
                        className="w-full h-auto"
                        onError={(e) => {
                          console.error('Error loading image:', results.annotatedImageUrl);
                          e.currentTarget.style.display = 'none';
                        }}
                      />
                    </div>
                  </div>
                )}

                {/* Score Summary */}
                <div className="grid grid-cols-2 gap-4">
                  <div className="bg-gradient-to-br from-blue-50 to-blue-100 rounded-xl p-6 text-center">
                    <div className="text-4xl text-[#2196F3] mb-2">{results.score}</div>
                    <div className="text-sm text-gray-700">Điểm tổng</div>
                  </div>
                  <div className="bg-gradient-to-br from-green-50 to-green-100 rounded-xl p-6 text-center">
                    <div className="text-4xl text-green-600 mb-2">{results.percentage}%</div>
                    <div className="text-sm text-gray-700">Tỷ lệ đúng</div>
                  </div>
                </div>

                {/* Stats */}
                <div className="grid grid-cols-3 gap-4">
                  <div className="text-center">
                    <div className="text-2xl text-gray-900 mb-1">{results.totalQuestions}</div>
                    <div className="text-sm text-gray-600">Tổng câu</div>
                  </div>
                  <div className="text-center">
                    <div className="text-2xl text-green-600 mb-1">{results.correctAnswers}</div>
                    <div className="text-sm text-gray-600">Câu đúng</div>
                  </div>
                  <div className="text-center">
                    <div className="text-2xl text-red-600 mb-1">{results.incorrectAnswers}</div>
                    <div className="text-sm text-gray-600">Câu sai</div>
                  </div>
                </div>

                {/* Pie Chart */}
                <div className="h-64">
                  <ResponsiveContainer width="100%" height="100%">
                    <PieChart>
                      <Pie
                        data={chartData}
                        cx="50%"
                        cy="50%"
                        innerRadius={60}
                        outerRadius={80}
                        paddingAngle={5}
                        dataKey="value"
                      >
                        {chartData.map((entry, index) => (
                          <Cell key={`cell-${index}`} fill={entry.color} />
                        ))}
                      </Pie>
                      <Legend />
                    </PieChart>
                  </ResponsiveContainer>
                </div>

                {/* Quick Results */}
                <div className="max-h-48 overflow-y-auto space-y-2">
                  {results.details.slice(0, 10).map((detail: any) => (
                    <div
                      key={detail.question}
                      className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                    >
                      <span className="text-sm text-gray-700">Câu {detail.question}</span>
                      <div className="flex items-center gap-3">
                        <span className="text-sm text-gray-600">
                          {detail.studentAnswer} / {detail.correctAnswer}
                        </span>
                        {detail.isCorrect ? (
                          <CheckCircle2 className="w-5 h-5 text-green-600" />
                        ) : (
                          <XCircle className="w-5 h-5 text-red-600" />
                        )}
                      </div>
                    </div>
                  ))}
                </div>

                {/* View Details Button */}
                <button
                  onClick={() => navigate('/ket-qua', { state: { results } })}
                  className="w-full py-3 bg-gray-900 text-white rounded-xl hover:bg-gray-800 transition-all"
                >
                  Xem chi tiết đầy đủ
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
