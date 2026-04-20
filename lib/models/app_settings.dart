class AppSettings {
  final double kasaTutari;
  final double kanatTutari;
  final double tulTutari;
  final double ipTutari;
  final double seritTutari;
  final double aksesuarTutari;
  final double iscilikTutari;
  final String firmaAdi;
  final String telefon;
  final String website;

  const AppSettings({
    this.kasaTutari = 20650,
    this.kanatTutari = 20650,
    this.tulTutari = 30,
    this.ipTutari = 290,
    this.seritTutari = 7,
    this.aksesuarTutari = 15,
    this.iscilikTutari = 0,
    this.firmaAdi = 'Hanimeli Yapı Yönetim',
    this.telefon = '0544 482 54 29',
    this.website = 'ilkadimsineklik.com',
  });

  AppSettings copyWith({
    double? kasaTutari,
    double? kanatTutari,
    double? tulTutari,
    double? ipTutari,
    double? seritTutari,
    double? aksesuarTutari,
    double? iscilikTutari,
    String? firmaAdi,
    String? telefon,
    String? website,
  }) {
    return AppSettings(
      kasaTutari: kasaTutari ?? this.kasaTutari,
      kanatTutari: kanatTutari ?? this.kanatTutari,
      tulTutari: tulTutari ?? this.tulTutari,
      ipTutari: ipTutari ?? this.ipTutari,
      seritTutari: seritTutari ?? this.seritTutari,
      aksesuarTutari: aksesuarTutari ?? this.aksesuarTutari,
      iscilikTutari: iscilikTutari ?? this.iscilikTutari,
      firmaAdi: firmaAdi ?? this.firmaAdi,
      telefon: telefon ?? this.telefon,
      website: website ?? this.website,
    );
  }

  Map<String, dynamic> toMap() => {
        'kasaTutari': kasaTutari,
        'kanatTutari': kanatTutari,
        'tulTutari': tulTutari,
        'ipTutari': ipTutari,
        'seritTutari': seritTutari,
        'aksesuarTutari': aksesuarTutari,
        'iscilikTutari': iscilikTutari,
        'firmaAdi': firmaAdi,
        'telefon': telefon,
        'website': website,
      };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
        kasaTutari: (map['kasaTutari'] as num?)?.toDouble() ?? 20650,
        kanatTutari: (map['kanatTutari'] as num?)?.toDouble() ?? 20650,
        tulTutari: (map['tulTutari'] as num?)?.toDouble() ?? 30,
        ipTutari: (map['ipTutari'] as num?)?.toDouble() ?? 290,
        seritTutari: (map['seritTutari'] as num?)?.toDouble() ?? 7,
        aksesuarTutari: (map['aksesuarTutari'] as num?)?.toDouble() ?? 15,
        iscilikTutari: (map['iscilikTutari'] as num?)?.toDouble() ?? 0,
        firmaAdi: map['firmaAdi'] as String? ?? 'Hanimeli Yapı Yönetim',
        telefon: map['telefon'] as String? ?? '0544 482 54 29',
        website: map['website'] as String? ?? 'ilkadimsineklik.com',
      );
}
