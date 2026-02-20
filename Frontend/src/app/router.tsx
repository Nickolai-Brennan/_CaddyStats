


import { BrowserRouter, Routes, Route } from "react-router-dom";
import { AppLayout } from "../layouts/AppLayout";
import { HomeView } from "../views/HomeView";

export function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<AppLayout />}>
          <Route path="/" element={<HomeView />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
