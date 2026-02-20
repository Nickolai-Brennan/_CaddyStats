from dataclasses import dataclass

@dataclass
class GQLContext:
    request_id: str | None = None
