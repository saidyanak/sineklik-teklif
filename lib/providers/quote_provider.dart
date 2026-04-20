import 'package:flutter/foundation.dart';
import '../models/quote.dart';
import '../models/sineklik_item.dart';
import '../services/quote_repository.dart';
import '../services/storage_service.dart';
import 'package:intl/intl.dart';

class QuoteProvider extends ChangeNotifier {
  final QuoteRepository _repository;

  QuoteProvider(this._repository);

  List<Quote> _history = [];
  List<SineklikItem> _currentItems = [];
  bool _kdvDahil = false;
  final double _kdvOrani = 0.20;

  List<Quote> get history => _history;
  List<SineklikItem> get currentItems => _currentItems;
  bool get kdvDahil => _kdvDahil;
  double get kdvOrani => _kdvOrani;

  Future<void> loadHistory() async {
    try {
      _history = await _repository.loadQuotes();
    } catch (e) {
      debugPrint('Geçmiş yüklenemedi: $e');
      _history = [];
    }
    notifyListeners();
  }

  void resetCurrent() {
    _currentItems = [SineklikItem(konum: '', en: 100, boy: 200)];
    _kdvDahil = false;
    notifyListeners();
  }

  void addItem() {
    if (_currentItems.length >= 10) return;
    _currentItems = [..._currentItems, SineklikItem(konum: '', en: 100, boy: 200)];
    notifyListeners();
  }

  void removeItem(int index) {
    if (_currentItems.length <= 1) return;
    final list = List<SineklikItem>.from(_currentItems);
    list.removeAt(index);
    _currentItems = list;
    notifyListeners();
  }

  void updateItem(int index, SineklikItem item) {
    final list = List<SineklikItem>.from(_currentItems);
    list[index] = item;
    _currentItems = list;
    notifyListeners();
  }

  void setKdv(bool value) {
    _kdvDahil = value;
    notifyListeners();
  }

  Future<Quote> saveQuote(String firmaAdi) async {
    final counter = await StorageService.nextTeklifNo();
    final teklifNo =
        'TKL-${DateFormat('yyyyMM').format(DateTime.now())}-${counter.toString().padLeft(3, '0')}';
    final quote = Quote(
      teklifNo: teklifNo,
      tarih: DateTime.now(),
      firmaAdi: firmaAdi,
      items: List.from(_currentItems),
      kdvDahil: _kdvDahil,
      kdvOrani: _kdvOrani,
    );
    final newId = await _repository.saveQuote(quote);
    await loadHistory();
    return Quote(
      id: newId,
      teklifNo: quote.teklifNo,
      tarih: quote.tarih,
      firmaAdi: quote.firmaAdi,
      items: quote.items,
      kdvDahil: quote.kdvDahil,
      kdvOrani: quote.kdvOrani,
    );
  }

  Future<void> deleteQuote(int id) async {
    await _repository.deleteQuote(id);
    await loadHistory();
  }
}
