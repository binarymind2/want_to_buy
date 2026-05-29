import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/app_database.dart';
import 'features/products/presentation/providers/known_product_providers.dart';
import 'features/purchases/domain/entities/shopping_item.dart';
import 'features/purchases/presentation/providers/shopping_item_providers.dart';

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
/// Теперь это ConsumerStatefulWidget.
///
/// Почему не обычный StatefulWidget:
/// экрану нужно читать providers через ref:
/// - shoppingItemsProvider;
/// - purchasesControllerProvider.
class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onAddPressed() async {
    final name = _nameController.text.trim();
    final quantity = _quantityController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите название товара')));
      return;
    }

    try {
      await ref
          .read(purchasesControllerProvider)
          .addPurchase(name: name, quantity: quantity);

      if (!mounted) {
        return;
      }

      _nameController.clear();
      _quantityController.clear();
      _nameFocusNode.requestFocus();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось добавить товар: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoppingItemsAsync = ref.watch(shoppingItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Покупки')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: shoppingItemsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyPurchasesView();
                  }

                  return ShoppingItemsList(items: items);
                },
                loading: () {
                  return const Center(child: CircularProgressIndicator());
                },
                error: (error, stackTrace) {
                  return ErrorMessageView(
                    title: 'Не удалось загрузить список покупок',
                    message: error.toString(),
                  );
                },
              ),
            ),
            AddPurchasePanel(
              nameController: _nameController,
              quantityController: _quantityController,
              nameFocusNode: _nameFocusNode,
              onAddPressed: _onAddPressed,
            ),
          ],
        ),
      ),
    );
  }
}

/// Список активных покупок.
class ShoppingItemsList extends StatelessWidget {
  const ShoppingItemsList({super.key, required this.items});

  final List<ShoppingItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (context, index) {
        return const Divider(height: 1);
      },
      itemBuilder: (context, index) {
        return ShoppingItemTile(item: items[index]);
      },
    );
  }
}

/// Одна строка активной покупки.
///
/// Сейчас строка только отображает товар.
/// В следующем шаге сюда добавим:
/// - нажатие;
/// - 5-секундный отсчёт;
/// - прогресс-бар;
/// - отмену удаления.
class ShoppingItemTile extends StatelessWidget {
  const ShoppingItemTile({super.key, required this.item});

  final ShoppingItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.nameSnapshot,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (item.hasQuantity) ...[
            const SizedBox(width: 12),
            Text(
              item.quantity!,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

/// Пустое состояние списка покупок.
///
/// Показываем его, когда shoppingItemsProvider вернул пустой список.
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
class AddPurchasePanel extends StatelessWidget {
  const AddPurchasePanel({
    super.key,
    required this.nameController,
    required this.quantityController,
    required this.nameFocusNode,
    required this.onAddPressed,
  });

  final TextEditingController nameController;
  final TextEditingController quantityController;
  final FocusNode nameFocusNode;
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
                focusNode: nameFocusNode,
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
/// Сейчас здесь:
/// - проверка обновлений;
/// - просмотр товаров в БД;
/// - информация о приложении.
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
          content: SizedBox(
            width: double.maxFinite,
            child: Consumer(
              builder: (context, ref, child) {
                final productsAsync = ref.watch(knownProductsProvider);

                return productsAsync.when(
                  data: (products) {
                    if (products.isEmpty) {
                      return const Text(
                        'База товаров пока пустая.\n'
                        'Добавьте товар на экране покупок.',
                      );
                    }

                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 360),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: products.length,
                        separatorBuilder: (context, index) {
                          return const Divider(height: 1);
                        },
                        itemBuilder: (context, index) {
                          final product = products[index];

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(product.name),
                            subtitle: product.wasPurchased
                                ? const Text('Товар уже покупали')
                                : const Text('Пока не покупали'),
                          );
                        },
                      ),
                    );
                  },
                  loading: () {
                    return const SizedBox(
                      height: 96,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  error: (error, stackTrace) {
                    return Text('Не удалось загрузить товары: $error');
                  },
                );
              },
            ),
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
              subtitle: const Text('Показать сохранённые товары'),
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

/// Виджет для отображения ошибки.
class ErrorMessageView extends StatelessWidget {
  const ErrorMessageView({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
