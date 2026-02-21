# Backend/app/db/session.py
from sqlalchemy.orm import sessionmaker

from app.db.content import content_engine

SessionLocal = sessionmaker(bind=content_engine, autoflush=False, autocommit=False, future=True)
