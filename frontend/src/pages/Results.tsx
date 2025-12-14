import { useLocation, useNavigate, Link } from 'react-router';
import { 
  CheckCircle2, 
  XCircle, 
  Download, 
  FileSpreadsheet, 
  FileText,
  ArrowLeft,
  TrendingUp,
  Award
} from 'lucide-react';
import { PieChart, Pie, Cell, ResponsiveContainer, Legend, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip } from 'recharts';

export default function Results() {
  const location = useLocation();
  const navigate = useNavigate();
  const results = location.state?.results;

  // If no results, redirect to grading tool
  if (!results) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="w-20 h-20 rounded-full bg-gray-100 flex items-center justify-center mx-auto mb-4">
            <FileText className="w-10 h-10 text-gray-400" />
          </div>
          <h2 className="text-2xl text-gray-900 mb-2">Chưa có kết quả</h2>
          <p className="text-gray-600 mb-6">Vui lòng chấm điểm bài thi trước</p>
          <Link
            to="/cham-diem"
            className="inline-flex items-center gap-2 px-6 py-3 bg-[#2196F3] text-white rounded-xl hover:bg-[#1976D2]"
          >
            <ArrowLeft className="w-5 h-5" />
            <span>Về trang chấm điểm</span>
          </Link>
        </div>
      </div>
    );
  }

  const chartData = [
    { name: 'Đúng', value: results.correctAnswers, color: '#10B981' },
    { name: 'Sai', value: results.incorrectAnswers, color: '#EF4444' }
  ];

  // Group questions by sections (10 questions each)
  const sections = [];
  for (let i = 0; i < results.totalQuestions; i += 10) {
    const sectionQuestions = results.details.slice(i, i + 10);
    const correctInSection = sectionQuestions.filter((q: any) => q.isCorrect).length;
    sections.push({
      name: `Câu ${i + 1}-${Math.min(i + 10, results.totalQuestions)}`,
      correct: correctInSection,
      incorrect: sectionQuestions.length - correctInSection
    });
  }

  const handleExportPDF = () => {
    alert('Xuất PDF thành công! (Demo)');
  };

  const handleExportExcel = () => {
    alert('Xuất Excel thành công! (Demo)');
  };

  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="max-w-7xl mx-auto px-6">
        {/* Header */}
        <div className="mb-8">
          <button
            onClick={() => navigate('/cham-diem')}
            className="inline-flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-4"
          >
            <ArrowLeft className="w-5 h-5" />
            <span>Quay lại</span>
          </button>
          <h1 className="text-4xl text-gray-900 mb-2">Kết quả chi tiết</h1>
          <p className="text-xl text-gray-600">Phân tích đầy đủ kết quả bài thi</p>
        </div>

        {/* Summary Cards */}
        <div className="grid md:grid-cols-4 gap-6 mb-8">
          <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-2xl p-6 text-white">
            <div className="flex items-center justify-between mb-4">
              <Award className="w-8 h-8" />
              <div className="text-3xl">{results.score}</div>
            </div>
            <div className="text-blue-100">Điểm tổng</div>
          </div>

          <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-2xl p-6 text-white">
            <div className="flex items-center justify-between mb-4">
              <TrendingUp className="w-8 h-8" />
              <div className="text-3xl">{results.percentage}%</div>
            </div>
            <div className="text-green-100">Tỷ lệ đúng</div>
          </div>

          <div className="bg-white rounded-2xl p-6 shadow-sm border-2 border-gray-100">
            <div className="flex items-center justify-between mb-4">
              <CheckCircle2 className="w-8 h-8 text-green-600" />
              <div className="text-3xl text-gray-900">{results.correctAnswers}</div>
            </div>
            <div className="text-gray-600">Câu đúng</div>
          </div>

          <div className="bg-white rounded-2xl p-6 shadow-sm border-2 border-gray-100">
            <div className="flex items-center justify-between mb-4">
              <XCircle className="w-8 h-8 text-red-600" />
              <div className="text-3xl text-gray-900">{results.incorrectAnswers}</div>
            </div>
            <div className="text-gray-600">Câu sai</div>
          </div>
        </div>

        <div className="grid lg:grid-cols-2 gap-8 mb-8">
          {/* Pie Chart */}
          <div className="bg-white rounded-2xl p-8 shadow-sm border-2 border-gray-100">
            <h2 className="text-2xl text-gray-900 mb-6">Phân bố kết quả</h2>
            <div className="h-80">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={chartData}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, value, percent }) => `${name}: ${value} (${(percent * 100).toFixed(0)}%)`}
                    outerRadius={100}
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
          </div>

          {/* Bar Chart */}
          <div className="bg-white rounded-2xl p-8 shadow-sm border-2 border-gray-100">
            <h2 className="text-2xl text-gray-900 mb-6">Phân tích theo phần</h2>
            <div className="h-80">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={sections}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Bar dataKey="correct" fill="#10B981" name="Đúng" />
                  <Bar dataKey="incorrect" fill="#EF4444" name="Sai" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>

        {/* Detailed Results Table */}
        <div className="bg-white rounded-2xl p-8 shadow-sm border-2 border-gray-100 mb-8">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-2xl text-gray-900">Bảng kết quả chi tiết</h2>
            <div className="flex gap-3">
              <button
                onClick={handleExportExcel}
                className="inline-flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-xl hover:bg-green-700 transition-all"
              >
                <FileSpreadsheet className="w-5 h-5" />
                <span>Xuất Excel</span>
              </button>
              <button
                onClick={handleExportPDF}
                className="inline-flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-xl hover:bg-red-700 transition-all"
              >
                <Download className="w-5 h-5" />
                <span>Xuất PDF</span>
              </button>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b-2 border-gray-200">
                  <th className="px-4 py-3 text-left text-gray-700">Câu hỏi</th>
                  <th className="px-4 py-3 text-left text-gray-700">Đáp án học sinh</th>
                  <th className="px-4 py-3 text-left text-gray-700">Đáp án đúng</th>
                  <th className="px-4 py-3 text-center text-gray-700">Kết quả</th>
                </tr>
              </thead>
              <tbody>
                {results.details.map((detail: any) => (
                  <tr
                    key={detail.question}
                    className="border-b border-gray-100 hover:bg-gray-50 transition-colors"
                  >
                    <td className="px-4 py-4">
                      <span className="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-gray-100 text-gray-700">
                        {detail.question}
                      </span>
                    </td>
                    <td className="px-4 py-4">
                      <span className={`inline-flex items-center justify-center w-8 h-8 rounded-lg ${
                        detail.isCorrect ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                      }`}>
                        {detail.studentAnswer}
                      </span>
                    </td>
                    <td className="px-4 py-4">
                      <span className="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-blue-100 text-blue-700">
                        {detail.correctAnswer}
                      </span>
                    </td>
                    <td className="px-4 py-4 text-center">
                      {detail.isCorrect ? (
                        <div className="inline-flex items-center gap-2 px-3 py-1 bg-green-100 text-green-700 rounded-full">
                          <CheckCircle2 className="w-4 h-4" />
                          <span className="text-sm">Đúng</span>
                        </div>
                      ) : (
                        <div className="inline-flex items-center gap-2 px-3 py-1 bg-red-100 text-red-700 rounded-full">
                          <XCircle className="w-4 h-4" />
                          <span className="text-sm">Sai</span>
                        </div>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex justify-center gap-4">
          <Link
            to="/cham-diem"
            className="inline-flex items-center gap-2 px-8 py-4 bg-[#2196F3] text-white rounded-xl hover:bg-[#1976D2] transition-all shadow-lg"
          >
            <FileText className="w-5 h-5" />
            <span>Chấm bài khác</span>
          </Link>
          <Link
            to="/lich-su"
            className="inline-flex items-center gap-2 px-8 py-4 bg-white text-gray-700 rounded-xl hover:bg-gray-50 transition-all border-2 border-gray-200"
          >
            <span>Xem lịch sử</span>
          </Link>
        </div>
      </div>
    </div>
  );
}
