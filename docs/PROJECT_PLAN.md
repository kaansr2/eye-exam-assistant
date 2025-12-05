# Göz Muayene Asistanı - Proje Yol Haritası

## Proje Genel Bakış

Bu belge, Göz Muayene Asistanı projesinin geliştirme fazlarını ve zaman çizelgesini içermektedir.

## Teknoloji Stack'i

- **Mobil Uygulama**: Flutter (Dart)
- **Backend**: Python FastAPI
- **Veritabanı**: PostgreSQL
- **AI/ML**: Google Gemini 2.5 Pro
- **Speech-to-Text**: Google Cloud Speech API

---

## Faz 1: Temel Altyapı (Hafta 1-2)

### Hedefler
- [x] Proje yapısının oluşturulması
- [ ] Backend iskelet yapısının kurulması
- [ ] Veritabanı şemasının tasarlanması
- [ ] Mobil uygulama iskeletinin oluşturulması

### Görevler

#### 1.1 Proje Yapısı
- Repository düzenlenmesi
- README ve dokümantasyon
- Gitignore ve linting kuralları

#### 1.2 Backend İskelet
- FastAPI kurulumu
- Proje klasör yapısı
- Temel endpoint'ler
- CORS ve güvenlik ayarları

#### 1.3 Veritabanı Şeması
- Hasta tablosu
- Muayene tablosu
- Görüntü kayıtları tablosu
- AI analiz sonuçları tablosu

#### 1.4 Mobil İskelet
- Flutter proje oluşturma
- Temel ekran yapıları
- Routing sistemi
- State management kurulumu

### Çıktılar
- Çalışan boş Flutter uygulaması
- Çalışan FastAPI sunucusu
- Veritabanı bağlantısı

---

## Faz 2: Ses → Yazı Dönüşümü (Hafta 2-3)

### Hedefler
- [ ] Ses kayıt modülünün geliştirilmesi
- [ ] Speech-to-Text API entegrasyonu
- [ ] Gerçek zamanlı transkripsiyon
- [ ] Tıbbi terim tanıma desteği

### Görevler

#### 2.1 Ses Kayıt Modülü
- Mikrofon izin yönetimi
- Ses kayıt başlatma/durdurma
- Ses dosyası formatı (WAV/MP3)
- Kayıt kalitesi ayarları

#### 2.2 Speech-to-Text Entegrasyonu
- Google Cloud Speech API kurulumu
- Türkçe dil desteği
- Streaming vs batch transkripsiyon
- Hata yönetimi

#### 2.3 Gerçek Zamanlı Transkripsiyon
- WebSocket bağlantısı
- UI'da canlı metin gösterimi
- Konuşma segmentasyonu

#### 2.4 Tıbbi Terim Tanıma
- Özel göz terimleri sözlüğü
- Terim düzeltme algoritması
- Bağlam bazlı düzeltme

### Çıktılar
- Çalışan ses kayıt ekranı
- Transkripsiyon sonuçları
- Tıbbi terim düzeltmeleri

---

## Faz 3: Akıllı Veri Çıkarımı (Hafta 3-4)

### Hedefler
- [ ] NLP ile göz bulguları ayıklama
- [ ] Şikayet kategorilendirme
- [ ] Derece/ölçüm parse etme
- [ ] Anamnez formu otomatik doldurma

### Görevler

#### 3.1 NLP Modülü
- Gemini API ile metin analizi
- Entity extraction (bulgular)
- İlişki çıkarımı (organ-bulgu)

#### 3.2 Şikayet Kategorilendirme
- Şikayet listesi tanımlama
- Sınıflandırma algoritması
- Güven skoru hesaplama

#### 3.3 Ölçüm Çıkarımı
- Görme keskinliği parse (20/20, 10/10)
- Göz içi basıncı (mmHg)
- Refraksiyon değerleri (sfer, silindir, aks)
- C/D oranı

#### 3.4 Form Doldurma
- Anamnez alanlarına eşleme
- Eksik bilgi tespiti
- Çakışma kontrolü

### Çıktılar
- Otomatik doldurulmuş anamnez formu
- Güven skorları
- Eksik bilgi uyarıları

---

## Faz 4: Görüntü Analizi (Hafta 4-5)

### Hedefler
- [ ] Kamera modülünün geliştirilmesi
- [ ] Gemini Vision API entegrasyonu
- [ ] AI analiz sonuçlarının gösterimi
- [ ] Görüntü karşılaştırma özelliği

### Görevler

#### 4.1 Kamera Modülü
- Kamera izin yönetimi
- Sağ/Sol göz seçimi
- Görüntü kalitesi kontrolleri
- Flash/zoom ayarları

#### 4.2 Gemini Vision Entegrasyonu
- API bağlantısı
- Görüntü ön işleme
- Prompt engineering
- Sonuç parsing

