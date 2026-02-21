"""
Post service – business logic for CMS content posts.
Populated in Phase 2+ (Database + GraphQL).
"""


async def get_posts(session, *, limit: int = 20, offset: int = 0) -> list:
    """Return a paginated list of published posts."""
    # TODO: implement with SQLAlchemy session
    return []


async def get_post_by_slug(session, slug: str) -> dict | None:
    """Return a single post by slug, or None if not found."""
    # TODO: implement with SQLAlchemy session
    return None


async def create_post(session, data: dict) -> dict:
    """Create a new post and return the created record."""
    # TODO: implement with SQLAlchemy session
    raise NotImplementedError
