import 'package:flutter/material.dart';

import 'core/database/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppDatabase.open();

  runApp(const WantToBuyApp());
}

/// Главный виджет приложения.
///
/// Здесь мы настраиваем:
/// - название приложения;
/// - тему;
/// - стартовый экран.
class WantToBuyApp extends StatelessWidget {
  const WantToBuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Want to Buy',
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
/// Он отвечает за переключение между двумя вкладками:
/// - Покупки
/// - Настройки
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

/// Экран покупок.
///
/// Сейчас это только каркас:
/// - сверху будет список активных покупок;
/// - снизу уже есть панель добавления товара.
class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _onAddPressed() {
    final name = _nameController.text.trim();
    final quantity = _quantityController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите название товара')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          quantity.isEmpty
              ? 'Позже добавим товар: $name'
              : 'Позже добавим товар: $name, количество: $quantity',
        ),
      ),
    );

    _nameController.clear();
    _quantityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Покупки')),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(child: EmptyPurchasesView()),
            AddPurchasePanel(
              nameController: _nameController,
              quantityController: _quantityController,
              onAddPressed: _onAddPressed,
            ),
          ],
        ),
      ),
    );
  }
}

/// Пустое состояние списка покупок.
///
/// Пока настоящего списка ещё нет, показываем пользователю,
/// что список пустой и товар можно добавить снизу.
class EmptyPurchasesView extends StatelessWidget {
  const EmptyPurchasesView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 72,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Список покупок пуст',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте товар внизу экрана',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Нижняя панель добавления товара.
///
/// Здесь есть:
/// - поле названия товара;
/// - поле количества;
/// - кнопка "+".
///
/// Сейчас панель только собирает ввод пользователя.
/// Реальную запись в БД добавим позже.
class AddPurchasePanel extends StatelessWidget {
  const AddPurchasePanel({
    super.key,
    required this.nameController,
    required this.quantityController,
    required this.onAddPressed,
  });

  final TextEditingController nameController;
  final TextEditingController quantityController;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Товар',
                  hintText: 'Например: молоко',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Кол-во',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => onAddPressed(),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              width: 48,
              child: FilledButton(
                onPressed: onAddPressed,
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Экран настроек.
///
/// Пока здесь только будущие действия:
/// - проверка обновлений;
/// - просмотр товаров в БД.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showUpdateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Проверка обновлений'),
          content: const Text(
            'Позже здесь будет проверка новой версии приложения.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ОК'),
            ),
          ],
        );
      },
    );
  }

  void _showProductsDatabaseDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Товары в БД'),
          content: const Text(
            'Позже здесь будет список товаров, которые приложение запомнило.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: SafeArea(
        child: ListView(
          children: [
            const SettingsSectionTitle(title: 'Обновления'),
            ListTile(
              leading: const Icon(Icons.system_update_outlined),
              title: const Text('Проверить обновления'),
              subtitle: const Text('Позже подключим реальную проверку версии'),
              onTap: () => _showUpdateDialog(context),
            ),
            const Divider(height: 1),
            const SettingsSectionTitle(title: 'База товаров'),
            ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text('Показать товары в БД'),
              subtitle: const Text('Позже покажем сохранённые товары'),
              onTap: () => _showProductsDatabaseDialog(context),
            ),
            const Divider(height: 1),
            const SettingsSectionTitle(title: 'О приложении'),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Want to Buy'),
              subtitle: Text('Минималистичный список покупок'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Заголовок секции на экране настроек.
class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
