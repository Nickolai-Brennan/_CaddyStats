import { useQuery } from "@tanstack/react-query";

const apiBaseUrl = (import.meta.env.VITE_API_HTTP_URL as string | undefined) ?? "http://localhost:8000";
const graphqlUrl =
  (import.meta.env.VITE_API_GRAPHQL_URL as string | undefined) ?? `${apiBaseUrl}/graphql`;

async function fetchHealth(): Promise<{ ok: boolean; db?: boolean }> {
  const res = await fetch(`${apiBaseUrl}/health`);
  if (!res.ok) throw new Error(`Health check failed: ${res.status}`);
  return res.json();
}

export function HomeView() {
  const q = useQuery({ queryKey: ["health"], queryFn: fetchHealth });

  return (
    <div className="card">
      <h2>Boot Check</h2>

      <p className="muted">
        Backend:{" "}
        {q.isLoading ? (
          <strong>checking...</strong>
        ) : q.data?.ok ? (
          <strong>OK ✅</strong>
        ) : (
          <strong>FAIL ❌</strong>
        )}
      </p>

      <p className="muted">
        DB:{" "}
        {q.isLoading ? (
          <strong>checking...</strong>
        ) : q.data?.db ? (
          <strong>OK ✅</strong>
        ) : (
          <strong>not connected ❌</strong>
        )}
      </p>

      {q.error ? <pre className="error">{String(q.error)}</pre> : null}

      <p className="muted">
        GraphQL endpoint: <code>{graphqlUrl}</code>
      </p>
    </div>
  );
}
