import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'providers/settings_provider.dart';
import 'providers/quote_provider.dart';
import 'services/quote_repository.dart';
import 'services/local_quote_repository.dart';
import 'services/supabase_quote_service.dart';
import 'screens/settings_screen.dart';
import 'screens/quote_form_screen.dart';
import 'screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  QuoteRepository repository;
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    repository = SupabaseQuoteService();
  } else {
    repository = LocalQuoteRepository();
  }

  final settingsProvider = SettingsProvider();
  final quoteProvider = QuoteProvider(repository);
  await settingsProvider.load();
  await quoteProvider.loadHistory();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: quoteProvider),
      ],
      child: const SineklikTeklifApp(),
    ),
  );
}

const kAmber = Color(0xFFF5A623);
const kCharcoal = Color(0xFF3D3D3D);
const kAmberLight = Color(0xFFFFF3D9);

class SineklikTeklifApp extends StatelessWidget {
  const SineklikTeklifApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sineklik Teklif',
      debugShowCheckedModeBanner: false,
      locale: const Locale('tr', 'TR'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kAmber).copyWith(
          primary: kCharcoal,
          onPrimary: Colors.white,
          primaryContainer: kAmberLight,
          onPrimaryContainer: kCharcoal,
          secondary: kAmber,
          onSecondary: kCharcoal,
          secondaryContainer: kAmberLight,
          onSecondaryContainer: kCharcoal,
          tertiary: kAmber,
          onTertiary: kCharcoal,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: kCharcoal,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: kAmber, width: 2),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kCharcoal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kCharcoal,
            side: const BorderSide(color: kCharcoal),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? kAmber : Colors.grey,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? kAmberLight
                : Colors.grey.shade200,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    QuoteFormScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: kAmberLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box, color: kCharcoal),
            label: 'Teklif',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: kCharcoal),
            label: 'Geçmiş',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: kCharcoal),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}
