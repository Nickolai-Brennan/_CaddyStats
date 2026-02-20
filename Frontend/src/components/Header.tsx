import { ThemeToggle } from "./ThemeToggle";

export function Header() {
  return (
    <header className="header">
      <div className="brand">
        <span className="logo">⛳</span>
        <span className="title">Caddy Stats</span>
      </div>

      <div style={{ marginLeft: "auto" }}>
        <ThemeToggle />
      </div>
    </header>
  );
}

<style> </style>