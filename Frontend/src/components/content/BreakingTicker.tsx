const DEFAULT_ITEMS = [
  'PGA Tour: Scottie Scheffler leads FedEx Cup',
  'LIV Golf: Jon Rahm wins Adelaide',
  'Masters Preview: Top 10 Favorites Released',
  'Tiger Woods Foundation Announces 2025 Events',
];

interface BreakingTickerProps {
  items?: string[];
}

export function BreakingTicker({ items = DEFAULT_ITEMS }: BreakingTickerProps) {
  const tickerText = items.join('  •  ');

  return (
    <div className="flex items-center bg-gray-900 dark:bg-black text-white overflow-hidden h-9">
      {/* Badge */}
      <div className="flex-shrink-0 bg-green-600 px-3 h-full flex items-center z-10">
        <span className="text-xs font-bold uppercase tracking-widest whitespace-nowrap">Breaking</span>
      </div>

      {/* Scrolling track */}
      <div className="flex-1 overflow-hidden relative h-full">
        <div
          className="flex items-center h-full whitespace-nowrap text-sm"
          style={{
            animation: 'ticker-scroll 30s linear infinite',
          }}
          onMouseEnter={(e) => {
            (e.currentTarget as HTMLDivElement).style.animationPlayState = 'paused';
          }}
          onMouseLeave={(e) => {
            (e.currentTarget as HTMLDivElement).style.animationPlayState = 'running';
          }}
        >
          {/* Duplicate content for seamless loop */}
          <span className="px-4">{tickerText}</span>
          <span className="px-4" aria-hidden="true">{tickerText}</span>
        </div>
      </div>

      <style>{`
        @keyframes ticker-scroll {
          0%   { transform: translateX(0); }
          100% { transform: translateX(-50%); }
        }
      `}</style>
    </div>
  );
}
