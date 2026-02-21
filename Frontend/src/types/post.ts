// Post-related TypeScript types
// Populated in Phase 2+ (GraphQL schema alignment)

export interface Post {
  id: string;
  title: string;
  slug: string;
  excerpt?: string;
  status: 'draft' | 'published';
  publishedAt?: string;
  featuredImageUrl?: string;
  contentJsonb?: unknown;
}

export interface PostListItem {
  id: string;
  title: string;
  slug: string;
  excerpt?: string;
  publishedAt?: string;
  featuredImageUrl?: string;
}
