import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/quote.dart';

class StorageService {
  static const _settingsKey = 'app_settings';
  static const _quotesKey = 'quotes_list';
  static const _counterKey = 'quote_counter';

  // Settings
  static Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_settingsKey);
    if (json == null) return const AppSettings();
    return AppSettings.fromMap(Map<String, dynamic>.from(
      jsonDecode(json) as Map,
    ));
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toMap()));
  }

  // Quote counter
  static Future<int> nextTeklifNo() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_counterKey) ?? 0;
    final next = current + 1;
    await prefs.setInt(_counterKey, next);
    return next;
  }

  // Quotes (stored as JSON list)
  static Future<List<Quote>> loadQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_quotesKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => Quote.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList()
        .reversed
        .toList();
  }

  static Future<int> saveQuote(Quote quote) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_quotesKey);
    final list = json != null ? (jsonDecode(json) as List) : [];
    final newId = DateTime.now().millisecondsSinceEpoch;
    final map = quote.toMap();
    map['id'] = newId;
    list.add(map);
    await prefs.setString(_quotesKey, jsonEncode(list));
    return newId;
  }

  static Future<void> deleteQuote(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_quotesKey);
    if (json == null) return;
    final list = (jsonDecode(json) as List)
        .where((e) => (e as Map)['id'] != id)
        .toList();
    await prefs.setString(_quotesKey, jsonEncode(list));
  }
}
