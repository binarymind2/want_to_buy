import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/app_database.dart';
import 'features/purchases/presentation/screens/purchases_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppDatabase.open();

  runApp(const ProviderScope(child: WantToBuyApp()));
}

/// Главный виджет приложения.
///
/// Здесь мы настраиваем:
/// - название приложения;
/// - светлую цветовую тему;
/// - стартовый экран.
///
/// Важно:
/// ProviderScope находится выше WantToBuyApp в main().
/// Благодаря этому все виджеты внутри приложения могут использовать Riverpod.
class WantToBuyApp extends StatelessWidget {
  const WantToBuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Хочу купить',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E8C61),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFBFDF8),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Color(0xFFFBFDF8),
          foregroundColor: Color(0xFF1A1C18),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Color(0xFFFFFFFF),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFFFFFFF),
        ),
      ),
      home: const PurchasesScreen(),
    );
  }
}
