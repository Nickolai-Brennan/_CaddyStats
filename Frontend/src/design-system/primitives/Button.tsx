import type { ButtonHTMLAttributes, ReactNode } from 'react';

type Variant = 'primary' | 'ghost' | 'outline' | 'danger';
type Size = 'sm' | 'md' | 'lg';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: Variant;
  size?: Size;
  loading?: boolean;
  children?: ReactNode;
}

const variantClasses: Record<Variant, string> = {
  primary:
    'bg-green-600 text-white hover:bg-green-700 focus:ring-green-500 disabled:bg-green-300',
  ghost:
    'bg-transparent text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-800 focus:ring-gray-400',
  outline:
    'border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-800 focus:ring-gray-400',
  danger:
    'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500 disabled:bg-red-300',
};

const sizeClasses: Record<Size, string> = {
  sm: 'px-3 py-1.5 text-sm',
  md: 'px-4 py-2 text-sm',
  lg: 'px-6 py-3 text-base',
};

export function Button({
  variant = 'primary',
  size = 'md',
  loading = false,
  disabled,
  className = '',
  children,
  ...rest
}: ButtonProps) {
  return (
    <button
      disabled={disabled ?? loading}
      className={[
        'inline-flex items-center justify-center gap-2 font-medium rounded-lg transition-colors',
        'focus:outline-none focus:ring-2 focus:ring-offset-2',
        'disabled:opacity-60 disabled:cursor-not-allowed',
        variantClasses[variant],
        sizeClasses[size],
        className,
      ].join(' ')}
      {...rest}
    >
      {loading && (
        <>
          <span
            className="inline-block w-4 h-4 border-2 border-current border-t-transparent rounded-full animate-spin"
            aria-hidden="true"
          />
          <span className="sr-only">Loading…</span>
        </>
      )}
      {children}
    </button>
  );
}
