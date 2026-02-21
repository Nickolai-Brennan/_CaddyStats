// GraphQL fragment definitions
// Populated in Phase 2+ (shared GraphQL fragments)

export const POST_FIELDS = `
  fragment PostFields on Post {
    id
    title
    slug
    excerpt
    status
    publishedAt
    featuredImageUrl
  }
`;

export const AUTHOR_FIELDS = `
  fragment AuthorFields on Author {
    id
    displayName
    slug
    avatarUrl
  }
`;
