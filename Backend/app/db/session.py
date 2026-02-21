# Backend/app/db/session.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os

CONTENT_DATABASE_URL = os.environ["CONTENT_DATABASE_URL"]

engine = create_engine(CONTENT_DATABASE_URL, pool_pre_ping=True, future=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)
