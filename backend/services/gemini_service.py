"""
Gemini API Servisi

Google Gemini 2.5 Pro ile görüntü ve metin analizi.
"""

import base64
from typing import Dict, Any, List, Optional
from config.settings import settings


class GeminiService:
    """
    Gemini API servisi

    Göz görüntülerini ve doktor notlarını analiz eder.
    """

    def __init__(self):
        """Gemini servisini başlat"""
        self.api_key = settings.GEMINI_API_KEY
        self.model = settings.GEMINI_MODEL
        self._client = None

    async def initialize(self) -> bool:
        """
        Gemini client'ı başlat

        Returns:
            bool: Başarılı ise True
        """
        if not self.api_key:
            print("⚠️ GEMINI_API_KEY ayarlanmadı")
            return False

        try:
            # TODO: Gerçek Gemini client başlatma
            # import google.generativeai as genai
            # genai.configure(api_key=self.api_key)
            # self._client = genai.GenerativeModel(self.model)
            return True
        except Exception as e:
            print(f"❌ Gemini başlatma hatası: {e}")
            return False

    async def analyze_eye_image(
        self,
        image_data: bytes,
        image_type: str = "fundus",
        additional_context: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Göz görüntüsünü analiz et

        Args:
            image_data: Görüntü verisi (bytes)
            image_type: Görüntü tipi (fundus, anterior, external)
            additional_context: Ek bağlam bilgisi

        Returns:
            Dict: Analiz sonuçları
        """
        if not self._client:
            return {
                "error": "Gemini servisi başlatılmadı",
                "findings": [],
                "confidence": 0.0,
            }

        # Prompt hazırla
        prompt = self._build_image_analysis_prompt(image_type, additional_context)

        try:
            # TODO: Gerçek API çağrısı
            # response = await self._client.generate_content_async([prompt, image_data])

            # Simüle edilmiş yanıt
            return {
                "findings": [],
                "suggested_diagnoses": [],
                "confidence": 0.0,
                "raw_response": "Analiz bekliyor...",
            }
        except Exception as e:
            return {
                "error": str(e),
                "findings": [],
                "confidence": 0.0,
            }

    async def analyze_medical_text(
        self,
        text: str,
        extraction_fields: Optional[List[str]] = None,
    ) -> Dict[str, Any]:
        """
        Tıbbi metni analiz et

        Args:
            text: Analiz edilecek metin
            extraction_fields: Çıkarılacak alan listesi

        Returns:
            Dict: Çıkarılan veriler
        """
        if not self._client:
            return {
                "error": "Gemini servisi başlatılmadı",
                "extracted_data": {},
                "confidence": 0.0,
            }

        prompt = self._build_text_analysis_prompt(text, extraction_fields)

        try:
            # TODO: Gerçek API çağrısı
            # response = await self._client.generate_content_async(prompt)

            # Simüle edilmiş yanıt
            return {
                "extracted_data": {},
                "field_mapping": {},
                "confidence": 0.0,
                "raw_response": "Analiz bekliyor...",
            }
        except Exception as e:
            return {
                "error": str(e),
                "extracted_data": {},
                "confidence": 0.0,
            }

    def _build_image_analysis_prompt(
        self,
        image_type: str,
        additional_context: Optional[str],
    ) -> str:
        """Görüntü analizi için prompt oluştur"""
        base_prompt = """Sen bir göz hastalıkları uzmanı AI asistanısın. 
        Verilen göz görüntüsünü analiz et ve şunları belirle:
        
        1. Gözlemlenen bulgular (findings)
        2. Olası tanılar (suggested_diagnoses)
        3. Önerilen tetkikler
        4. Güven skoru (0-1 arası)
        
        Yanıtını JSON formatında ver."""

        type_prompts = {
            "fundus": "Bu bir fundus (retina) görüntüsüdür. Optik disk, makula, damarlar ve retina parankimini değerlendir.",
            "anterior": "Bu bir ön segment görüntüsüdür. Kornea, ön kamara, iris ve lensi değerlendir.",
            "external": "Bu bir dış göz görüntüsüdür. Kapaklar, konjonktiva ve kornea yüzeyini değerlendir.",
        }

        prompt = f"{base_prompt}\n\n{type_prompts.get(image_type, '')}"

        if additional_context:
            prompt += f"\n\nEk bilgi: {additional_context}"

        return prompt

    def _build_text_analysis_prompt(
        self,
        text: str,
        extraction_fields: Optional[List[str]],
    ) -> str:
        """Metin analizi için prompt oluştur"""
        fields = extraction_fields or [
            "gorme_keskinligi",
            "goz_ici_basinci",
            "sikayet",
            "bulgular",
            "tani",
        ]

        prompt = f"""Sen bir göz hastalıkları uzmanı AI asistanısın.
        Aşağıdaki doktor notlarını analiz et ve yapılandırılmış veri çıkar.
        
        Çıkarılacak alanlar: {', '.join(fields)}
        
        Doktor notları:
        {text}
        
        Yanıtını JSON formatında ver. Her alan için güven skoru da belirt."""

        return prompt


# Yardımcı fonksiyonlar
def image_to_base64(image_data: bytes) -> str:
    """Görüntüyü base64 formatına dönüştür"""
    return base64.b64encode(image_data).decode("utf-8")


def base64_to_image(base64_string: str) -> bytes:
    """Base64 stringi görüntü verisine dönüştür"""
    return base64.b64decode(base64_string)


# Göz bulguları için referans verileri
EYE_FINDINGS_REFERENCE = {
    "fundus": {
        "normal": [
            "Normal optik disk görünümü",
            "Normal C/D oranı",
            "Normal foveal refle",
            "Normal damar kalibresi",
        ],
        "abnormal": {
            "glaucoma": ["Artmış C/D oranı", "Nöroretinal rim incelmesi", "Disk hemorajisi"],
            "diabetic_retinopathy": [
                "Mikroanevrizma",
                "Dot-blot hemoraji",
                "Sert eksuda",
                "Cotton-wool spot",
            ],
            "amd": ["Drusen", "Pigment değişikliği", "Koroid neovaskülarizasyon"],
        },
    },
    "anterior": {
        "normal": [
            "Berrak kornea",
            "Derin ön kamara",
            "Normal pupilla",
            "Berrak lens",
        ],
        "abnormal": {
            "cataract": ["Lens opasitesi", "Nükleer skleroz", "Kortikal opasifikasyon"],
            "uveitis": ["Ön kamara hücresi", "Flare", "Keratik presipitat"],
        },
    },
}
