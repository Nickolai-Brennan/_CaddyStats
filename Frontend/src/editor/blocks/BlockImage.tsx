import type { ImageBlock } from '../../types/blocks';

interface BlockImageProps {
  block: ImageBlock;
}

export function BlockImage({ block }: BlockImageProps) {
  return (
    <figure className="my-6 overflow-hidden rounded-xl">
      <img
        src={block.url}
        alt={block.alt ?? ''}
        loading="lazy"
        className="w-full h-auto"
      />
      {block.caption && (
        <figcaption className="mt-2 text-sm text-center text-gray-500 dark:text-gray-400">
          {block.caption}
        </figcaption>
      )}
    </figure>
  );
}
