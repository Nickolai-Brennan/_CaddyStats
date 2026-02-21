import type { ReactNode } from 'react';

type Padding = 'sm' | 'md' | 'lg';

interface CardProps {
  children: ReactNode;
  className?: string;
  padding?: Padding;
  hover?: boolean;
}

const paddingClasses: Record<Padding, string> = {
  sm: 'p-3',
  md: 'p-5',
  lg: 'p-8',
};

export function Card({ children, className = '', padding = 'md', hover = false }: CardProps) {
  return (
    <div
      className={[
        'bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl',
        paddingClasses[padding],
        hover ? 'transition-shadow hover:shadow-md cursor-pointer' : '',
        className,
      ].join(' ')}
    >
      {children}
    </div>
  );
}
