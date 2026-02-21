// Auth hook
// Populated in Phase 2+ (JWT auth integration)

import { useState, useCallback } from 'react';
import { login as apiLogin, logout as apiLogout, type LoginPayload } from '../api/auth';
import type { AuthState } from '../types/user';

const _storedToken = localStorage.getItem('access_token');

const initialState: AuthState = {
  user: null,
  token: _storedToken,
  isAuthenticated: !!_storedToken,
};

export function useAuth() {
  const [auth, setAuth] = useState<AuthState>(initialState);

  const login = useCallback(async (payload: LoginPayload) => {
    const { accessToken } = await apiLogin(payload);
    localStorage.setItem('access_token', accessToken);
    setAuth({ user: null, token: accessToken, isAuthenticated: true });
  }, []);

  const logout = useCallback(async () => {
    await apiLogout();
    localStorage.removeItem('access_token');
    setAuth({ user: null, token: null, isAuthenticated: false });
  }, []);

  return { ...auth, login, logout };
}
