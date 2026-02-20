from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_env: str = "development"

    content_database_url: str = "postgresql+psycopg2://db_caddystats:postgresd@localhost:5432/caddystats"
    stats_database_url: str = "postgresql+psycopg2://db_caddystats:postgresd@localhost:5432/caddystats"

    jwt_secret: str = "change_me"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60

    cors_allow_origins: list[str] = [
        "http://localhost:5173",
        "http://127.0.0.1:5173",
    ]


settings = Settings()
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Centralized config loader.
    Reads from .env (root or backend) and environment variables.
    """

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # Environment
    app_env: str = "development"

    # Database URLs (single DB, 2 schemas: content + stats)
    content_database_url: str = "postgresql+psycopg2://caddystats:caddystats_password@localhost:5432/caddystats"
    stats_database_url: str = "postgresql+psycopg2://caddystats:caddystats_password@localhost:5432/caddystats"

    # Auth
    jwt_secret: str = "change_me"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60

    # CORS (dev defaults)
    cors_allow_origins: list[str] = [
        "http://localhost:5173",
        "http://127.0.0.1:5173",
    ]


settings = Settings()
