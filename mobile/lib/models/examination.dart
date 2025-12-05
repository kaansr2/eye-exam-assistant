import 'patient.dart';

/// Göz muayenesi veri modeli
class Examination {
  final String? id;
  final String patientId;
  final DateTime muayeneTarihi;
  final String? protokolNo;
  final String? basvuruSikayeti;
  final VisionData? gormeKeskinligi;
  final RefractionData? refraksiyon;
  final IopData? gozIciBasinci;
  final AnteriorSegmentData? onSegment;
  final PosteriorSegmentData? arkaSegment;
  final String? tani;
  final String? tedavi;
  final String? notlar;
  final List<String>? gorsellerUrls;
  final AiAnalysisData? aiAnalizi;
  final bool doktorOnayi;
  final DateTime? olusturmaTarihi;
  final DateTime? guncellemeTarihi;

  Examination({
    this.id,
    required this.patientId,
    required this.muayeneTarihi,
    this.protokolNo,
    this.basvuruSikayeti,
    this.gormeKeskinligi,
    this.refraksiyon,
    this.gozIciBasinci,
    this.onSegment,
    this.arkaSegment,
    this.tani,
    this.tedavi,
    this.notlar,
    this.gorsellerUrls,
    this.aiAnalizi,
    this.doktorOnayi = false,
    this.olusturmaTarihi,
    this.guncellemeTarihi,
  });

  /// JSON'dan Examination oluşturma
  factory Examination.fromJson(Map<String, dynamic> json) {
    return Examination(
      id: json['id'] as String?,
      patientId: json['patient_id'] as String,
      muayeneTarihi: DateTime.parse(json['muayene_tarihi'] as String),
      protokolNo: json['protokol_no'] as String?,
      basvuruSikayeti: json['basvuru_sikayeti'] as String?,
      gormeKeskinligi: json['gorme_keskinligi'] != null
          ? VisionData.fromJson(json['gorme_keskinligi'] as Map<String, dynamic>)
          : null,
      refraksiyon: json['refraksiyon'] != null
          ? RefractionData.fromJson(json['refraksiyon'] as Map<String, dynamic>)
          : null,
      gozIciBasinci: json['goz_ici_basinci'] != null
          ? IopData.fromJson(json['goz_ici_basinci'] as Map<String, dynamic>)
          : null,
      onSegment: json['on_segment'] != null
          ? AnteriorSegmentData.fromJson(json['on_segment'] as Map<String, dynamic>)
          : null,
      arkaSegment: json['arka_segment'] != null
          ? PosteriorSegmentData.fromJson(json['arka_segment'] as Map<String, dynamic>)
          : null,
      tani: json['tani'] as String?,
      tedavi: json['tedavi'] as String?,
      notlar: json['notlar'] as String?,
      gorsellerUrls: (json['gorseller_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      aiAnalizi: json['ai_analizi'] != null
          ? AiAnalysisData.fromJson(json['ai_analizi'] as Map<String, dynamic>)
          : null,
      doktorOnayi: json['doktor_onayi'] as bool? ?? false,
      olusturmaTarihi: json['olusturma_tarihi'] != null
          ? DateTime.parse(json['olusturma_tarihi'] as String)
          : null,
      guncellemeTarihi: json['guncelleme_tarihi'] != null
          ? DateTime.parse(json['guncelleme_tarihi'] as String)
          : null,
    );
  }

  /// Examination'ı JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'patient_id': patientId,
      'muayene_tarihi': muayeneTarihi.toIso8601String(),
      if (protokolNo != null) 'protokol_no': protokolNo,
      if (basvuruSikayeti != null) 'basvuru_sikayeti': basvuruSikayeti,
      if (gormeKeskinligi != null) 'gorme_keskinligi': gormeKeskinligi!.toJson(),
      if (refraksiyon != null) 'refraksiyon': refraksiyon!.toJson(),
      if (gozIciBasinci != null) 'goz_ici_basinci': gozIciBasinci!.toJson(),
      if (onSegment != null) 'on_segment': onSegment!.toJson(),
      if (arkaSegment != null) 'arka_segment': arkaSegment!.toJson(),
      if (tani != null) 'tani': tani,
      if (tedavi != null) 'tedavi': tedavi,
      if (notlar != null) 'notlar': notlar,
      if (gorsellerUrls != null) 'gorseller_urls': gorsellerUrls,
      if (aiAnalizi != null) 'ai_analizi': aiAnalizi!.toJson(),
      'doktor_onayi': doktorOnayi,
    };
  }

