# Backend/app/graphql/schema.py
import strawberry
from app.graphql.queries import Query
from app.graphql.mutations import Mutation
from app.graphql.context import get_context  # you will create this

schema = strawberry.Schema(
    query=Query,
    mutation=Mutation,
)
