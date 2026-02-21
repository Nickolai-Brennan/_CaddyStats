import { useEffect } from 'react';

interface SeoHeadProps {
  title: string;
  description?: string;
  ogImage?: string;
  ogType?: string;
  canonical?: string;
  keywords?: string;
}

function setMeta(nameAttr: 'name' | 'property', nameValue: string, content: string) {
  let el = document.querySelector<HTMLMetaElement>(`meta[${nameAttr}="${nameValue}"]`);
  if (!el) {
    el = document.createElement('meta');
    el.setAttribute(nameAttr, nameValue);
    document.head.appendChild(el);
  }
  el.setAttribute('content', content);
}

function setLink(rel: string, href: string) {
  let el = document.querySelector<HTMLLinkElement>(`link[rel="${rel}"]`);
  if (!el) {
    el = document.createElement('link');
    el.rel = rel;
    document.head.appendChild(el);
  }
  el.href = href;
}

export function SeoHead({
  title,
  description,
  ogImage,
  ogType = 'website',
  canonical,
  keywords,
}: SeoHeadProps) {
  useEffect(() => {
    const prevTitle = document.title;
    document.title = title;

    if (description) setMeta('name', 'description', description);
    if (keywords) setMeta('name', 'keywords', keywords);

    setMeta('property', 'og:title', title);
    setMeta('property', 'og:type', ogType);
    if (description) setMeta('property', 'og:description', description);
    if (ogImage) setMeta('property', 'og:image', ogImage);

    setMeta('name', 'twitter:card', 'summary_large_image');
    setMeta('name', 'twitter:title', title);
    if (description) setMeta('name', 'twitter:description', description);

    if (canonical) setLink('canonical', canonical);

    return () => {
      document.title = prevTitle;
    };
  }, [title, description, ogImage, ogType, canonical, keywords]);

  return null;
}
