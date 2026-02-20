export const API_HTTP_URL =
  (import.meta.env.VITE_API_HTTP_URL as string | undefined) ?? "http://localhost:8000";

export const API_GRAPHQL_URL =
  (import.meta.env.VITE_API_GRAPHQL_URL as string | undefined) ?? `${API_HTTP_URL}/graphql`;
