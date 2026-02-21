// SEO utility functions
// Populated in Phase 7+ (SEO engineering)

export function buildPageTitle(title: string, siteName = 'Caddy Stats'): string {
  return `${title} | ${siteName}`;
}

export function buildCanonicalUrl(path: string, baseUrl = ''): string {
  return `${baseUrl}${path.startsWith('/') ? path : `/${path}`}`;
}

export function truncateDescription(text: string, maxLength = 160): string {
  if (text.length <= maxLength) return text;
  return text.slice(0, maxLength - 3) + '...';
}
