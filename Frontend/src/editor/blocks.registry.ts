import type { Block } from '../types/blocks';
import type { ComponentType } from 'react';
import { BlockHeading } from './blocks/BlockHeading';
import { BlockParagraph } from './blocks/BlockParagraph';
import { BlockList } from './blocks/BlockList';
import { BlockQuote } from './blocks/BlockQuote';
import { BlockImage } from './blocks/BlockImage';
import { BlockDivider } from './blocks/BlockDivider';
import { BlockCode } from './blocks/BlockCode';
import { BlockEmbed } from './blocks/BlockEmbed';

// Each registry entry accepts a block prop typed as the broad Block union.
// Individual components narrow to their specific type internally.
export const registry: Record<string, ComponentType<{ block: Block }>> = {
  heading: BlockHeading as ComponentType<{ block: Block }>,
  paragraph: BlockParagraph as ComponentType<{ block: Block }>,
  list: BlockList as ComponentType<{ block: Block }>,
  quote: BlockQuote as ComponentType<{ block: Block }>,
  image: BlockImage as ComponentType<{ block: Block }>,
  divider: BlockDivider as ComponentType<{ block: Block }>,
  code: BlockCode as ComponentType<{ block: Block }>,
  embed: BlockEmbed as ComponentType<{ block: Block }>,
};
