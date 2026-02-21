import { useQuery } from '@tanstack/react-query';
import { queryKeys } from '../lib/queryKeys';

export interface Tag {
  id: string;
  name: string;
  slug: string;
}

const STUB_TAGS: Tag[] = [
  'PGA Tour',
  'LIV Golf',
  'Masters',
  'Player Stats',
  'Betting',
  'Course Guide',
].map((name) => ({
  id: name.toLowerCase().replace(/\s+/g, '-'),
  name,
  slug: name.toLowerCase().replace(/\s+/g, '-'),
}));

export function useTags() {
  return useQuery<Tag[]>({
    queryKey: queryKeys.tags.all(),
    queryFn: () => Promise.resolve(STUB_TAGS),
    staleTime: 60_000,
  });
}
