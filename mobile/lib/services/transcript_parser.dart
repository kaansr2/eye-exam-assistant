import 'dart:core';

/// Service for parsing speech transcript into structured medical data
/// Extracts medical findings from Turkish speech text
class TranscriptParser {
  // Regex patterns for vision acuity
  static final _rightVisionPatterns = [
    RegExp(r'sağ\s*göz(?:\s*görme\s*keskinliği)?[:\s]*(\d+[.,]\d+)', caseSensitive: false),
    RegExp(r'(?:od|o\.?d\.?)[:\s]*(\d+[.,]\d+)', caseSensitive: false),
    RegExp(r'görme\s*keskinliği\s*sağ[:\s]*(\d+[.,]\d+)', caseSensitive: false),
    RegExp(r'sağda[:\s]*(\d+[.,]\d+)', caseSensitive: false),
    RegExp(r'(?:vizyon|va)\s*(?:sağ|od)[:\s]*(\d+[.,]\d+)', caseSensitive: false),
    RegExp(r'sağ[:\s]*(?:göz)?[:\s]*(\d+[.,]\d+)', caseSensitive: false),
  ];

  static final _leftVisionPatterns = [
    RegExp(r'sol\s*göz(?:\s*görme\s*keskinliği)?[:\s]*(\d+[.,]\d+)', caseSensitive: false),
    RegExp(r'(?:os|o\.?s\.?)[:\s]*(\d+[.,]\d+)', caseSensitive: false),
    RegExp(r'görme\s*keskinliği\s*sol[:\s]*(\d+[.,]\d+)', caseSensitive: false),
    RegExp(r'solda[:\s]*(\d+[.,]\d+)', caseSensitive: false),
    RegExp(r'(?:vizyon|va)\s*(?:sol|os)[:\s]*(\d+[.,]\d+)', caseSensitive: false),
    RegExp(r'sol[:\s]*(?:göz)?[:\s]*(\d+[.,]\d+)', caseSensitive: false),
  ];

  // Regex patterns for IOP
  static final _iopCombinedPatterns = [
    RegExp(r'(?:göz\s*içi\s*basıncı|basınç|iop|tansiyon).*?sağ(?:da)?[:\s]*(\d+).*?sol(?:da)?[:\s]*(\d+)', caseSensitive: false),
    RegExp(r'(?:basınç|iop|tansiyon)[:\s]*(\d+)\s*[/\\]\s*(\d+)', caseSensitive: false),
  ];

  static final _rightIopPatterns = [
    RegExp(r'(?:sağ|od).*?(?:basınç|iop|tansiyon)[:\s]*(\d+)', caseSensitive: false),
    RegExp(r'(?:basınç|iop|tansiyon).*?(?:sağ|od)[:\s]*(\d+)', caseSensitive: false),
    RegExp(r'sağda.*?(\d+)(?:\s*mmhg)?', caseSensitive: false),
  ];

  static final _leftIopPatterns = [
    RegExp(r'(?:sol|os).*?(?:basınç|iop|tansiyon)[:\s]*(\d+)', caseSensitive: false),
    RegExp(r'(?:basınç|iop|tansiyon).*?(?:sol|os)[:\s]*(\d+)', caseSensitive: false),
    RegExp(r'solda.*?(\d+)(?:\s*mmhg)?', caseSensitive: false),
  ];

  // Regex patterns for medical conditions
  static final _medicalConditionPatterns = {
    'katarakt': RegExp(r'katarakt', caseSensitive: false),
    'glokom': RegExp(r'glokom', caseSensitive: false),
    'miyopi': RegExp(r'miyop|miyopi', caseSensitive: false),
    'hipermetropi': RegExp(r'hipermetrop|hipermetropi', caseSensitive: false),
    'astigmatizma': RegExp(r'astigmat', caseSensitive: false),
    'retinopati': RegExp(r'retinopati', caseSensitive: false),
    'makula': RegExp(r'maküla|makula', caseSensitive: false),
  };

