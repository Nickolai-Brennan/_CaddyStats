import type { ReactNode } from 'react';

type Variant = 'default' | 'primary' | 'success' | 'warning' | 'error' | 'info';

interface BadgeProps {
  variant?: Variant;
  pill?: boolean;
  className?: string;
  children: ReactNode;
}

const variantClasses: Record<Variant, string> = {
  default: 'bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-200',
  primary: 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
  success: 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
  warning: 'bg-amber-100 text-amber-800 dark:bg-amber-900 dark:text-amber-200',
  error: 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200',
  info: 'bg-sky-100 text-sky-800 dark:bg-sky-900 dark:text-sky-200',
};

export function Badge({ variant = 'default', pill = false, className = '', children }: BadgeProps) {
  return (
    <span
      className={[
        'inline-flex items-center px-2 py-0.5 text-xs font-medium',
        pill ? 'rounded-full' : 'rounded',
        variantClasses[variant],
        className,
      ].join(' ')}
    >
      {children}
    </span>
  );
}
