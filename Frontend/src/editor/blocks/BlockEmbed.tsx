import type { EmbedBlock } from '../../types/blocks';
import { Icon } from '../../design-system/icons/Icon';

interface BlockEmbedProps {
  block: EmbedBlock;
}

function isSafeUrl(url: string): boolean {
  try {
    const parsed = new URL(url);
    return parsed.protocol === 'http:' || parsed.protocol === 'https:';
  } catch {
    return false;
  }
}

export function BlockEmbed({ block }: BlockEmbedProps) {
  const safeUrl = isSafeUrl(block.url) ? block.url : null;

  return (
    <div className="my-4 p-4 border border-gray-200 dark:border-gray-700 rounded-lg bg-gray-50 dark:bg-gray-800 text-sm">
      <div className="flex items-start gap-3">
        <Icon name="externalLink" size={16} className="text-gray-400 mt-0.5 flex-shrink-0" />
        <div className="flex-1 min-w-0">
          <p className="text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-1">
            External embed
          </p>
          {safeUrl ? (
            <a
              href={safeUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="text-green-600 dark:text-green-400 hover:underline break-all"
            >
              {safeUrl}
            </a>
          ) : (
            <span className="text-gray-400 italic">Invalid URL</span>
          )}
          {block.caption && (
            <p className="mt-1 text-gray-600 dark:text-gray-400">{block.caption}</p>
          )}
        </div>
      </div>
    </div>
  );
}
