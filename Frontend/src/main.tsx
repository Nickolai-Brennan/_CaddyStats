import React from "react";
import ReactDOM from "react-dom/client";
import "./styles.css";
import { QueryProvider } from "./app/providers/QueryProvider";
import { ThemeProvider } from "./app/providers/ThemeProvider";
import { AppRouter } from "./app/router";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <ThemeProvider>
      <QueryProvider>
        <AppRouter />
      </QueryProvider>
    </ThemeProvider>
  </React.StrictMode>
);

