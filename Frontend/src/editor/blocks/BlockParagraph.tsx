import type { ParagraphBlock } from '../../types/blocks';
import { sanitizeHtml } from '../../utils/sanitize';

interface BlockParagraphProps {
  block: ParagraphBlock;
}

export function BlockParagraph({ block }: BlockParagraphProps) {
  return (
    <p
      className="mb-4 text-base leading-relaxed text-gray-700 dark:text-gray-300"
      dangerouslySetInnerHTML={{ __html: sanitizeHtml(block.html) }}
    />
  );
}
