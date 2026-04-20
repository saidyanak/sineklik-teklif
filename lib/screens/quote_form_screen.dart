import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/quote_provider.dart';
import '../providers/settings_provider.dart';
import '../services/calculation_service.dart';
import '../widgets/sineklik_row_widget.dart';
import '../main.dart';
import 'quote_preview_screen.dart';

class QuoteFormScreen extends StatefulWidget {
  const QuoteFormScreen({super.key});

  @override
  State<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends State<QuoteFormScreen> {
  static final _fmt = NumberFormat('#,##0.00', 'tr_TR');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuoteProvider>().resetCurrent();
    });
  }

  Future<void> _createQuote() async {
    final qp = context.read<QuoteProvider>();
    final sp = context.read<SettingsProvider>();
    final items = qp.currentItems;

    final invalid = items.any((i) => i.en <= 0 || i.boy <= 0);
    if (invalid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm EN ve BOY değerlerini girin')),
      );
      return;
    }

    final quote = await qp.saveQuote(sp.settings.firmaAdi);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuotePreviewScreen(quote: quote),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final qp = context.watch<QuoteProvider>();
    final sp = context.watch<SettingsProvider>();
    final settings = sp.settings;
    final items = qp.currentItems;

    final grandTotal = CalculationService.calculateGrandTotal(items, settings);
    final kdvTutari = qp.kdvDahil ? grandTotal * qp.kdvOrani : 0.0;
    final genelToplam = grandTotal + kdvTutari;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teklif Oluştur'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return SineklikRowWidget(
                    key: ValueKey(item.id),
                    index: idx,
                    item: item,
                    canDelete: items.length > 1,
                    onDelete: () => qp.removeItem(idx),
                    onChanged: (updated) => qp.updateItem(idx, updated),
                  );
                }),
                if (items.length < 10)
                  OutlinedButton.icon(
                    onPressed: qp.addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Sineklik Ekle'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: kCharcoal,
                      side: const BorderSide(color: kAmber, width: 1.5),
                    ),
                  ),
                const SizedBox(height: 8),
                Card(
                  child: SwitchListTile(
                    title: const Text('KDV Ekle (%20)'),
                    value: qp.kdvDahil,
                    onChanged: qp.setKdv,
                    activeColor: kAmber,
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Bottom totals bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ara Toplam:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text('₺${_fmt.format(grandTotal)}',
                        style: const TextStyle(fontSize: 13, color: kCharcoal)),
                  ],
                ),
                if (qp.kdvDahil) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('KDV (%20):', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text('₺${_fmt.format(kdvTutari)}',
                          style: const TextStyle(fontSize: 13, color: kCharcoal)),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Container(height: 1.5, color: kAmber),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'GENEL TOPLAM:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kCharcoal,
                      ),
                    ),
                    Text(
                      '₺${_fmt.format(genelToplam)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kAmber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _createQuote,
                    icon: const Icon(Icons.description),
                    label: const Text(
                      'Teklif Oluştur',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAmber,
                      foregroundColor: kCharcoal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
