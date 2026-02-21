import { Link } from 'react-router-dom';
import { cn } from '../../utils/cn';
import { formatDate } from '../../utils/formatters';

export interface ArticleCardProps {
  id: string;
  title: string;
  slug: string;
  excerpt?: string;
  featuredImageUrl?: string;
  publishedAt?: string;
  author?: string;
  category?: string;
  tags?: string[];
  readTime?: string;
  variant?: 'hero' | 'standard' | 'compact';
}

function ImagePlaceholder({ className }: { className?: string }) {
  return <div className={cn('bg-gray-200 dark:bg-gray-700', className)} aria-hidden="true" />;
}

export function ArticleCard({
  title,
  slug,
  excerpt,
  featuredImageUrl,
  publishedAt,
  author,
  category,
  readTime,
  variant = 'standard',
}: ArticleCardProps) {
  const href = `/post/${slug}`;

  if (variant === 'hero') {
    return (
      <Link to={href} className="block relative overflow-hidden rounded-xl aspect-[16/9] bg-gray-100 dark:bg-gray-800 group">
        {featuredImageUrl ? (
          <img
            src={featuredImageUrl}
            alt={title}
            loading="lazy"
            sizes="(max-width: 768px) 100vw, 66vw"
            className="absolute inset-0 w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
          />
        ) : (
          <ImagePlaceholder className="absolute inset-0 w-full h-full" />
        )}
        <div className="absolute inset-0 bg-gradient-to-t from-black/70 to-transparent" />
        <div className="absolute bottom-0 left-0 right-0 p-6">
          {category && (
            <span className="text-xs font-semibold uppercase tracking-wider text-green-400 mb-2 block">
              {category}
            </span>
          )}
          <h2 className="text-2xl font-bold text-white leading-tight line-clamp-3">{title}</h2>
          {publishedAt && (
            <p className="mt-2 text-sm text-gray-300">{formatDate(publishedAt)}</p>
          )}
        </div>
      </Link>
    );
  }

  if (variant === 'compact') {
    return (
      <Link to={href} className="flex gap-3 items-start group">
        <div className="flex-shrink-0 w-20 h-20 rounded-lg overflow-hidden">
          {featuredImageUrl ? (
            <img
              src={featuredImageUrl}
              alt={title}
              loading="lazy"
              sizes="80px"
              className="w-full h-full object-cover transition-transform duration-200 group-hover:scale-105"
            />
          ) : (
            <ImagePlaceholder className="w-full h-full" />
          )}
        </div>
        <div className="flex-1 min-w-0">
          <h3 className="text-sm font-semibold text-gray-900 dark:text-gray-100 line-clamp-2 group-hover:text-green-600 dark:group-hover:text-green-400 transition-colors">
            {title}
          </h3>
          {publishedAt && (
            <p className="mt-1 text-xs text-gray-500 dark:text-gray-400">{formatDate(publishedAt)}</p>
          )}
        </div>
      </Link>
    );
  }

  // standard
  return (
    <Link to={href} className="block group">
      <div className="aspect-video rounded-lg overflow-hidden bg-gray-100 dark:bg-gray-800 mb-3">
        {featuredImageUrl ? (
          <img
            src={featuredImageUrl}
            alt={title}
            loading="lazy"
            sizes="(max-width: 640px) 100vw, 50vw"
            className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
          />
        ) : (
          <ImagePlaceholder className="w-full h-full" />
        )}
      </div>
      <div>
        {category && (
          <span className="text-xs font-semibold uppercase tracking-wider text-green-600 dark:text-green-400 mb-1 block">
            {category}
          </span>
        )}
        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 line-clamp-2 group-hover:text-green-600 dark:group-hover:text-green-400 transition-colors">
          {title}
        </h3>
        {excerpt && (
          <p className="mt-1 text-sm text-gray-600 dark:text-gray-400 line-clamp-2">{excerpt}</p>
        )}
        <div className="mt-2 flex items-center gap-2 text-xs text-gray-500 dark:text-gray-400">
          {publishedAt && <span>{formatDate(publishedAt)}</span>}
          {readTime && <><span>·</span><span>{readTime}</span></>}
          {author && <><span>·</span><span>{author}</span></>}
        </div>
      </div>
    </Link>
  );
}
