import { useEffect, type ReactNode } from 'react';
import { createPortal } from 'react-dom';

type Side = 'left' | 'right';

interface DrawerProps {
  open: boolean;
  onClose: () => void;
  title?: string;
  children: ReactNode;
  side?: Side;
}

export function Drawer({ open, onClose, title, children, side = 'right' }: DrawerProps) {
  useEffect(() => {
    if (!open) return;
    const handler = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose();
    };
    document.addEventListener('keydown', handler);
    return () => document.removeEventListener('keydown', handler);
  }, [open, onClose]);

  return createPortal(
    <div
      className={[
        'fixed inset-0 z-[1300] flex',
        side === 'right' ? 'justify-end' : 'justify-start',
        open ? 'pointer-events-auto' : 'pointer-events-none',
      ].join(' ')}
      role="dialog"
      aria-modal="true"
      aria-label={title}
    >
      {/* Backdrop */}
      <div
        className={[
          'absolute inset-0 bg-black/50 transition-opacity duration-300',
          open ? 'opacity-100' : 'opacity-0',
        ].join(' ')}
        onClick={onClose}
        aria-hidden="true"
      />
      {/* Panel */}
      <div
        className={[
          'relative z-10 h-full w-80 max-w-full bg-white dark:bg-gray-800 shadow-xl flex flex-col',
          'transition-transform duration-300 ease-in-out',
          side === 'right'
            ? open ? 'translate-x-0' : 'translate-x-full'
            : open ? 'translate-x-0' : '-translate-x-full',
        ].join(' ')}
      >
        <div className="flex items-center justify-between px-4 py-3 border-b border-gray-200 dark:border-gray-700">
          {title && <h2 className="text-base font-semibold text-gray-900 dark:text-gray-100">{title}</h2>}
          <button
            autoFocus={open}
            onClick={onClose}
            className="ml-auto p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-700 text-gray-500 dark:text-gray-400 focus:outline-none focus:ring-2 focus:ring-green-500"
            aria-label="Close drawer"
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>
        <div className="flex-1 overflow-y-auto p-4">{children}</div>
      </div>
    </div>,
    document.body,
  );
}
