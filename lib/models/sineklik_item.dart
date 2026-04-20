import 'package:uuid/uuid.dart';

class SineklikItem {
  final String id;
  final String konum;
  final double en;
  final double boy;
  final double? iscilikOverride;

  SineklikItem({
    String? id,
    required this.konum,
    required this.en,
    required this.boy,
    this.iscilikOverride,
  }) : id = id ?? const Uuid().v4();

  SineklikItem copyWith({
    String? konum,
    double? en,
    double? boy,
    double? iscilikOverride,
    bool clearIscilik = false,
  }) {
    return SineklikItem(
      id: id,
      konum: konum ?? this.konum,
      en: en ?? this.en,
      boy: boy ?? this.boy,
      iscilikOverride: clearIscilik ? null : (iscilikOverride ?? this.iscilikOverride),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'konum': konum,
        'en': en,
        'boy': boy,
        'iscilikOverride': iscilikOverride,
      };

  factory SineklikItem.fromMap(Map<String, dynamic> map) => SineklikItem(
        id: map['id'] as String?,
        konum: map['konum'] as String? ?? '',
        en: (map['en'] as num?)?.toDouble() ?? 100,
        boy: (map['boy'] as num?)?.toDouble() ?? 200,
        iscilikOverride: (map['iscilikOverride'] as num?)?.toDouble(),
      );
}
