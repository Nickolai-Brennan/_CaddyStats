import type { ReactNode } from 'react';
import { cn } from '../../utils/cn';

type Size = 'sm' | 'md' | 'lg' | 'xl' | 'full';

interface ContainerProps {
  size?: Size;
  className?: string;
  children: ReactNode;
}

const sizeMap: Record<Size, string> = {
  sm: 'max-w-2xl',
  md: 'max-w-4xl',
  lg: 'max-w-6xl',
  xl: 'max-w-7xl',
  full: 'max-w-full',
};

export function Container({ size = 'xl', className, children }: ContainerProps) {
  return (
    <div className={cn('mx-auto px-4 sm:px-6 lg:px-8', sizeMap[size], className)}>
      {children}
    </div>
  );
}
