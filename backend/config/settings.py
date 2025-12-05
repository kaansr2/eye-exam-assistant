"""
Uygulama yapılandırma ayarları

Pydantic Settings kullanarak ortam değişkenlerinden yapılandırma yükler.
"""

from typing import List
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Uygulama ayarları"""

    # Uygulama
    APP_NAME: str = "Göz Muayene Asistanı"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    # Güvenlik
    SECRET_KEY: str = "your-secret-key-change-in-production"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # CORS
    ALLOWED_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://127.0.0.1:3000",
    ]

    # Veritabanı
    DATABASE_URL: str = "postgresql+asyncpg://user:password@localhost:5432/eye_exam_db"

    # Google Cloud / Gemini
    GOOGLE_APPLICATION_CREDENTIALS: str = ""
    GEMINI_API_KEY: str = ""
    GEMINI_MODEL: str = "gemini-2.5-pro"

    # Dosya yükleme
    UPLOAD_DIR: str = "./uploads"
    MAX_UPLOAD_SIZE: int = 10 * 1024 * 1024  # 10 MB

    # Loglama
    LOG_LEVEL: str = "INFO"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True


# Global settings instance
settings = Settings()
