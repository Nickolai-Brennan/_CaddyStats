// REST API stubs for stats endpoints
import type { LeaderboardDTO, Projection } from '../types/stats';

const API_BASE = (import.meta.env.VITE_API_HTTP_URL as string | undefined) ?? 'http://localhost:8000';

export async function fetchLeaderboard(tournamentId: string): Promise<LeaderboardDTO> {
  const res = await fetch(`${API_BASE}/api/leaderboard/${tournamentId}`);
  if (!res.ok) throw new Error(`fetchLeaderboard failed: ${res.status}`);
  return res.json() as Promise<LeaderboardDTO>;
}

export async function fetchProjections(tournamentId: string): Promise<Projection[]> {
  const res = await fetch(`${API_BASE}/api/projections/${tournamentId}`);
  if (!res.ok) throw new Error(`fetchProjections failed: ${res.status}`);
  return res.json() as Promise<Projection[]>;
}
