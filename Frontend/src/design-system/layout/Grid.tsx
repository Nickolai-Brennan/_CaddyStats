import type { ReactNode } from 'react';
import { cn } from '../../utils/cn';

type ColCount = 1 | 2 | 3 | 4 | 6 | 12;
type SpanCount = 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 'full';
type Gap = 'sm' | 'md' | 'lg' | 'xl';

export interface GridProps {
  cols?: ColCount;
  smCols?: ColCount;
  mdCols?: ColCount;
  lgCols?: ColCount;
  gap?: Gap;
  className?: string;
  children: ReactNode;
}

export interface GridItemProps {
  span?: SpanCount;
  smSpan?: SpanCount;
  mdSpan?: SpanCount;
  lgSpan?: SpanCount;
  className?: string;
  children: ReactNode;
}

// Full class strings required for Tailwind purging
const colsMap: Record<ColCount, string> = {
  1: 'grid-cols-1',
  2: 'grid-cols-2',
  3: 'grid-cols-3',
  4: 'grid-cols-4',
  6: 'grid-cols-6',
  12: 'grid-cols-12',
};

const smColsMap: Record<ColCount, string> = {
  1: 'sm:grid-cols-1',
  2: 'sm:grid-cols-2',
  3: 'sm:grid-cols-3',
  4: 'sm:grid-cols-4',
  6: 'sm:grid-cols-6',
  12: 'sm:grid-cols-12',
};

const mdColsMap: Record<ColCount, string> = {
  1: 'md:grid-cols-1',
  2: 'md:grid-cols-2',
  3: 'md:grid-cols-3',
  4: 'md:grid-cols-4',
  6: 'md:grid-cols-6',
  12: 'md:grid-cols-12',
};

const lgColsMap: Record<ColCount, string> = {
  1: 'lg:grid-cols-1',
  2: 'lg:grid-cols-2',
  3: 'lg:grid-cols-3',
  4: 'lg:grid-cols-4',
  6: 'lg:grid-cols-6',
  12: 'lg:grid-cols-12',
};

const gapMap: Record<Gap, string> = {
  sm: 'gap-2',
  md: 'gap-4',
  lg: 'gap-6',
  xl: 'gap-8',
};

const spanMap: Record<SpanCount, string> = {
  1: 'col-span-1',
  2: 'col-span-2',
  3: 'col-span-3',
  4: 'col-span-4',
  5: 'col-span-5',
  6: 'col-span-6',
  7: 'col-span-7',
  8: 'col-span-8',
  9: 'col-span-9',
  10: 'col-span-10',
  11: 'col-span-11',
  12: 'col-span-12',
  full: 'col-span-full',
};

const smSpanMap: Record<SpanCount, string> = {
  1: 'sm:col-span-1',
  2: 'sm:col-span-2',
  3: 'sm:col-span-3',
  4: 'sm:col-span-4',
  5: 'sm:col-span-5',
  6: 'sm:col-span-6',
  7: 'sm:col-span-7',
  8: 'sm:col-span-8',
  9: 'sm:col-span-9',
  10: 'sm:col-span-10',
  11: 'sm:col-span-11',
  12: 'sm:col-span-12',
  full: 'sm:col-span-full',
};

const mdSpanMap: Record<SpanCount, string> = {
  1: 'md:col-span-1',
  2: 'md:col-span-2',
  3: 'md:col-span-3',
  4: 'md:col-span-4',
  5: 'md:col-span-5',
  6: 'md:col-span-6',
  7: 'md:col-span-7',
  8: 'md:col-span-8',
  9: 'md:col-span-9',
  10: 'md:col-span-10',
  11: 'md:col-span-11',
  12: 'md:col-span-12',
  full: 'md:col-span-full',
};

const lgSpanMap: Record<SpanCount, string> = {
  1: 'lg:col-span-1',
  2: 'lg:col-span-2',
  3: 'lg:col-span-3',
  4: 'lg:col-span-4',
  5: 'lg:col-span-5',
  6: 'lg:col-span-6',
  7: 'lg:col-span-7',
  8: 'lg:col-span-8',
  9: 'lg:col-span-9',
  10: 'lg:col-span-10',
  11: 'lg:col-span-11',
  12: 'lg:col-span-12',
  full: 'lg:col-span-full',
};

export function Grid({
  cols = 1,
  smCols,
  mdCols,
  lgCols,
  gap = 'md',
  className,
  children,
}: GridProps) {
  return (
    <div
      className={cn(
        'grid',
        colsMap[cols],
        smCols && smColsMap[smCols],
        mdCols && mdColsMap[mdCols],
        lgCols && lgColsMap[lgCols],
        gapMap[gap],
        className,
      )}
    >
      {children}
    </div>
  );
}

export function GridItem({
  span,
  smSpan,
  mdSpan,
  lgSpan,
  className,
  children,
}: GridItemProps) {
  return (
    <div
      className={cn(
        span && spanMap[span],
        smSpan && smSpanMap[smSpan],
        mdSpan && mdSpanMap[mdSpan],
        lgSpan && lgSpanMap[lgSpan],
        className,
      )}
    >
      {children}
    </div>
  );
}
