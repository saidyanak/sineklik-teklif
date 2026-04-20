import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quote.dart';
import 'quote_repository.dart';

class SupabaseQuoteService implements QuoteRepository {
  SupabaseClient get _db => Supabase.instance.client;

  @override
  Future<List<Quote>> loadQuotes() async {
    final data = await _db
        .from('quotes')
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((row) {
      final m = Map<String, dynamic>.from(row as Map);
      // Supabase: boolean → int dönüşümü (Quote.fromMap int bekliyor)
      m['kdvDahil'] = (m['kdv_dahil'] as bool? ?? m['kdvDahil'] as bool? ?? false) ? 1 : 0;
      m['teklifNo'] = m['teklif_no'] ?? m['teklifNo'];
      m['firmaAdi'] = m['firma_adi'] ?? m['firmaAdi'];
      m['kdvOrani'] = (m['kdv_orani'] as num?)?.toDouble() ?? (m['kdvOrani'] as num?)?.toDouble() ?? 0.20;
      // items: Supabase jsonb olarak dönebilir, stringe çevir
      if (m['items'] is List || m['items'] is Map) {
        m['items'] = jsonEncode(m['items']);
      }
      return Quote.fromMap(m);
    }).toList();
  }

  @override
  Future<int> saveQuote(Quote quote) async {
    final response = await _db.from('quotes').insert({
      'teklif_no': quote.teklifNo,
      'tarih': quote.tarih.toIso8601String(),
      'firma_adi': quote.firmaAdi,
      'items': quote.items.map((e) => e.toMap()).toList(),
      'kdv_dahil': quote.kdvDahil,
      'kdv_orani': quote.kdvOrani,
    }).select('id').single();

    return response['id'] as int;
  }

  @override
  Future<void> deleteQuote(int id) async {
    await _db.from('quotes').delete().eq('id', id);
  }
}
