import { SeoHead } from '../../design-system/seo/SeoHead';

interface DirectoryCard {
  id: string;
  title: string;
  description: string;
  href: string;
  badge?: string;
}

const DIRECTORY_ITEMS: DirectoryCard[] = [
  {
    id: 'caddy-stats',
    title: 'Caddy Stats',
    description: 'In-depth golf analytics, tournament previews, and player performance breakdowns powered by Strik3Zone data.',
    href: '/',
    badge: 'Live',
  },
  {
    id: 'strik3zone',
    title: 'Strik3Zone Platform',
    description: 'The underlying data engine powering Caddy Stats. Provides strokes-gained models, projections, and betting market signals.',
    href: '#',
    badge: 'Coming Soon',
  },
  {
    id: 'betting-intel',
    title: 'Betting Intelligence Hub',
    description: 'Curated betting picks, value identification, and odds comparison tools for professional golf tournaments.',
    href: '#',
    badge: 'Coming Soon',
  },
  {
    id: 'course-guides',
    title: 'Course Guide Library',
    description: 'Detailed guides for every major venue on the PGA Tour and LIV Golf circuit — hole-by-hole breakdowns and historical data.',
    href: '#',
    badge: 'Coming Soon',
  },
];

export function DirectoryView() {
  return (
    <>
      <SeoHead
        title="Directory | Caddy Stats"
        description="Browse the Strik3Zone product directory — golf analytics tools, data services, and more."
      />
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <h1 className="text-4xl font-bold text-gray-900 dark:text-gray-100 mb-2">Strik3Zone Directory</h1>
        <p className="text-gray-500 dark:text-gray-400 mb-10">
          Explore the full suite of tools and services in the Strik3Zone ecosystem.
        </p>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
          {DIRECTORY_ITEMS.map((item) => (
            <a
              key={item.id}
              href={item.href}
              className="block rounded-xl border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 p-6 hover:border-green-400 dark:hover:border-green-500 hover:shadow-md transition-all group"
              rel={item.href !== '/' ? 'noopener noreferrer' : undefined}
            >
              <div className="flex items-start justify-between mb-3">
                <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100 group-hover:text-green-600 dark:group-hover:text-green-400 transition-colors">
                  {item.title}
                </h2>
                {item.badge && (
                  <span className={`ml-2 flex-shrink-0 text-xs font-semibold px-2 py-0.5 rounded-full ${
                    item.badge === 'Live'
                      ? 'bg-green-100 dark:bg-green-900/40 text-green-700 dark:text-green-400'
                      : 'bg-gray-100 dark:bg-gray-800 text-gray-500 dark:text-gray-400'
                  }`}>
                    {item.badge}
                  </span>
                )}
              </div>
              <p className="text-sm text-gray-600 dark:text-gray-400 leading-relaxed">
                {item.description}
              </p>
            </a>
          ))}
        </div>
      </div>
    </>
  );
}
