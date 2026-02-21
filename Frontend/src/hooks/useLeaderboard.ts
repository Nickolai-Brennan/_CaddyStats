// Leaderboard data hook
// Populated in Phase 3+ (stats API integration)

import { useQuery } from '@tanstack/react-query';
import { fetchLeaderboard } from '../api/stats';

export function useLeaderboard(tournamentId: string) {
  return useQuery({
    queryKey: ['leaderboard', tournamentId],
    queryFn: () => fetchLeaderboard(tournamentId),
    enabled: !!tournamentId,
  });
}
