import { useMemo, useState } from 'react';
import { SeoHead } from '../design-system/seo/SeoHead';
import { Section } from '../design-system/layout/Section';
import {
  Badge,
  Button,
  Card,
  Dialog,
  Drawer,
  EmptyState,
  ErrorState,
  Input,
  Select,
  SkeletonCard,
  Spinner,
  Textarea,
  Tooltip,
} from '../design-system/primitives';
import { colors, typography } from '../design-system/tokens';

function ColorSwatch({ name, value }: { name: string; value: string }) {
  return (
    <div className="flex items-center justify-between gap-3 rounded-lg border border-gray-200 dark:border-gray-700 p-3 bg-white dark:bg-gray-800">
      <div className="min-w-0">
        <div className="text-sm font-medium text-gray-900 dark:text-gray-100 truncate">{name}</div>
        <div className="text-xs text-gray-500 dark:text-gray-400">{value}</div>
      </div>
      <div
        className="w-10 h-10 rounded-md border border-black/10 dark:border-white/10"
        style={{ background: value }}
      />
    </div>
  );
}

export function StyleGuideView() {
  const [dialogOpen, setDialogOpen] = useState(false);
  const [drawerOpen, setDrawerOpen] = useState(false);

  const neutralEntries = useMemo(
    () =>
      Object.entries(colors.neutral).map(([k, v]) => ({
        name: `neutral.${k}`,
        value: v,
      })),
    [],
  );

  return (
    <> 
      <SeoHead
        title="Style Guide | Caddy Stats"
        description="Internal UI style guide for Caddy Stats components and tokens."
      />

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <Section title="Style Guide" subtitle="Hidden route: /style-guide. Tokens + primitives reference." className="pt-6">
          <div className="grid gap-6">
            <Card padding="md">
              <div className="flex items-center justify-between gap-4">
                <div>
                  <h3 className="text-lg font-semibold">Colors</h3>
                  <p className="text-sm text-gray-500 dark:text-gray-400">
                    From <code className="text-xs">design-system/tokens/colors.ts</code>
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  <Badge variant="primary">brand</Badge>
                  <Badge variant="info" pill>
                    tokens
                  </Badge>
                </div>
              </div>

              <div className="mt-4 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                <ColorSwatch name="brand.primary" value={colors.brand.primary} />
                <ColorSwatch name="brand.secondary" value={colors.brand.secondary} />
                <ColorSwatch name="brand.accent" value={colors.brand.accent} />
                <ColorSwatch name="semantic.success" value={colors.semantic.success} />
                <ColorSwatch name="semantic.warning" value={colors.semantic.warning} />
                <ColorSwatch name="semantic.error" value={colors.semantic.error} />
                <ColorSwatch name="semantic.info" value={colors.semantic.info} />
              </div>

              <div className="mt-4">
                <h4 className="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Neutral ramp</h4>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                  {neutralEntries.map((e) => (
                    <ColorSwatch key={e.name} name={e.name} value={e.value} />
                  ))}
                </div>
              </div>
            </Card>

            <Card padding="md">
              <h3 className="text-lg font-semibold">Typography</h3>
              <p className="text-sm text-gray-500 dark:text-gray-400">
                Uses <code className="text-xs">design-system/tokens/typography.ts</code> (and global system font in{' '}
                <code className="text-xs">styles.css</code>)
              </p>

              <div className="mt-4 grid gap-3">
                <div className="text-3xl font-bold">Heading / 3xl Bold</div>
                <div className="text-xl font-semibold">Subheading / xl Semibold</div>
                <div className="text-base">Body text — The quick brown fox jumps over the lazy dog.</div>
                <div className="text-sm text-gray-600 dark:text-gray-300">
                  Muted text — The quick brown fox jumps over the lazy dog.
                </div>
                <div className="text-xs text-gray-500 dark:text-gray-400">
                  Token reference (debug): <code>{JSON.stringify(Object.keys(typography))}</code>
                </div>
              </div>
            </Card>

            <Card padding="md">
              <h3 className="text-lg font-semibold">Buttons</h3>
              <div className="mt-4 flex flex-wrap items-center gap-3">
                <Button variant="primary">Primary</Button>
                <Button variant="ghost">Ghost</Button>
                <Button variant="outline">Outline</Button>
                <Button variant="danger">Danger</Button>
                <Button loading>Loading</Button>
                <Button disabled>Disabled</Button>
              </div>

              <div className="mt-4 flex flex-wrap items-center gap-3">
                <Button size="sm">Small</Button>
                <Button size="md">Medium</Button>
                <Button size="lg">Large</Button>
              </div>
            </Card>

            <Card padding="md">
              <h3 className="text-lg font-semibold">Inputs</h3>
              <div className="mt-4 grid grid-cols-1 md:grid-cols-2 gap-4">
                <Input label="Name" placeholder="Nickolai Brennan" />
                <Input label="Email" placeholder="name@example.com" helperText="We’ll never share your email." />
                <Input label="With error" placeholder="Bad value" error="This field is required." />
                <Textarea label="Message" placeholder="Write something…" />
              </div>

              <div className="mt-4 max-w-sm">
                <Select
                  label="Select"
                  helperText="Example select"
                  options={[
                    { value: 'pga', label: 'PGA' },
                    { value: 'dp', label: 'DP World Tour' },
                    { value: 'lpga', label: 'LPGA' },
                  ]}
                />
              </div>
            </Card>

            <Card padding="md">
              <h3 className="text-lg font-semibold">Card + Badge</h3>
              <div className="mt-4 grid grid-cols-1 md:grid-cols-2 gap-4">
                <Card padding="md">
                  <div className="flex items-center justify-between">
                    <div className="font-semibold">Default card</div>
                    <Badge>Default</Badge>
                  </div>
                  <p className="mt-2 text-sm text-gray-500 dark:text-gray-400">
                    This is a Card inside a Card to show nesting.
                  </p>
                </Card>

                <Card padding="md" hover>
                  <div className="flex items-center justify-between">
                    <div className="font-semibold">Hover card</div>
                    <Badge variant="info" pill>
                      Hover
                    </Badge>
                  </div>
                  <p className="mt-2 text-sm text-gray-500 dark:text-gray-400">
                    Hover should apply a shadow and cursor.
                  </p>
                </Card>
              </div>
            </Card>

            <Card padding="md">
              <h3 className="text-lg font-semibold">Feedback</h3>
              <div className="mt-4 flex items-center gap-4">
                <Spinner />
                <div className="w-full max-w-xs">
                  <SkeletonCard />
                </div>
              </div>

              <div className="mt-4 grid grid-cols-1 md:grid-cols-2 gap-4">
                <EmptyState title="Empty" description="Nothing to show yet." />
                <ErrorState title="Error" description="Something went wrong." onRetry={() => window.location.reload()} />
              </div>
            </Card>

            <Card padding="md">
              <h3 className="text-lg font-semibold">Overlays</h3>
              <div className="mt-4 flex flex-wrap items-center gap-3">
                <Tooltip content="Tooltip content">
                  <span className="underline cursor-help">Hover me</span>
                </Tooltip>

                <Button variant="outline" onClick={() => setDialogOpen(true)}>
                  Open Dialog
                </Button>
                <Button variant="outline" onClick={() => setDrawerOpen(true)}>
                  Open Drawer
                </Button>
              </div>

              <Dialog open={dialogOpen} onOpenChange={setDialogOpen} title="Dialog title">
                <div className="space-y-3">
                  <p className="text-sm text-gray-600 dark:text-gray-300">This is a dialog example.</p>
                  <div className="flex justify-end gap-2">
                    <Button variant="ghost" onClick={() => setDialogOpen(false)}>
                      Close
                    </Button>
                    <Button onClick={() => setDialogOpen(false)}>Confirm</Button>
                  </div>
                </div>
              </Dialog>

              <Drawer open={drawerOpen} onOpenChange={setDrawerOpen} title="Drawer title">
                <div className="space-y-3">
                  <p className="text-sm text-gray-600 dark:text-gray-300">This is a drawer example.</p>
                  <div className="flex justify-end">
                    <Button onClick={() => setDrawerOpen(false)}>Done</Button>
                  </div>
                </div>
              </Drawer>
            </Card>
          </div>
        </Section>
      </div>
    </>
  );
}