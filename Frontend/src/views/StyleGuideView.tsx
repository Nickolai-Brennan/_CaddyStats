import React from 'react';
import { Button, Input, Textarea, Card, Badge, Select, Tooltip, Dialog, Drawer, Spinner, Skeleton, EmptyState, ErrorState } from 'your-design-system';
import { colors, typography } from 'your-tokens';

const StyleGuideView = () => {
  return (
    <div>
      <h1>Style Guide</h1>
      
      <section>
        <h2>Colors</h2>
        <div style={{ background: colors.primary, padding: '10px' }}>Primary Color</div>
        <div style={{ background: colors.secondary, padding: '10px' }}>Secondary Color</div>
        {/* Add other colors */}
      </section>

      <section>
        <h2>Typography</h2>
        <p style={{ fontFamily: typography.fontFamily }}>Sample text with default typography</p>
        {/* Add more typography samples */}
      </section>

      <section>
        <h2>Buttons</h2>
        <Button label="Primary Button" />
        {/* Add examples for different button types */}
      </section>

      <section>
        <h2>Forms</h2>
        <Input placeholder="Type something..." />
        <Textarea placeholder="Your message..." />
        <Select options={[{ value: 'option1', label: 'Option 1' }]} />
      </section>

      <section>
        <h2>Cards</h2>
        <Card title="Card Title" content="Card Content" />
      </section>

      <section>
        <h2>Badges</h2>
        <Badge label="New" />
      </section>

      <section>
        <h2>Feedback</h2>
        <Spinner />
        <Skeleton />
        <EmptyState />
        <ErrorState />
      </section>

      <section>
        <h2>Overlay Components</h2>
        <Tooltip text="Tooltip Text">Hover over me</Tooltip>
        <Dialog title="Dialog Title">Dialog Content</Dialog>
        <Drawer title="Drawer Title">Drawer Content</Drawer>
      </section>
    </div>
  );
};

export default StyleGuideView;
