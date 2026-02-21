import type { ReactNode } from 'react';
import { Grid, GridItem } from './Grid';
import { cn } from '../../utils/cn';

interface LayoutProps {
  className?: string;
  children: ReactNode;
}

/** Single centered column */
export function OneColumnStack({ className, children }: LayoutProps) {
  return (
    <Grid cols={1} gap="lg" className={cn('max-w-3xl mx-auto', className)}>
      <GridItem span="full">{children}</GridItem>
    </Grid>
  );
}

type TwoColumnVariant = '6/6' | '8/4';

interface TwoColumnSplitProps {
  variant?: TwoColumnVariant;
  left: ReactNode;
  right: ReactNode;
  className?: string;
}

/** Two-column split: 50/50 or 66/33 */
export function TwoColumnSplit({
  variant = '6/6',
  left,
  right,
  className,
}: TwoColumnSplitProps) {
  return (
    <Grid cols={1} mdCols={12} gap="lg" className={className}>
      <GridItem span="full" mdSpan={variant === '8/4' ? 8 : 6}>
        {left}
      </GridItem>
      <GridItem span="full" mdSpan={variant === '8/4' ? 4 : 6}>
        {right}
      </GridItem>
    </Grid>
  );
}

/** Three equal columns */
export function ThreeColumn({ className, children }: LayoutProps) {
  return (
    <Grid cols={1} smCols={2} lgCols={3} gap="lg" className={className}>
      {children}
    </Grid>
  );
}

/** 2-col mobile → 3-col tablet → 6-col desktop card grid */
export function SixCardGrid({ className, children }: LayoutProps) {
  return (
    <Grid cols={2} mdCols={3} lgCols={6} gap="md" className={className}>
      {children}
    </Grid>
  );
}

interface HeroPlusGridProps {
  hero: ReactNode;
  sidebar: ReactNode;
  className?: string;
}

/** Hero (8 cols) + sidebar (4 cols) on desktop, stacked on mobile */
export function HeroPlusGrid({ hero, sidebar, className }: HeroPlusGridProps) {
  return (
    <Grid cols={1} lgCols={12} gap="lg" className={className}>
      <GridItem span="full" lgSpan={8}>
        {hero}
      </GridItem>
      <GridItem span="full" lgSpan={4}>
        {sidebar}
      </GridItem>
    </Grid>
  );
}
