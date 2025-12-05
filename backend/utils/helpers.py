"""
Yardımcı fonksiyonlar

Genel amaçlı yardımcı fonksiyonlar ve sabitler.
"""

import uuid
import re
from datetime import datetime, date
from typing import Optional, Dict, Any, List


def generate_uuid() -> str:
    """Benzersiz UUID oluştur"""
    return str(uuid.uuid4())


def generate_protocol_number() -> str:
    """
    Protokol numarası oluştur

    Format: YIL-AY-GÜN-SAAT-DAKİKA-SANİYE-RASTGELE
    Örnek: 2024-01-15-143052-ABC1
    """
    now = datetime.now()
    random_suffix = uuid.uuid4().hex[:4].upper()
    return f"{now.strftime('%Y-%m-%d-%H%M%S')}-{random_suffix}"


def validate_tc_kimlik(tc_no: str) -> bool:
    """
    TC Kimlik No doğrulama

    Args:
        tc_no: TC Kimlik numarası

    Returns:
        bool: Geçerli ise True
    """
    if not tc_no or len(tc_no) != 11:
        return False

    if not tc_no.isdigit():
        return False

    if tc_no[0] == "0":
        return False

    # TC Kimlik algoritması
    digits = [int(d) for d in tc_no]

    # 1, 3, 5, 7, 9. hanelerin toplamının 7 katından
    # 2, 4, 6, 8. hanelerin toplamı çıkarılır, mod 10 = 10. hane
    odd_sum = sum(digits[i] for i in range(0, 9, 2))
    even_sum = sum(digits[i] for i in range(1, 8, 2))
    check_10 = (odd_sum * 7 - even_sum) % 10

    if check_10 != digits[9]:
        return False

    # İlk 10 hanenin toplamının mod 10'u = 11. hane
    check_11 = sum(digits[:10]) % 10

    if check_11 != digits[10]:
        return False

    return True


def calculate_age(birth_date: date) -> int:
    """
    Yaş hesapla

    Args:
        birth_date: Doğum tarihi

    Returns:
        int: Yaş
    """
    today = date.today()
    age = today.year - birth_date.year

    if (today.month, today.day) < (birth_date.month, birth_date.day):
        age -= 1

    return age


def format_date_turkish(dt: datetime) -> str:
    """
    Tarihi Türkçe formatta döndür

    Args:
        dt: Tarih

    Returns:
        str: Formatlanmış tarih (örn: "15 Ocak 2024")
    """
    months = [
        "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
        "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"
    ]
    return f"{dt.day} {months[dt.month - 1]} {dt.year}"


def parse_vision_value(text: str) -> Optional[Dict[str, int]]:
    """
    Görme keskinliği değerini parse et

    Args:
        text: Görme değeri metni (örn: "20/20", "10/10", "8 üzerinden 10")

    Returns:
        Dict: {"numerator": x, "denominator": y} veya None
    """
    # Pattern 1: X/Y formatı
    pattern1 = re.match(r"(\d+)\s*/\s*(\d+)", text)
    if pattern1:
        return {
            "numerator": int(pattern1.group(1)),
            "denominator": int(pattern1.group(2)),
        }

    # Pattern 2: X üzerinden Y formatı
    pattern2 = re.match(r"(\d+)\s*üzerinden\s*(\d+)", text.lower())
    if pattern2:
        return {
            "numerator": int(pattern2.group(1)),
            "denominator": int(pattern2.group(2)),
        }

    return None


def parse_iop_value(text: str) -> Optional[float]:
    """
    Göz içi basıncı değerini parse et

    Args:
        text: IOP metni (örn: "18 mmHg", "tansiyon 22")

    Returns:
        float: IOP değeri veya None
    """
    pattern = re.search(r"(\d+(?:\.\d+)?)\s*(?:mmHg|mm\s*Hg)?", text, re.IGNORECASE)
    if pattern:
        return float(pattern.group(1))
    return None


def parse_refraction(text: str) -> Optional[Dict[str, Any]]:
    """
    Refraksiyon değerlerini parse et

    Args:
        text: Refraksiyon metni (örn: "-2.50 -1.25 x 180")

    Returns:
        Dict: {"sphere": x, "cylinder": y, "axis": z} veya None
    """
    # Pattern: [+-]X.XX [+-]X.XX x XXX
    pattern = re.match(
        r"([+-]?\d+(?:\.\d+)?)\s*([+-]?\d+(?:\.\d+)?)\s*[xX@]\s*(\d+)",
        text.strip()
    )
    if pattern:
        return {
            "sphere": float(pattern.group(1)),
            "cylinder": float(pattern.group(2)),
            "axis": int(pattern.group(3)),
        }

    # Sadece sfer
    sphere_only = re.match(r"([+-]?\d+(?:\.\d+)?)", text.strip())
    if sphere_only:
        return {
            "sphere": float(sphere_only.group(1)),
            "cylinder": None,
            "axis": None,
        }

    return None


# Sabitler

# ICD-10 göz hastalıkları kodları (sık kullanılanlar)
ICD10_EYE_CODES = {
    "H25": "Senil katarakt",
    "H26": "Diğer katarakt",
    "H40": "Glokom",
    "H35.3": "Maküler dejenerasyon",
    "H36.0": "Diyabetik retinopati",
    "H04.1": "Kuru göz",
    "H10": "Konjonktivit",
    "H16": "Keratit",
    "H20": "İridosiklit (Üveit)",
    "H01.0": "Blefarit",
    "H50": "Şaşılık",
    "H52": "Refraksiyon bozuklukları",
    "H52.1": "Miyopi",
    "H52.0": "Hipermetropi",
    "H52.2": "Astigmatizma",
    "H52.4": "Presbiyopi",
}

# Yaygın göz ilaçları
COMMON_EYE_MEDICATIONS = {
    "antiglaucoma": [
        "Timolol",
        "Latanoprost",
        "Dorzolamid",
        "Brimonidine",
        "Travoprost",
        "Bimatoprost",
    ],
    "antibiotic": [
        "Moksifloksasin",
        "Tobramisin",
        "Siprofloksasin",
        "Ofloksasin",
        "Fucithalmic",
    ],
    "antiinflammatory": [
        "Prednizolon",
        "Deksametazon",
        "Loteprednol",
        "Fluorometolon",
    ],
    "artificial_tears": [
        "Suni gözyaşı",
        "Hyaluronik asit",
        "Karboksimetilselüloz",
    ],
    "mydriatic": [
        "Tropikamid",
        "Siklopentolat",
        "Fenilefrin",
        "Atropin",
    ],
}

# Ölçüm birimleri
MEASUREMENT_UNITS = {
    "iop": "mmHg",
    "vision": "Snellen",
    "refraction": "Diyoptri (D)",
    "pachymetry": "μm",
    "axial_length": "mm",
    "cd_ratio": "oran",
}
