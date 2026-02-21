import { useState, useCallback } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useTheme } from '../app/providers/ThemeProvider';
import { Icon } from '../design-system/icons/Icon';
import { Drawer } from '../design-system/primitives/Drawer';
import { cn } from '../utils/cn';

const NAV_LINKS = [
  { label: 'Home', to: '/' },
  { label: 'Archive', to: '/archive' },
  { label: 'About', to: '/about' },
  { label: 'Contact', to: '/contact' },
] as const;

function NavLink({ to, label }: { to: string; label: string }) {
  const { pathname } = useLocation();
  const active = pathname === to || (to !== '/' && pathname.startsWith(to));
  return (
    <Link
      to={to}
      className={cn(
        'text-sm font-medium px-3 py-1.5 rounded-md transition-colors',
        active
          ? 'bg-green-100 text-green-700 dark:bg-green-900/40 dark:text-green-300'
          : 'text-gray-600 hover:text-gray-900 dark:text-gray-300 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-800',
      )}
    >
      {label}
    </Link>
  );
}

export function Header() {
  const { theme, toggleTheme } = useTheme();
  const [drawerOpen, setDrawerOpen] = useState(false);
  const closeDrawer = useCallback(() => setDrawerOpen(false), []);

  return (
    <>
      {/* Skip-to-content for accessibility */}
      <a
        href="#main-content"
        className="sr-only focus:not-sr-only focus:fixed focus:top-2 focus:left-2 focus:z-[9999] focus:bg-white focus:text-green-700 focus:px-4 focus:py-2 focus:rounded focus:shadow-lg focus:outline-none focus:ring-2 focus:ring-green-500"
      >
        Skip to content
      </a>

      <header className="sticky top-0 z-50 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-700 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-14 flex items-center gap-4">
          {/* Logo */}
          <Link
            to="/"
            className="flex items-center gap-2 font-bold text-gray-900 dark:text-white hover:opacity-80 transition-opacity shrink-0"
            aria-label="Caddy Stats home"
          >
            <span className="text-xl" aria-hidden="true">⛳</span>
            <span className="text-base">Caddy Stats</span>
          </Link>

          {/* Desktop nav */}
          <nav className="hidden md:flex items-center gap-1 ml-4" aria-label="Primary navigation">
            {NAV_LINKS.map((link) => (
              <NavLink key={link.to} to={link.to} label={link.label} />
            ))}
          </nav>

          {/* Right actions */}
          <div className="flex items-center gap-2 ml-auto">
            {/* Search trigger */}
            <button
              type="button"
              onClick={() => { /* TODO: open search */ }}
              className="p-2 rounded-md text-gray-500 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
              aria-label="Search"
            >
              <Icon name="search" size={18} />
            </button>

            {/* Theme toggle */}
            <button
              type="button"
              onClick={toggleTheme}
              className="p-2 rounded-md text-gray-500 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
              aria-label={theme === 'light' ? 'Switch to dark mode' : 'Switch to light mode'}
            >
              <Icon name={theme === 'light' ? 'moon' : 'sun'} size={18} />
            </button>

            {/* Mobile hamburger */}
            <button
              type="button"
              className="md:hidden p-2 rounded-md text-gray-500 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
              aria-label="Open navigation menu"
              aria-expanded={drawerOpen}
              onClick={() => setDrawerOpen(true)}
            >
              <Icon name="menu" size={20} />
            </button>
          </div>
        </div>
      </header>

      {/* Mobile nav drawer */}
      <Drawer open={drawerOpen} onClose={closeDrawer} title="Navigation" side="right">
        <nav className="flex flex-col gap-1" aria-label="Mobile navigation">
          {NAV_LINKS.map((link) => (
            <Link
              key={link.to}
              to={link.to}
              onClick={closeDrawer}
              className="block px-3 py-2.5 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700 transition-colors"
            >
              {link.label}
            </Link>
          ))}
        </nav>
      </Drawer>
    </>
  );
}
