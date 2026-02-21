import type { IconName } from './types';
import { iconMap } from './iconMap';

interface IconProps {
  name: IconName;
  size?: number;
  className?: string;
  'aria-label'?: string;
}

export function Icon({ name, size = 16, className, 'aria-label': ariaLabel }: IconProps) {
  const svg = iconMap[name];
  if (!svg) return null;
  return (
    <span
      role={ariaLabel ? 'img' : undefined}
      aria-label={ariaLabel}
      aria-hidden={ariaLabel ? undefined : true}
      className={className}
      style={{ display: 'inline-flex', width: size, height: size, flexShrink: 0 }}
    >
      {svg}
    </span>
  );
}
