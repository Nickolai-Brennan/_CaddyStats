import strawberry
from datetime import datetime


@strawberry.type
class Query:
    @strawberry.field
    def ping(self) -> str:
        return "pong"

    @strawberry.field
    def server_time(self) -> str:
        return datetime.utcnow().isoformat() + "Z"


schema = strawberry.Schema(query=Query)