  /// Kopyalama metodu
  Examination copyWith({
    String? id,
    String? patientId,
    DateTime? muayeneTarihi,
    String? protokolNo,
    String? basvuruSikayeti,
    VisionData? gormeKeskinligi,
    RefractionData? refraksiyon,
    IopData? gozIciBasinci,
    AnteriorSegmentData? onSegment,
    PosteriorSegmentData? arkaSegment,
    String? tani,
    String? tedavi,
    String? notlar,
    List<String>? gorsellerUrls,
    AiAnalysisData? aiAnalizi,
    bool? doktorOnayi,
  }) {
    return Examination(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      muayeneTarihi: muayeneTarihi ?? this.muayeneTarihi,
      protokolNo: protokolNo ?? this.protokolNo,
      basvuruSikayeti: basvuruSikayeti ?? this.basvuruSikayeti,
      gormeKeskinligi: gormeKeskinligi ?? this.gormeKeskinligi,
      refraksiyon: refraksiyon ?? this.refraksiyon,
      gozIciBasinci: gozIciBasinci ?? this.gozIciBasinci,
      onSegment: onSegment ?? this.onSegment,
      arkaSegment: arkaSegment ?? this.arkaSegment,
      tani: tani ?? this.tani,
      tedavi: tedavi ?? this.tedavi,
      notlar: notlar ?? this.notlar,
      gorsellerUrls: gorsellerUrls ?? this.gorsellerUrls,
      aiAnalizi: aiAnalizi ?? this.aiAnalizi,
      doktorOnayi: doktorOnayi ?? this.doktorOnayi,
      olusturmaTarihi: olusturmaTarihi,
      guncellemeTarihi: guncellemeTarihi,
    );
  }
}

/// Görme keskinliği verisi
class VisionData {
  final String? sagGozluksuz; // OD SC
  final String? solGozluksuz; // OS SC
  final String? sagGozluklu; // OD CC
  final String? solGozluklu; // OS CC
  final String? sagPinhole; // OD PH
  final String? solPinhole; // OS PH

  VisionData({
    this.sagGozluksuz,
    this.solGozluksuz,
    this.sagGozluklu,
    this.solGozluklu,
    this.sagPinhole,
    this.solPinhole,
  });

  factory VisionData.fromJson(Map<String, dynamic> json) {
    return VisionData(
      sagGozluksuz: json['sag_gozluksuz'] as String?,
      solGozluksuz: json['sol_gozluksuz'] as String?,
      sagGozluklu: json['sag_gozluklu'] as String?,
      solGozluklu: json['sol_gozluklu'] as String?,
      sagPinhole: json['sag_pinhole'] as String?,
      solPinhole: json['sol_pinhole'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (sagGozluksuz != null) 'sag_gozluksuz': sagGozluksuz,
      if (solGozluksuz != null) 'sol_gozluksuz': solGozluksuz,
      if (sagGozluklu != null) 'sag_gozluklu': sagGozluklu,
      if (solGozluklu != null) 'sol_gozluklu': solGozluklu,
      if (sagPinhole != null) 'sag_pinhole': sagPinhole,
      if (solPinhole != null) 'sol_pinhole': solPinhole,
    };
  }
}

/// Refraksiyon verisi
class RefractionData {
  final double? sagSfer;
  final double? sagSilindir;
  final int? sagAks;
  final double? solSfer;
  final double? solSilindir;
  final int? solAks;
  final double? sagAdd;
  final double? solAdd;

  RefractionData({
    this.sagSfer,
    this.sagSilindir,
    this.sagAks,
    this.solSfer,
    this.solSilindir,
    this.solAks,
    this.sagAdd,
    this.solAdd,
  });

