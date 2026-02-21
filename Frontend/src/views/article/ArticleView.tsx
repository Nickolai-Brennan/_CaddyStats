import { useParams, Link } from 'react-router-dom';
import { SeoHead } from '../../design-system/seo/SeoHead';
import { Skeleton, SkeletonText } from '../../design-system/primitives/Skeleton';
import { ErrorState } from '../../design-system/primitives/ErrorState';
import { PostMetaBar } from '../../components/content/PostMetaBar';
import { AuthorCard } from '../../components/content/AuthorCard';
import BlockRenderer from '../../editor/BlockRenderer';
import { usePostBySlug } from '../../hooks/usePostBySlug';
import type { Block } from '../../types/blocks';

function isBlockArray(value: unknown): value is Block[] {
  return Array.isArray(value) && value.every((item) => typeof item === 'object' && item !== null && 'type' in item);
}

function ArticleSkeleton() {
  return (
    <div className="space-y-6">
      <Skeleton height="2.5rem" width="80%" />
      <div className="flex gap-4">
        <Skeleton height="1rem" width="8rem" />
        <Skeleton height="1rem" width="6rem" />
      </div>
      <Skeleton height="400px" className="rounded-xl" />
      <SkeletonText lines={6} />
      <SkeletonText lines={4} />
    </div>
  );
}

export function ArticleView() {
  const { slug = '' } = useParams<{ slug: string }>();
  const { data: post, isLoading, isError, refetch } = usePostBySlug(slug);

  const blocks: Block[] = isBlockArray(post?.contentJsonb) ? post.contentJsonb : [];

  return (
    <>
      {post && (
        <SeoHead
          title={`${post.title} | Caddy Stats`}
          description={post.excerpt}
          ogType="article"
        />
      )}

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
          {/* Main content */}
          <main className="lg:col-span-8">
            {isLoading ? (
              <ArticleSkeleton />
            ) : isError || !post ? (
              <ErrorState
                title="Article not found"
                description="This article could not be loaded. It may have been removed or the server is offline."
                onRetry={() => { void refetch(); }}
              />
            ) : (
              <article>
                <h1 className="text-3xl sm:text-4xl font-bold text-gray-900 dark:text-gray-100 leading-tight mb-4">
                  {post.title}
                </h1>

                <PostMetaBar
                  publishedAt={post.publishedAt}
                  onShare={() => {
                    if (navigator.share) {
                      void navigator.share({ title: post.title, url: window.location.href });
                    }
                  }}
                />

                {post.featuredImageUrl && (
                  <div className="mt-6 rounded-xl overflow-hidden aspect-video bg-gray-100 dark:bg-gray-800">
                    <img
                      src={post.featuredImageUrl}
                      alt={post.title}
                      className="w-full h-full object-cover"
                    />
                  </div>
                )}

                <div className="mt-8 prose prose-lg dark:prose-invert max-w-none">
                  {blocks.length > 0 ? (
                    <BlockRenderer blocks={blocks} />
                  ) : post.excerpt ? (
                    <p className="text-gray-700 dark:text-gray-300 text-lg leading-relaxed">{post.excerpt}</p>
                  ) : (
                    <p className="text-gray-500 dark:text-gray-400 italic">No content available.</p>
                  )}
                </div>

                <div className="mt-12 pt-8 border-t border-gray-200 dark:border-gray-700">
                  <AuthorCard name="Caddy Stats Editorial" bio="Expert golf analysis powered by Strik3Zone data." />
                </div>
              </article>
            )}

            <div className="mt-8">
              <Link to="/archive" className="text-sm font-medium text-green-600 dark:text-green-400 hover:underline">
                ← Back to Archive
              </Link>
            </div>
          </main>

          {/* Right rail */}
          <aside className="lg:col-span-4 space-y-6">
            <div className="rounded-xl border border-gray-200 dark:border-gray-700 p-4 bg-gray-50 dark:bg-gray-800">
              <p className="text-xs font-semibold uppercase tracking-widest text-gray-400 mb-3">Trending</p>
              <p className="text-sm text-gray-500 dark:text-gray-400 italic">Trending articles coming soon.</p>
            </div>
            <div className="rounded-xl border border-dashed border-gray-300 dark:border-gray-600 p-4 flex items-center justify-center h-40">
              <p className="text-xs text-gray-400 dark:text-gray-500">Advertisement</p>
            </div>
          </aside>
        </div>
      </div>
    </>
  );
}
