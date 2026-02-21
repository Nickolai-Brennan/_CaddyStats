import type { Block } from '../types/blocks';

const WORDS_PER_MINUTE = 200;

function countWords(text: string): number {
  return text.trim().split(/\s+/).filter(Boolean).length;
}

function extractTextFromBlocks(blocks: Block[]): string {
  return blocks.map((block) => {
    switch (block.type) {
      case 'heading':
        return block.text;
      case 'paragraph':
        // Strip HTML tags for word count
        return block.html.replace(/<[^>]+>/g, ' ');
      case 'list':
        return block.items.join(' ');
      case 'quote':
        return block.text + (block.caption ?? '');
      case 'code':
        return block.code;
      case 'image':
        return block.caption ?? '';
      case 'embed':
        return block.caption ?? '';
      default:
        return '';
    }
  }).join(' ');
}

export function estimateReadTime(content: string | Block[]): string {
  const text = Array.isArray(content) ? extractTextFromBlocks(content) : content;
  const words = countWords(text);
  const minutes = Math.max(1, Math.round(words / WORDS_PER_MINUTE)); // minimum 1 min
  return `${minutes} min read`;
}
