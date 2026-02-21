// Posts data hook
// Populated in Phase 2+ (GraphQL integration)

import { useQuery } from '@tanstack/react-query';
import { gqlClient } from '../graphql/client';
import { GET_POSTS } from '../graphql/queries';
import type { PostListItem } from '../types/post';
import { queryKeys } from '../lib/queryKeys';

interface GetPostsResult {
  posts: PostListItem[];
}

export function usePosts(limit = 20, offset = 0) {
  return useQuery<PostListItem[]>({
    queryKey: queryKeys.posts.list({ limit, offset }),
    queryFn: async () => {
      const data = await gqlClient.request<GetPostsResult>(GET_POSTS, { limit, offset });
      return data.posts;
    },
    staleTime: 60_000,
  });
}