  // Regex patterns for complaints
  static final _complaintPatterns = {
    'bulanık_görme': RegExp(r'bulanık\s*görme|bulanıklık', caseSensitive: false),
    'ağrı': RegExp(r'ağrı|acı', caseSensitive: false),
    'kızarıklık': RegExp(r'kızarıklık|kırmızı', caseSensitive: false),
    'kaşıntı': RegExp(r'kaşıntı|kaşın', caseSensitive: false),
    'sulanma': RegExp(r'sulanma|yaşarma', caseSensitive: false),
    'yanma': RegExp(r'yanma', caseSensitive: false),
  };

  /// Parse transcript into structured findings
  static Map<String, dynamic> parse(String transcript) {
    if (transcript.isEmpty) return {};

    final findings = <String, dynamic>{};
    final lowerText = transcript.toLowerCase();

    // Parse Görme Keskinliği (Visual Acuity)
    findings.addAll(_parseVisionAcuity(lowerText));

    // Parse Göz İçi Basıncı (Intraocular Pressure - IOP)
    findings.addAll(_parseIOP(lowerText));

    // Parse Ön Segment (Anterior Segment)
    findings.addAll(_parseAnteriorSegment(lowerText));

    // Parse Fundus/Arka Segment
    findings.addAll(_parsePosteriorSegment(lowerText));

    // Parse Şikayet (Complaint)
    findings.addAll(_parseComplaint(lowerText));

    return findings;
  }

  /// Parse vision acuity values
  static Map<String, dynamic> _parseVisionAcuity(String text) {
    final findings = <String, dynamic>{};

    // Patterns for right eye (sağ göz, OD)
    for (final pattern in _rightVisionPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        findings['gorme_keskinligi_od'] = match.group(1)?.replaceAll(',', '.');
        break;
      }
    }

