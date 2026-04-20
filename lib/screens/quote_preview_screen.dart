import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import '../models/quote.dart';
import '../providers/settings_provider.dart';
import '../services/pdf_service.dart';
import '../widgets/quote_table_widget.dart';
import '../main.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class QuotePreviewScreen extends StatefulWidget {
  final Quote quote;

  const QuotePreviewScreen({super.key, required this.quote});

  @override
  State<QuotePreviewScreen> createState() => _QuotePreviewScreenState();
}

class _QuotePreviewScreenState extends State<QuotePreviewScreen> {
  bool _isGenerating = false;

  Future<List<int>> _getPdfBytes() async {
    final settings = context.read<SettingsProvider>().settings;
    return PdfService.generateQuotePdf(widget.quote, settings);
  }

  Future<void> _savePdf() async {
    setState(() => _isGenerating = true);
    try {
      final bytes = await _getPdfBytes();
      await Printing.layoutPdf(
        onLayout: (_) async => Uint8List.fromList(bytes),
        name: 'teklif_${widget.quote.teklifNo}',
      );
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _sharePdf() async {
    setState(() => _isGenerating = true);
    try {
      final bytes = await _getPdfBytes();
      final filename = 'teklif_${widget.quote.teklifNo}.pdf';

      if (kIsWeb) {
        await Printing.sharePdf(
          bytes: Uint8List.fromList(bytes),
          filename: filename,
        );
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'application/pdf')],
          subject:
              '${widget.quote.firmaAdi} - ${widget.quote.teklifNo} Sineklik Teklifi',
        );
      }
    } catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _showError(Object e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teklif Önizleme'),
        actions: [
          if (_isGenerating)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'PDF Kaydet / Yazdır',
              onPressed: _savePdf,
            ),
            IconButton(
              icon: Icon(kIsWeb ? Icons.download : Icons.share),
              tooltip: kIsWeb ? 'PDF İndir' : 'Paylaş',
              onPressed: _sharePdf,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              decoration: BoxDecoration(
                color: kCharcoal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.quote.firmaAdi,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Sineklik Teklif Formu',
                                style: TextStyle(color: Colors.white60, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              _ContactChip(icon: Icons.phone, text: settings.telefon),
                              const SizedBox(height: 4),
                              _ContactChip(icon: Icons.language, text: settings.website),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: kAmber,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.quote.teklifNo,
                                style: const TextStyle(
                                  color: kCharcoal,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('dd.MM.yyyy').format(widget.quote.tarih),
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 3,
                    decoration: const BoxDecoration(
                      color: kAmber,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quote table
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: QuoteTableWidget(
                  quote: widget.quote,
                  settings: settings,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isGenerating ? null : _savePdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF Kaydet'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _sharePdf,
                    icon: Icon(kIsWeb ? Icons.download : Icons.share),
                    label: Text(kIsWeb ? 'PDF İndir' : 'Paylaş'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAmber,
                      foregroundColor: kCharcoal,
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: kAmber),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
