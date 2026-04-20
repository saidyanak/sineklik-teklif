import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../providers/settings_provider.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firmaAdiCtrl;
  late final TextEditingController _telefonCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _kasaCtrl;
  late final TextEditingController _kanatCtrl;
  late final TextEditingController _tulCtrl;
  late final TextEditingController _ipCtrl;
  late final TextEditingController _seritCtrl;
  late final TextEditingController _aksesuarCtrl;
  late final TextEditingController _iscilikCtrl;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>().settings;
    _firmaAdiCtrl = TextEditingController(text: s.firmaAdi);
    _telefonCtrl = TextEditingController(text: s.telefon);
    _websiteCtrl = TextEditingController(text: s.website);
    _kasaCtrl = TextEditingController(text: s.kasaTutari.toStringAsFixed(0));
    _kanatCtrl = TextEditingController(text: s.kanatTutari.toStringAsFixed(0));
    _tulCtrl = TextEditingController(text: s.tulTutari.toStringAsFixed(0));
    _ipCtrl = TextEditingController(text: s.ipTutari.toStringAsFixed(0));
    _seritCtrl = TextEditingController(text: s.seritTutari.toStringAsFixed(0));
    _aksesuarCtrl = TextEditingController(text: s.aksesuarTutari.toStringAsFixed(0));
    _iscilikCtrl = TextEditingController(text: s.iscilikTutari.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _firmaAdiCtrl.dispose();
    _telefonCtrl.dispose();
    _websiteCtrl.dispose();
    _kasaCtrl.dispose();
    _kanatCtrl.dispose();
    _tulCtrl.dispose();
    _ipCtrl.dispose();
    _seritCtrl.dispose();
    _aksesuarCtrl.dispose();
    _iscilikCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final updated = AppSettings(
      firmaAdi: _firmaAdiCtrl.text.trim(),
      telefon: _telefonCtrl.text.trim(),
      website: _websiteCtrl.text.trim(),
      kasaTutari: double.parse(_kasaCtrl.text),
      kanatTutari: double.parse(_kanatCtrl.text),
      tulTutari: double.parse(_tulCtrl.text),
      ipTutari: double.parse(_ipCtrl.text),
      seritTutari: double.parse(_seritCtrl.text),
      aksesuarTutari: double.parse(_aksesuarCtrl.text),
      iscilikTutari: double.parse(_iscilikCtrl.text),
    );
    await context.read<SettingsProvider>().update(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ayarlar kaydedildi'),
          backgroundColor: kAmber,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader('Firma Bilgileri'),
            _buildTextField(
              controller: _firmaAdiCtrl,
              label: 'Firma Adı',
              icon: Icons.business,
              isText: true,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _telefonCtrl,
              label: 'Telefon Numarası',
              icon: Icons.phone,
              isText: true,
              required: false,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _websiteCtrl,
              label: 'Web Sitesi',
              icon: Icons.language,
              isText: true,
              required: false,
            ),
            const SizedBox(height: 16),
            _SectionHeader('Malzeme Tutarları (₺)'),
            const Text(
              'Bu değerler malzeme birim fiyatlarını temsil eder.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _kasaCtrl,
              label: 'KASA Tutarı (₺)',
              icon: Icons.window,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _kanatCtrl,
              label: 'KANAT Tutarı (₺)',
              icon: Icons.door_back_door,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _tulCtrl,
              label: 'TÜL Metre Fiyatı (₺/m²)',
              icon: Icons.grid_on,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _ipCtrl,
              label: 'İP Tutarı (₺)',
              icon: Icons.linear_scale,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _seritCtrl,
              label: 'ŞERİT Metre Fiyatı (₺/m)',
              icon: Icons.horizontal_rule,
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _aksesuarCtrl,
              label: 'AKSESUAR Tutarı (₺)',
              icon: Icons.settings_input_component,
            ),
            const SizedBox(height: 16),
            _SectionHeader('İşçilik'),
            _buildTextField(
              controller: _iscilikCtrl,
              label: 'Varsayılan İşçilik (₺)',
              icon: Icons.handyman,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Ayarları Kaydet', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAmber,
                  foregroundColor: kCharcoal,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isText = false,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: true,
      ),
      keyboardType: isText
          ? TextInputType.text
          : const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: isText
          ? null
          : [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      validator: (v) {
        if (!required) return null;
        if (v == null || v.isEmpty) return 'Bu alan boş bırakılamaz';
        if (!isText && double.tryParse(v) == null) return 'Geçerli bir sayı girin';
        return null;
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: kAmber,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kCharcoal,
              ),
            ),
          ],
        ),
      );
}
