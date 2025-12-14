import { Outlet, Link, useLocation } from 'react-router';
import { GraduationCap, Home, FileCheck, History, Info } from 'lucide-react';

export default function Layout() {
  const location = useLocation();
  
  const isActive = (path: string) => {
    if (path === '/' && location.pathname === '/') return true;
    if (path !== '/' && location.pathname.startsWith(path)) return true;
    return false;
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Navigation */}
      <nav className="bg-white border-b border-gray-200 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            {/* Logo */}
            <Link to="/" className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#2196F3] to-[#1976D2] flex items-center justify-center">
                <GraduationCap className="w-6 h-6 text-white" />
              </div>
              <span className="text-xl font-semibold text-gray-900">X-Exam Grader</span>
            </Link>

            {/* Navigation Links */}
            <div className="flex items-center gap-2">
              <Link
                to="/"
                className={`px-4 py-2 rounded-lg transition-all ${
                  isActive('/')
                    ? 'bg-blue-50 text-[#2196F3]'
                    : 'text-gray-600 hover:bg-gray-100'
                }`}
              >
                <div className="flex items-center gap-2">
                  <Home className="w-4 h-4" />
                  <span>Trang chủ</span>
                </div>
              </Link>
              <Link
                to="/cham-diem"
                className={`px-4 py-2 rounded-lg transition-all ${
                  isActive('/cham-diem')
                    ? 'bg-blue-50 text-[#2196F3]'
                    : 'text-gray-600 hover:bg-gray-100'
                }`}
              >
                <div className="flex items-center gap-2">
                  <FileCheck className="w-4 h-4" />
                  <span>Chấm điểm</span>
                </div>
              </Link>
              <Link
                to="/lich-su"
                className={`px-4 py-2 rounded-lg transition-all ${
                  isActive('/lich-su')
                    ? 'bg-blue-50 text-[#2196F3]'
                    : 'text-gray-600 hover:bg-gray-100'
                }`}
              >
                <div className="flex items-center gap-2">
                  <History className="w-4 h-4" />
                  <span>Lịch sử</span>
                </div>
              </Link>
              <Link
                to="/gioi-thieu"
                className={`px-4 py-2 rounded-lg transition-all ${
                  isActive('/gioi-thieu')
                    ? 'bg-blue-50 text-[#2196F3]'
                    : 'text-gray-600 hover:bg-gray-100'
                }`}
              >
                <div className="flex items-center gap-2">
                  <Info className="w-4 h-4" />
                  <span>Giới thiệu</span>
                </div>
              </Link>
            </div>
          </div>
        </div>
      </nav>

      {/* Main Content */}
      <main>
        <Outlet />
      </main>
    </div>
  );
}
