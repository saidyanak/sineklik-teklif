import 'dart:convert';
import 'sineklik_item.dart';

class Quote {
  final int? id;
  final String teklifNo;
  final DateTime tarih;
  final String firmaAdi;
  final List<SineklikItem> items;
  final bool kdvDahil;
  final double kdvOrani;

  Quote({
    this.id,
    required this.teklifNo,
    required this.tarih,
    required this.firmaAdi,
    required this.items,
    this.kdvDahil = false,
    this.kdvOrani = 0.20,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'teklifNo': teklifNo,
        'tarih': tarih.toIso8601String(),
        'firmaAdi': firmaAdi,
        'items': jsonEncode(items.map((e) => e.toMap()).toList()),
        'kdvDahil': kdvDahil ? 1 : 0,
        'kdvOrani': kdvOrani,
      };

  factory Quote.fromMap(Map<String, dynamic> map) => Quote(
        id: map['id'] as int?,
        teklifNo: map['teklifNo'] as String? ?? '',
        tarih: DateTime.parse(map['tarih'] as String),
        firmaAdi: map['firmaAdi'] as String? ?? '',
        items: (jsonDecode(map['items'] as String) as List)
            .map((e) => SineklikItem.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        kdvDahil: (map['kdvDahil'] as int?) == 1,
        kdvOrani: (map['kdvOrani'] as num?)?.toDouble() ?? 0.20,
      );

  Quote copyWith({
    String? teklifNo,
    DateTime? tarih,
    String? firmaAdi,
    List<SineklikItem>? items,
    bool? kdvDahil,
    double? kdvOrani,
  }) {
    return Quote(
      id: id,
      teklifNo: teklifNo ?? this.teklifNo,
      tarih: tarih ?? this.tarih,
      firmaAdi: firmaAdi ?? this.firmaAdi,
      items: items ?? this.items,
      kdvDahil: kdvDahil ?? this.kdvDahil,
      kdvOrani: kdvOrani ?? this.kdvOrani,
    );
  }
}
