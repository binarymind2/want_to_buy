import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../purchases/presentation/providers/shopping_item_providers.dart';
import '../../domain/entities/known_product.dart';
import 'known_product_providers.dart';

/// Provider последних покупок.
///
/// Мы не создаём отдельную таблицу истории покупок.
/// Вместо этого используем поле KnownProduct.lastPurchasedAt.
///
/// Логика:
/// - берём все известные товары;
/// - оставляем только те, которые уже покупали;
/// - исключаем товары, которые уже есть в активном списке;
/// - сортируем от самой новой покупки к самой старой;
/// - берём первые 5 товаров.
///
/// Почему исключаем активные товары:
/// если "Молоко" уже есть в списке покупок,
/// не нужно предлагать его ещё раз в блоке "Последние покупки".
final recentKnownProductsProvider = Provider<List<KnownProduct>>((ref) {
  final knownProductsAsync = ref.watch(knownProductsProvider);
  final shoppingItemsAsync = ref.watch(shoppingItemsProvider);

  final activeKnownProductIds = shoppingItemsAsync.maybeWhen(
    data: (items) {
      return items.map((item) => item.knownProductId).toSet();
    },
    orElse: () => const <String>{},
  );

  return knownProductsAsync.maybeWhen(
    data: (products) {
      final recentProducts = products.where((product) {
        final wasPurchased = product.lastPurchasedAt != null;
        final isAlreadyInActiveList = activeKnownProductIds.contains(
          product.id,
        );

        return wasPurchased && !isAlreadyInActiveList;
      }).toList();

      recentProducts.sort((first, second) {
        return second.lastPurchasedAt!.compareTo(first.lastPurchasedAt!);
      });

      return recentProducts.take(5).toList();
    },
    orElse: () => const <KnownProduct>[],
  );
});
