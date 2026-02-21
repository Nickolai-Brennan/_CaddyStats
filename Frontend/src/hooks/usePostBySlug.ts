import { useQuery } from '@tanstack/react-query';
import { gqlClient } from '../graphql/client';
import { GET_POST_BY_SLUG } from '../graphql/queries';
import type { Post } from '../types/post';
import { queryKeys } from '../lib/queryKeys';

interface GetPostBySlugResult {
  postBySlug: Post;
}

export function usePostBySlug(slug: string) {
  return useQuery<Post>({
    queryKey: queryKeys.posts.bySlug(slug),
    queryFn: async () => {
      const data = await gqlClient.request<GetPostBySlugResult>(GET_POST_BY_SLUG, { slug });
      return data.postBySlug;
    },
    enabled: !!slug,
    staleTime: 60_000,
  });
}
