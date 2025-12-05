"""
Göz Muayene Asistanı - Backend API

FastAPI ile geliştirilmiş REST API.
Hasta yönetimi, muayene kayıtları ve AI analizi için endpoint'ler içerir.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config.settings import settings
from api.routes import patients, examinations, analysis

# FastAPI uygulaması oluştur
app = FastAPI(
    title="Göz Muayene Asistanı API",
    description="Göz muayenesi için sesli asistan ve AI destekli analiz sistemi backend API'si",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS ayarları
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Root endpoint
@app.get("/")
async def root():
    """API ana endpoint'i - durum kontrolü"""
    return {
        "message": "Göz Muayene Asistanı API",
        "version": "1.0.0",
        "status": "active",
    }


# Sağlık kontrolü
@app.get("/health")
async def health_check():
    """API sağlık kontrolü"""
    return {
        "status": "healthy",
        "database": "connected",  # TODO: Gerçek veritabanı kontrolü
        "services": {
            "gemini": "available",  # TODO: Gerçek servis kontrolü
            "speech": "available",
        },
    }


# API route'larını ekle
app.include_router(patients.router, prefix="/api/patients", tags=["Hastalar"])
app.include_router(
    examinations.router, prefix="/api/examinations", tags=["Muayeneler"]
)
app.include_router(analysis.router, prefix="/api/analysis", tags=["AI Analiz"])


# Uygulama başlangıç eventi
@app.on_event("startup")
async def startup_event():
    """Uygulama başladığında çalışır"""
    print("🏥 Göz Muayene Asistanı API başlatılıyor...")
    # TODO: Veritabanı bağlantısı, cache vb.


# Uygulama kapatma eventi
@app.on_event("shutdown")
async def shutdown_event():
    """Uygulama kapandığında çalışır"""
    print("👋 Göz Muayene Asistanı API kapatılıyor...")
    # TODO: Kaynakları temizle


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
    )
