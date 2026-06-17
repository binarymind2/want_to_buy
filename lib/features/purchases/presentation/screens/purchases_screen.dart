import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/known_product.dart';
import '../../../products/presentation/providers/recent_known_product_providers.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../domain/entities/shopping_item.dart';
import '../providers/shopping_item_providers.dart';
import '../widgets/add_purchase_bottom_sheet.dart';
import '../widgets/empty_purchases_view.dart';
import '../widgets/error_message_view.dart';
import '../widgets/shopping_items_list.dart';

/// Экран покупок.
///
/// Это главный экран приложения.
/// Он отвечает за пользовательский сценарий:
/// - показать активные покупки;
/// - ниже показать последние покупки;
/// - открыть окно добавления новой покупки;
/// - запустить удаление покупки через 5 секунд;
/// - отменить удаление повторным нажатием.
///
/// Почему это ConsumerStatefulWidget:
/// - Consumer нужен, чтобы читать Riverpod providers через ref;
/// - Stateful нужен, потому что таймеры удаления — это временное UI-состояние.
class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> {
  static const Duration _removalDelay = Duration(seconds: 5);

  /// Таймеры отложенного удаления.
  ///
  /// Ключ — id активной покупки.
  /// Значение — Timer, который завершит покупку через 5 секунд.
  final Map<String, Timer> _removalTimers = {};

  /// id покупок, которые сейчас ожидают удаления.
  ///
  /// Это именно UI-состояние.
  /// В БД мы ничего не меняем, пока 5 секунд не прошли.
  final Set<String> _pendingRemovalItemIds = {};

  @override
  void dispose() {
    for (final timer in _removalTimers.values) {
      timer.cancel();
    }

    _removalTimers.clear();

    super.dispose();
  }

  void _openAddPurchaseSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AddPurchaseBottomSheet();
      },
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const SettingsScreen()),
    );
  }

  void _onShoppingItemPressed(ShoppingItem item) {
    if (_pendingRemovalItemIds.contains(item.id)) {
      _cancelPendingRemoval(item.id);
      return;
    }

    _startPendingRemoval(item);
  }

  /// Добавляет товар из последних покупок в активный список.
  ///
  /// Нажатие на последнюю покупку по-прежнему работает быстро:
  /// товар сразу возвращается в активный список.
  void _onRecentProductPressed(KnownProduct product) {
    unawaited(_addRecentProductToPurchases(product));
  }

  Future<void> _addRecentProductToPurchases(KnownProduct product) async {
    try {
      await ref.read(purchasesControllerProvider).addRecentPurchase(product);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось добавить последнюю покупку: $error'),
        ),
      );
    }
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
    final recentProducts = ref.watch(recentKnownProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Покупки'),
        actions: [
          IconButton(
            tooltip: 'Настройки',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: shoppingItemsAsync.when(
          data: (items) {
            final hasActiveItems = items.isNotEmpty;
            final hasRecentProducts = recentProducts.isNotEmpty;

            if (!hasActiveItems && !hasRecentProducts) {
              return const EmptyPurchasesView();
            }

            return ShoppingItemsList(
              items: items,
              recentProducts: recentProducts,
              pendingRemovalItemIds: _pendingRemovalItemIds,
              removalDelay: _removalDelay,
              onItemPressed: _onShoppingItemPressed,
              onRecentProductPressed: _onRecentProductPressed,
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: FloatingActionButton(
          tooltip: 'Добавить товар',
          onPressed: _openAddPurchaseSheet,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
