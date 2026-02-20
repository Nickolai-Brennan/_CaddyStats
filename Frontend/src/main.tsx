import React from "react";
import ReactDOM from "react-dom/client";
import { QueryClient, QueryClientProvider, useQuery } from "@tanstack/react-query";
import "./styles.css";

const client = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false
    }
  }
});

async function fetchHealth(): Promise<{ ok: boolean; db?: boolean }> {
  const base = import.meta.env.VITE_API_HTTP_URL as string;
  const res = await fetch(`${base}/health`);
  if (!res.ok) throw new Error(`Health check failed: ${res.status}`);
  return res.json();
}

function HealthCard() {
  const q = useQuery({ queryKey: ["health"], queryFn: fetchHealth });

  return (
    <div className="card">
      <h1>Caddy Stats</h1>

      <p className="muted">
        Frontend: <strong>OK</strong> ✅
      </p>

      <p className="muted">
        Backend:{" "}
        {q.isLoading ? (
          <strong>checking…</strong>
        ) : q.data?.ok ? (
          <strong>OK ✅</strong>
        ) : (
          <strong>FAIL ❌</strong>
        )}
      </p>

      <p className="muted">
        DB:{" "}
        {q.isLoading ? (
          <strong>checking…</strong>
        ) : q.data?.db ? (
          <strong>OK ✅</strong>
        ) : (
          <strong>not connected ❌</strong>
        )}
      </p>

      {q.error ? <pre className="error">{String(q.error)}</pre> : null}

      <p className="muted">
        GraphQL endpoint: <code>{import.meta.env.VITE_API_GRAPHQL_URL}</code>
      </p>
    </div>
  );
}

function App() {
  return (
    <QueryClientProvider client={client}>
      <HealthCard />
    </QueryClientProvider>
  );
}

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
