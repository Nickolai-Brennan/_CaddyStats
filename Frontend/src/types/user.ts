// User-related TypeScript types
// Populated in Phase 2+ (auth integration)

export type UserRole = 'admin' | 'editor' | 'contributor';

export interface User {
  id: string;
  email: string;
  role: UserRole;
  status: string;
}

export interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
}
