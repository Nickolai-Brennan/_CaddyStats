import { useLeaderboard } from '../../hooks/useLeaderboard';
import { Skeleton } from '../../design-system/primitives/Skeleton';
import { EmptyState } from '../../design-system/primitives/EmptyState';
import { ErrorState } from '../../design-system/primitives/ErrorState';
import { formatScore } from '../../utils/formatters';

const TOURNAMENT_ID = 'masters-2025';

const STATUS_LABELS: Record<string, string> = {
  active: 'Active',
  cut: 'CUT',
  wd: 'WD',
  dq: 'DQ',
};

function SkeletonRows() {
  return (
    <>
      {[1, 2, 3, 4, 5].map((i) => (
        <tr key={i} className="border-b border-gray-100 dark:border-gray-800">
          {[1, 2, 3, 4].map((j) => (
            <td key={j} className="px-4 py-3">
              <Skeleton height="1rem" width={j === 2 ? '10rem' : '4rem'} />
            </td>
          ))}
        </tr>
      ))}
    </>
  );
}

export function LeaderboardDemo() {
  const { data, isLoading, isError, refetch } = useLeaderboard(TOURNAMENT_ID);

  return (
    <div className="rounded-xl border border-gray-200 dark:border-gray-700 overflow-hidden">
      <div className="bg-gray-50 dark:bg-gray-800 px-4 py-3 border-b border-gray-200 dark:border-gray-700">
        <h2 className="text-sm font-bold uppercase tracking-wider text-gray-600 dark:text-gray-300">
          Leaderboard Demo
        </h2>
        <p className="text-xs text-gray-400 mt-0.5">Tournament: {TOURNAMENT_ID}</p>
      </div>

      {isLoading ? (
        <table className="w-full text-sm">
          <thead className="bg-white dark:bg-gray-900">
            <tr className="text-left text-gray-500 dark:text-gray-400 text-xs uppercase">
              <th className="px-4 py-2">Pos</th>
              <th className="px-4 py-2">Player</th>
              <th className="px-4 py-2">Score</th>
              <th className="px-4 py-2">Status</th>
            </tr>
          </thead>
          <tbody><SkeletonRows /></tbody>
        </table>
      ) : isError ? (
        <div className="p-4">
          <ErrorState
            title="Leaderboard unavailable"
            description="The stats backend is currently offline. Leaderboard data will appear here once the API is running."
            onRetry={() => { void refetch(); }}
          />
        </div>
      ) : !data || data.entries.length === 0 ? (
        <div className="p-4">
          <EmptyState
            title="No leaderboard data"
            description="No entries available for this tournament."
          />
        </div>
      ) : (
        <>
          <table className="w-full text-sm">
            <thead className="bg-white dark:bg-gray-900">
              <tr className="text-left text-gray-500 dark:text-gray-400 text-xs uppercase">
                <th className="px-4 py-2">Pos</th>
                <th className="px-4 py-2">Player</th>
                <th className="px-4 py-2">Score</th>
                <th className="px-4 py-2">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100 dark:divide-gray-800 bg-white dark:bg-gray-900">
              {data.entries.map((entry) => (
                <tr key={entry.playerId} className="hover:bg-gray-50 dark:hover:bg-gray-800/40 transition-colors">
                  <td className="px-4 py-3 font-semibold text-gray-900 dark:text-gray-100">{entry.position}</td>
                  <td className="px-4 py-3 text-gray-800 dark:text-gray-200">{entry.playerName}</td>
                  <td className="px-4 py-3 font-mono text-gray-700 dark:text-gray-300">
                    {formatScore(entry.totalScore)}
                  </td>
                  <td className="px-4 py-3">
                    <span className={`text-xs font-semibold px-1.5 py-0.5 rounded ${
                      entry.status === 'active'
                        ? 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400'
                        : 'bg-gray-100 dark:bg-gray-800 text-gray-500 dark:text-gray-400'
                    }`}>
                      {STATUS_LABELS[entry.status] ?? entry.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="px-4 py-2 text-xs text-gray-400 dark:text-gray-500 border-t border-gray-100 dark:border-gray-800">
            Last updated: {new Date(data.lastUpdated).toLocaleString()} · Round {data.round}
          </div>
        </>
      )}
    </div>
  );
}
