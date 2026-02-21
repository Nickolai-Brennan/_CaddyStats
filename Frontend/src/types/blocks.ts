export type BlockType =
  | 'heading'
  | 'paragraph'
  | 'list'
  | 'quote'
  | 'image'
  | 'divider'
  | 'code'
  | 'embed'
  | 'unknown';

export interface BaseBlock {
  type: BlockType;
  id?: string;
}

export interface HeadingBlock extends BaseBlock {
  type: 'heading';
  level: 1 | 2 | 3 | 4 | 5 | 6;
  text: string;
}

export interface ParagraphBlock extends BaseBlock {
  type: 'paragraph';
  html: string;
}

export interface ListBlock extends BaseBlock {
  type: 'list';
  style: 'ordered' | 'unordered';
  items: string[];
}

export interface QuoteBlock extends BaseBlock {
  type: 'quote';
  text: string;
  caption?: string;
}

export interface ImageBlock extends BaseBlock {
  type: 'image';
  url: string;
  alt?: string;
  caption?: string;
}

export interface DividerBlock extends BaseBlock {
  type: 'divider';
}

export interface CodeBlock extends BaseBlock {
  type: 'code';
  code: string;
  language?: string;
}

export interface EmbedBlock extends BaseBlock {
  type: 'embed';
  url: string;
  caption?: string;
}

export interface UnknownBlock extends BaseBlock {
  type: 'unknown';
  [key: string]: unknown;
}

export type Block =
  | HeadingBlock
  | ParagraphBlock
  | ListBlock
  | QuoteBlock
  | ImageBlock
  | DividerBlock
  | CodeBlock
  | EmbedBlock
  | UnknownBlock;
