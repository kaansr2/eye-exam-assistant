/// Tıbbi terim tanıma ve düzeltme için yardımcı sınıf
/// Göz hastalıkları için özel terim listesi
/// 
/// Bu sınıf, ses tanıma ile elde edilen metinlerdeki tıbbi terimleri
/// standart formata dönüştürür ve değerleri çıkarır.
/// 
/// Kullanım örneği:
/// ```dart
/// String text = "göz içi basıncı 18 milimetre civa";
/// String corrected = MedicalTerms.correctText(text);
/// // corrected: "IOP: 18 mmHg"
/// 
/// Map<String, dynamic> values = MedicalTerms.extractValues(text);
/// // values: {'iop': 18}
/// ```
class MedicalTerms {
  /// Görme keskinliği terimleri
  static const Map<String, String> visionTerms = {
    'sıfır nokta bir': '0.1',
    'sıfır nokta iki': '0.2',
    'sıfır nokta üç': '0.3',
    'sıfır nokta dört': '0.4',
    'sıfır nokta beş': '0.5',
    'sıfır nokta altı': '0.6',
    'sıfır nokta yedi': '0.7',
    'sıfır nokta sekiz': '0.8',
    'sıfır nokta dokuz': '0.9',
    'bir': '1.0',
    'parmak sayma': 'PS',
    'el hareketi': 'EH',
    'ışık hissi': 'IH',
    'ışık hissi yok': 'IH(-)',
    'yirmi yirmi': '20/20',
    'yirmi yirmi beş': '20/25',
    'yirmi otuz': '20/30',
    'yirmi kırk': '20/40',
    'yirmi elli': '20/50',
    'yirmi altmış': '20/60',
    'yirmi yetmiş': '20/70',
    'yirmi seksen': '20/80',
    'yirmi yüz': '20/100',
    'yirmi iki yüz': '20/200',
  };

  /// Göz yapıları terimleri
  static const Map<String, String> eyeStructures = {
    'kornea': 'kornea',
    'kornya': 'kornea',
    'retina': 'retina',
    'makula': 'makula',
    'maküla': 'makula',
    'optik disk': 'optik disk',
    'vitreus': 'vitreus',
    'vitröz': 'vitreus',
    'konjonktiva': 'konjonktiva',
    'konjunktiva': 'konjonktiva',
    'iris': 'iris',
    'lens': 'lens',
    'pupilla': 'pupilla',
    'pupil': 'pupilla',
    'ön kamara': 'ön kamara',
    'ön segment': 'ön segment',
    'arka segment': 'arka segment',
    'fundus': 'fundus',
    'fovea': 'fovea',
    'koroid': 'koroid',
    'sklera': 'sklera',
  };

  /// Hastalık terimleri
  static const Map<String, String> diseases = {
    'katarakt': 'katarakt',
    'glokom': 'glokom',
    'glokoma': 'glokom',
    'keratit': 'keratit',
    'üveit': 'üveit',
    'uveit': 'üveit',
    'blefarit': 'blefarit',
    'konjonktivit': 'konjonktivit',
    'retinopatı': 'retinopati',
    'retinopati': 'retinopati',
    'diyabetik retinopati': 'diyabetik retinopati',
    'yme': 'YMD',
    'yaşa bağlı makula dejenerasyonu': 'YMD',
    'makula dejenerasyonu': 'makula dejenerasyonu',
    'pterigium': 'pterigium',
    'terijyum': 'pterigium',
    'şalazyon': 'şalazyon',
    'arpacık': 'hordeolum',
    'hordeolum': 'hordeolum',
    'drusen': 'drusen',
    'ödem': 'ödem',
    'hemoraji': 'hemoraji',
    'kanama': 'hemoraji',
    'infiltrat': 'infiltrat',
    'neovaskülarizasyon': 'neovaskülarizasyon',
  };

