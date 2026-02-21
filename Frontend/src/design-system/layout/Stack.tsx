import type { ReactNode } from 'react';
import { cn } from '../../utils/cn';

type Gap = 'sm' | 'md' | 'lg' | 'xl';

interface StackProps {
  gap?: Gap;
  className?: string;
  children: ReactNode;
}

const gapMap: Record<Gap, string> = {
  sm: 'gap-2',
  md: 'gap-4',
  lg: 'gap-6',
  xl: 'gap-8',
};

export function Stack({ gap = 'md', className, children }: StackProps) {
  return (
    <div className={cn('flex flex-col', gapMap[gap], className)}>
      {children}
    </div>
  );
}
