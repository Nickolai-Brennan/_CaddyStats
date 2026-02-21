// Stats REST API client
// Populated in Phase 3+ (stats API integration)

const STATS_API_URL = import.meta.env.VITE_API_HTTP_URL ?? '';

export async function fetchLeaderboard(tournamentId: string): Promise<unknown> {
  const res = await fetch(`${STATS_API_URL}/tournaments/${tournamentId}/leaderboard`);
  if (!res.ok) throw new Error(`Stats API error: ${res.status}`);
  return res.json();
}

export async function fetchProjections(tournamentId: string): Promise<unknown> {
  const res = await fetch(`${STATS_API_URL}/tournaments/${tournamentId}/projections`);
  if (!res.ok) throw new Error(`Stats API error: ${res.status}`);
  return res.json();
}
