# Database Directory

Bu klasör veritabanı şemaları ve migration dosyalarını içerir.

## Yapı

```
database/
├── migrations/     # Alembic migration dosyaları
├── schemas/        # SQL şema tanımları
└── seeds/          # Test verileri
```

## Şemalar

Veritabanı şemaları `backend/models/` dizinindeki SQLAlchemy modellerinden türetilir.

### Tablolar

1. **patients** - Hasta bilgileri
2. **examinations** - Muayene kayıtları
3. **images** - Göz görüntüleri (ileride eklenecek)
4. **ai_analyses** - AI analiz sonuçları (ileride eklenecek)

## Kurulum

```bash
# PostgreSQL veritabanı oluştur
createdb eye_exam_db

# Alembic ile migration çalıştır
cd backend
alembic upgrade head
```
