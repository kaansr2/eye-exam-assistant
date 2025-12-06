# 📱 Göz Muayene Asistanı - Mobil Uygulama

Bu mobil uygulama, göz doktorlarının muayene sırasında sesli kayıt ve AI destekli analiz yapabilmelerini sağlar.

## 🚀 Faz 4 Güncellemeleri

### ✅ Düzeltilen Sorunlar

#### 1. Gemini API Yapılandırması (.env Desteği)
- ✅ `flutter_dotenv` paketi eklendi
- ✅ `.env` dosya desteği eklendi
- ✅ Demo mod: API key olmadan da çalışabilir
- ✅ `.env.example` referans dosyası oluşturuldu

**Kullanım:**
1. `.env.example` dosyasını proje kök dizinine `.env` olarak kopyalayın
2. `GEMINI_API_KEY=your_actual_key` şeklinde API key'inizi ekleyin
3. Uygulamayı yeniden başlatın

**Önemli:** `.env` dosyası uygulama paketine (APK) dahil edilmez, sadece geliştirme sırasında kullanılır. Production'da environment variables veya secure storage kullanın.

**Demo Mod:** API key yoksa uygulama demo modda çalışır, AI analiz fonksiyonları örnek yanıt döndürür.

#### 2. Transcript Parser İyileştirmeleri
- ✅ Türkçe tıbbi terimler için güçlendirilmiş regex desenleri
- ✅ Çoklu varyasyon desteği:
  - Görme keskinliği: "sağ göz", "OD", "sağda", "vizyon", "VA"
  - Basınç: "basınç", "tansiyon", "IOP", "göz içi basıncı"
- ✅ Tıbbi durumlar: katarakt, glokom, miyopi, hipermetropi, astigmatizma
- ✅ Parsed bulgular UI'a otomatik aktarılıyor

#### 3. Muayene Detay Ekranı
- ✅ `examination_detail_screen.dart` oluşturuldu
- ✅ Ana ekrandan geçmiş muayenelere tıklayınca detay açılıyor
- ✅ Tüm muayene verileri görüntüleniyor
- ✅ Göz fotoğrafları büyütülebilir

#### 4. Kamera Ekranı İyileştirmeleri
- ✅ İki ayrı buton:
  - 📷 **Kamera ile Çek** - Telefon kamerasını açar
  - 📁 **Cihazdan Aktar** - Galeri/dosya yöneticisini açar
- ✅ **Fotoğrafsız Devam Et** butonu eklendi
- ✅ Fotoğraflar artık opsiyonel
- ✅ AppBar'da "Atla" butonu her zaman görünür

#### 5. Review Screen Görüntü Desteği
- ✅ `dart:io` kullanılarak mobil uyumlu dosya işleme
- ✅ `Image.file()` ile doğrudan görüntü gösterimi
- ✅ Hata kontrolü ile güvenli görüntü yükleme

#### 6. Türkçe STT İyileştirmeleri
- ✅ Locale: `tr-TR` doğru şekilde ayarlanmış
- ✅ Dinleme süresi: 300 saniye (5 dakika)
- ✅ Partial results: Aktif
- ✅ Dictation mode: Uzun konuşmalar için optimize

## 🛠️ Kurulum

### Gereksinimler
- Flutter SDK 3.2.0+
- Dart SDK 3.0+
- Android Studio / Xcode
- Mikrofon ve kamera izinleri

### Adımlar

1. **Bağımlılıkları yükleyin:**
```bash
cd mobile
flutter pub get
```

2. **API Key ayarlayın (opsiyonel - sadece geliştirme için):**
```bash
# .env dosyası sadece geliştirme için kullanılır
cp .env.example .env
# .env dosyasını düzenleyin ve API key'inizi ekleyin
```

**Not:** Production'da `.env` dosyası kullanılmaz. API key'i `--dart-define` ile build sırasında veya secure storage ile runtime'da sağlayın.

