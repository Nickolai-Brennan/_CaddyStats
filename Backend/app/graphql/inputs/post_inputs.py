# Backend/app/graphql/inputs/post_inputs.py
import strawberry
from typing import Optional

@strawberry.input
class PostFilterInput:
    status: Optional[str] = None
    author_id: Optional[str] = None
    tag_slug: Optional[str] = None
    category_slug: Optional[str] = None
    search: Optional[str] = None

@strawberry.input
class PostSortInput:
    field: str = "CREATED_AT"   # CREATED_AT | PUBLISHED_AT
    direction: str = "DESC"     # ASC | DESC
