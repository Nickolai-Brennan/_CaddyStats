# Backend/app/graphql/types/post.py
import strawberry

@strawberry.type
class Post:
    id: str
    title: str
    slug: str
    status: str
    created_at: str
