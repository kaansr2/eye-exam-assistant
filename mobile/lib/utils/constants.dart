/// Uygulama sabitleri
class Constants {
  // API Endpoint'leri
  static const String patientsEndpoint = '/patients';
  static const String examinationsEndpoint = '/examinations';
  static const String analysisEndpoint = '/analysis';
  static const String speechEndpoint = '/speech';
  
  // Hata mesajları
  static const String networkError = 'İnternet bağlantısı kurulamadı. Lütfen bağlantınızı kontrol edin.';
  static const String serverError = 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.';
  static const String unknownError = 'Beklenmeyen bir hata oluştu.';
  static const String permissionDenied = 'İzin reddedildi. Lütfen ayarlardan izin verin.';
  static const String microphonePermission = 'Ses kaydı için mikrofon izni gereklidir.';
  static const String cameraPermission = 'Fotoğraf çekmek için kamera izni gereklidir.';
  
  // Başarı mesajları
  static const String saveSuccess = 'Kayıt başarıyla oluşturuldu.';
  static const String updateSuccess = 'Güncelleme başarılı.';
  static const String deleteSuccess = 'Silme işlemi başarılı.';
  
  // Onay mesajları
  static const String confirmDelete = 'Bu kaydı silmek istediğinizden emin misiniz?';
  static const String confirmExit = 'Kaydedilmemiş değişiklikler kaybolacak. Çıkmak istediğinizden emin misiniz?';
  
  // Placeholder metinler
  static const String searchPatientHint = 'TC Kimlik No veya Ad Soyad ile arayın...';
  static const String noPatientFound = 'Hasta bulunamadı.';
  static const String noExaminationFound = 'Muayene kaydı bulunamadı.';
  static const String noRecordingYet = 'Henüz ses kaydı yapılmadı.';
  
  // Buton metinleri
  static const String startRecording = 'Kayda Başla';
  static const String stopRecording = 'Kaydı Durdur';
  static const String takePhoto = 'Fotoğraf Çek';
  static const String save = 'Kaydet';
  static const String cancel = 'İptal';
  static const String confirm = 'Onayla';
  static const String edit = 'Düzenle';
  static const String delete = 'Sil';
  static const String next = 'İleri';
  static const String back = 'Geri';
  static const String newExamination = 'Yeni Muayene Başlat';
  static const String searchPatient = 'Hasta Ara';
  static const String addPatient = 'Yeni Hasta Ekle';
  static const String viewHistory = 'Geçmiş Muayeneler';
  
  // Göz seçenekleri
  static const String rightEye = 'Sağ Göz (OD)';
  static const String leftEye = 'Sol Göz (OS)';
  static const String bothEyes = 'Her İki Göz (OU)';
  
  // Cinsiyet seçenekleri
  static const String male = 'Erkek';
  static const String female = 'Kadın';
  
  // Tarih formatları
  static const String dateFormat = 'dd.MM.yyyy';
  static const String dateTimeFormat = 'dd.MM.yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  
  // Yaygın göz şikayetleri
  static const List<String> commonComplaints = [
    'Görmede azalma',
    'Bulanık görme',
    'Çift görme',
    'Kızarıklık',
    'Ağrı',
    'Kaşıntı',
    'Sulanma',
    'Batma hissi',
    'Işık çakması',
    'Uçuşan cisimler',
    'Işığa hassasiyet',
    'Yanma',
    'Kuruluk',
    'Şişlik',
    'Kabuklanma',
    'Akıntı',
    'Görme alanı kaybı',
  ];
  
  // Katarakt tipleri
  static const List<String> cataractTypes = [
    'Nükleer',
    'Kortikal',
    'Posterior Subkapsüler (PSC)',
    'Matur',
    'Hipermatur',
  ];
  
  // Katarakt dereceleri
  static const List<String> cataractGrades = [
    '+',
    '++',
    '+++',
    '++++',
  ];
  
  // IOP ölçüm yöntemleri
  static const List<String> iopMethods = [
    'Goldmann Applanasyon',
    'Non-contact (Havalı)',
    'Tonopen',
    'iCare',
    'Palpasyon',
  ];
}
