# Backend/app/graphql/types/pagination.py
from __future__ import annotations
import strawberry
from typing import Generic, List, Optional, TypeVar

T = TypeVar("T")

@strawberry.type
class PageInfo:
    has_next_page: bool
    end_cursor: Optional[str]

@strawberry.type
class Edge(Generic[T]):
    cursor: str
    node: T

@strawberry.type
class Connection(Generic[T]):
    edges: List[Edge[T]]
    page_info: PageInfo
