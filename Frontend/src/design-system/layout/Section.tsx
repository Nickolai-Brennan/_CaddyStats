import type { ReactNode } from 'react';
import { Link } from 'react-router-dom';
import { cn } from '../../utils/cn';

export interface SectionProps {
  title?: string;
  subtitle?: string;
  actions?: ReactNode;
  viewAllHref?: string;
  viewAllLabel?: string;
  className?: string;
  children: ReactNode;
}

export function Section({
  title,
  subtitle,
  actions,
  viewAllHref,
  viewAllLabel = 'View all',
  className,
  children,
}: SectionProps) {
  const hasHeader = title || subtitle || actions || viewAllHref;

  return (
    <section className={cn('py-6', className)}>
      {hasHeader && (
        <div className="flex items-start justify-between mb-4 gap-4">
          <div className="min-w-0">
            {title && (
              <h2 className="text-xl font-bold text-gray-900 dark:text-gray-100 leading-tight">
                {title}
              </h2>
            )}
            {subtitle && (
              <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">{subtitle}</p>
            )}
          </div>
          <div className="flex items-center gap-3 shrink-0">
            {actions}
            {viewAllHref && (
              <Link
                to={viewAllHref}
                className="text-sm font-medium text-green-600 dark:text-green-400 hover:underline whitespace-nowrap"
              >
                {viewAllLabel} →
              </Link>
            )}
          </div>
        </div>
      )}
      {children}
    </section>
  );
}
