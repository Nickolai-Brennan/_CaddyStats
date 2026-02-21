// GraphQL mutation definitions
// Populated in Phase 2+ (CMS content mutations)

export const CREATE_POST = `
  mutation CreatePost($input: CreatePostInput!) {
    createPost(input: $input) {
      id
      title
      slug
      status
    }
  }
`;

export const UPDATE_POST = `
  mutation UpdatePost($id: ID!, $input: UpdatePostInput!) {
    updatePost(id: $id, input: $input) {
      id
      title
      slug
      status
    }
  }
`;
