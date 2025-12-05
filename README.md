# 🏥 Göz Muayene Asistanı

Doktorun hastayı muayene ederken sesli komutlarla hasta bilgilerini ve göz bulgularını kaydetmesini sağlayan, Gemini 2.5 Pro ile görüntü analizi yapan mobil uygulama ve backend sistemi.

## 📋 Proje Açıklaması

Bu uygulama, göz doktorlarının muayene sürecini hızlandırmak ve kolaylaştırmak için tasarlanmıştır. Temel özellikleri:

- **Sesli Kayıt**: Doktor konuşmasını gerçek zamanlı olarak metne dönüştürür
- **Akıllı Veri Çıkarımı**: NLP ile göz bulgularını otomatik olarak anamnez formuna eşler
- **Görüntü Analizi**: Gemini 2.5 Pro ile göz fotoğraflarını analiz eder
- **Hasta Geçmişi**: Tüm muayene kayıtlarını güvenli bir şekilde saklar

## 🛠 Teknoloji Stack'i

### Mobil Uygulama
- **Flutter** (Dart) - Cross-platform mobil geliştirme
- **Material Design 3** - Modern ve kullanıcı dostu arayüz
- **Provider** - State management

### Backend
- **Python 3.11+** - Backend geliştirme
- **FastAPI** - Modern, hızlı web framework
- **PostgreSQL** - İlişkisel veritabanı

### AI/ML
- **Google Gemini 2.5 Pro** - Görüntü analizi ve metin işleme
- **Google Cloud Speech-to-Text** - Ses tanıma

## 📁 Proje Yapısı

```
eye-exam-assistant/
├── README.md                    # Bu dosya
├── .gitignore                   # Git ignore kuralları
├── mobile/                      # Flutter mobil uygulaması
│   ├── lib/
│   │   ├── main.dart           # Uygulama giriş noktası
│   │   ├── config/             # Yapılandırma dosyaları
│   │   ├── models/             # Veri modelleri
│   │   ├── screens/            # Ekran widget'ları
│   │   ├── widgets/            # Yeniden kullanılabilir widget'lar
│   │   ├── services/           # API ve servis katmanları
│   │   └── utils/              # Yardımcı fonksiyonlar
│   └── assets/                 # Resimler ve diğer varlıklar
├── backend/                     # Python FastAPI backend
│   ├── main.py                 # API giriş noktası
│   ├── config/                 # Yapılandırma
│   ├── api/routes/             # API endpoint'leri
│   ├── models/                 # Veritabanı modelleri
│   ├── services/               # İş mantığı servisleri
│   └── utils/                  # Yardımcı fonksiyonlar
├── docs/                        # Dokümantasyon
│   ├── PROJECT_PLAN.md         # Proje yol haritası
│   └── ANAMNEZ_TEMPLATE.md     # Göz anamnez şablonu
└── database/                    # Veritabanı şemaları
```

## 🚀 Kurulum

### Gereksinimler

- Flutter SDK 3.16+
- Dart 3.2+
- Python 3.11+
- PostgreSQL 14+
- Google Cloud hesabı (Gemini API ve Speech-to-Text için)

### Mobil Uygulama Kurulumu

```bash
# Proje dizinine gidin
cd mobile

# Bağımlılıkları yükleyin
flutter pub get

# iOS için ek kurulum (macOS gerekli)
cd ios && pod install && cd ..

# Uygulamayı çalıştırın
flutter run
```

### Backend Kurulumu

```bash
# Backend dizinine gidin
cd backend

# Sanal ortam oluşturun
python -m venv venv

# Sanal ortamı aktifleştirin
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Bağımlılıkları yükleyin
pip install -r requirements.txt

# Ortam değişkenlerini ayarlayın
cp .env.example .env
# .env dosyasını düzenleyin

# Sunucuyu başlatın
uvicorn main:app --reload
```

### Ortam Değişkenleri

Backend için gerekli ortam değişkenleri:

```env
# Veritabanı
DATABASE_URL=postgresql://user:password@localhost:5432/eye_exam_db

# Google Cloud
GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account.json
GEMINI_API_KEY=your-gemini-api-key

# Uygulama
SECRET_KEY=your-secret-key
DEBUG=true
```

## 📱 Ekranlar

| Ekran | Açıklama |
|-------|----------|
| **Ana Ekran** | Yeni muayene başlatma ve son muayeneler listesi |
| **Hasta Arama** | TC/Ad ile hasta arama ve yeni hasta ekleme |
| **Ses Kayıt** | Doktor konuşmasını kaydetme ve transkripsiyon |
| **Kamera** | Sağ/sol göz fotoğrafı çekme |
| **Onay** | Muayene bilgilerini gözden geçirme ve onaylama |
| **Geçmiş** | Hasta muayene geçmişi görüntüleme |

## 🎨 UI/UX Prensipleri

- ✅ Doktor dostu büyük butonlar (minimum 48x48 dp)
- ✅ Minimal dikkat dağıtıcı unsur
- ✅ Kolay tek el kullanımı
- ✅ Yüksek kontrast renkler (tıbbi ortam için uygun)
- ✅ Anlaşılır ikonlar
- ✅ Hızlı erişim için gesture desteği
- ✅ Tablet uyumlu responsive tasarım

## 📚 Dokümantasyon

- [Proje Yol Haritası](docs/PROJECT_PLAN.md) - Geliştirme fazları ve zaman çizelgesi
- [Anamnez Şablonu](docs/ANAMNEZ_TEMPLATE.md) - Kapsamlı göz hastalıkları anamnez şablonu

## 🤝 Katkıda Bulunma

1. Bu repository'yi fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'feat: Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

### Commit Mesajı Kuralları

- `feat:` - Yeni özellik
- `fix:` - Hata düzeltmesi
- `docs:` - Dokümantasyon değişikliği
- `style:` - Kod formatı değişikliği
- `refactor:` - Kod yeniden yapılandırması
- `test:` - Test ekleme/düzenleme
- `chore:` - Genel bakım işleri

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 📞 İletişim

Sorularınız için issue açabilir veya pull request gönderebilirsiniz.

---

**Not**: Bu uygulama sadece doktor yardımcısı olarak tasarlanmıştır. Tüm AI önerileri doktor onayına tabidir ve kesin tanı/tedavi kararları doktor tarafından verilmelidir.
