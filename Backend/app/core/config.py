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

    # Database URL (single Postgres cluster, website_content schema)
    content_database_url: str = "postgresql+psycopg2://caddystats:caddystats_password@localhost:5432/caddystats"

    # External Stats API (no local stats DB)
    stats_api_url: str = "http://localhost:9000"
    stats_api_timeout: int = 10

    # Auth
    jwt_secret: str = "change_me"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60

    # CORS (dev defaults)
    cors_allow_origins: list[str] = [
        "http://localhost:5173",
        "http://127.0.0.1:5173",
    ]

    # Media uploads
    upload_max_size_mb: int = 10
    upload_allowed_mimes: list[str] = [
        "image/jpeg",
        "image/png",
        "image/webp",
        "image/gif",
    ]
    upload_storage_path: str = "./media_uploads"


settings = Settings()
