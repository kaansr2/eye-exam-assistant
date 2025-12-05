"""
Hasta veritabanı modeli

SQLAlchemy ORM modeli.
"""

from datetime import date, datetime
from typing import Optional, List
from sqlalchemy import Column, String, Date, DateTime, Text
from sqlalchemy.orm import relationship


# NOT: Base import'u gerçek uygulamada database.py'den yapılacak
# from database import Base

# Placeholder Base sınıfı
class BasePlaceholder:
    pass


Base = BasePlaceholder


class Patient:
    """
    Hasta veritabanı modeli

    Attributes:
        id: Benzersiz hasta ID'si (UUID)
        tc_kimlik_no: TC Kimlik Numarası (11 hane)
        ad_soyad: Hasta adı ve soyadı
        dogum_tarihi: Doğum tarihi
        cinsiyet: Cinsiyet (Erkek/Kadın)
        telefon: Telefon numarası (opsiyonel)
        email: E-posta adresi (opsiyonel)
        adres: Adres (opsiyonel)
        olusturma_tarihi: Kayıt oluşturulma tarihi
        guncelleme_tarihi: Son güncelleme tarihi
    """

    __tablename__ = "patients"

    # Birincil anahtar
    id: str  # Column(String(36), primary_key=True)

    # Zorunlu alanlar
    tc_kimlik_no: str  # Column(String(11), unique=True, nullable=False, index=True)
    ad_soyad: str  # Column(String(100), nullable=False, index=True)
    dogum_tarihi: date  # Column(Date, nullable=False)
    cinsiyet: str  # Column(String(10), nullable=False)

    # Opsiyonel alanlar
    telefon: Optional[str] = None  # Column(String(20), nullable=True)
    email: Optional[str] = None  # Column(String(100), nullable=True)
    adres: Optional[str] = None  # Column(Text, nullable=True)

    # Zaman damgaları
    olusturma_tarihi: datetime  # Column(DateTime, default=datetime.utcnow)
    guncelleme_tarihi: Optional[datetime] = None  # Column(DateTime, onupdate=datetime.utcnow)

    # İlişkiler
    # examinations = relationship("Examination", back_populates="patient")

    def __repr__(self) -> str:
        return f"<Patient(id={self.id}, tc={self.tc_kimlik_no}, ad_soyad={self.ad_soyad})>"

    @property
    def yas(self) -> int:
        """Hastanın yaşını hesapla"""
        today = date.today()
        age = today.year - self.dogum_tarihi.year
        if (today.month, today.day) < (self.dogum_tarihi.month, self.dogum_tarihi.day):
            age -= 1
        return age

    def to_dict(self) -> dict:
        """Modeli sözlüğe dönüştür"""
        return {
            "id": self.id,
            "tc_kimlik_no": self.tc_kimlik_no,
            "ad_soyad": self.ad_soyad,
            "dogum_tarihi": self.dogum_tarihi.isoformat() if self.dogum_tarihi else None,
            "cinsiyet": self.cinsiyet,
            "telefon": self.telefon,
            "email": self.email,
            "adres": self.adres,
            "yas": self.yas,
            "olusturma_tarihi": self.olusturma_tarihi.isoformat() if self.olusturma_tarihi else None,
            "guncelleme_tarihi": self.guncelleme_tarihi.isoformat() if self.guncelleme_tarihi else None,
        }


# Veritabanı şeması SQL (referans için)
"""
CREATE TABLE patients (
    id VARCHAR(36) PRIMARY KEY,
    tc_kimlik_no VARCHAR(11) UNIQUE NOT NULL,
    ad_soyad VARCHAR(100) NOT NULL,
    dogum_tarihi DATE NOT NULL,
    cinsiyet VARCHAR(10) NOT NULL,
    telefon VARCHAR(20),
    email VARCHAR(100),
    adres TEXT,
    olusturma_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    guncelleme_tarihi TIMESTAMP
);

CREATE INDEX idx_patients_tc ON patients(tc_kimlik_no);
CREATE INDEX idx_patients_ad ON patients(ad_soyad);
"""
