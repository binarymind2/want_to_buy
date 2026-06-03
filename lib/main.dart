import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/app_database.dart';
import 'features/purchases/presentation/screens/purchases_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppDatabase.open();

  runApp(const ProviderScope(child: WantToBuyApp()));
}

/// Главный виджет приложения.
///
/// Здесь мы настраиваем:
/// - название приложения;
/// - тему;
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

/// Основной экран-контейнер.
///
/// Он отвечает только за переключение между двумя вкладками:
/// - Покупки;
/// - Настройки.
///
/// Важно:
/// конкретная логика экрана покупок теперь вынесена в PurchasesScreen.
/// main.dart остаётся точкой входа и не превращается в большой файл со всем UI.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [PurchasesScreen(), SettingsScreen()];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Покупки',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}
