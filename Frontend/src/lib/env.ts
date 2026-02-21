// Validates required env vars at build time; warns in dev if missing
const isDev = import.meta.env.DEV;

function getEnvVar(key: string, fallback: string): string {
  const value = import.meta.env[key] as string | undefined;
  if (!value) {
    if (isDev) {
      console.warn(`[env] ${key} is not set – falling back to "${fallback}"`);
    }
    return fallback;
  }
  return value;
}

export const API_HTTP_URL = getEnvVar('VITE_API_HTTP_URL', 'http://localhost:8000');

// API_GRAPHQL_URL defaults to API_HTTP_URL + '/graphql' when not explicitly set
export const API_GRAPHQL_URL = getEnvVar('VITE_API_GRAPHQL_URL', `${API_HTTP_URL}/graphql`);