  /// Katarakt tipleri
  static const Map<String, String> cataractTypes = {
    'nükleer': 'nükleer',
    'nuklear': 'nükleer',
    'kortikal': 'kortikal',
    'subkapsüler': 'subkapsüler',
    'subkapsuler': 'subkapsüler',
    'psk': 'PSC',
    'psc': 'PSC',
    'posterior subkapsüler': 'PSC',
    'matur': 'matur',
    'hipermatur': 'hipermatur',
    'immatür': 'immatür',
  };

  /// Ölçüm terimleri
  static const Map<String, String> measurements = {
    'iop': 'IOP',
    'göz içi basıncı': 'IOP',
    'göz tansiyonu': 'IOP',
    'milimetre civa': 'mmHg',
    'mm civa': 'mmHg',
    'cup disk': 'C/D',
    'cd oranı': 'C/D',
    'c d oranı': 'C/D',
    'cup disk oranı': 'C/D oranı',
    'sferik': 'sph',
    'silindirik': 'cyl',
    'aks': 'axis',
    'diyoptri': 'D',
  };

  /// Göz lateralite terimleri
  static const Map<String, String> laterality = {
    'sağ göz': 'OD (Sağ Göz)',
    'sol göz': 'OS (Sol Göz)',
    'her iki göz': 'OU (Her İki Göz)',
    'od': 'OD',
    'os': 'OS',
    'ou': 'OU',
    'sağda': 'OD',
    'solda': 'OS',
    'bilateral': 'OU',
  };

  /// Derece ifadeleri
  static const Map<String, String> grades = {
    'bir artı': '+1',
    'iki artı': '+2',
    'üç artı': '+3',
    'dört artı': '+4',
    'hafif': 'hafif (+1)',
    'orta': 'orta (+2)',
    'şiddetli': 'şiddetli (+3)',
    'çok şiddetli': 'çok şiddetli (+4)',
    'grade bir': 'Grade 1',
    'grade iki': 'Grade 2',
    'grade üç': 'Grade 3',
    'grade dört': 'Grade 4',
  };

  /// Muayene bulguları
  static const Map<String, String> findings = {
    'normal': 'normal',
    'anormal': 'anormal',
    'doğal': 'doğal',
    'temiz': 'temiz',
    'berrak': 'berrak',
    'bulanık': 'bulanık',
    'opak': 'opak',
    'şeffaf': 'şeffaf',
    'düzgün': 'düzgün',
    'düzensiz': 'düzensiz',
    'santral': 'santral',
    'periferik': 'periferik',
    'yuvarlak': 'yuvarlak',
    'reaksiyon var': 'reaktif',
    'reaksiyon yok': 'areaktif',
    'izoreaktif': 'izoreaktif',
    'anizokori': 'anizokori',
  };

  /// Tüm terimleri birleştir
  static Map<String, String> get allTerms {
    return {
      ...visionTerms,
      ...eyeStructures,
      ...diseases,
      ...cataractTypes,
      ...measurements,
      ...laterality,
      ...grades,
      ...findings,
    };
  }

  // Pre-compiled regex patterns cache
  static final Map<String, RegExp> _compiledPatterns = {};

  /// Pre-compile regex patterns for better performance
  static RegExp _getPattern(String key) {
    return _compiledPatterns.putIfAbsent(
      key,
      () => RegExp(r'\b' + RegExp.escape(key) + r'\b', caseSensitive: false),
    );
  }

  /// Metni tıbbi terimlerle düzelt
  /// Performs efficient string replacement using pre-compiled regex patterns
  static String correctText(String text) {
    String corrected = text.toLowerCase();

    // Sort terms by length descending to match longer phrases first
    final sortedEntries = allTerms.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

    // Tıbbi terimleri düzelt using pre-compiled patterns
    for (final entry in sortedEntries) {
      final pattern = _getPattern(entry.key);
      corrected = corrected.replaceAllMapped(pattern, (match) => entry.value);
    }

    // Özel düzeltmeler
    corrected = _applySpecialCorrections(corrected);

    return corrected;
  }

