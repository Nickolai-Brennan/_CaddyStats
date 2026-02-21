import { Link, useLocation } from 'react-router-dom';
import { cn } from '../../utils/cn';

const CATEGORIES = [
  { label: 'Golf News', to: '/archive' },
  { label: 'PGA Tour', to: '/archive' },
  { label: 'LIV Golf', to: '/archive' },
  { label: 'Player Stats', to: '/archive' },
  { label: 'Betting Lines', to: '/archive' },
  { label: 'Course Guide', to: '/archive' },
];

interface LeftRailProps {
  className?: string;
}

export function LeftRail({ className }: LeftRailProps) {
  const { pathname } = useLocation();

  return (
    <aside className={cn('space-y-6', className)} aria-label="Category navigation">
      <div>
        <h2 className="text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-3 px-2">
          Categories
        </h2>
        <nav>
          <ul className="space-y-0.5">
            {CATEGORIES.map(({ label, to }) => {
              const active = pathname === to;
              return (
                <li key={label}>
                  <Link
                    to={to}
                    className={cn(
                      'block px-3 py-2 rounded-md text-sm font-medium transition-colors',
                      active
                        ? 'bg-green-100 text-green-700 dark:bg-green-900/40 dark:text-green-300'
                        : 'text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 hover:text-gray-900 dark:hover:text-white',
                    )}
                  >
                    {label}
                  </Link>
                </li>
              );
            })}
          </ul>
        </nav>
      </div>

      {/* Promo / Ad slot */}
      <div className="rounded-lg border-2 border-dashed border-gray-200 dark:border-gray-700 p-4 text-center">
        <p className="text-xs text-gray-400 dark:text-gray-500">Advertisement</p>
        <div className="mt-2 h-24 bg-gray-100 dark:bg-gray-800 rounded" aria-hidden="true" />
      </div>
    </aside>
  );
}
