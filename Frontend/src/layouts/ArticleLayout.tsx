// ArticleLayout – single article reading layout
// Populated in Phase 6+ (Post Templates & Views)

import type { ReactNode } from 'react';

interface Props {
  children: ReactNode;
}

export default function ArticleLayout({ children }: Props) {
  return <article className="article-layout">{children}</article>;
}
