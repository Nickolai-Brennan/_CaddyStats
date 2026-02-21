type Size = 'sm' | 'md' | 'lg';

interface SpinnerProps {
  size?: Size;
  className?: string;
}

const sizes: Record<Size, number> = { sm: 16, md: 24, lg: 32 };

export function Spinner({ size = 'md', className = '' }: SpinnerProps) {
  const px = sizes[size];
  return (
    <svg
      width={px}
      height={px}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={2.5}
      strokeLinecap="round"
      className={['animate-spin', className].join(' ')}
      aria-label="Loading"
      role="status"
    >
      <path d="M21 12a9 9 0 1 1-6.219-8.56" />
    </svg>
  );
}
