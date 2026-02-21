// Auth REST API client
// Populated in Phase 2+ (JWT auth integration)

const API_URL = import.meta.env.VITE_API_HTTP_URL ?? '';

export interface LoginPayload {
  email: string;
  password: string;
}

export interface AuthTokens {
  accessToken: string;
}

export async function login(payload: LoginPayload): Promise<AuthTokens> {
  const res = await fetch(`${API_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });
  if (!res.ok) throw new Error(`Auth error: ${res.status}`);
  return res.json();
}

export async function logout(): Promise<void> {
  await fetch(`${API_URL}/auth/logout`, { method: 'POST' });
}
