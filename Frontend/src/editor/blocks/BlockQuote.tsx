import type { QuoteBlock } from '../../types/blocks';

interface BlockQuoteProps {
  block: QuoteBlock;
}

export function BlockQuote({ block }: BlockQuoteProps) {
  return (
    <blockquote className="border-l-4 border-green-500 pl-4 my-4 italic text-gray-600 dark:text-gray-400">
      <p>{block.text}</p>
      {block.caption && (
        <cite className="block mt-2 text-sm not-italic text-gray-500 dark:text-gray-500">
          — {block.caption}
        </cite>
      )}
    </blockquote>
  );
}
