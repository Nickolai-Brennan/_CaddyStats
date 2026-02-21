export const queryKeys = {
  posts: {
    all: () => ['posts'] as const,
    list: (params?: { limit?: number; offset?: number; q?: string; category?: string; tag?: string }) =>
      ['posts', 'list', params] as const,
    bySlug: (slug: string) => ['posts', 'bySlug', slug] as const,
  },
  tags: {
    all: () => ['tags'] as const,
  },
  categories: {
    all: () => ['categories'] as const,
  },
  trending: {
    all: () => ['trending'] as const,
  },
  leaderboard: {
    byTournament: (id: string) => ['leaderboard', id] as const,
  },
  health: {
    all: () => ['health'] as const,
  },
} as const;
