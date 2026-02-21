// Leaderboard data hook
// Populated in Phase 3+ (stats API integration)

import { useQuery } from '@tanstack/react-query';
import { fetchLeaderboard } from '../api/stats';
import { queryKeys } from '../lib/queryKeys';

export function useLeaderboard(tournamentId: string) {
  return useQuery({
    queryKey: queryKeys.leaderboard.byTournament(tournamentId),
    queryFn: () => fetchLeaderboard(tournamentId),
    enabled: !!tournamentId,
  });
}
