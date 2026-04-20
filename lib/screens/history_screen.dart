import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/quote_provider.dart';
import '../providers/settings_provider.dart';
import '../services/calculation_service.dart';
import '../models/quote.dart';
import '../main.dart';
import 'quote_preview_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static final _dateFmt = DateFormat('dd.MM.yyyy');
  static final _moneyFmt = NumberFormat('#,##0.00', 'tr_TR');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuoteProvider>().loadHistory();
    });
  }

  Future<void> _confirmDelete(BuildContext ctx, Quote quote) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Teklifi Sil'),
        content: Text('${quote.teklifNo} numaralı teklif silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed == true && quote.id != null && ctx.mounted) {
      await ctx.read<QuoteProvider>().deleteQuote(quote.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qp = context.watch<QuoteProvider>();
    final sp = context.watch<SettingsProvider>();
    final history = qp.history;

    return Scaffold(
      appBar: AppBar(title: const Text('Geçmiş Teklifler')),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: kAmberLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.history, size: 44, color: kAmber),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz teklif oluşturulmadı',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              itemBuilder: (ctx, idx) {
                final quote = history[idx];
                final grandTotal = CalculationService.calculateGrandTotal(
                  quote.items,
                  sp.settings,
                );
                final kdvTutari = quote.kdvDahil ? grandTotal * quote.kdvOrani : 0.0;
                final genelToplam = grandTotal + kdvTutari;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => QuotePreviewScreen(quote: quote),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: kAmberLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  quote.teklifNo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: kCharcoal,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _dateFmt.format(quote.tarih),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red, size: 20),
                                    onPressed: () => _confirmDelete(ctx, quote),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.grid_view_rounded, size: 15, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                '${quote.items.length} sineklik',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                              const SizedBox(width: 12),
                              if (quote.kdvDahil)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: kAmberLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'KDV Dahil',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: kAmber,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: kCharcoal,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'GENEL TOPLAM',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '₺${_moneyFmt.format(genelToplam)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: kAmber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
