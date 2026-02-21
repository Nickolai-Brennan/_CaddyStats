// MagazineLayout – multi-column editorial layout
// Populated in Phase 4+ (UI Base)

import type { ReactNode } from 'react';

interface Props {
  children: ReactNode;
}

export default function MagazineLayout({ children }: Props) {
  return <div className="magazine-layout">{children}</div>;
}
