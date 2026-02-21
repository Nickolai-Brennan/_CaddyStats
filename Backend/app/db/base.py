from sqlalchemy import create_engine
from sqlalchemy.engine import Engine


def make_engine(db_url: str) -> Engine:
    """
    Shared engine builder.
    pool_pre_ping helps avoid stale connections after container restarts.
    """
    return create_engine(db_url, pool_pre_ping=True)