3. **Uygulamayı çalıştırın:**
```bash
# Debug modda
flutter run

# Release APK oluşturun
flutter build apk --release

# API key ile build
flutter build apk --release --dart-define=GEMINI_API_KEY=your_key
```

## 📋 Test Senaryoları

### ✅ Test 1: Kamera İşlevleri
1. Yeni muayene başlat
2. Ses kaydı yap
3. Kamera ekranına gel
4. "📷 Kamera ile Çek" butonuna bas → Kamera açılmalı
5. "📁 Cihazdan Aktar" butonuna bas → Galeri açılmalı
6. "Fotoğrafsız Devam Et" → Muayene devam etmeli

### ✅ Test 2: Ses Tanıma
1. Mikrofon butonuna bas
2. Türkçe konuş: "Sağ göz sıfır yedi, sol göz sıfır sekiz"
3. Durdur
4. Review ekranında görme keskinliği değerleri görünmeli

### ✅ Test 3: AI Analizi
**API Key varsa:**
- Analiz butonu AI sonucu göstermeli

**API Key yoksa:**
- Demo analiz mesajı göstermeli
- Uygulama çökme yaşamamalı

### ✅ Test 4: Muayene Geçmişi
1. Ana ekranda geçmiş muayeneyi gör
2. Tıkla
3. Detay ekranı açılmalı
4. Tüm bilgiler görünmeli

## 🔧 Yapılandırma

### app_config.dart
```dart
static const String speechLocale = 'tr-TR';
static const int maxRecordingDurationSeconds = 300; // 5 dakika
```

### İzinler (Android)
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### İzinler (iOS)
```xml
<!-- ios/Runner/Info.plist -->
<key>NSCameraUsageDescription</key>
<string>Göz fotoğrafı çekmek için kamera erişimi gereklidir</string>
<key>NSMicrophoneUsageDescription</key>
<string>Muayene kaydı için mikrofon erişimi gereklidir</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Göz fotoğraflarını kaydetmek için galeri erişimi gereklidir</string>
```

## 📱 APK Build

### Development Build
```bash
flutter build apk --debug
```

### Release Build (API key ile)
```bash
flutter build apk --release --dart-define=GEMINI_API_KEY=your_gemini_key
```

### Release Build (.env ile)
```bash
# .env dosyasını ayarladıktan sonra
flutter build apk --release
```

APK dosyası: `build/app/outputs/flutter-apk/app-release.apk`

## 🐛 Bilinen Sorunlar ve Çözümler

### Sorun: "Unsupported operation: _Namespace"
**Çözüm:** ✅ Düzeltildi - `dart:io` kullanılarak mobil uyumlu hale getirildi

### Sorun: API key yapılandırılmadı uyarısı
**Çözüm:** ✅ Demo mod eklendi - API key olmadan da çalışır

### Sorun: Transcript bulguları UI'a aktarılmıyor
**Çözüm:** ✅ Parser güçlendirildi ve bağlantı doğrulandı

### Sorun: Muayene geçmişine tıklanmıyor
**Çözüm:** ✅ Detay ekranı eklendi

## 📚 Ek Kaynaklar

- [Flutter Documentation](https://flutter.dev/docs)
- [Google Generative AI](https://ai.google.dev/)
- [Speech to Text Plugin](https://pub.dev/packages/speech_to_text)
- [Image Picker Plugin](https://pub.dev/packages/image_picker)

## 📝 Notlar

- Mobil uygulama için optimize edilmiştir (APK)
- Web platformu desteklenmemektedir
- API key opsiyoneldir, demo modda çalışabilir
- Fotoğraflar opsiyoneldir
- Türkçe STT optimize edilmiştir

## 🔐 Güvenlik

- `.env` dosyası Git'e eklenmez (`.gitignore`'da)
- API keys asla commit edilmez
- Hassas hasta verileri lokal olarak saklanır
