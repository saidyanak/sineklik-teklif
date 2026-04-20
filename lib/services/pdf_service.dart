import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/quote.dart';
import '../models/app_settings.dart';
import '../services/calculation_service.dart';

class PdfService {
  static final _fmt = NumberFormat('#,##0.00', 'tr_TR');

  static const _amber     = PdfColor.fromInt(0xFFF5A623);
  static const _charcoal  = PdfColor.fromInt(0xFF3D3D3D);
  static const _lightGray = PdfColor.fromInt(0xFFF8F8F8);
  static const _border    = PdfColor.fromInt(0xFFE8E8E8);
  static const _textGray  = PdfColor.fromInt(0xFF6B7280);
  static const _amberLight = PdfColor.fromInt(0xFFFFF3D9);

  static Future<List<int>> generateQuotePdf(
    Quote quote,
    AppSettings settings,
  ) async {
    final fontData       = await rootBundle.load('assets/NotoSans-Regular.ttf');
    final fontBoldData   = await rootBundle.load('assets/NotoSans-Bold.ttf');
    final fontItalicData = await rootBundle.load('assets/NotoSans-Italic.ttf');

    final font       = pw.Font.ttf(fontData);
    final fontBold   = pw.Font.ttf(fontBoldData);
    final fontItalic = pw.Font.ttf(fontItalicData);

    pw.MemoryImage? logoImg;
    try {
      final logoData = await rootBundle.load('assets/logo.jpeg');
      logoImg = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {
      try {
        final logoData = await rootBundle.load('assets/logo.png');
        logoImg = pw.MemoryImage(logoData.buffer.asUint8List());
      } catch (_) {}
    }

    final pdf        = pw.Document();
    final grandTotal = CalculationService.calculateGrandTotal(quote.items, settings);
    final kdvTutari  = quote.kdvDahil ? grandTotal * quote.kdvOrani : 0.0;
    final genelToplam = grandTotal + kdvTutari;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 30, vertical: 32),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
          italic: fontItalic,
        ),
        header: (ctx) => _header(quote, settings, logoImg, font, fontBold),
        footer: (ctx) => _footer(ctx, settings, font),
        build: (ctx) => [
          pw.SizedBox(height: 20),

          pw.Row(
            children: [
              pw.Container(
                width: 4,
                height: 16,
                decoration: pw.BoxDecoration(
                  color: _amber,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'SİNEKLİK LİSTESİ',
                style: pw.TextStyle(font: fontBold, fontSize: 11, color: _charcoal),
              ),
            ],
          ),
          pw.SizedBox(height: 8),

          _table(quote, settings, font, fontBold),

          pw.SizedBox(height: 20),

          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              width: 270,
              child: _totals(quote, grandTotal, kdvTutari, genelToplam, font, fontBold),
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _lightGray,
              borderRadius: pw.BorderRadius.circular(5),
              border: pw.Border.all(color: _border),
            ),
            child: pw.Text(
              'Bu teklif tahmini fiyat içermektedir. '
              'Kesin fiyat için yetkili personelinizle iletişime geçiniz.',
              style: pw.TextStyle(font: fontItalic, fontSize: 8.5, color: _textGray),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ══════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════
  static pw.Widget _header(
    Quote quote,
    AppSettings settings,
    pw.MemoryImage? logo,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: pw.BoxDecoration(
            color: _lightGray,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: _border, width: 1),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Sol: logo + firma bilgileri
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (logo != null) ...[
                    pw.Container(
                      width: 70,
                      height: 56,
                      child: pw.Image(logo, fit: pw.BoxFit.contain),
                    ),
                    pw.SizedBox(width: 14),
                  ],
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        quote.firmaAdi,
                        style: pw.TextStyle(font: fontBold, color: _charcoal, fontSize: 14),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Pencere · Sineklik · Cam Balkon · Yapı İşleri',
                        style: pw.TextStyle(font: font, color: _textGray, fontSize: 8),
                      ),
                      if (settings.telefon.isNotEmpty || settings.website.isNotEmpty) ...[
                        pw.SizedBox(height: 5),
                        pw.Row(
                          children: [
                            if (settings.telefon.isNotEmpty) ...[
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: pw.BoxDecoration(
                                  color: _amberLight,
                                  borderRadius: pw.BorderRadius.circular(3),
                                ),
                                child: pw.Text(
                                  'Tel: ${settings.telefon}',
                                  style: pw.TextStyle(font: fontBold, color: _charcoal, fontSize: 8),
                                ),
                              ),
                              pw.SizedBox(width: 6),
                            ],
                            if (settings.website.isNotEmpty)
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: pw.BoxDecoration(
                                  color: _amberLight,
                                  borderRadius: pw.BorderRadius.circular(3),
                                ),
                                child: pw.Text(
                                  settings.website,
                                  style: pw.TextStyle(font: fontBold, color: _charcoal, fontSize: 8),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              // Sağ: teklif no + tarih
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: pw.BoxDecoration(
                      color: _amber,
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Text(
                      'TEKLİF  #${quote.teklifNo}',
                      style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 10),
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    DateFormat('dd.MM.yyyy').format(quote.tarih),
                    style: pw.TextStyle(font: font, color: _textGray, fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Amber alt şerit
        pw.Container(
          height: 3,
          decoration: pw.BoxDecoration(
            color: _amber,
            borderRadius: const pw.BorderRadius.only(
              bottomLeft: pw.Radius.circular(2),
              bottomRight: pw.Radius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // FOOTER
  // ══════════════════════════════════════════════
  static pw.Widget _footer(pw.Context ctx, AppSettings settings, pw.Font font) {
    final contactParts = <String>[];
    if (settings.telefon.isNotEmpty) contactParts.add('Tel: ${settings.telefon}');
    if (settings.website.isNotEmpty) contactParts.add(settings.website);
    final contact = contactParts.join('  |  ');

    return pw.Column(
      children: [
        pw.Container(height: 2, color: _amber),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              contact.isNotEmpty ? contact : '${DateFormat('dd.MM.yyyy').format(DateTime.now())} tarihinde düzenlenmiştir.',
              style: pw.TextStyle(font: font, fontSize: 7.5, color: _textGray),
            ),
            pw.Text(
              'Sayfa ${ctx.pageNumber} / ${ctx.pagesCount}',
              style: pw.TextStyle(font: font, fontSize: 7.5, color: _textGray),
            ),
          ],
        ),
        if (contact.isNotEmpty)
          pw.Align(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              '${DateFormat('dd.MM.yyyy').format(DateTime.now())} tarihinde düzenlenmiştir.',
              style: pw.TextStyle(font: font, fontSize: 7, color: _textGray),
            ),
          ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // TABLO
  // ══════════════════════════════════════════════
  static pw.Widget _table(Quote quote, AppSettings settings, pw.Font font, pw.Font fontBold) {
    return pw.Table(
      border: pw.TableBorder.all(color: _border, width: .7),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.8),
        1: const pw.FlexColumnWidth(1.6),
        2: const pw.FlexColumnWidth(1.4),
        3: const pw.FlexColumnWidth(1.6),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _amber),
          children: [
            _hCell('KONUM', fontBold),
            _hCell('EN × BOY (cm)', fontBold),
            _hCell('İŞÇİLİK (₺)', fontBold),
            _hCell('TOPLAM (₺)', fontBold),
          ],
        ),
        ...quote.items.asMap().entries.map((e) {
          final item   = e.value;
          final result = CalculationService.calculate(item, settings);
          final isEven = e.key % 2 == 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : _lightGray,
            ),
            children: [
              _dCell(item.konum.isEmpty ? '—' : item.konum, font),
              _dCell('${item.en.toStringAsFixed(0)} × ${item.boy.toStringAsFixed(0)}', font),
              _dCell(_fmt.format(result.iscilik), font),
              _dCell(_fmt.format(result.toplam), fontBold),
            ],
          );
        }),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // TOPLAMLAR
  // ══════════════════════════════════════════════
  static pw.Widget _totals(
    Quote quote,
    double grandTotal,
    double kdvTutari,
    double genelToplam,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      children: [
        _totalRow('Ara Toplam', _fmt.format(grandTotal), font, fontBold),
        if (quote.kdvDahil)
          _totalRow(
            'KDV (%${(quote.kdvOrani * 100).toStringAsFixed(0)})',
            _fmt.format(kdvTutari),
            font,
            fontBold,
          ),
        pw.SizedBox(height: 4),
        pw.Container(height: 2, color: _amber),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: pw.BoxDecoration(
            color: _charcoal,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'GENEL TOPLAM',
                style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 11),
              ),
              pw.Text(
                '${_fmt.format(genelToplam)} ₺',
                style: pw.TextStyle(font: fontBold, color: _amber, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _hCell(String t, pw.Font f) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        child: pw.Text(
          t,
          style: pw.TextStyle(font: f, fontSize: 9, color: PdfColors.white),
          textAlign: pw.TextAlign.center,
        ),
      );

  static pw.Widget _dCell(String t, pw.Font f) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: pw.Text(
          t,
          style: pw.TextStyle(font: f, fontSize: 9.5, color: _charcoal),
          textAlign: pw.TextAlign.center,
        ),
      );

  static pw.Widget _totalRow(String label, String value, pw.Font font, pw.Font fontBold) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10, color: _textGray)),
            pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 10, color: _charcoal)),
          ],
        ),
      );
}
