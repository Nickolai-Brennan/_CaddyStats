// GraphQL query definitions
// Populated in Phase 2+ (CMS content queries)

export const GET_POSTS = `
  query GetPosts($limit: Int, $offset: Int) {
    posts(limit: $limit, offset: $offset) {
      id
      title
      slug
      excerpt
      status
      publishedAt
      featuredImageUrl
    }
  }
`;

export const GET_POST_BY_SLUG = `
  query GetPostBySlug($slug: String!) {
    postBySlug(slug: $slug) {
      id
      title
      slug
      excerpt
      status
      publishedAt
      featuredImageUrl
      contentJsonb
    }
  }
`;
