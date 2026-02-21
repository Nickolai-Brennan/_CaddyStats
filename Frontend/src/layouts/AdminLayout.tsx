// AdminLayout – admin dashboard layout
// Populated in Phase 10+ (Admin & Analytics)

import type { ReactNode } from 'react';

interface Props {
  children: ReactNode;
}

export default function AdminLayout({ children }: Props) {
  return <div className="admin-layout">{children}</div>;
}
