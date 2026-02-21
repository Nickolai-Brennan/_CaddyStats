
import { lazy, Suspense } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { AppLayout } from '../layouts/AppLayout';

const HomeView = lazy(() =>
  import('../views/HomeView').then((m) => ({ default: m.HomeView })),
);
const ArchiveView = lazy(() =>
  import('../views/ArchiveView').then((m) => ({ default: m.ArchiveView })),
);
const PostView = lazy(() =>
  import('../views/PostView').then((m) => ({ default: m.PostView })),
);
const AboutView = lazy(() =>
  import('../views/AboutView').then((m) => ({ default: m.AboutView })),
);
const ContactView = lazy(() =>
  import('../views/ContactView').then((m) => ({ default: m.ContactView })),
);
const DirectoryView = lazy(() =>
  import('../views/DirectoryView').then((m) => ({ default: m.DirectoryView })),
);
const NotFound = lazy(() =>
  import('../views/NotFound').then((m) => ({ default: m.NotFound })),
);

const Spinner = () => (
  <div className="flex items-center justify-center min-h-[40vh]">
    <div className="w-8 h-8 border-4 border-blue-600 border-t-transparent rounded-full animate-spin" />
  </div>
);

export function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route element={<AppLayout />}>
          <Route
            path="/"
            element={
              <Suspense fallback={<Spinner />}>
                <HomeView />
              </Suspense>
            }
          />
          <Route
            path="/archive"
            element={
              <Suspense fallback={<Spinner />}>
                <ArchiveView />
              </Suspense>
            }
          />
          <Route
            path="/post/:slug"
            element={
              <Suspense fallback={<Spinner />}>
                <PostView />
              </Suspense>
            }
          />
          <Route
            path="/about"
            element={
              <Suspense fallback={<Spinner />}>
                <AboutView />
              </Suspense>
            }
          />
          <Route
            path="/contact"
            element={
              <Suspense fallback={<Spinner />}>
                <ContactView />
              </Suspense>
            }
          />
          <Route
            path="/directory"
            element={
              <Suspense fallback={<Spinner />}>
                <DirectoryView />
              </Suspense>
            }
          />
          <Route
            path="*"
            element={
              <Suspense fallback={<Spinner />}>
                <NotFound />
              </Suspense>
            }
          />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

