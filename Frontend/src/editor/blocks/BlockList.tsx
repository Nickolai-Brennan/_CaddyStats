import type { ListBlock } from '../../types/blocks';
import { sanitizeHtml } from '../../utils/sanitize';
import { cn } from '../../utils/cn';

interface BlockListProps {
  block: ListBlock;
}

export function BlockList({ block }: BlockListProps) {
  const Tag = block.style === 'ordered' ? 'ol' : 'ul';
  const styleClass = block.style === 'ordered' ? 'list-decimal' : 'list-disc';

  return (
    <Tag className={cn('mb-4 pl-6 space-y-1', styleClass)}>
      {block.items.map((item, i) => (
        // biome-ignore lint/suspicious/noArrayIndexKey: list items have no stable id
        <li
          key={i}
          className="text-base text-gray-700 dark:text-gray-300"
          dangerouslySetInnerHTML={{ __html: sanitizeHtml(item) }}
        />
      ))}
    </Tag>
  );
}
