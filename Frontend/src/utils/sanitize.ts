// Simple regex-based HTML sanitizer for XSS prevention (no external deps)
// Allowed tags: p, br, strong, em, b, i, a, ul, ol, li, blockquote, code, pre, h1-h6, span

const ALLOWED_TAGS = new Set([
  'p', 'br', 'strong', 'em', 'b', 'i', 'a',
  'ul', 'ol', 'li', 'blockquote', 'code', 'pre',
  'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'span',
]);

const DANGEROUS_TAG_RE = /<(script|iframe|object|embed|form|style)[^>]*>[\s\S]*?<\/\1>/gi;
const DANGEROUS_SELF_RE = /<(script|iframe|object|embed|form|style)[^>]*\/?\s*>/gi;

// Strip dangerous attributes from a single tag's attribute string.
// Uses \b so event handlers without preceding whitespace are also caught.
const EVENT_HANDLER_RE = /\bon\w+\s*=\s*(?:"[^"]*"|'[^']*'|[^\s>]*)/gi;
const STYLE_ATTR_RE = /\bstyle\s*=\s*(?:"[^"]*"|'[^']*'|[^\s>]*)/gi;
const UNSAFE_PROTO_RE = /\b(href|src)\s*=\s*["']?\s*(?:javascript:|data:)[^"'\s>]*/gi;

function sanitizeTag(attrs: string): string {
  // Iteratively remove on* event handler attributes (handles patterns like ononclick=)
  let safe = removeUntilStable(attrs, EVENT_HANDLER_RE);
  // Remove style attributes
  safe = removeUntilStable(safe, STYLE_ATTR_RE);
  // Strip javascript: and data: protocols from href/src
  safe = safe.replace(UNSAFE_PROTO_RE, '$1=""');
  return safe;
}

// Check if a tag name is in the allowed set
function isAllowedTag(tagName: string): boolean {
  return ALLOWED_TAGS.has(tagName.toLowerCase());
}

// Repeatedly apply a pattern until the string stops changing (handles nested/malformed tags)
function removeUntilStable(input: string, pattern: RegExp): string {
  let prev = input;
  let next = input.replace(pattern, '');
  while (next !== prev) {
    prev = next;
    pattern.lastIndex = 0;
    next = next.replace(pattern, '');
  }
  return next;
}

export function sanitizeHtml(html: string): string {
  if (!html) return '';

  // Iteratively remove dangerous block tags (catches nested/malformed patterns)
  let result = removeUntilStable(html, DANGEROUS_TAG_RE);
  result = removeUntilStable(result, DANGEROUS_SELF_RE);

  // Process remaining tags: keep allowed ones, strip everything else
  result = result.replace(/<(\/?)([a-zA-Z][a-zA-Z0-9]*)((?:\s[^>]*)?)\s*\/?>/gi, (_match, closing: string, tagName: string, attrs: string) => {
    if (!isAllowedTag(tagName)) {
      return ''; // discard disallowed tag entirely
    }
    if (closing) {
      return `</${tagName.toLowerCase()}>`;
    }
    const safeAttrs = sanitizeTag(attrs);
    return `<${tagName.toLowerCase()}${safeAttrs}>`;
  });

  return result;
}
