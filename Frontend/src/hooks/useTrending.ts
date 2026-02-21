import { useQuery } from '@tanstack/react-query';
import { queryKeys } from '../lib/queryKeys';

export interface TrendingItem {
  id: string;
  title: string;
  slug: string;
  views: number;
}

const STUB_TRENDING: TrendingItem[] = [
  { id: '1', title: 'Scottie Scheffler Dominates the FedEx Cup Rankings', slug: 'scheffler-fedex-cup', views: 12400 },
  { id: '2', title: 'Masters 2025: Course Preview and Top Contenders', slug: 'masters-2025-preview', views: 9800 },
  { id: '3', title: 'LIV Golf\'s Impact on World Rankings Explained', slug: 'liv-golf-world-rankings', views: 8200 },
  { id: '4', title: 'Best Betting Value Picks for This Week\'s PGA Event', slug: 'pga-betting-picks', views: 7600 },
  { id: '5', title: 'Rory McIlroy\'s Grand Slam Quest: A Statistical Deep Dive', slug: 'rory-grand-slam-stats', views: 6900 },
];

export function useTrending() {
  return useQuery<TrendingItem[]>({
    queryKey: queryKeys.trending.all(),
    queryFn: () => Promise.resolve(STUB_TRENDING),
    staleTime: 30_000,
  });
}