    // Patterns for left eye (sol göz, OS)
    for (final pattern in _leftVisionPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        findings['gorme_keskinligi_os'] = match.group(1)?.replaceAll(',', '.');
        break;
      }
    }

    return findings;
  }

  /// Parse intraocular pressure (IOP)
  static Map<String, dynamic> _parseIOP(String text) {
    final findings = <String, dynamic>{};

    // Patterns for IOP - combined (both eyes)
    for (final pattern in _iopCombinedPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        findings['iop_od'] = '${match.group(1)} mmHg';
        findings['iop_os'] = '${match.group(2)} mmHg';
        return findings;
      }
    }

    // Individual patterns - right eye
    for (final pattern in _rightIopPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        findings['iop_od'] = '${match.group(1)} mmHg';
        break;
      }
    }

    // Individual patterns - left eye
    for (final pattern in _leftIopPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        findings['iop_os'] = '${match.group(1)} mmHg';
        break;
      }
    }

    return findings;
  }

  /// Parse anterior segment findings
  static Map<String, dynamic> _parseAnteriorSegment(String text) {
    final findings = <String, dynamic>{};

    // Kornea
    if (text.contains(RegExp(r'kornea\s*(?:temiz|normal|berrak)', caseSensitive: false))) {
      findings['kornea'] = 'Normal, temiz';
    } else if (text.contains(RegExp(r'kornea.*?(?:ödem|bulanık|lezyon)', caseSensitive: false))) {
      final match = RegExp(r'kornea[:\s]*([^.]+)', caseSensitive: false).firstMatch(text);
      if (match != null) {
        findings['kornea'] = match.group(1)?.trim();
      }
    }

    // Ön Segment genel
    if (text.contains(RegExp(r'(?:ön\s*segment|on\s*segment)\s*(?:normal|doğal)', caseSensitive: false))) {
      findings['on_segment'] = 'Normal';
    } else if (text.contains(RegExp(r'(?:ön\s*segment|on\s*segment)', caseSensitive: false))) {
      final match = RegExp(r'(?:ön\s*segment|on\s*segment)[:\s]*([^.]+)', caseSensitive: false).firstMatch(text);
      if (match != null) {
        findings['on_segment'] = match.group(1)?.trim();
      }
    }

    return findings;
  }

  /// Parse posterior segment (fundus) findings
  static Map<String, dynamic> _parsePosteriorSegment(String text) {
    final findings = <String, dynamic>{};

    // Fundus
    if (text.contains(RegExp(r'fundus\s*(?:normal|doğal)', caseSensitive: false))) {
      findings['fundus'] = 'Normal';
    } else if (text.contains('fundus')) {
      final match = RegExp(r'fundus[:\s]*([^.]+)', caseSensitive: false).firstMatch(text);
      if (match != null) {
        findings['fundus'] = match.group(1)?.trim();
      }
    }

    // Retina
    if (text.contains(RegExp(r'retina\s*(?:normal|doğal)', caseSensitive: false))) {
      findings['retina'] = 'Normal';
    } else if (text.contains('retina')) {
      final match = RegExp(r'retina[:\s]*([^.]+)', caseSensitive: false).firstMatch(text);
      if (match != null) {
        findings['retina'] = match.group(1)?.trim();
      }
    }

    return findings;
  }

  /// Parse complaint/symptoms
  static Map<String, dynamic> _parseComplaint(String text) {
    final findings = <String, dynamic>{};

    // Common complaints
    final complaints = <String>[];

    if (_complaintPatterns['bulanık_görme']!.hasMatch(text)) {
      complaints.add('Bulanık görme');
    }
    if (_complaintPatterns['ağrı']!.hasMatch(text)) {
      complaints.add('Göz ağrısı');
    }
    if (_complaintPatterns['kızarıklık']!.hasMatch(text)) {
      complaints.add('Göz kızarıklığı');
    }
    if (_complaintPatterns['kaşıntı']!.hasMatch(text)) {
      complaints.add('Kaşıntı');
    }
    if (_complaintPatterns['sulanma']!.hasMatch(text)) {
      complaints.add('Göz sulanması');
    }
    if (_complaintPatterns['yanma']!.hasMatch(text)) {
      complaints.add('Yanma hissi');
    }

    if (complaints.isNotEmpty) {
      findings['sikayet'] = complaints.join(', ');
    }

    // Medical conditions/diagnoses
    final conditions = <String>[];
    
    if (_medicalConditionPatterns['katarakt']!.hasMatch(text)) {
      conditions.add('Katarakt şüphesi');
    }
    if (_medicalConditionPatterns['glokom']!.hasMatch(text)) {
      conditions.add('Glokom şüphesi');
    }
    if (_medicalConditionPatterns['miyopi']!.hasMatch(text)) {
      conditions.add('Miyopi');
    }
    if (_medicalConditionPatterns['hipermetropi']!.hasMatch(text)) {
      conditions.add('Hipermetropi');
    }
    if (_medicalConditionPatterns['astigmatizma']!.hasMatch(text)) {
      conditions.add('Astigmatizma');
    }
    if (_medicalConditionPatterns['retinopati']!.hasMatch(text)) {
      conditions.add('Retinopati');
    }
    if (_medicalConditionPatterns['makula']!.hasMatch(text)) {
      conditions.add('Makula ile ilgili bulgu');
    }
    
    if (conditions.isNotEmpty) {
      findings['olasiliklar'] = conditions.join(', ');
    }

    return findings;
  }

  /// Get a summary of extracted findings
  static String getSummary(Map<String, dynamic> findings) {
    if (findings.isEmpty) return 'Bulgu tespit edilemedi';

    final parts = <String>[];

    if (findings.containsKey('gorme_keskinligi_od') || findings.containsKey('gorme_keskinligi_os')) {
      final od = findings['gorme_keskinligi_od'] ?? '-';
      final os = findings['gorme_keskinligi_os'] ?? '-';
      parts.add('Görme Keskinliği: OD $od, OS $os');
    }

    if (findings.containsKey('iop_od') || findings.containsKey('iop_os')) {
      final od = findings['iop_od'] ?? '-';
      final os = findings['iop_os'] ?? '-';
      parts.add('Göz İçi Basıncı: OD $od, OS $os');
    }

    if (findings.containsKey('kornea')) {
      parts.add('Kornea: ${findings['kornea']}');
    }

    if (findings.containsKey('on_segment')) {
      parts.add('Ön Segment: ${findings['on_segment']}');
    }

    if (findings.containsKey('fundus')) {
      parts.add('Fundus: ${findings['fundus']}');
    }

    if (findings.containsKey('sikayet')) {
      parts.add('Şikayet: ${findings['sikayet']}');
    }

    if (findings.containsKey('olasiliklar')) {
      parts.add('Olası Durumlar: ${findings['olasiliklar']}');
    }

    return parts.join('\n');
  }
}
