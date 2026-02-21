import type { CodeBlock } from '../../types/blocks';

interface BlockCodeProps {
  block: CodeBlock;
}

export function BlockCode({ block }: BlockCodeProps) {
  return (
    <div className="my-4 overflow-x-auto rounded-lg bg-gray-900 text-sm text-gray-100 font-mono">
      {block.language && (
        <div className="px-4 pt-3 pb-1 text-xs text-gray-400 font-sans border-b border-gray-700">
          {block.language}
        </div>
      )}
      <pre className="p-4 overflow-x-auto">
        <code>{block.code}</code>
      </pre>
    </div>
  );
}
