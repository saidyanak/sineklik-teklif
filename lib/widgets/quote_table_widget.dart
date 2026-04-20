import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/quote.dart';
import '../models/app_settings.dart';
import '../services/calculation_service.dart';
import '../main.dart';

class QuoteTableWidget extends StatelessWidget {
  final Quote quote;
  final AppSettings settings;

  const QuoteTableWidget({
    super.key,
    required this.quote,
    required this.settings,
  });

  static final _fmt = NumberFormat('#,##0.00', 'tr_TR');

  @override
  Widget build(BuildContext context) {
    final grandTotal = CalculationService.calculateGrandTotal(quote.items, settings);
    final kdvTutari = quote.kdvDahil ? grandTotal * quote.kdvOrani : 0.0;
    final genelToplam = grandTotal + kdvTutari;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table header – amber
        Container(
          decoration: const BoxDecoration(
            color: kAmber,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: const Row(
            children: [
              _HeaderCell('KONUM', flex: 2),
              _HeaderCell('EN×BOY', flex: 2),
              _HeaderCell('TOPLAM', flex: 2),
            ],
          ),
        ),
        // Rows
        ...quote.items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final result = CalculationService.calculate(item, settings);
          return Container(
            decoration: BoxDecoration(
              color: idx % 2 == 0 ? Colors.white : const Color(0xFFF8F8F8),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                _DataCell(item.konum.isEmpty ? '—' : item.konum, flex: 2),
                _DataCell(
                  '${item.en.toStringAsFixed(0)}×${item.boy.toStringAsFixed(0)}',
                  flex: 2,
                ),
                _DataCell(
                  '₺${_fmt.format(result.toplam)}',
                  flex: 2,
                  bold: true,
                  color: kCharcoal,
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 12),
        _TotalRow(label: 'Ara Toplam', value: '₺${_fmt.format(grandTotal)}'),
        if (quote.kdvDahil) ...[
          _TotalRow(
            label: 'KDV (%${(quote.kdvOrani * 100).toStringAsFixed(0)})',
            value: '₺${_fmt.format(kdvTutari)}',
          ),
        ],
        const SizedBox(height: 4),
        Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: kAmber,
        ),
        const SizedBox(height: 4),
        // Genel toplam – charcoal bg
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
              Text(
                '₺${_fmt.format(genelToplam)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: kAmber,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const _HeaderCell(this.text, {this.flex = 1});

  @override
  Widget build(BuildContext context) => Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
}

class _DataCell extends StatelessWidget {
  final String text;
  final int flex;
  final bool bold;
  final Color? color;

  const _DataCell(this.text, {this.flex = 1, this.bold = false, this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;

  const _TotalRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 13, color: kCharcoal, fontWeight: FontWeight.w500)),
          ],
        ),
      );
}
