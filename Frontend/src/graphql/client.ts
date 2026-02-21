// GraphQL client setup
// Populated in Phase 2+ (GraphQL integration)

import { GraphQLClient } from 'graphql-request';

const GRAPHQL_URL = import.meta.env.VITE_API_GRAPHQL_URL ?? '/graphql';

export const gqlClient = new GraphQLClient(GRAPHQL_URL, {
  headers: () => {
    const token = localStorage.getItem('access_token');
    return token ? { Authorization: `Bearer ${token}` } : {};
  },
});
