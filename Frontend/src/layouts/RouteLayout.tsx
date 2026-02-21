import { Outlet } from 'react-router-dom';
import { AppLayout } from './AppLayout';
import { Header } from '../components/Header';
import { Footer } from '../components/Footer';
import { Container } from '../design-system/layout/Container';

type LayoutVariant = 'default' | 'article' | 'full-width' | 'magazine';

interface RouteLayoutProps {
  variant?: LayoutVariant;
}

/** Article layout — centered, no side rails, max-width for readability */
function ArticleShell() {
  return (
    <div className="min-h-screen flex flex-col bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-100">
      <Header />
      <main id="main-content" className="flex-1 py-8">
        <Container size="md">
          <Outlet />
        </Container>
      </main>
      <Footer />
    </div>
  );
}

/** Full-width layout — no sidebar, no max-width on content */
function FullWidthShell() {
  return (
    <div className="min-h-screen flex flex-col bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-100">
      <Header />
      <main id="main-content" className="flex-1">
        <Outlet />
      </main>
      <Footer />
    </div>
  );
}

/** Magazine layout — similar to default but content spans full 12 cols (no side rails) */
function MagazineShell() {
  return (
    <div className="min-h-screen flex flex-col bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-100">
      <Header />
      <main id="main-content" className="flex-1 py-6">
        <Container size="xl">
          <Outlet />
        </Container>
      </main>
      <Footer />
    </div>
  );
}

/**
 * RouteLayout switches the shell based on the variant prop.
 * Wrap `<Route>` elements with this component to change the layout.
 */
export function RouteLayout({ variant = 'default' }: RouteLayoutProps) {
  switch (variant) {
    case 'article':
      return <ArticleShell />;
    case 'full-width':
      return <FullWidthShell />;
    case 'magazine':
      return <MagazineShell />;
    case 'default':
    default:
      return <AppLayout />;
  }
}
