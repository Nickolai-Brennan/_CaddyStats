import { useEffect, useState } from 'react';
import { BreakingTicker } from '../components/content/BreakingTicker';
import { HeroStoryBlock } from '../components/content/HeroStoryBlock';
import { ArticleCard } from '../components/content/ArticleCard';
import { SixCardGrid } from '../design-system/layout/layouts';
import { Section } from '../design-system/layout/Section';
import { SkeletonCard } from '../design-system/primitives/Skeleton';
import { EmptyState } from '../design-system/primitives/EmptyState';
import { ErrorState } from '../design-system/primitives/ErrorState';
import { SeoHead } from '../design-system/seo/SeoHead';
import { usePosts } from '../hooks/usePosts';
import { STUB_POST_LIST } from '../lib/stubData';
import type { PostListItem } from '../types/post';

export function HomeView() {
  const { data, isLoading, isError, refetch } = usePosts(12);
  const [displayPosts, setDisplayPosts] = useState<PostListItem[]>([]);

  useEffect(() => {
    if (data && data.length > 0) {
      setDisplayPosts(data);
    } else if (isError || (!isLoading && (!data || data.length === 0))) {
      setDisplayPosts(STUB_POST_LIST);
    }
  }, [data, isError, isLoading]);

  const heroPosts = displayPosts.slice(0, 1);
  const secondaryPosts = displayPosts.slice(1, 5);
  const gridPosts = displayPosts.slice(1, 7);

  return (
    <>
      <SeoHead title="Home | Caddy Stats" description="Golf analytics, tournament coverage, betting intelligence, and player stats powered by Strik3Zone." />
      <BreakingTicker />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Hero */}
        <Section className="pt-6">
          {isLoading ? (
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-4">
              <div className="lg:col-span-8"><SkeletonCard className="aspect-video" /></div>
              <div className="lg:col-span-4 flex flex-col gap-4">
                {[1, 2, 3].map((i) => <SkeletonCard key={i} />)}
              </div>
            </div>
          ) : heroPosts.length > 0 ? (
            <HeroStoryBlock
              hero={{ ...heroPosts[0], category: 'Featured' }}
              secondary={secondaryPosts}
            />
          ) : null}
        </Section>

        {/* Recent Articles */}
        <Section title="Recent Articles" viewAllHref="/archive" viewAllLabel="View all">
          {isLoading ? (
            <SixCardGrid>
              {[1, 2, 3, 4, 5, 6].map((i) => <SkeletonCard key={i} />)}
            </SixCardGrid>
          ) : isError && displayPosts.length === 0 ? (
            <ErrorState
              title="Could not load articles"
              description="The content server may be offline. Showing cached content."
              onRetry={() => { void refetch(); }}
            />
          ) : gridPosts.length === 0 ? (
            <EmptyState
              title="No articles yet"
              description="Check back soon for the latest golf news and analytics."
            />
          ) : (
            <SixCardGrid>
              {gridPosts.map((post) => (
                <ArticleCard key={post.id} {...post} />
              ))}
            </SixCardGrid>
          )}
        </Section>
      </div>
    </>
  );
}

