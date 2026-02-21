import React from "react";
import ReactDOM from "react-dom/client";
import "./styles/tailwind.css";
import "./styles.css";
import { QueryProvider } from "./app/providers/QueryProvider";
import { ThemeProvider } from "./app/providers/ThemeProvider";
import { ToastProvider } from "./app/providers/ToastProvider";
import { ErrorBoundary } from "./app/providers/ErrorBoundary";
import { AppRouter } from "./app/router";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <ErrorBoundary>
      <ThemeProvider>
        <QueryProvider>
          <ToastProvider>
            <AppRouter />
          </ToastProvider>
        </QueryProvider>
      </ThemeProvider>
    </ErrorBoundary>
  </React.StrictMode>
);

