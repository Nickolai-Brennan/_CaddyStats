import { ArticleCard, type ArticleCardProps } from './ArticleCard';

interface HeroStoryBlockProps {
  hero: ArticleCardProps;
  secondary?: ArticleCardProps[];
}

export function HeroStoryBlock({ hero, secondary = [] }: HeroStoryBlockProps) {
  return (
    <div className="grid grid-cols-1 lg:grid-cols-12 gap-4">
      <div className="lg:col-span-8">
        <ArticleCard {...hero} variant="hero" />
      </div>
      {secondary.length > 0 && (
        <div className="lg:col-span-4 flex flex-col gap-4">
          {secondary.slice(0, 4).map((article) => (
            <ArticleCard key={article.id} {...article} variant="compact" />
          ))}
        </div>
      )}
    </div>
  );
}
