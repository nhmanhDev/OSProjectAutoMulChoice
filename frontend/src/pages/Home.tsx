import { Link } from 'react-router';
import {
  Sparkles,
  Scan,
  CheckCircle2,
  BarChart3,
  FileSpreadsheet,
  Zap,
  Shield,
  Clock,
  Users,
  ArrowRight,
  Star,
  Mail,
  Phone,
  MapPin
} from 'lucide-react';

export default function Home() {
  const features = [
    {
      icon: <Scan className="w-6 h-6" />,
      title: "Nhận diện phiếu trả lời tự động",
      description: "Công nghệ AI nhận diện và xử lý phiếu trả lời trắc nghiệm chính xác cao"
    },
    {
      icon: <CheckCircle2 className="w-6 h-6" />,
      title: "So sánh với đáp án",
      description: "Tự động so sánh câu trả lời của học sinh với đáp án chuẩn"
    },
    {
      icon: <FileSpreadsheet className="w-6 h-6" />,
      title: "Xuất bảng điểm",
      description: "Xuất kết quả ra Excel, PDF với format chuyên nghiệp"
    },
    {
      icon: <BarChart3 className="w-6 h-6" />,
      title: "Phân tích thống kê",
      description: "Biểu đồ trực quan, phân tích chi tiết từng câu hỏi"
    }
  ];

  const benefits = [
    {
      icon: <Zap className="w-8 h-8" />,
      title: "Nhanh chóng",
      description: "Chấm điểm hàng trăm bài thi chỉ trong vài phút"
    },
    {
      icon: <Shield className="w-8 h-8" />,
      title: "Chính xác",
      description: "Độ chính xác lên đến 99.5% nhờ công nghệ AI tiên tiến"
    },
    {
      icon: <Clock className="w-8 h-8" />,
      title: "Tiết kiệm thời gian",
      description: "Giảm 90% thời gian chấm điểm so với phương pháp thủ công"
    },
    {
      icon: <Users className="w-8 h-8" />,
      title: "Dễ sử dụng",
      description: "Giao diện thân thiện, không cần đào tạo phức tạp"
    }
  ];

  const testimonials = [
    {
      name: "Nguyễn Văn An",
      role: "Giáo viên THPT Lê Hồng Phong",
      content: "X-Exam Grader đã giúp tôi tiết kiệm hàng giờ đồng hồ chấm bài. Kết quả chính xác và nhanh chóng đến không ngờ!",
      rating: 5
    },
    {
      name: "Trần Thị Bình",
      role: "Trưởng phòng Khảo thí",
      content: "Công cụ tuyệt vời cho các kỳ thi lớn. Chúng tôi đã sử dụng cho kỳ thi học kỳ với hơn 2000 học sinh.",
      rating: 5
    },
    {
      name: "Lê Hoàng Minh",
      role: "Giáo viên THCS Trần Phú",
      content: "Giao diện dễ sử dụng, kết quả chi tiết với biểu đồ trực quan. Đáng đồng tiền bát gạo!",
      rating: 5
    }
  ];

  return (
    <div className="bg-white">
      {/* Hero Section */}
      <section className="relative overflow-hidden bg-gradient-to-br from-blue-50 via-white to-blue-50">
        <div className="max-w-7xl mx-auto px-6 py-20">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            {/* Left Content */}
            <div className="space-y-8">
              <div className="inline-flex items-center gap-2 px-4 py-2 bg-blue-100 text-[#2196F3] rounded-full">
                <Sparkles className="w-4 h-4" />
                <span className="text-sm font-medium">Công nghệ AI tiên tiến</span>
              </div>

              <h1 className="text-5xl lg:text-6xl text-gray-900 leading-tight">
                Chấm điểm bài thi trắc nghiệm bằng AI
              </h1>

              <p className="text-xl text-gray-600 leading-relaxed">
                Giải pháp chấm điểm tự động thông minh, nhanh chóng và chính xác.
                Tiết kiệm thời gian, tăng hiệu quả cho giáo viên và cơ sở giáo dục.
              </p>

              <div className="flex flex-wrap gap-4">
                <Link
                  to="/cham-diem"
                  className="inline-flex items-center gap-2 px-8 py-4 bg-[#2196F3] text-white rounded-xl hover:bg-[#1976D2] transition-all shadow-lg hover:shadow-xl"
                >
                  <span>Bắt đầu chấm điểm</span>
                  <ArrowRight className="w-5 h-5" />
                </Link>
                <Link
                  to="/gioi-thieu"
                  className="inline-flex items-center gap-2 px-8 py-4 bg-white text-gray-700 rounded-xl hover:bg-gray-50 transition-all border-2 border-gray-200"
                >
                  <span>Tìm hiểu thêm</span>
                </Link>
              </div>

              {/* Stats */}
              <div className="grid grid-cols-3 gap-8 pt-8 border-t border-gray-200">
                <div>
                  <div className="text-3xl text-[#2196F3] mb-1">99.5%</div>
                  <div className="text-sm text-gray-600">Độ chính xác</div>
                </div>
                <div>
                  <div className="text-3xl text-[#2196F3] mb-1">10K+</div>
                  <div className="text-sm text-gray-600">Bài thi đã chấm</div>
                </div>
                <div>
                  <div className="text-3xl text-[#2196F3] mb-1">500+</div>
                  <div className="text-sm text-gray-600">Giáo viên tin dùng</div>
                </div>
              </div>
            </div>

            {/* Right Image */}
            <div className="relative">
              <div className="relative rounded-2xl overflow-hidden shadow-2xl">
                <img
                  src="/image/truong-dai-hoc-thang-long-1.jpg"
                  alt="AI Education"
                  className="w-full h-full object-cover"
                />
                <div className="absolute inset-0 bg-gradient-to-tr from-[#2196F3]/20 to-transparent"></div>
              </div>

              {/* Floating Card */}
              <div className="absolute -bottom-6 -left-6 bg-white rounded-xl shadow-xl p-6 max-w-xs">
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-full bg-green-100 flex items-center justify-center">
                    <CheckCircle2 className="w-6 h-6 text-green-600" />
                  </div>
                  <div>
                    <div className="text-2xl text-gray-900">2,543</div>
                    <div className="text-sm text-gray-600">Bài thi hôm nay</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-6">
          <div className="text-center mb-16">
            <h2 className="text-4xl text-gray-900 mb-4">Tính năng nổi bật</h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Hệ thống chấm điểm toàn diện với đầy đủ tính năng cần thiết
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {features.map((feature, index) => (
              <div
                key={index}
                className="bg-gray-50 rounded-2xl p-8 hover:bg-blue-50 transition-all hover:shadow-lg group"
              >
                <div className="w-12 h-12 rounded-xl bg-[#2196F3] text-white flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                  {feature.icon}
                </div>
                <h3 className="text-xl text-gray-900 mb-3">{feature.title}</h3>
                <p className="text-gray-600">{feature.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Why Choose Us Section */}
      <section className="py-20 bg-gradient-to-br from-gray-50 to-blue-50">
        <div className="max-w-7xl mx-auto px-6">
          <div className="text-center mb-16">
            <h2 className="text-4xl text-gray-900 mb-4">Tại sao chọn X-Exam Grader?</h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Giải pháp chấm điểm hàng đầu được tin dùng bởi hàng trăm giáo viên
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {benefits.map((benefit, index) => (
              <div
                key={index}
                className="bg-white rounded-2xl p-8 text-center hover:shadow-xl transition-all"
              >
                <div className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-blue-100 text-[#2196F3] mb-6">
                  {benefit.icon}
                </div>
                <h3 className="text-xl text-gray-900 mb-3">{benefit.title}</h3>
                <p className="text-gray-600">{benefit.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-6">
          <div className="text-center mb-16">
            <h2 className="text-4xl text-gray-900 mb-4">Giáo viên nói gì về chúng tôi</h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Phản hồi tích cực từ những người dùng thực tế
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {testimonials.map((testimonial, index) => (
              <div
                key={index}
                className="bg-gray-50 rounded-2xl p-8 hover:shadow-lg transition-all"
              >
                <div className="flex gap-1 mb-4">
                  {[...Array(testimonial.rating)].map((_, i) => (
                    <Star key={i} className="w-5 h-5 fill-yellow-400 text-yellow-400" />
                  ))}
                </div>
                <p className="text-gray-700 mb-6 italic">"{testimonial.content}"</p>
                <div>
                  <div className="text-gray-900 font-medium">{testimonial.name}</div>
                  <div className="text-sm text-gray-600">{testimonial.role}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-gradient-to-br from-[#2196F3] to-[#1976D2]">
        <div className="max-w-4xl mx-auto px-6 text-center">
          <h2 className="text-4xl text-white mb-6">
            Sẵn sàng trải nghiệm chấm điểm thông minh?
          </h2>
          <p className="text-xl text-blue-100 mb-8">
            Bắt đầu ngay hôm nay và khám phá sự khác biệt
          </p>
          <Link
            to="/cham-diem"
            className="inline-flex items-center gap-2 px-8 py-4 bg-white text-[#2196F3] rounded-xl hover:bg-gray-100 transition-all shadow-lg"
          >
            <span>Bắt đầu chấm điểm miễn phí</span>
            <ArrowRight className="w-5 h-5" />
          </Link>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-gray-300 py-12">
        <div className="max-w-7xl mx-auto px-6">
          <div className="grid md:grid-cols-4 gap-8 mb-8">
            <div>
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#2196F3] to-[#1976D2] flex items-center justify-center">
                  <CheckCircle2 className="w-6 h-6 text-white" />
                </div>
                <span className="text-xl text-white">X-Exam Grader</span>
              </div>
              <p className="text-sm">
                Giải pháp chấm điểm tự động thông minh cho giáo dục
              </p>
            </div>

            <div>
              <h4 className="text-white mb-4">Sản phẩm</h4>
              <ul className="space-y-2 text-sm">
                <li><Link to="/cham-diem" className="hover:text-white">Chấm điểm</Link></li>
                <li><Link to="/lich-su" className="hover:text-white">Lịch sử</Link></li>
                <li><Link to="/gioi-thieu" className="hover:text-white">Giới thiệu</Link></li>
              </ul>
            </div>

            <div>
              <h4 className="text-white mb-4">Hỗ trợ</h4>
              <ul className="space-y-2 text-sm">
                <li><a href="#" className="hover:text-white">Hướng dẫn sử dụng</a></li>
                <li><a href="#" className="hover:text-white">Câu hỏi thường gặp</a></li>
                <li><a href="#" className="hover:text-white">Liên hệ hỗ trợ</a></li>
              </ul>
            </div>

            <div>
              <h4 className="text-white mb-4">Liên hệ</h4>
              <ul className="space-y-3 text-sm">
                <li className="flex items-center gap-2">
                  <Mail className="w-4 h-4" />
                  <span>support@xexamgrader.vn</span>
                </li>
                <li className="flex items-center gap-2">
                  <Phone className="w-4 h-4" />
                  <span>1900 1234</span>
                </li>
                <li className="flex items-center gap-2">
                  <MapPin className="w-4 h-4" />
                  <span>Hà Nội, Việt Nam</span>
                </li>
              </ul>
            </div>
          </div>

          <div className="pt-8 border-t border-gray-800 flex flex-col md:flex-row justify-between items-center gap-4 text-sm">
            <p>&copy; 2025 X-Exam Grader. All rights reserved.</p>
            <div className="flex gap-6">
              <a href="#" className="hover:text-white">Điều khoản dịch vụ</a>
              <a href="#" className="hover:text-white">Chính sách bảo mật</a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
