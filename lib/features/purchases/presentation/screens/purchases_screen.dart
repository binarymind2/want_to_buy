import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/known_product.dart';
import '../../../products/presentation/providers/known_product_providers.dart';
import '../../../products/presentation/providers/recent_known_product_providers.dart';
import '../../domain/entities/shopping_item.dart';
import '../providers/shopping_item_providers.dart';
import '../widgets/add_purchase_panel.dart';
import '../widgets/empty_purchases_view.dart';
import '../widgets/error_message_view.dart';
import '../widgets/shopping_items_list.dart';

/// Экран покупок.
///
/// Это главный экран приложения.
/// Он отвечает за пользовательский сценарий:
/// - показать активные покупки;
/// - добавить новую покупку;
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

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
    final recentProducts = ref.watch(recentKnownProductsProvider);

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
                    removalDelay: _removalDelay,
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
              recentProducts: recentProducts,
              activeKnownProductIds: activeKnownProductIds,
              onAddPressed: _onAddPressed,
            ),
          ],
        ),
      ),
    );
  }
}
