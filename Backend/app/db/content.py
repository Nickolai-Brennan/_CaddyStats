from sqlalchemy import text
from sqlalchemy.engine import Engine

from app.core.config import settings
from app.db.base import make_engine

content_engine: Engine = make_engine(settings.content_database_url)


def set_content_search_path(conn) -> None:
    """
    Sets the default schema for this connection/session to 'content'.
    Call this right after opening a connection/session.
    """
    conn.execute(text("SET search_path TO content"))