  factory RefractionData.fromJson(Map<String, dynamic> json) {
    return RefractionData(
      sagSfer: (json['sag_sfer'] as num?)?.toDouble(),
      sagSilindir: (json['sag_silindir'] as num?)?.toDouble(),
      sagAks: json['sag_aks'] as int?,
      solSfer: (json['sol_sfer'] as num?)?.toDouble(),
      solSilindir: (json['sol_silindir'] as num?)?.toDouble(),
      solAks: json['sol_aks'] as int?,
      sagAdd: (json['sag_add'] as num?)?.toDouble(),
      solAdd: (json['sol_add'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (sagSfer != null) 'sag_sfer': sagSfer,
      if (sagSilindir != null) 'sag_silindir': sagSilindir,
      if (sagAks != null) 'sag_aks': sagAks,
      if (solSfer != null) 'sol_sfer': solSfer,
      if (solSilindir != null) 'sol_silindir': solSilindir,
      if (solAks != null) 'sol_aks': solAks,
      if (sagAdd != null) 'sag_add': sagAdd,
      if (solAdd != null) 'sol_add': solAdd,
    };
  }
}

/// Göz içi basıncı verisi
class IopData {
  final double? sagIop; // mmHg
  final double? solIop;
  final String? olcumYontemi;
  final String? olcumSaati;

  IopData({
    this.sagIop,
    this.solIop,
    this.olcumYontemi,
    this.olcumSaati,
  });

  factory IopData.fromJson(Map<String, dynamic> json) {
    return IopData(
      sagIop: (json['sag_iop'] as num?)?.toDouble(),
      solIop: (json['sol_iop'] as num?)?.toDouble(),
      olcumYontemi: json['olcum_yontemi'] as String?,
      olcumSaati: json['olcum_saati'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (sagIop != null) 'sag_iop': sagIop,
      if (solIop != null) 'sol_iop': solIop,
      if (olcumYontemi != null) 'olcum_yontemi': olcumYontemi,
      if (olcumSaati != null) 'olcum_saati': olcumSaati,
    };
  }
}

/// Ön segment verisi
class AnteriorSegmentData {
  final String? kapaklar;
  final String? konjonktiva;
  final String? kornea;
  final String? onKamara;
  final String? iris;
  final String? pupilla;
  final String? lens;

  AnteriorSegmentData({
    this.kapaklar,
    this.konjonktiva,
    this.kornea,
    this.onKamara,
    this.iris,
    this.pupilla,
    this.lens,
  });

  factory AnteriorSegmentData.fromJson(Map<String, dynamic> json) {
    return AnteriorSegmentData(
      kapaklar: json['kapaklar'] as String?,
      konjonktiva: json['konjonktiva'] as String?,
      kornea: json['kornea'] as String?,
      onKamara: json['on_kamara'] as String?,
      iris: json['iris'] as String?,
      pupilla: json['pupilla'] as String?,
      lens: json['lens'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (kapaklar != null) 'kapaklar': kapaklar,
      if (konjonktiva != null) 'konjonktiva': konjonktiva,
      if (kornea != null) 'kornea': kornea,
      if (onKamara != null) 'on_kamara': onKamara,
      if (iris != null) 'iris': iris,
      if (pupilla != null) 'pupilla': pupilla,
      if (lens != null) 'lens': lens,
    };
  }
}

/// Arka segment verisi (Fundus)
class PosteriorSegmentData {
  final String? vitreus;
  final String? optikDisk;
  final String? cdOrani; // Cup/Disc oranı
  final String? makula;
  final String? damarlar;
  final String? periferi;

  PosteriorSegmentData({
    this.vitreus,
    this.optikDisk,
    this.cdOrani,
    this.makula,
    this.damarlar,
    this.periferi,
  });

  factory PosteriorSegmentData.fromJson(Map<String, dynamic> json) {
    return PosteriorSegmentData(
      vitreus: json['vitreus'] as String?,
      optikDisk: json['optik_disk'] as String?,
      cdOrani: json['cd_orani'] as String?,
      makula: json['makula'] as String?,
      damarlar: json['damarlar'] as String?,
      periferi: json['periferi'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (vitreus != null) 'vitreus': vitreus,
      if (optikDisk != null) 'optik_disk': optikDisk,
      if (cdOrani != null) 'cd_orani': cdOrani,
      if (makula != null) 'makula': makula,
      if (damarlar != null) 'damarlar': damarlar,
      if (periferi != null) 'periferi': periferi,
    };
  }
}

/// AI analiz verisi
class AiAnalysisData {
  final String? gorselAnalizSonucu;
  final String? metinAnalizSonucu;
  final double? guvenSkoru;
  final List<String>? onerilenTanilar;
  final DateTime? analizTarihi;

  AiAnalysisData({
    this.gorselAnalizSonucu,
    this.metinAnalizSonucu,
    this.guvenSkoru,
    this.onerilenTanilar,
    this.analizTarihi,
  });

  factory AiAnalysisData.fromJson(Map<String, dynamic> json) {
    return AiAnalysisData(
      gorselAnalizSonucu: json['gorsel_analiz_sonucu'] as String?,
      metinAnalizSonucu: json['metin_analiz_sonucu'] as String?,
      guvenSkoru: (json['guven_skoru'] as num?)?.toDouble(),
      onerilenTanilar: (json['onerilen_tanilar'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      analizTarihi: json['analiz_tarihi'] != null
          ? DateTime.parse(json['analiz_tarihi'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (gorselAnalizSonucu != null) 'gorsel_analiz_sonucu': gorselAnalizSonucu,
      if (metinAnalizSonucu != null) 'metin_analiz_sonucu': metinAnalizSonucu,
      if (guvenSkoru != null) 'guven_skoru': guvenSkoru,
      if (onerilenTanilar != null) 'onerilen_tanilar': onerilenTanilar,
      if (analizTarihi != null) 'analiz_tarihi': analizTarihi!.toIso8601String(),
    };
  }
}
