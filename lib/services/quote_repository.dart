import '../models/quote.dart';

abstract class QuoteRepository {
  Future<List<Quote>> loadQuotes();
  Future<int> saveQuote(Quote quote);
  Future<void> deleteQuote(int id);
}
