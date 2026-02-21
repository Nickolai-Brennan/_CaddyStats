// Projections data hook
// Populated in Phase 3+ (stats API integration)

import { useQuery } from '@tanstack/react-query';
import { fetchProjections } from '../api/stats';

export function useProjections(tournamentId: string) {
  return useQuery({
    queryKey: ['projections', tournamentId],
    queryFn: () => fetchProjections(tournamentId),
    enabled: !!tournamentId,
  });
}
