import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/sineklik_item.dart';
import '../providers/settings_provider.dart';
import '../services/calculation_service.dart';
import '../main.dart';
import 'package:intl/intl.dart';

class SineklikRowWidget extends StatefulWidget {
  final int index;
  final SineklikItem item;
  final bool canDelete;
  final VoidCallback onDelete;
  final void Function(SineklikItem updated) onChanged;

  const SineklikRowWidget({
    super.key,
    required this.index,
    required this.item,
    required this.canDelete,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<SineklikRowWidget> createState() => _SineklikRowWidgetState();
}

class _SineklikRowWidgetState extends State<SineklikRowWidget> {
  late final TextEditingController _konumCtrl;
  late final TextEditingController _enCtrl;
  late final TextEditingController _boyCtrl;
  late final TextEditingController _iscilikCtrl;
  bool _iscilikOverrideEnabled = false;

  static final _fmt = NumberFormat('#,##0.00', 'tr_TR');

  @override
  void initState() {
    super.initState();
    _konumCtrl = TextEditingController(text: widget.item.konum);
    _enCtrl = TextEditingController(text: widget.item.en.toStringAsFixed(0));
    _boyCtrl = TextEditingController(text: widget.item.boy.toStringAsFixed(0));
    _iscilikOverrideEnabled = widget.item.iscilikOverride != null;
    final settings = context.read<SettingsProvider>().settings;
    _iscilikCtrl = TextEditingController(
      text: (widget.item.iscilikOverride ?? settings.iscilikTutari).toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _konumCtrl.dispose();
    _enCtrl.dispose();
    _boyCtrl.dispose();
    _iscilikCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    final en = double.tryParse(_enCtrl.text) ?? widget.item.en;
    final boy = double.tryParse(_boyCtrl.text) ?? widget.item.boy;
    final iscilik = _iscilikOverrideEnabled
        ? double.tryParse(_iscilikCtrl.text)
        : null;
    widget.onChanged(
      SineklikItem(
        id: widget.item.id,
        konum: _konumCtrl.text,
        en: en,
        boy: boy,
        iscilikOverride: iscilik,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final result = CalculationService.calculate(widget.item, settings);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Üst başlık şeridi – amber
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: kAmberLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: kAmber,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index + 1}',
                      style: const TextStyle(
                        color: kCharcoal,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Sineklik',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: kCharcoal,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                if (widget.canDelete)
                  InkWell(
                    onTap: widget.onDelete,
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    ),
                  ),
              ],
            ),
          ),

          // İçerik
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _konumCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Konum / Oda Adı',
                    hintText: 'Örn: Salon, Yatak Odası',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => _notify(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _enCtrl,
                        decoration: const InputDecoration(
                          labelText: 'EN (cm)',
                          prefixIcon: Icon(Icons.swap_horiz),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => _notify(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _boyCtrl,
                        decoration: const InputDecoration(
                          labelText: 'BOY (cm)',
                          prefixIcon: Icon(Icons.swap_vert),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => _notify(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Switch(
                      value: _iscilikOverrideEnabled,
                      onChanged: (v) {
                        setState(() => _iscilikOverrideEnabled = v);
                        _notify();
                      },
                    ),
                    const Text('İşçilik Özelleştir', style: TextStyle(fontSize: 13)),
                    if (_iscilikOverrideEnabled) ...[
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _iscilikCtrl,
                          decoration: const InputDecoration(
                            labelText: 'İşçilik (₺)',
                            isDense: true,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                          onChanged: (_) => _notify(),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                // Birim maliyet
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: kCharcoal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Birim Maliyet',
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                      Text(
                        '₺${_fmt.format(result.toplam)}',
                        style: const TextStyle(
                          color: kAmber,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
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
