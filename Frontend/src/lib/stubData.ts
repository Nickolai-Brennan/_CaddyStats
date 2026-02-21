import type { PostListItem } from '../types/post';

const MS_PER_DAY = 86_400_000;

/** Stub posts used when the GraphQL backend is offline or returns no data. */
export const STUB_POST_LIST: PostListItem[] = [
  {
    id: 'stub-1',
    title: 'Scottie Scheffler Extends FedEx Cup Lead With Dominant Performance',
    slug: 'scheffler-fedex-cup-lead',
    excerpt: 'World number one Scottie Scheffler puts on a masterclass to extend his FedEx Cup lead heading into the playoffs.',
    publishedAt: new Date(Date.now() - MS_PER_DAY).toISOString(),
  },
  {
    id: 'stub-2',
    title: 'Masters 2025 Course Preview: Augusta National Secrets Revealed',
    slug: 'masters-2025-preview',
    excerpt: 'Our analysts break down the key holes, pin positions, and course conditions that will define the 2025 Masters.',
    publishedAt: new Date(Date.now() - 2 * MS_PER_DAY).toISOString(),
  },
  {
    id: 'stub-3',
    title: "LIV Golf's Impact on OWGR: Everything You Need to Know",
    slug: 'liv-golf-owgr-impact',
    excerpt: 'With LIV Golf finally receiving world ranking points, we explore how the landscape of professional golf is shifting.',
    publishedAt: new Date(Date.now() - 3 * MS_PER_DAY).toISOString(),
  },
  {
    id: 'stub-4',
    title: 'Top Betting Value Picks for the PGA Championship',
    slug: 'pga-championship-betting-picks',
    excerpt: 'Our data-driven model identifies five undervalued players worth backing at Valhalla Golf Club this week.',
    publishedAt: new Date(Date.now() - 4 * MS_PER_DAY).toISOString(),
  },
  {
    id: 'stub-5',
    title: "Rory McIlroy's Grand Slam Quest: A Statistical Analysis",
    slug: 'rory-grand-slam-analysis',
    excerpt: "After years of near misses, we use advanced statistics to assess whether 2025 could be Rory's year at Augusta.",
    publishedAt: new Date(Date.now() - 5 * MS_PER_DAY).toISOString(),
  },
  {
    id: 'stub-6',
    title: 'How Strokes Gained Analytics Are Changing Golf Coaching',
    slug: 'strokes-gained-coaching',
    excerpt: 'From the range to the putting green, SG metrics are now at the heart of how elite coaches build champions.',
    publishedAt: new Date(Date.now() - 6 * MS_PER_DAY).toISOString(),
  },
];
