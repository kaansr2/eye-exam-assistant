/// Hasta veri modeli
class Patient {
  final String? id;
  final String tcKimlikNo;
  final String adSoyad;
  final DateTime dogumTarihi;
  final String cinsiyet;
  final String? telefon;
  final String? email;
  final String? adres;
  final DateTime? olusturmaTarihi;
  final DateTime? guncellemeTarihi;

  Patient({
    this.id,
    required this.tcKimlikNo,
    required this.adSoyad,
    required this.dogumTarihi,
    required this.cinsiyet,
    this.telefon,
    this.email,
    this.adres,
    this.olusturmaTarihi,
    this.guncellemeTarihi,
  });

  /// Yaş hesaplama
  int get yas {
    final now = DateTime.now();
    int age = now.year - dogumTarihi.year;
    if (now.month < dogumTarihi.month ||
        (now.month == dogumTarihi.month && now.day < dogumTarihi.day)) {
      age--;
    }
    return age;
  }

  /// JSON'dan Patient oluşturma
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String?,
      tcKimlikNo: json['tc_kimlik_no'] as String,
      adSoyad: json['ad_soyad'] as String,
      dogumTarihi: DateTime.parse(json['dogum_tarihi'] as String),
      cinsiyet: json['cinsiyet'] as String,
      telefon: json['telefon'] as String?,
      email: json['email'] as String?,
      adres: json['adres'] as String?,
      olusturmaTarihi: json['olusturma_tarihi'] != null
          ? DateTime.parse(json['olusturma_tarihi'] as String)
          : null,
      guncellemeTarihi: json['guncelleme_tarihi'] != null
          ? DateTime.parse(json['guncelleme_tarihi'] as String)
          : null,
    );
  }

  /// Patient'ı JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'tc_kimlik_no': tcKimlikNo,
      'ad_soyad': adSoyad,
      'dogum_tarihi': dogumTarihi.toIso8601String().split('T')[0],
      'cinsiyet': cinsiyet,
      if (telefon != null) 'telefon': telefon,
      if (email != null) 'email': email,
      if (adres != null) 'adres': adres,
    };
  }

  /// Kopyalama metodu
  Patient copyWith({
    String? id,
    String? tcKimlikNo,
    String? adSoyad,
    DateTime? dogumTarihi,
    String? cinsiyet,
    String? telefon,
    String? email,
    String? adres,
  }) {
    return Patient(
      id: id ?? this.id,
      tcKimlikNo: tcKimlikNo ?? this.tcKimlikNo,
      adSoyad: adSoyad ?? this.adSoyad,
      dogumTarihi: dogumTarihi ?? this.dogumTarihi,
      cinsiyet: cinsiyet ?? this.cinsiyet,
      telefon: telefon ?? this.telefon,
      email: email ?? this.email,
      adres: adres ?? this.adres,
      olusturmaTarihi: olusturmaTarihi,
      guncellemeTarihi: guncellemeTarihi,
    );
  }

  @override
  String toString() {
    return 'Patient(id: $id, tcKimlikNo: $tcKimlikNo, adSoyad: $adSoyad, yas: $yas)';
  }
}
