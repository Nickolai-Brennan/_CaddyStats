"""
Embed service – resolves stat embeds inside post content blocks.
Populated in Phase 5+ (Blog Editor System).
"""


async def resolve_embeds(content_jsonb: list) -> list:
    """
    Walk a list of editor blocks and resolve any stat-embed blocks
    by fetching live data from the Stats API.
    """
    # TODO: iterate blocks, detect embed type, fetch & inject data
    return content_jsonb
