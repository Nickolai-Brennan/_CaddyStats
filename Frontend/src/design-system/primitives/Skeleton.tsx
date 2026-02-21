import type { CSSProperties } from 'react';

interface SkeletonProps {
  className?: string;
  width?: CSSProperties['width'];
  height?: CSSProperties['height'];
  rounded?: boolean;
}

export function Skeleton({ className = '', width, height, rounded = false }: SkeletonProps) {
  return (
    <div
      className={[
        'animate-pulse bg-gray-200 dark:bg-gray-700',
        rounded ? 'rounded-full' : 'rounded',
        className,
      ].join(' ')}
      style={{ width, height }}
    />
  );
}

export function SkeletonText({ lines = 3, className = '' }: { lines?: number; className?: string }) {
  return (
    <div className={['space-y-2', className].join(' ')}>
      {Array.from({ length: lines }).map((_, i) => (
        <Skeleton
          key={i}
          height="1rem"
          width={i === lines - 1 ? '75%' : '100%'}
        />
      ))}
    </div>
  );
}

export function SkeletonCard({ className = '' }: { className?: string }) {
  return (
    <div className={['bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-xl p-5 space-y-3', className].join(' ')}>
      <Skeleton height="1.25rem" width="60%" />
      <SkeletonText lines={3} />
    </div>
  );
}
