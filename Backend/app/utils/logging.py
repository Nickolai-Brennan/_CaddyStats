import logging
import sys

from app.core.config import settings


def configure_logging() -> None:
    if settings.app_env == "production":
        try:
            from pythonjsonlogger import jsonlogger

            handler = logging.StreamHandler(sys.stdout)
            formatter = jsonlogger.JsonFormatter(
                "%(asctime)s %(levelname)s %(name)s %(message)s"
            )
            handler.setFormatter(formatter)
            logging.basicConfig(level=logging.INFO, handlers=[handler])
        except ImportError:
            # Fallback if python-json-logger is not installed
            logging.basicConfig(
                level=logging.INFO,
                format="%(asctime)s %(levelname)s %(name)s :: %(message)s",
                handlers=[logging.StreamHandler(sys.stdout)],
            )
    else:
        logging.basicConfig(
            level=logging.INFO,
            format="%(asctime)s %(levelname)s %(name)s :: %(message)s",
            handlers=[logging.StreamHandler(sys.stdout)],
        )
