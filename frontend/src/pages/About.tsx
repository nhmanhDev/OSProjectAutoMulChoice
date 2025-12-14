import { Link } from 'react-router';
import {
  Target,
  Cpu,
  Eye,
  Zap,
  Users,
  Mail,
  Phone,
  MapPin,
  Github,
  Linkedin,
  ArrowRight,
  CheckCircle2,
  Sparkles
} from 'lucide-react';

export default function About() {
  const technologies = [
    {
      icon: <Cpu className="w-6 h-6" />,
      name: 'Python',
      description: 'Ngôn ngữ lập trình chính cho xử lý AI và machine learning'
    },
    {
      icon: <Zap className="w-6 h-6" />,
      name: 'FastAPI',
      description: 'Framework web hiệu năng cao cho API backend'
    },
    {
      icon: <Eye className="w-6 h-6" />,
      name: 'OpenCV',
      description: 'Thư viện xử lý ảnh và computer vision mạnh mẽ'
    },
    {
      icon: <Sparkles className="w-6 h-6" />,
      name: 'CNN',
      description: 'Mạng neural tích chập cho nhận dạng ký tự chính xác cao'
    }
  ];

  const team = [
    {
      name: 'Nguyễn Hùng Mạnh',
      role: 'Lead Developer',
      image: '/image/anh1.jpg'
    },
    {
      name: 'Nguyễn Mạnh Hùng',
      role: 'AI Engineer',
      image: '/image/anh2.jpg'
    },
    {
      name: 'Hùng Mạnh Nguyễn',
      role: 'Full-stack Developer',
      image: '/image/anh3.jpg'
    },
    {
      name: 'Mạnh Hùng Nguyễn',
      role: 'UI/UX Designer',
      image: '/image/anh4.jpg'
    }
  ];

  const features = [
    'Nhận dạng phiếu trả lời tự động với độ chính xác cao',
    'Xử lý hàng loạt nhiều bài thi cùng lúc',
    'Xuất kết quả ra nhiều định dạng (PDF, Excel)',
    'Phân tích thống kê chi tiết và trực quan',
    'Lưu trữ lịch sử chấm điểm dễ dàng',
    'Giao diện thân thiện, dễ sử dụng'
  ];

  return (
    <div className="min-h-screen bg-white">
      {/* Hero Section */}
      <section className="relative bg-gradient-to-br from-blue-50 via-white to-blue-50 py-20">
        <div className="max-w-7xl mx-auto px-6">
          <div className="text-center max-w-3xl mx-auto">
            <div className="inline-flex items-center gap-2 px-4 py-2 bg-blue-100 text-[#2196F3] rounded-full mb-6">
              <Target className="w-4 h-4" />
              <span className="text-sm font-medium">Giới thiệu về chúng tôi</span>
            </div>
            <h1 className="text-5xl text-gray-900 mb-6">X-Exam Grader</h1>
            <p className="text-xl text-gray-600 leading-relaxed">
              Giải pháp chấm điểm tự động thông minh, sử dụng công nghệ AI và xử lý ảnh tiên tiến
              để mang lại hiệu quả cao nhất cho giáo viên và cơ sở giáo dục.
            </p>
          </div>
        </div>
      </section>

      {/* Mission Section */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-6">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <div>
              <h2 className="text-4xl text-gray-900 mb-6">Mục tiêu của chúng tôi</h2>
              <div className="space-y-4 text-lg text-gray-600 leading-relaxed">
                <p>
                  X-Exam Grader được phát triển với mục tiêu giúp giáo viên tiết kiệm thời gian
                  và công sức trong việc chấm điểm bài thi trắc nghiệm.
                </p>
                <p>
                  Chúng tôi tin rằng công nghệ AI có thể hỗ trợ đắc lực cho giáo dục, giúp giáo viên
                  có nhiều thời gian hơn để tập trung vào việc giảng dạy và phát triển học sinh.
                </p>
                <p>
                  Với độ chính xác cao và tốc độ xử lý nhanh chóng, X-Exam Grader là công cụ đắc lực
                  cho mọi cơ sở giáo dục, từ trường học đến trung tâm đào tạo.
                </p>
              </div>

              <div className="mt-8 grid grid-cols-2 gap-4">
                {features.map((feature, index) => (
                  <div key={index} className="flex items-start gap-2">
                    <CheckCircle2 className="w-5 h-5 text-green-600 flex-shrink-0 mt-1" />
                    <span className="text-gray-700">{feature}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="relative">
              <img
                src="https://images.unsplash.com/photo-1551288049-bebda4e38f71?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxkYXRhJTIwYW5hbHl0aWNzJTIwZGFzaGJvYXJkfGVufDF8fHx8MTc2NTQ0MDMwM3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
                alt="Analytics Dashboard"
                className="w-full rounded-2xl shadow-2xl"
              />
            </div>
          </div>
        </div>
      </section>

      {/* Technology Section */}
      <section className="py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-6">
          <div className="text-center mb-16">
            <h2 className="text-4xl text-gray-900 mb-4">Công nghệ sử dụng</h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              X-Exam Grader được xây dựng trên nền tảng công nghệ hiện đại và đáng tin cậy
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {technologies.map((tech, index) => (
              <div
                key={index}
                className="bg-white rounded-2xl p-8 hover:shadow-xl transition-all group"
              >
                <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-[#2196F3] to-[#1976D2] text-white flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                  {tech.icon}
                </div>
                <h3 className="text-xl text-gray-900 mb-3">{tech.name}</h3>
                <p className="text-gray-600">{tech.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Team Section */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-6">
          <div className="text-center mb-16">
            <h2 className="text-4xl text-gray-900 mb-4">Đội ngũ phát triển</h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Những con người đam mê công nghệ và giáo dục đứng sau X-Exam Grader
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {team.map((member, index) => (
              <div
                key={index}
                className="group"
              >
                <div className="relative overflow-hidden rounded-2xl mb-4">
                  <img
                    src={member.image}
                    alt={member.name}
                    className="w-full h-64 object-cover group-hover:scale-110 transition-transform duration-300"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 group-hover:opacity-100 transition-opacity flex items-end justify-center pb-6 gap-3">
                    <a href="#" className="w-10 h-10 rounded-full bg-white flex items-center justify-center hover:bg-gray-100 transition-colors">
                      <Github className="w-5 h-5 text-gray-900" />
                    </a>
                    <a href="#" className="w-10 h-10 rounded-full bg-white flex items-center justify-center hover:bg-gray-100 transition-colors">
                      <Linkedin className="w-5 h-5 text-gray-900" />
                    </a>
                  </div>
                </div>
                <h3 className="text-xl text-gray-900 mb-1">{member.name}</h3>
                <p className="text-gray-600">{member.role}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Contact Section */}
      <section className="py-20 bg-gradient-to-br from-gray-50 to-blue-50">
        <div className="max-w-7xl mx-auto px-6">
          <div className="grid lg:grid-cols-2 gap-12">
            {/* Contact Info */}
            <div>
              <h2 className="text-4xl text-gray-900 mb-6">Liên hệ với chúng tôi</h2>
              <p className="text-xl text-gray-600 mb-8">
                Chúng tôi luôn sẵn sàng hỗ trợ và giải đáp mọi thắc mắc của bạn
              </p>

              <div className="space-y-6">
                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-xl bg-[#2196F3] text-white flex items-center justify-center flex-shrink-0">
                    <Mail className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="text-lg text-gray-900 mb-1">Email</h3>
                    <p className="text-gray-600">nhmanh.dev@gmail.com</p>
                    <p className="text-gray-600">nhmanh.dev@gmail.com</p>
                  </div>
                </div>

                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-xl bg-green-600 text-white flex items-center justify-center flex-shrink-0">
                    <Phone className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="text-lg text-gray-900 mb-1">Điện thoại</h3>
                    <p className="text-gray-600">Hotline: 0392389623</p>
                    <p className="text-gray-600">Hỗ trợ: 0392389623</p>
                  </div>
                </div>

                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-xl bg-red-600 text-white flex items-center justify-center flex-shrink-0">
                    <MapPin className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="text-lg text-gray-900 mb-1">Địa chỉ</h3>
                    <p className="text-gray-600">Trường Đại học Thăng Long</p>
                    <p className="text-gray-600">Nghiêm Xuân Yên, Hà Nội</p>
                  </div>
                </div>

                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-xl bg-purple-600 text-white flex items-center justify-center flex-shrink-0">
                    <Users className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="text-lg text-gray-900 mb-1">Giờ làm việc</h3>
                    <p className="text-gray-600">Thứ 2 - Thứ 6: 8:00 - 17:00</p>
                    {/* <p className="text-gray-600">Thứ 7: 8:00 - 12:00</p> */}
                  </div>
                </div>
              </div>
            </div>

            {/* Contact Form */}
            <div className="bg-white rounded-2xl p-8 shadow-lg">
              <h3 className="text-2xl text-gray-900 mb-6">Gửi tin nhắn cho chúng tôi</h3>
              <form className="space-y-4">
                <div>
                  <label className="block text-gray-700 mb-2">Họ và tên</label>
                  <input
                    type="text"
                    className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-[#2196F3] focus:outline-none"
                    placeholder="Nhập họ và tên"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 mb-2">Email</label>
                  <input
                    type="email"
                    className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-[#2196F3] focus:outline-none"
                    placeholder="example@email.com"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 mb-2">Số điện thoại</label>
                  <input
                    type="tel"
                    className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-[#2196F3] focus:outline-none"
                    placeholder="0123 456 789"
                  />
                </div>

                <div>
                  <label className="block text-gray-700 mb-2">Nội dung</label>
                  <textarea
                    rows={4}
                    className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-[#2196F3] focus:outline-none resize-none"
                    placeholder="Nhập nội dung tin nhắn..."
                  ></textarea>
                </div>

                <button
                  type="submit"
                  className="w-full py-3 bg-[#2196F3] text-white rounded-xl hover:bg-[#1976D2] transition-all"
                >
                  Gửi tin nhắn
                </button>
              </form>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-gradient-to-br from-[#2196F3] to-[#1976D2]">
        <div className="max-w-4xl mx-auto px-6 text-center">
          <h2 className="text-4xl text-white mb-6">
            Sẵn sàng trải nghiệm X-Exam Grader?
          </h2>
          <p className="text-xl text-blue-100 mb-8">
            Bắt đầu chấm điểm thông minh ngay hôm nay
          </p>
          <Link
            to="/cham-diem"
            className="inline-flex items-center gap-2 px-8 py-4 bg-white text-[#2196F3] rounded-xl hover:bg-gray-100 transition-all shadow-lg"
          >
            <span>Bắt đầu ngay</span>
            <ArrowRight className="w-5 h-5" />
          </Link>
        </div>
      </section>
    </div>
  );
}
