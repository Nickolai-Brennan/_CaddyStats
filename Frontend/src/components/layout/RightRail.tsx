import { cn } from '../../utils/cn';

const TRENDING_ITEMS = [
  'Scottie Scheffler leads FedEx standings',
  'Rory McIlroy wins at Augusta',
  'LIV Golf announces new season schedule',
  'Tiger Woods returns to competition',
  'Jon Rahm tops world rankings',
];

interface RightRailProps {
  className?: string;
}

function TrendingList() {
  return (
    <div>
      <h2 className="text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-3 px-2">
        Trending
      </h2>
      <ol className="space-y-2">
        {TRENDING_ITEMS.map((item, i) => (
          <li key={item} className="flex gap-3 px-2">
            <span className="text-sm font-bold text-green-600 dark:text-green-400 shrink-0 w-4">
              {i + 1}
            </span>
            <span className="text-sm text-gray-700 dark:text-gray-300 leading-snug">{item}</span>
          </li>
        ))}
      </ol>
    </div>
  );
}

function NewsletterCTA() {
  return (
    <div className="rounded-lg bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 p-4">
      <h3 className="text-sm font-bold text-gray-900 dark:text-gray-100 mb-1">Stay in the loop</h3>
      <p className="text-xs text-gray-500 dark:text-gray-400 mb-3">
        Get the latest golf news delivered to your inbox.
      </p>
      <div className="flex flex-col gap-2">
        <input
          type="email"
          placeholder="your@email.com"
          className="w-full px-3 py-1.5 text-sm rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-green-500"
          aria-label="Email address for newsletter"
        />
        <button
          type="button"
          className="w-full px-3 py-1.5 text-sm font-medium rounded-md bg-green-600 hover:bg-green-700 text-white transition-colors"
        >
          Subscribe
        </button>
      </div>
    </div>
  );
}

function AdSlot({ label = 'Advertisement' }: { label?: string }) {
  return (
    <div className="rounded-lg border-2 border-dashed border-gray-200 dark:border-gray-700 p-4 text-center">
      <p className="text-xs text-gray-400 dark:text-gray-500">{label}</p>
      <div className="mt-2 h-32 bg-gray-100 dark:bg-gray-800 rounded" aria-hidden="true" />
    </div>
  );
}

export function RightRail({ className }: RightRailProps) {
  return (
    <aside className={cn('space-y-6', className)} aria-label="Sidebar">
      <TrendingList />
      <NewsletterCTA />
      <AdSlot />
      <AdSlot />
    </aside>
  );
}
