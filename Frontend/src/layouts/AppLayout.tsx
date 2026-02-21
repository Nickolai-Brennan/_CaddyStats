import { Outlet } from 'react-router-dom';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { LeftRail } from '../components/layout/LeftRail';
import { RightRail } from '../components/layout/RightRail';

export function AppLayout() {
  return (
    <div className="min-h-screen flex flex-col bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-100">
      <Header />

      {/* 20 / 50 / 30 three-column grid */}
      <div className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <div className="grid grid-cols-1 lg:grid-cols-[200px_1fr_280px] gap-6">
          {/* Left rail — desktop only */}
          <LeftRail className="hidden lg:block" />

          {/* Main content */}
          <main id="main-content" className="min-w-0">
            <Outlet />
          </main>

          {/* Right rail — tablet + desktop */}
          <RightRail className="hidden md:block" />
        </div>
      </div>

      <Footer />
    </div>
  );
}

