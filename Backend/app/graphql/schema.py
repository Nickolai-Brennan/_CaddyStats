import strawberry

from app.graphql.queries import Query
from app.graphql.mutations import Mutation

@strawberry.type
class Query:
    @strawberry.field
    def ping(self) -> str:
        return "pong"

    @strawberry.field
    def server_time(self) -> str:
        return datetime.utcnow().isoformat() + "Z"


schema = strawberry.Schema(query=Query)
