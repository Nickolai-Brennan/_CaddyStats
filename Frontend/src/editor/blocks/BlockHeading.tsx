import type { HeadingBlock } from '../../types/blocks';
import { cn } from '../../utils/cn';

interface BlockHeadingProps {
  block: HeadingBlock;
}

const levelClasses: Record<HeadingBlock['level'], string> = {
  1: 'text-4xl font-bold',
  2: 'text-3xl font-bold',
  3: 'text-2xl font-semibold',
  4: 'text-xl font-semibold',
  5: 'text-lg font-medium',
  6: 'text-base font-medium',
};

const baseClasses = 'mt-6 mb-3 text-gray-900 dark:text-gray-100';

export function BlockHeading({ block }: BlockHeadingProps) {
  const Tag = `h${block.level}` as 'h1' | 'h2' | 'h3' | 'h4' | 'h5' | 'h6';
  return (
    <Tag className={cn(baseClasses, levelClasses[block.level])}>
      {block.text}
    </Tag>
  );
}
