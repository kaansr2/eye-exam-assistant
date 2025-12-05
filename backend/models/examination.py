"""
Muayene veritabanı modeli

SQLAlchemy ORM modeli.
"""

from datetime import datetime
from typing import Optional, List, Dict, Any
from sqlalchemy import Column, String, DateTime, Text, Boolean, Float, ForeignKey, JSON
from sqlalchemy.orm import relationship


# NOT: Base import'u gerçek uygulamada database.py'den yapılacak
# from database import Base

# Placeholder Base sınıfı
class BasePlaceholder:
    pass


Base = BasePlaceholder


class Examination:
    """
    Muayene veritabanı modeli

    Attributes:
        id: Benzersiz muayene ID'si (UUID)
        patient_id: Hasta ID'si (Foreign Key)
        muayene_tarihi: Muayene tarihi ve saati
        protokol_no: Hastane protokol numarası
        basvuru_sikayeti: Hasta şikayeti
        gorme_keskinligi: Görme keskinliği verileri (JSON)
        refraksiyon: Refraksiyon verileri (JSON)
        goz_ici_basinci: IOP verileri (JSON)
        on_segment: Ön segment bulguları (JSON)
        arka_segment: Arka segment/fundus bulguları (JSON)
        tani: Konulan tanı
        tedavi: Uygulanan/önerilen tedavi
        notlar: Ek notlar
        gorseller_urls: Göz fotoğrafları URL'leri (JSON array)
        ai_analizi: AI analiz sonuçları (JSON)
        doktor_onayi: Doktor onay durumu
        olusturma_tarihi: Kayıt oluşturulma tarihi
        guncelleme_tarihi: Son güncelleme tarihi
    """

    __tablename__ = "examinations"

    # Birincil anahtar
    id: str  # Column(String(36), primary_key=True)

    # Hasta ilişkisi
    patient_id: str  # Column(String(36), ForeignKey("patients.id"), nullable=False)

    # Muayene bilgileri
    muayene_tarihi: datetime  # Column(DateTime, nullable=False)
    protokol_no: Optional[str] = None  # Column(String(50), nullable=True)

    # Anamnez
    basvuru_sikayeti: Optional[str] = None  # Column(Text, nullable=True)

    # Muayene bulguları (JSON formatında)
    gorme_keskinligi: Optional[Dict[str, Any]] = None  # Column(JSON, nullable=True)
    refraksiyon: Optional[Dict[str, Any]] = None  # Column(JSON, nullable=True)
    goz_ici_basinci: Optional[Dict[str, Any]] = None  # Column(JSON, nullable=True)
    on_segment: Optional[Dict[str, Any]] = None  # Column(JSON, nullable=True)
    arka_segment: Optional[Dict[str, Any]] = None  # Column(JSON, nullable=True)

    # Tanı ve tedavi
    tani: Optional[str] = None  # Column(Text, nullable=True)
    tedavi: Optional[str] = None  # Column(Text, nullable=True)
    notlar: Optional[str] = None  # Column(Text, nullable=True)

    # Görseller
    gorseller_urls: Optional[List[str]] = None  # Column(JSON, nullable=True)

    # AI analizi
    ai_analizi: Optional[Dict[str, Any]] = None  # Column(JSON, nullable=True)

    # Onay durumu
    doktor_onayi: bool = False  # Column(Boolean, default=False)

    # Zaman damgaları
    olusturma_tarihi: datetime  # Column(DateTime, default=datetime.utcnow)
    guncelleme_tarihi: Optional[datetime] = None  # Column(DateTime, onupdate=datetime.utcnow)

    # İlişkiler
    # patient = relationship("Patient", back_populates="examinations")

    def __repr__(self) -> str:
        return f"<Examination(id={self.id}, patient_id={self.patient_id}, tarih={self.muayene_tarihi})>"

    def to_dict(self) -> dict:
        """Modeli sözlüğe dönüştür"""
        return {
            "id": self.id,
            "patient_id": self.patient_id,
            "muayene_tarihi": self.muayene_tarihi.isoformat() if self.muayene_tarihi else None,
            "protokol_no": self.protokol_no,
            "basvuru_sikayeti": self.basvuru_sikayeti,
            "gorme_keskinligi": self.gorme_keskinligi,
            "refraksiyon": self.refraksiyon,
            "goz_ici_basinci": self.goz_ici_basinci,
            "on_segment": self.on_segment,
            "arka_segment": self.arka_segment,
            "tani": self.tani,
            "tedavi": self.tedavi,
            "notlar": self.notlar,
            "gorseller_urls": self.gorseller_urls,
            "ai_analizi": self.ai_analizi,
            "doktor_onayi": self.doktor_onayi,
            "olusturma_tarihi": self.olusturma_tarihi.isoformat() if self.olusturma_tarihi else None,
            "guncelleme_tarihi": self.guncelleme_tarihi.isoformat() if self.guncelleme_tarihi else None,
        }


# Veritabanı şeması SQL (referans için)
"""
CREATE TABLE examinations (
    id VARCHAR(36) PRIMARY KEY,
    patient_id VARCHAR(36) NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    muayene_tarihi TIMESTAMP NOT NULL,
    protokol_no VARCHAR(50),
    basvuru_sikayeti TEXT,
    gorme_keskinligi JSONB,
    refraksiyon JSONB,
    goz_ici_basinci JSONB,
    on_segment JSONB,
    arka_segment JSONB,
    tani TEXT,
    tedavi TEXT,
    notlar TEXT,
    gorseller_urls JSONB,
    ai_analizi JSONB,
    doktor_onayi BOOLEAN DEFAULT FALSE,
    olusturma_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    guncelleme_tarihi TIMESTAMP
);

CREATE INDEX idx_examinations_patient ON examinations(patient_id);
CREATE INDEX idx_examinations_tarih ON examinations(muayene_tarihi);
"""
