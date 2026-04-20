import '../models/app_settings.dart';
import '../models/sineklik_item.dart';

class CalculationResult {
  final double kasa;
  final double kanat;
  final double tul;
  final double ip;
  final double serit;
  final double aksesuar;
  final double iscilik;
  final double toplam;

  const CalculationResult({
    required this.kasa,
    required this.kanat,
    required this.tul,
    required this.ip,
    required this.serit,
    required this.aksesuar,
    required this.iscilik,
    required this.toplam,
  });
}

class CalculationService {
  // Exact formulas reverse-engineered from Excel spreadsheet
  // Verified: EN=100, BOY=200 → TOPLAM=1398.48
  //
  // Row 4 formulas (cost contributions):
  //   KASA   = (EN + BOY) * 2
  //   KANAT  = BOY - 8
  //   TÜL    = (EN/100) * (BOY/100) * TUL_TUTARI
  //   İP     = ((EN + BOY) * 2) * (IP_TUTARI / 500) / 100
  //   ŞERİT  = (BOY + BOY) * (SERIT_TUTARI / 100)
  //   AKSESUAR = AKSESUAR_TUTARI
  //   İŞÇİLİK = manual input

  static CalculationResult calculate(
    SineklikItem item,
    AppSettings settings,
  ) {
    final en = item.en;
    final boy = item.boy;
    final iscilik = item.iscilikOverride ?? settings.iscilikTutari;

    final kasa = (en + boy) * 2;
    final kanat = boy - 8;
    final tul = (en / 100) * (boy / 100) * settings.tulTutari;
    final ip = ((en + boy) * 2) * (settings.ipTutari / 500) / 100;
    final serit = (boy + boy) * (settings.seritTutari / 100);
    final aksesuar = settings.aksesuarTutari;
    final iscilikCost = iscilik;

    final toplam = kasa + kanat + tul + ip + serit + aksesuar + iscilikCost;

    return CalculationResult(
      kasa: kasa,
      kanat: kanat,
      tul: tul,
      ip: ip,
      serit: serit,
      aksesuar: aksesuar,
      iscilik: iscilikCost,
      toplam: toplam,
    );
  }

  static double calculateTotal(SineklikItem item, AppSettings settings) {
    return calculate(item, settings).toplam;
  }

  static double calculateGrandTotal(
    List<SineklikItem> items,
    AppSettings settings,
  ) {
    return items.fold(0, (sum, item) => sum + calculateTotal(item, settings));
  }

  static double calculateWithKdv(double total, double kdvOrani) {
    return total * (1 + kdvOrani);
  }
}
