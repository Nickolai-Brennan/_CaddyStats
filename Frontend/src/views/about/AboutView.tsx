import { SeoHead } from '../../design-system/seo/SeoHead';

export function AboutView() {
  return (
    <>
      <SeoHead
        title="About | Caddy Stats"
        description="Learn about Caddy Stats, the golf analytics platform powered by Strik3Zone."
      />
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <h1 className="text-4xl font-bold text-gray-900 dark:text-gray-100 mb-6">About Caddy Stats</h1>

        <section className="mb-10">
          <h2 className="text-2xl font-semibold text-gray-800 dark:text-gray-200 mb-3">Our Mission</h2>
          <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
            Caddy Stats is the premier destination for data-driven golf coverage. We believe that behind every great round is a wealth of insight waiting to be uncovered — from strokes gained breakdowns to predictive tournament models. Our mission is to make advanced golf analytics accessible to fans, bettors, and coaches alike.
          </p>
        </section>

        <section className="mb-10">
          <h2 className="text-2xl font-semibold text-gray-800 dark:text-gray-200 mb-3">About Strik3Zone</h2>
          <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
            Caddy Stats is proudly powered by <strong className="text-gray-900 dark:text-gray-100">Strik3Zone</strong>, a sports analytics company specialising in professional golf. Strik3Zone's proprietary models aggregate shot-level data, course history, and betting market signals to provide an edge that goes beyond the scorecard.
          </p>
          <p className="mt-4 text-gray-600 dark:text-gray-400 leading-relaxed">
            From casual fans looking for context to professional analysts seeking an edge, Strik3Zone's platform is built to scale — delivering insights at the speed the modern game demands.
          </p>
        </section>

        <section>
          <h2 className="text-2xl font-semibold text-gray-800 dark:text-gray-200 mb-3">Get in Touch</h2>
          <p className="text-gray-600 dark:text-gray-400">
            Questions, feedback, or partnership enquiries? Reach us at{' '}
            <a
              href="mailto:hello@strik3zone.com"
              className="text-green-600 dark:text-green-400 hover:underline font-medium"
            >
              hello@strik3zone.com
            </a>
          </p>
        </section>
      </div>
    </>
  );
}
