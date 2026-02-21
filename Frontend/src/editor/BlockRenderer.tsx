import type { Block } from '../types/blocks';
import { registry } from './blocks.registry';

interface BlockRendererProps {
  blocks?: Block[];
  block?: Block;
}

function renderBlock(block: Block): React.ReactNode {
  try {
    const Component = registry[block.type];
    if (!Component) {
      if (import.meta.env.DEV) {
        return (
          <div
            key={block.id ?? block.type}
            className="text-xs text-gray-400 italic my-1"
          >
            {`[Unknown block: ${block.type}]`}
          </div>
        );
      }
      return null;
    }
    return <Component key={block.id ?? block.type} block={block} />;
  } catch (err) {
    if (import.meta.env.DEV) {
      console.error('BlockRenderer: error rendering block', block, err);
    }
    return null;
  }
}

export default function BlockRenderer({ blocks, block }: BlockRendererProps) {
  if (block) {
    return <>{renderBlock(block)}</>;
  }
  if (!blocks || blocks.length === 0) {
    return null;
  }
  return <>{blocks.map(renderBlock)}</>;
}
