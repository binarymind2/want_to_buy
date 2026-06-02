import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/app_database.dart';
import 'features/products/domain/entities/known_product.dart';
import 'features/products/domain/utils/product_name_normalizer.dart';
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
  static const Duration _removalDelay = Duration(seconds: 5);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  final Map<String, Timer> _removalTimers = {};
  final Set<String> _pendingRemovalItemIds = {};

  @override
  void dispose() {
    for (final timer in _removalTimers.values) {
      timer.cancel();
    }

    _removalTimers.clear();

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

  void _onShoppingItemPressed(ShoppingItem item) {
    if (_pendingRemovalItemIds.contains(item.id)) {
      _cancelPendingRemoval(item.id);
      return;
    }

    _startPendingRemoval(item);
  }

  void _startPendingRemoval(ShoppingItem item) {
    final itemId = item.id;

    _removalTimers[itemId]?.cancel();

    setState(() {
      _pendingRemovalItemIds.add(itemId);
    });

    _removalTimers[itemId] = Timer(_removalDelay, () {
      unawaited(_completePendingRemoval(item));
    });
  }

  void _cancelPendingRemoval(String itemId) {
    final timer = _removalTimers.remove(itemId);
    timer?.cancel();

    if (!_pendingRemovalItemIds.contains(itemId)) {
      return;
    }

    setState(() {
      _pendingRemovalItemIds.remove(itemId);
    });
  }

  Future<void> _completePendingRemoval(ShoppingItem item) async {
    final itemId = item.id;

    _removalTimers.remove(itemId);

    if (mounted) {
      setState(() {
        _pendingRemovalItemIds.remove(itemId);
      });
    }

    try {
      await ref.read(purchasesControllerProvider).completePurchase(item);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось завершить покупку: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoppingItemsAsync = ref.watch(shoppingItemsProvider);
    final knownProductsAsync = ref.watch(knownProductsProvider);

    final knownProducts = knownProductsAsync.maybeWhen(
      data: (products) => products,
      orElse: () => const <KnownProduct>[],
    );

    final activeKnownProductIds = shoppingItemsAsync.maybeWhen(
      data: (items) {
        return items.map((item) => item.knownProductId).toSet();
      },
      orElse: () => const <String>{},
    );

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

                  return ShoppingItemsList(
                    items: items,
                    pendingRemovalItemIds: _pendingRemovalItemIds,
                    onItemPressed: _onShoppingItemPressed,
                  );
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
              knownProducts: knownProducts,
              activeKnownProductIds: activeKnownProductIds,
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
  const ShoppingItemsList({
    super.key,
    required this.items,
    required this.pendingRemovalItemIds,
    required this.onItemPressed,
  });

  final List<ShoppingItem> items;
  final Set<String> pendingRemovalItemIds;
  final ValueChanged<ShoppingItem> onItemPressed;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (context, index) {
        return const Divider(height: 1);
      },
      itemBuilder: (context, index) {
        final item = items[index];

        return ShoppingItemTile(
          key: ValueKey(item.id),
          item: item,
          isPendingRemoval: pendingRemovalItemIds.contains(item.id),
          onPressed: () => onItemPressed(item),
        );
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
  const ShoppingItemTile({
    super.key,
    required this.item,
    required this.isPendingRemoval,
    required this.onPressed,
  });

  final ShoppingItem item;
  final bool isPendingRemoval;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onPressed,
      child: AnimatedOpacity(
        opacity: isPendingRemoval ? 0.55 : 1,
        duration: const Duration(milliseconds: 180),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
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
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isPendingRemoval)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('removal-progress-${item.id}'),
                  tween: Tween<double>(begin: 1, end: 0),
                  duration: const Duration(seconds: 5),
                  curve: Curves.linear,
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 3,
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.08,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary.withValues(alpha: 0.35),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
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
/// - кнопка "+";
/// - подсказки известных товаров.
class AddPurchasePanel extends StatelessWidget {
  const AddPurchasePanel({
    super.key,
    required this.nameController,
    required this.quantityController,
    required this.nameFocusNode,
    required this.knownProducts,
    required this.activeKnownProductIds,
    required this.onAddPressed,
  });

  final TextEditingController nameController;
  final TextEditingController quantityController;
  final FocusNode nameFocusNode;

  /// Все известные товары из БД.
  ///
  /// Именно из них мы строим подсказки.
  final List<KnownProduct> knownProducts;

  /// id товаров, которые уже есть в активном списке покупок.
  ///
  /// Зачем нужно:
  /// если товар уже добавлен в покупки, не нужно снова предлагать его
  /// в подсказках.
  final Set<String> activeKnownProductIds;

  final VoidCallback onAddPressed;

  /// Ищет подсказки для текущего текста в поле названия.
  ///
  /// Пример:
  /// query: "мо"
  ///
  /// knownProducts:
  /// - Молоко
  /// - Морковь
  /// - Хлеб
  ///
  /// результат:
  /// - Молоко
  /// - Морковь
  List<KnownProduct> _findSuggestions(String query) {
    final normalizedQuery = normalizeProductName(query);

    if (normalizedQuery.isEmpty) {
      return const <KnownProduct>[];
    }

    final suggestions = knownProducts.where((product) {
      final isAlreadyInActiveList = activeKnownProductIds.contains(product.id);

      if (isAlreadyInActiveList) {
        return false;
      }

      return product.normalizedName.contains(normalizedQuery);
    }).toList();

    suggestions.sort((first, second) {
      final firstStartsWithQuery = first.normalizedName.startsWith(
        normalizedQuery,
      );
      final secondStartsWithQuery = second.normalizedName.startsWith(
        normalizedQuery,
      );

      if (firstStartsWithQuery != secondStartsWithQuery) {
        return firstStartsWithQuery ? -1 : 1;
      }

      return first.normalizedName.compareTo(second.normalizedName);
    });

    return suggestions.take(5).toList();
  }

  /// Подставляет выбранную подсказку в поле названия.
  void _selectSuggestion(KnownProduct product) {
    nameController.value = TextEditingValue(
      text: product.name,
      selection: TextSelection.collapsed(offset: product.name.length),
    );

    nameFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: nameController,
              builder: (context, value, child) {
                final suggestions = _findSuggestions(value.text);

                if (suggestions.isEmpty) {
                  return const SizedBox.shrink();
                }

                return ProductSuggestionsList(
                  suggestions: suggestions,
                  onSuggestionSelected: _selectSuggestion,
                );
              },
            ),
            Row(
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
          ],
        ),
      ),
    );
  }
}

/// Список подсказок для поля названия товара.
///
/// Это не отдельный экран и не данные из интернета.
/// Это маленькая панель над нижней строкой ввода.
///
/// Почему подсказки здесь:
/// пользователь вводит товар внизу экрана,
/// поэтому варианты должны появляться рядом с местом ввода.
class ProductSuggestionsList extends StatelessWidget {
  const ProductSuggestionsList({
    super.key,
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  final List<KnownProduct> suggestions;
  final ValueChanged<KnownProduct> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: suggestions.length,
            separatorBuilder: (context, index) {
              return const Divider(height: 1);
            },
            itemBuilder: (context, index) {
              final product = suggestions[index];

              return ListTile(
                dense: true,
                leading: const Icon(Icons.history),
                title: Text(product.name),
                onTap: () => onSuggestionSelected(product),
              );
            },
          ),
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