#### 4.3 AI Analiz Özellikleri
- Retina analizi
- Katarakt tespiti
- Glokom belirtileri
- Maküler değişiklikler
- Diabetik retinopati

#### 4.4 Sonuç Gösterimi
- Analiz sonuç kartları
- Güven skorları
- İşaretlenmiş görüntüler
- Öneri listesi

### Çıktılar
- Çalışan kamera ekranı
- AI analiz raporları
- Görsel bulgular

---

## Faz 5: Doktor Onay & Kayıt (Hafta 5-6)

### Hedefler
- [ ] Özet ekranı geliştirme
- [ ] Düzenleme/onay mekanizması
- [ ] Veritabanına kayıt
- [ ] Hasta geçmişi görüntüleme

### Görevler

#### 5.1 Özet Ekranı
- Tüm bilgilerin gösterimi
- Bölüm bazlı görünüm
- Yazdırılabilir format

#### 5.2 Düzenleme Mekanizması
- Inline düzenleme
- Toplu düzenleme
- Değişiklik geçmişi

#### 5.3 Onay Sistemi
- Doktor imzası
- Dijital onay
- Düzenleme kilitleme

#### 5.4 Veritabanı Kaydı
- Muayene kaydetme
- Görüntü saklama
- AI sonuçları saklama

#### 5.5 Hasta Geçmişi
- Geçmiş muayene listesi
- Karşılaştırma özelliği
- Trend analizi

### Çıktılar
- Tam fonksiyonel onay ekranı
- Veritabanı kayıtları
- Hasta geçmişi görünümü

---

## Faz 6: Test & Optimizasyon (Hafta 6-7)

### Hedefler
- [ ] UI/UX iyileştirmeleri
- [ ] Hata yönetimi
- [ ] Test senaryoları
- [ ] Performans optimizasyonu

### Görevler

#### 6.1 UI/UX İyileştirmeleri
- Kullanıcı geri bildirimleri
- Erişilebilirlik kontrolleri
- Responsive tasarım
- Animasyonlar

#### 6.2 Hata Yönetimi
- Global error handling
- Kullanıcı dostu hata mesajları
- Offline mod desteği
- Yeniden deneme mekanizması

#### 6.3 Test Senaryoları
- Unit testler
- Widget testler
- Integration testler
- End-to-end testler

#### 6.4 Performans
- API yanıt süreleri
- Görüntü sıkıştırma
- Cache stratejileri
- Memory yönetimi

### Çıktılar
- Optimize edilmiş uygulama
- Test raporları
- Performans metrikleri

---

## Başarı Kriterleri

### Fonksiyonel Kriterler
- [ ] Ses kaydı %95+ doğrulukla transkribe edilebilmeli
- [ ] AI analizi %90+ doğrulukla bulgu tespit etmeli
- [ ] Muayene süresi %30 kısalmalı
- [ ] Tüm veriler güvenli şekilde saklanmalı

### Teknik Kriterler
- [ ] API yanıt süresi < 2 saniye
- [ ] Uygulama açılış süresi < 3 saniye
- [ ] %99.9 uptime
- [ ] Mobile responsive tasarım

### Kullanıcı Deneyimi Kriterleri
- [ ] Tek el kullanımı mümkün olmalı
- [ ] Minimum öğrenme eğrisi
- [ ] Doktor memnuniyeti > %85

---

## Risk Analizi

| Risk | Olasılık | Etki | Önlem |
|------|----------|------|-------|
| Speech API doğruluk sorunu | Orta | Yüksek | Özel tıbbi sözlük, manuel düzeltme |
| Gemini API kesintisi | Düşük | Yüksek | Offline mod, cache |
| Veri güvenliği ihlali | Düşük | Kritik | Şifreleme, erişim kontrolü |
| Performans sorunları | Orta | Orta | Optimizasyon, CDN |

---

## Ekip ve Sorumluluklar

| Rol | Sorumluluk |
|-----|------------|
| Mobil Geliştirici | Flutter uygulaması |
| Backend Geliştirici | FastAPI, veritabanı |
| AI/ML Mühendisi | Gemini entegrasyonu, NLP |
| UI/UX Tasarımcı | Arayüz tasarımı |
| QA Mühendisi | Test ve kalite kontrolü |

---

## Sürüm Planı

| Sürüm | Tarih | İçerik |
|-------|-------|--------|
| v0.1.0 | Hafta 2 | Temel iskelet |
| v0.2.0 | Hafta 3 | Ses kayıt özelliği |
| v0.3.0 | Hafta 4 | NLP entegrasyonu |
| v0.4.0 | Hafta 5 | Görüntü analizi |
| v0.5.0 | Hafta 6 | Tam fonksiyonel MVP |
| v1.0.0 | Hafta 7 | Production-ready sürüm |
