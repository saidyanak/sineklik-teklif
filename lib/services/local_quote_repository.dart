import '../models/quote.dart';
import 'quote_repository.dart';
import 'storage_service.dart';

class LocalQuoteRepository implements QuoteRepository {
  @override
  Future<List<Quote>> loadQuotes() => StorageService.loadQuotes();

  @override
  Future<int> saveQuote(Quote quote) => StorageService.saveQuote(quote);

  @override
  Future<void> deleteQuote(int id) => StorageService.deleteQuote(id);
}
