import { useState } from 'react';
import { SeoHead } from '../../design-system/seo/SeoHead';
import { Input, Textarea } from '../../design-system/primitives/Input';
import { Button } from '../../design-system/primitives/Button';
import { Tooltip } from '../../design-system/primitives/Tooltip';

export function ContactView() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState('');

  return (
    <>
      <SeoHead
        title="Contact | Caddy Stats"
        description="Get in touch with the Caddy Stats team."
      />
      <div className="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <h1 className="text-4xl font-bold text-gray-900 dark:text-gray-100 mb-2">Contact Us</h1>
        <p className="text-gray-500 dark:text-gray-400 mb-10">
          Have a question or want to work together? Fill out the form below.
        </p>

        <form
          className="space-y-6"
          onSubmit={(e) => e.preventDefault()}
          aria-label="Contact form"
        >
          <div>
            <label htmlFor="contact-name" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Name
            </label>
            <Input
              id="contact-name"
              placeholder="Your name"
              value={name}
              onChange={(e) => setName(e.target.value)}
              autoComplete="name"
            />
          </div>

          <div>
            <label htmlFor="contact-email" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Email
            </label>
            <Input
              id="contact-email"
              type="email"
              placeholder="you@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              autoComplete="email"
            />
          </div>

          <div>
            <label htmlFor="contact-message" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Message
            </label>
            <Textarea
              id="contact-message"
              placeholder="How can we help?"
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              rows={5}
            />
          </div>

          <Tooltip content="Contact form coming soon — email us directly at hello@strik3zone.com">
            <span className="inline-block">
              <Button type="submit" variant="primary" disabled>
                Send Message
              </Button>
            </span>
          </Tooltip>
        </form>

        <div className="mt-12 pt-8 border-t border-gray-200 dark:border-gray-700">
          <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-2">Direct Contact</h2>
          <p className="text-gray-600 dark:text-gray-400">
            Email:{' '}
            <a
              href="mailto:hello@strik3zone.com"
              className="text-green-600 dark:text-green-400 hover:underline"
            >
              hello@strik3zone.com
            </a>
          </p>
        </div>
      </div>
    </>
  );
}
