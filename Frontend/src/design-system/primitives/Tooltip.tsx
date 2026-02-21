import type { ReactNode } from 'react';

type Position = 'top' | 'bottom' | 'left' | 'right';

interface TooltipProps {
  content: string;
  children: ReactNode;
  position?: Position;
}

const positionClasses: Record<Position, string> = {
  top: 'bottom-full left-1/2 -translate-x-1/2 mb-2',
  bottom: 'top-full left-1/2 -translate-x-1/2 mt-2',
  left: 'right-full top-1/2 -translate-y-1/2 mr-2',
  right: 'left-full top-1/2 -translate-y-1/2 ml-2',
};

export function Tooltip({ content, children, position = 'top' }: TooltipProps) {
  return (
    <span className="relative inline-flex group">
      {children}
      <span
        role="tooltip"
        className={[
          'absolute z-50 px-2 py-1 text-xs font-medium text-white bg-gray-900 dark:bg-gray-700 rounded whitespace-nowrap',
          'opacity-0 group-hover:opacity-100 pointer-events-none transition-opacity duration-150',
          positionClasses[position],
        ].join(' ')}
      >
        {content}
      </span>
    </span>
  );
}
