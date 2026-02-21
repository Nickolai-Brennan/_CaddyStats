import { Icon } from '../../design-system/icons/Icon';

interface AuthorCardProps {
  name: string;
  bio?: string;
  avatarUrl?: string;
  twitterHandle?: string;
  website?: string;
}

function getInitials(name: string): string {
  return name
    .split(' ')
    .map((part) => part[0] ?? '')
    .slice(0, 2)
    .join('')
    .toUpperCase();
}

export function AuthorCard({ name, bio, avatarUrl, twitterHandle, website }: AuthorCardProps) {
  return (
    <div className="flex items-start gap-4">
      {/* Avatar */}
      <div className="flex-shrink-0 w-12 h-12 rounded-full overflow-hidden bg-gray-200 dark:bg-gray-700 flex items-center justify-center">
        {avatarUrl ? (
          <img src={avatarUrl} alt={name} className="w-full h-full object-cover" />
        ) : (
          <span className="text-sm font-semibold text-gray-600 dark:text-gray-300" aria-hidden="true">
            {getInitials(name)}
          </span>
        )}
      </div>

      {/* Info */}
      <div className="flex-1 min-w-0">
        <p className="text-xs text-gray-500 dark:text-gray-400 mb-0.5">Written by</p>
        <p className="font-semibold text-gray-900 dark:text-gray-100">{name}</p>
        {bio && <p className="mt-1 text-sm text-gray-600 dark:text-gray-400 line-clamp-2">{bio}</p>}

        {(twitterHandle || website) && (
          <div className="mt-2 flex items-center gap-3">
            {twitterHandle && (
              <a
                href={`https://twitter.com/${twitterHandle}`}
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-400 hover:text-blue-400 transition-colors"
                aria-label={`${name} on Twitter`}
              >
                <Icon name="link" size={16} />
              </a>
            )}
            {website && (
              <a
                href={website}
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-400 hover:text-green-500 transition-colors"
                aria-label={`${name}'s website`}
              >
                <Icon name="externalLink" size={16} />
              </a>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
