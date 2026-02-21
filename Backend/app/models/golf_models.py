"""
Golf stats SQLAlchemy ORM models.
Populated in Phase 2+ (Stats Schema development).

All tables live in the `stats` PostgreSQL schema.
"""

import uuid
from datetime import date, datetime

from sqlalchemy import Date, Float, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy.sql import func

_SCHEMA = "stats"


class Base(DeclarativeBase):
    pass


class Golfer(Base):
    __tablename__ = "golfers"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    datagolf_id: Mapped[str | None] = mapped_column(Text, nullable=True, unique=True)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    country: Mapped[str | None] = mapped_column(String(3), nullable=True)
    handedness: Mapped[str | None] = mapped_column(Text, nullable=True)
    birthdate: Mapped[date | None] = mapped_column(Date, nullable=True)
    owgr_rank: Mapped[int | None] = mapped_column(Integer, nullable=True)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())


class Course(Base):
    __tablename__ = "courses"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    location: Mapped[str | None] = mapped_column(Text, nullable=True)
    par: Mapped[int | None] = mapped_column(Integer, nullable=True)
    yardage: Mapped[int | None] = mapped_column(Integer, nullable=True)
    course_key: Mapped[str] = mapped_column(Text, nullable=False, unique=True)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())


class Tournament(Base):
    __tablename__ = "tournaments"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name: Mapped[str] = mapped_column(Text, nullable=False)
    season_year: Mapped[int] = mapped_column(Integer, nullable=False)
    start_date: Mapped[date] = mapped_column(Date, nullable=False)
    end_date: Mapped[date] = mapped_column(Date, nullable=False)
    course_id: Mapped[uuid.UUID | None] = mapped_column(
        ForeignKey(f"{_SCHEMA}.courses.id", ondelete="SET NULL"), nullable=True
    )
    tour: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    course: Mapped["Course | None"] = relationship()


class Projection(Base):
    __tablename__ = "projections"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    tournament_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey(f"{_SCHEMA}.tournaments.id", ondelete="CASCADE"), nullable=False
    )
    golfer_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey(f"{_SCHEMA}.golfers.id", ondelete="CASCADE"), nullable=False
    )
    model_version: Mapped[str] = mapped_column(Text, nullable=False)
    proj_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    win_prob: Mapped[float | None] = mapped_column(Float, nullable=True)
    top10_prob: Mapped[float | None] = mapped_column(Float, nullable=True)
    make_cut_prob: Mapped[float | None] = mapped_column(Float, nullable=True)
    edge_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    components_jsonb: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)
    created_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())

    tournament: Mapped["Tournament"] = relationship()
    golfer: Mapped["Golfer"] = relationship()


class BettingOdds(Base):
    __tablename__ = "betting_odds"
    __table_args__ = {"schema": _SCHEMA}

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    tournament_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey(f"{_SCHEMA}.tournaments.id", ondelete="CASCADE"), nullable=False
    )
    golfer_id: Mapped[uuid.UUID] = mapped_column(
        ForeignKey(f"{_SCHEMA}.golfers.id", ondelete="CASCADE"), nullable=False
    )
    book: Mapped[str] = mapped_column(Text, nullable=False)
    market: Mapped[str] = mapped_column(Text, nullable=False)
    odds: Mapped[int] = mapped_column(Integer, nullable=False)
    implied_prob: Mapped[float] = mapped_column(Float, nullable=False)
    captured_at: Mapped[datetime] = mapped_column(nullable=False, server_default=func.now())
    odds_jsonb: Mapped[dict] = mapped_column(JSONB, nullable=False, default=dict)

    tournament: Mapped["Tournament"] = relationship()
    golfer: Mapped["Golfer"] = relationship()
