"""
Hasta API endpoint'leri

Hasta CRUD operasyonları için REST API endpoint'leri.
"""

from typing import List, Optional
from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel
from datetime import date, datetime

router = APIRouter()


# ==================== PYDANTIC MODELLER ====================


class PatientBase(BaseModel):
    """Hasta temel model"""

    tc_kimlik_no: str
    ad_soyad: str
    dogum_tarihi: date
    cinsiyet: str
    telefon: Optional[str] = None
    email: Optional[str] = None
    adres: Optional[str] = None


class PatientCreate(PatientBase):
    """Hasta oluşturma modeli"""

    pass


class PatientUpdate(BaseModel):
    """Hasta güncelleme modeli"""

    ad_soyad: Optional[str] = None
    telefon: Optional[str] = None
    email: Optional[str] = None
    adres: Optional[str] = None


class PatientResponse(PatientBase):
    """Hasta yanıt modeli"""

    id: str
    olusturma_tarihi: datetime
    guncelleme_tarihi: Optional[datetime] = None

    class Config:
        from_attributes = True


class PatientListResponse(BaseModel):
    """Hasta listesi yanıt modeli"""

    data: List[PatientResponse]
    total: int
    page: int
    per_page: int


# ==================== ENDPOINT'LER ====================


@router.get("/", response_model=PatientListResponse)
async def list_patients(
    page: int = Query(1, ge=1, description="Sayfa numarası"),
    per_page: int = Query(10, ge=1, le=100, description="Sayfa başına kayıt"),
):
    """
    Tüm hastaları listele

    Sayfalama destekli hasta listesi döndürür.
    """
    # TODO: Veritabanından hastaları getir
    return PatientListResponse(data=[], total=0, page=page, per_page=per_page)


@router.get("/search")
async def search_patients(
    q: str = Query(..., min_length=2, description="Arama sorgusu (TC veya isim)"),
):
    """
    Hasta ara

    TC Kimlik No veya isim ile hasta arar.
    """
    # TODO: Veritabanında ara
    return {"data": [], "query": q}


@router.get("/{patient_id}", response_model=PatientResponse)
async def get_patient(patient_id: str):
    """
    Hasta detayı getir

    Belirtilen ID'ye sahip hastanın detaylarını döndürür.
    """
    # TODO: Veritabanından hastayı getir
    raise HTTPException(status_code=404, detail="Hasta bulunamadı")


@router.post("/", response_model=PatientResponse, status_code=201)
async def create_patient(patient: PatientCreate):
    """
    Yeni hasta oluştur

    Yeni bir hasta kaydı oluşturur.
    """
    # TC Kimlik No validasyonu
    if len(patient.tc_kimlik_no) != 11:
        raise HTTPException(
            status_code=400, detail="TC Kimlik No 11 haneli olmalıdır"
        )

    # TODO: Veritabanına kaydet
    # Simüle edilmiş yanıt
    return PatientResponse(
        id="new-patient-id",
        tc_kimlik_no=patient.tc_kimlik_no,
        ad_soyad=patient.ad_soyad,
        dogum_tarihi=patient.dogum_tarihi,
        cinsiyet=patient.cinsiyet,
        telefon=patient.telefon,
        email=patient.email,
        adres=patient.adres,
        olusturma_tarihi=datetime.now(),
    )


@router.put("/{patient_id}", response_model=PatientResponse)
async def update_patient(patient_id: str, patient: PatientUpdate):
    """
    Hasta güncelle

    Mevcut hasta bilgilerini günceller.
    """
    # TODO: Veritabanında güncelle
    raise HTTPException(status_code=404, detail="Hasta bulunamadı")


@router.delete("/{patient_id}", status_code=204)
async def delete_patient(patient_id: str):
    """
    Hasta sil

    Belirtilen hastayı siler.
    """
    # TODO: Veritabanından sil
    raise HTTPException(status_code=404, detail="Hasta bulunamadı")


@router.get("/{patient_id}/examinations")
async def get_patient_examinations(
    patient_id: str,
    page: int = Query(1, ge=1),
    per_page: int = Query(10, ge=1, le=100),
):
    """
    Hasta muayene geçmişi

    Hastanın tüm muayene kayıtlarını döndürür.
    """
    # TODO: Veritabanından muayeneleri getir
    return {"data": [], "total": 0, "page": page, "per_page": per_page}
