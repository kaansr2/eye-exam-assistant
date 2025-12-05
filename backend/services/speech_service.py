"""
Speech-to-Text Servisi

Google Cloud Speech API ile ses tanıma.
"""

from typing import Dict, Any, Optional, List
from config.settings import settings


class SpeechService:
    """
    Speech-to-Text servisi

    Doktor ses kayıtlarını metne dönüştürür.
    """

    def __init__(self):
        """Speech servisini başlat"""
        self.credentials_path = settings.GOOGLE_APPLICATION_CREDENTIALS
        self._client = None
        self.language_code = "tr-TR"

    async def initialize(self) -> bool:
        """
        Speech client'ı başlat

        Returns:
            bool: Başarılı ise True
        """
        if not self.credentials_path:
            print("⚠️ GOOGLE_APPLICATION_CREDENTIALS ayarlanmadı")
            return False

        try:
            # TODO: Gerçek Speech client başlatma
            # from google.cloud import speech
            # self._client = speech.SpeechClient()
            return True
        except Exception as e:
            print(f"❌ Speech servisi başlatma hatası: {e}")
            return False

    async def transcribe_audio(
        self,
        audio_data: bytes,
        audio_format: str = "wav",
        sample_rate: int = 16000,
    ) -> Dict[str, Any]:
        """
        Ses dosyasını metne dönüştür

        Args:
            audio_data: Ses verisi (bytes)
            audio_format: Ses formatı (wav, mp3, flac)
            sample_rate: Örnekleme hızı

        Returns:
            Dict: Transkripsiyon sonucu
        """
        if not self._client:
            return {
                "error": "Speech servisi başlatılmadı",
                "transcription": "",
                "confidence": 0.0,
            }

        try:
            # TODO: Gerçek transkripsiyon
            # config = speech.RecognitionConfig(
            #     encoding=self._get_encoding(audio_format),
            #     sample_rate_hertz=sample_rate,
            #     language_code=self.language_code,
            #     enable_automatic_punctuation=True,
            #     use_enhanced=True,
            #     model="latest_long",
            # )
            # audio = speech.RecognitionAudio(content=audio_data)
            # response = self._client.recognize(config=config, audio=audio)

            # Simüle edilmiş yanıt
            return {
                "transcription": "",
                "confidence": 0.0,
                "words": [],
            }
        except Exception as e:
            return {
                "error": str(e),
                "transcription": "",
                "confidence": 0.0,
            }

    async def transcribe_streaming(
        self,
        audio_generator,
    ):
        """
        Gerçek zamanlı ses tanıma (streaming)

        Args:
            audio_generator: Ses verisi generator'ı

        Yields:
            Dict: Anlık transkripsiyon sonuçları
        """
        # TODO: Streaming transkripsiyon implementasyonu
        pass

    def _get_encoding(self, audio_format: str):
        """Ses formatına göre encoding döndür"""
        encodings = {
            "wav": "LINEAR16",
            "mp3": "MP3",
            "flac": "FLAC",
            "ogg": "OGG_OPUS",
        }
        return encodings.get(audio_format.lower(), "LINEAR16")


class MedicalTermCorrector:
    """
    Tıbbi terim düzeltici

    Ses tanıma çıktısındaki tıbbi terimleri düzeltir.
    """

    # Göz terimleri sözlüğü
    EYE_TERMS = {
        # Anatomik terimler
        "kornea": "kornea",
        "retina": "retina",
        "makula": "makula",
        "maküla": "makula",
        "vitreus": "vitreus",
        "vitröz": "vitreus",
        "iris": "iris",
        "pupil": "pupilla",
        "pupilla": "pupilla",
        "lens": "lens",
        "optik disk": "optik disk",
        "optik sinir": "optik sinir",
        "konjonktiva": "konjonktiva",
        "konjunktiva": "konjonktiva",
        "sklera": "sklera",
        
        # Hastalıklar
        "katarakt": "katarakt",
        "glokom": "glokom",
        "glokoma": "glokom",
        "retinopati": "retinopati",
        "maküler dejenerasyon": "maküler dejenerasyon",
        "üveit": "üveit",
        "uveit": "üveit",
        "keratit": "keratit",
        "blefarit": "blefarit",
        
        # Bulgular
        "nükleer": "nükleer",
        "kortikal": "kortikal",
        "subkapsüler": "subkapsüler",
        "drusen": "drusen",
        "mikroanevrizma": "mikroanevrizma",
        "hemoraji": "hemoraji",
        "eksuda": "eksuda",
        "ödem": "ödem",
        
        # Ölçümler
        "diyoptri": "diyoptri",
        "milimetre": "mm",
        "milimetreCiva": "mmHg",
    }

    # Sayı dönüşümleri (Türkçe yazılıştan rakama)
    NUMBER_WORDS = {
        "sıfır": "0",
        "bir": "1",
        "iki": "2",
        "üç": "3",
        "dört": "4",
        "beş": "5",
        "altı": "6",
        "yedi": "7",
        "sekiz": "8",
        "dokuz": "9",
        "on": "10",
        "onbir": "11",
        "oniki": "12",
        "onüç": "13",
        "ondört": "14",
        "onbeş": "15",
        "onaltı": "16",
        "onyedi": "17",
        "onsekiz": "18",
        "ondokuz": "19",
        "yirmi": "20",
    }

    @classmethod
    def correct_text(cls, text: str) -> str:
        """
        Metindeki tıbbi terimleri düzelt

        Args:
            text: Düzeltilecek metin

        Returns:
            str: Düzeltilmiş metin
        """
        corrected = text.lower()

        # Tıbbi terimleri düzelt
        for wrong, correct in cls.EYE_TERMS.items():
            corrected = corrected.replace(wrong.lower(), correct)

        # Sayıları dönüştür
        for word, number in cls.NUMBER_WORDS.items():
            corrected = corrected.replace(word, number)

        return corrected

    @classmethod
    def extract_measurements(cls, text: str) -> Dict[str, Any]:
        """
        Metinden ölçümleri çıkar

        Args:
            text: Metin

        Returns:
            Dict: Çıkarılan ölçümler
        """
        import re

        measurements = {}

        # Görme keskinliği pattern'leri
        vision_patterns = [
            r"(\d+)\s*/\s*(\d+)",  # 20/20, 10/10
            r"(\d+)\s*üzerinden\s*(\d+)",  # 10 üzerinden 8
        ]
        for pattern in vision_patterns:
            matches = re.findall(pattern, text)
            if matches:
                measurements["vision"] = f"{matches[0][0]}/{matches[0][1]}"
                break

        # IOP pattern'i
        iop_pattern = r"(?:basınç|tansiyon|iop)\s*(\d+)"
        iop_matches = re.findall(iop_pattern, text.lower())
        if iop_matches:
            measurements["iop"] = int(iop_matches[0])

        # C/D oranı pattern'i
        cd_pattern = r"(?:cd|c/d|cup\s*disk)\s*(?:oranı)?\s*([\d.]+)"
        cd_matches = re.findall(cd_pattern, text.lower())
        if cd_matches:
            measurements["cd_ratio"] = float(cd_matches[0])

        # Refraksiyon pattern'i (örn: -2.50 veya +1.25)
        refraction_pattern = r"([+-]?\d+\.?\d*)\s*(?:diyoptri|d)?"
        # TODO: Daha karmaşık refraksiyon parsing'i

        return measurements
