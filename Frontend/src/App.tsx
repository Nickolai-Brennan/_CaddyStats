import { Header } from "./components/Header";
import { AppRouter } from "./app/router";

export function App() {
  return (
    <div className="shell">
      <Header />
      <main className="main">
        <AppRouter />
      </main>
    </div>
  );
}