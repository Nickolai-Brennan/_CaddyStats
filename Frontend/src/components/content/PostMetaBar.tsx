import { Icon } from '../../design-system/icons/Icon';
import { formatDate } from '../../utils/formatters';

interface PostMetaBarProps {
  publishedAt?: string;
  readTime?: string;
  author?: string;
  onShare?: () => void;
}

export function PostMetaBar({ publishedAt, readTime, author, onShare }: PostMetaBarProps) {
  return (
    <div className="flex items-center justify-between gap-4 text-sm text-gray-500 dark:text-gray-400">
      <div className="flex items-center gap-4 flex-wrap">
        {publishedAt && (
          <span className="flex items-center gap-1.5">
            <Icon name="calendar" size={14} />
            <span>{formatDate(publishedAt)}</span>
          </span>
        )}
        {readTime && (
          <span className="flex items-center gap-1.5">
            <Icon name="clock" size={14} />
            <span>{readTime}</span>
          </span>
        )}
        {author && (
          <span className="flex items-center gap-1.5">
            <Icon name="author" size={14} />
            <span>{author}</span>
          </span>
        )}
      </div>

      {onShare && (
        <button
          type="button"
          onClick={onShare}
          aria-label="Share this article"
          className="flex items-center gap-1.5 text-gray-400 hover:text-gray-700 dark:hover:text-gray-200 transition-colors"
        >
          <Icon name="share" size={16} />
        </button>
      )}
    </div>
  );
}
