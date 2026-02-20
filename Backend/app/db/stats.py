from sqlalchemy import text
from sqlalchemy.engine import Engine

from app.core.config import settings
from app.db.base import make_engine

stats_engine: Engine = make_engine(settings.stats_database_url)


def set_stats_search_path(conn) -> None:
    """
    Sets the default schema for this connection/session to 'stats'.
    Call this right after opening a connection/session.
    """
    conn.execute(text("SET search_path TO stats"))
