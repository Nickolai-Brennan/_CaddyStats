import type { DividerBlock } from '../../types/blocks';

interface BlockDividerProps {
  block: DividerBlock;
}

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export function BlockDivider({ block: _block }: BlockDividerProps) {
  return <hr className="my-8 border-t border-gray-200 dark:border-gray-700" />;
}
