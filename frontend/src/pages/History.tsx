import { useState } from 'react';
import { Link } from 'react-router';
import { 
  Search, 
  Filter, 
  Eye, 
  Download, 
  Calendar,
  CheckCircle2,
  FileText,
  TrendingUp,
  Clock
} from 'lucide-react';

export default function History() {
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState('all');

  // Mock history data
  const historyData = [
    {
      id: 1,
      date: '12/12/2025 14:30',
      examName: 'Bài kiểm tra Toán học - Lớp 10A1',
      totalQuestions: 40,
      correctAnswers: 35,
      score: 8.75,
      percentage: 87.5,
      status: 'completed'
    },
    {
      id: 2,
      date: '11/12/2025 10:15',
      examName: 'Kiểm tra Tiếng Anh - Unit 5',
      totalQuestions: 50,
      correctAnswers: 42,
      score: 8.4,
      percentage: 84,
      status: 'completed'
    },
    {
      id: 3,
      date: '10/12/2025 16:45',
      examName: 'Bài thi Vật lý - Chương 3',
      totalQuestions: 30,
      correctAnswers: 28,
      score: 9.33,
      percentage: 93.3,
      status: 'completed'
    },
    {
      id: 4,
      date: '09/12/2025 09:20',
      examName: 'Kiểm tra Hóa học - Bài 7',
      totalQuestions: 40,
      correctAnswers: 32,
      score: 8.0,
      percentage: 80,
      status: 'completed'
    },
    {
      id: 5,
      date: '08/12/2025 13:00',
      examName: 'Bài thi Sinh học - Giữa kỳ',
      totalQuestions: 45,
      correctAnswers: 40,
      score: 8.89,
      percentage: 88.9,
      status: 'completed'
    },
    {
      id: 6,
      date: '07/12/2025 11:30',
      examName: 'Kiểm tra Lịch sử - Thế kỷ 20',
      totalQuestions: 35,
      correctAnswers: 30,
      score: 8.57,
      percentage: 85.7,
      status: 'completed'
    },
    {
      id: 7,
      date: '06/12/2025 15:45',
      examName: 'Bài thi Địa lý - Châu Á',
      totalQuestions: 40,
      correctAnswers: 36,
      score: 9.0,
      percentage: 90,
      status: 'completed'
    },
    {
      id: 8,
      date: '05/12/2025 10:00',
      examName: 'Kiểm tra GDCD - Bài 4',
      totalQuestions: 25,
      correctAnswers: 24,
      score: 9.6,
      percentage: 96,
      status: 'completed'
    }
  ];

  const filteredData = historyData.filter(item => 
    item.examName.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getScoreColor = (score: number) => {
    if (score >= 9) return 'text-green-600';
    if (score >= 7) return 'text-blue-600';
    if (score >= 5) return 'text-yellow-600';
    return 'text-red-600';
  };

  const getScoreBgColor = (score: number) => {
    if (score >= 9) return 'bg-green-100';
    if (score >= 7) return 'bg-blue-100';
    if (score >= 5) return 'bg-yellow-100';
    return 'bg-red-100';
  };

  // Calculate statistics
  const totalExams = historyData.length;
  const averageScore = (historyData.reduce((sum, item) => sum + item.score, 0) / totalExams).toFixed(2);
  const highestScore = Math.max(...historyData.map(item => item.score)).toFixed(2);
  const totalQuestions = historyData.reduce((sum, item) => sum + item.totalQuestions, 0);

  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="max-w-7xl mx-auto px-6">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl text-gray-900 mb-2">Lịch sử chấm điểm</h1>
          <p className="text-xl text-gray-600">Xem lại các bài thi đã chấm trước đây</p>
        </div>

        {/* Statistics Cards */}
        <div className="grid md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-2xl p-6 shadow-sm border-2 border-gray-100">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-10 h-10 rounded-xl bg-blue-100 flex items-center justify-center">
                <FileText className="w-5 h-5 text-[#2196F3]" />
              </div>
              <div className="text-3xl text-gray-900">{totalExams}</div>
            </div>
            <div className="text-gray-600">Tổng bài thi</div>
          </div>

          <div className="bg-white rounded-2xl p-6 shadow-sm border-2 border-gray-100">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-10 h-10 rounded-xl bg-green-100 flex items-center justify-center">
                <TrendingUp className="w-5 h-5 text-green-600" />
              </div>
              <div className="text-3xl text-gray-900">{averageScore}</div>
            </div>
            <div className="text-gray-600">Điểm trung bình</div>
          </div>

          <div className="bg-white rounded-2xl p-6 shadow-sm border-2 border-gray-100">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-10 h-10 rounded-xl bg-yellow-100 flex items-center justify-center">
                <CheckCircle2 className="w-5 h-5 text-yellow-600" />
              </div>
              <div className="text-3xl text-gray-900">{highestScore}</div>
            </div>
            <div className="text-gray-600">Điểm cao nhất</div>
          </div>

          <div className="bg-white rounded-2xl p-6 shadow-sm border-2 border-gray-100">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-10 h-10 rounded-xl bg-purple-100 flex items-center justify-center">
                <Clock className="w-5 h-5 text-purple-600" />
              </div>
              <div className="text-3xl text-gray-900">{totalQuestions}</div>
            </div>
            <div className="text-gray-600">Tổng câu hỏi</div>
          </div>
        </div>

        {/* Search and Filter */}
        <div className="bg-white rounded-2xl p-6 shadow-sm border-2 border-gray-100 mb-8">
          <div className="flex flex-col md:flex-row gap-4">
            {/* Search */}
            <div className="flex-1 relative">
              <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
              <input
                type="text"
                placeholder="Tìm kiếm theo tên bài thi..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-12 pr-4 py-3 border-2 border-gray-200 rounded-xl focus:border-[#2196F3] focus:outline-none"
              />
            </div>

            {/* Filter */}
            <div className="flex gap-2">
              <button className="inline-flex items-center gap-2 px-4 py-3 bg-gray-100 text-gray-700 rounded-xl hover:bg-gray-200 transition-all">
                <Filter className="w-5 h-5" />
                <span>Lọc</span>
              </button>
              <button className="inline-flex items-center gap-2 px-4 py-3 bg-gray-100 text-gray-700 rounded-xl hover:bg-gray-200 transition-all">
                <Calendar className="w-5 h-5" />
                <span>Ngày tháng</span>
              </button>
            </div>
          </div>
        </div>

        {/* History Table */}
        <div className="bg-white rounded-2xl shadow-sm border-2 border-gray-100 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b-2 border-gray-200">
                <tr>
                  <th className="px-6 py-4 text-left text-gray-700">Ngày giờ</th>
                  <th className="px-6 py-4 text-left text-gray-700">Tên bài thi</th>
                  <th className="px-6 py-4 text-center text-gray-700">Tổng điểm</th>
                  <th className="px-6 py-4 text-center text-gray-700">Số câu đúng</th>
                  <th className="px-6 py-4 text-center text-gray-700">Tỷ lệ</th>
                  <th className="px-6 py-4 text-center text-gray-700">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                {filteredData.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="px-6 py-12 text-center">
                      <div className="flex flex-col items-center">
                        <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mb-4">
                          <FileText className="w-8 h-8 text-gray-400" />
                        </div>
                        <p className="text-gray-600 mb-2">Không tìm thấy kết quả</p>
                        <p className="text-sm text-gray-500">Thử tìm kiếm với từ khóa khác</p>
                      </div>
                    </td>
                  </tr>
                ) : (
                  filteredData.map((item) => (
                    <tr
                      key={item.id}
                      className="border-b border-gray-100 hover:bg-gray-50 transition-colors"
                    >
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2 text-gray-600">
                          <Clock className="w-4 h-4" />
                          <span>{item.date}</span>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-gray-900">{item.examName}</div>
                        <div className="text-sm text-gray-500">{item.totalQuestions} câu hỏi</div>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <span className={`inline-flex items-center justify-center w-16 h-16 rounded-xl ${getScoreBgColor(item.score)} ${getScoreColor(item.score)}`}>
                          {item.score}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <div className="inline-flex items-center gap-2 px-3 py-1 bg-green-100 text-green-700 rounded-full">
                          <CheckCircle2 className="w-4 h-4" />
                          <span>{item.correctAnswers}/{item.totalQuestions}</span>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <div className="text-gray-900">{item.percentage}%</div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center justify-center gap-2">
                          <button className="inline-flex items-center gap-2 px-4 py-2 bg-blue-100 text-[#2196F3] rounded-lg hover:bg-blue-200 transition-all">
                            <Eye className="w-4 h-4" />
                            <span>Xem</span>
                          </button>
                          <button className="inline-flex items-center gap-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-all">
                            <Download className="w-4 h-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>

        {/* CTA */}
        <div className="mt-12 text-center">
          <Link
            to="/cham-diem"
            className="inline-flex items-center gap-2 px-8 py-4 bg-[#2196F3] text-white rounded-xl hover:bg-[#1976D2] transition-all shadow-lg"
          >
            <FileText className="w-5 h-5" />
            <span>Chấm bài thi mới</span>
          </Link>
        </div>
      </div>
    </div>
  );
}
