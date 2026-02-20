import { useTheme } from "../app/providers/ThemeProvider";

export function ThemeToggle() {
  const { theme, toggleTheme } = useTheme();

  return (
    <button className="btn" onClick={toggleTheme} type="button" aria-label="Toggle theme">
      {theme === "light" ? "🌙 Dark" : "☀️ Light"}
    </button>
  );
}