  /// Özel düzeltmeler uygula
  static String _applySpecialCorrections(String text) {
    String corrected = text;

    // Sayı dönüşümleri
    corrected = corrected.replaceAllMapped(
      RegExp(r'(\d+)\s*milimetre\s*civa', caseSensitive: false),
      (match) => '${match.group(1)} mmHg',
    );

    // C/D oranı düzeltmesi
    corrected = corrected.replaceAllMapped(
      RegExp(r'(?:cup\s*disk|cd|c\s*d)\s*(?:oranı)?\s*(\d+)\s*(?:nokta|\.)\s*(\d+)', caseSensitive: false),
      (match) => 'C/D: ${match.group(1)}.${match.group(2)}',
    );

    // IOP düzeltmesi
    corrected = corrected.replaceAllMapped(
      RegExp(r'(?:iop|göz\s*içi\s*basınç[ıi]?|göz\s*tansiyon[u]?)\s*(\d+)', caseSensitive: false),
      (match) => 'IOP: ${match.group(1)} mmHg',
    );

    // Görme keskinliği düzeltmesi (ondalık)
    corrected = corrected.replaceAllMapped(
      RegExp(r'(?:görme\s*keskinliği|vizyon)\s*(\d+)\s*(?:nokta|\.)\s*(\d+)', caseSensitive: false),
      (match) => 'GK: ${match.group(1)}.${match.group(2)}',
    );

    return corrected;
  }

  /// Metinden tıbbi değerleri çıkar
  static Map<String, dynamic> extractValues(String text) {
    final Map<String, dynamic> values = {};
    final lowerText = text.toLowerCase();

    // Görme keskinliği (ondalık format)
    final visionDecimalPattern = RegExp(r'(?:görme\s*keskinliği|gk|vizyon)[:\s]*(\d+)[\.,](\d+)');
    final visionDecimalMatches = visionDecimalPattern.allMatches(lowerText);
    for (final match in visionDecimalMatches) {
      values['vision'] = '${match.group(1)}.${match.group(2)}';
    }

    // Görme keskinliği (Snellen format)
    final visionSnellenPattern = RegExp(r'(\d+)\s*[/üzerinden]\s*(\d+)');
    final visionSnellenMatches = visionSnellenPattern.allMatches(lowerText);
    for (final match in visionSnellenMatches) {
      values['vision_snellen'] = '${match.group(1)}/${match.group(2)}';
    }

    // IOP (Göz içi basıncı)
    final iopPattern = RegExp(r'(?:iop|göz\s*içi\s*basınç|tansiyon)[:\s]*(\d+)');
    final iopMatches = iopPattern.allMatches(lowerText);
    for (final match in iopMatches) {
      values['iop'] = int.tryParse(match.group(1) ?? '');
    }

    // C/D oranı
    final cdPattern = RegExp(r'(?:c/?d|cup\s*disk)[:\s]*(\d+)[\.,](\d+)');
    final cdMatches = cdPattern.allMatches(lowerText);
    for (final match in cdMatches) {
      values['cd_ratio'] = double.tryParse('${match.group(1)}.${match.group(2)}');
    }

    // Lateralite (Hangi göz)
    if (lowerText.contains('sağ göz') || lowerText.contains('od')) {
      values['eye'] = 'OD';
    } else if (lowerText.contains('sol göz') || lowerText.contains('os')) {
      values['eye'] = 'OS';
    } else if (lowerText.contains('her iki göz') || lowerText.contains('ou') || lowerText.contains('bilateral')) {
      values['eye'] = 'OU';
    }

    return values;
  }

  /// Sık kullanılan ifadeler için kısayollar
  static const Map<String, String> shortcuts = {
    'gk': 'Görme Keskinliği',
    'gibi': 'Göz İçi Basıncı',
    'fd': 'Fundus',
    'ks': 'Ön Segment',
    'as': 'Arka Segment',
    'ok': 'Ön Kamara',
    'od': 'Optik Disk',
    'dr': 'Diyabetik Retinopati',
    'ymd': 'Yaşa Bağlı Makula Dejenerasyonu',
  };
}
