import { API_HTTP_URL } from "../config";

export type HealthResponse = {
  ok: boolean;
  db?: boolean;
};

export async function fetchHealth(): Promise<HealthResponse> {
  const res = await fetch(`${API_HTTP_URL}/health`);
  if (!res.ok) {
    throw new Error(`Health check failed: ${res.status}`);
  }
  return res.json();
}
