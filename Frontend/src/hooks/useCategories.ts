import { useQuery } from '@tanstack/react-query';
import { queryKeys } from '../lib/queryKeys';

export interface Category {
  id: string;
  name: string;
  slug: string;
  count?: number;
}

const STUB_CATEGORIES: Category[] = [
  { name: 'Golf News', count: 42 },
  { name: 'Analytics', count: 28 },
  { name: 'Tournaments', count: 55 },
  { name: 'Player Profiles', count: 19 },
  { name: 'Betting Intelligence', count: 34 },
].map((c) => ({
  ...c,
  id: c.name.toLowerCase().replace(/\s+/g, '-'),
  slug: c.name.toLowerCase().replace(/\s+/g, '-'),
}));

export function useCategories() {
  return useQuery<Category[]>({
    queryKey: queryKeys.categories.all(),
    queryFn: () => Promise.resolve(STUB_CATEGORIES),
    staleTime: 60_000,
  });
}
