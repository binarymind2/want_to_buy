import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../purchases/domain/entities/shopping_item.dart';
import '../../../purchases/presentation/providers/shopping_item_providers.dart';

/// Provider последних покупок.
///
/// Название файла осталось старым, чтобы рефакторинг был меньше,
/// но источник данных изменился.
///
/// Раньше последние покупки строились из KnownProduct.lastPurchasedAt.
/// Теперь KnownProduct — чистый справочник, поэтому последние покупки
/// строятся из ShoppingItem со status == purchased.
final recentShoppingItemsProvider = Provider<List<ShoppingItem>>((ref) {
  final purchasedItemsAsync = ref.watch(purchasedShoppingItemsProvider);

  return purchasedItemsAsync.maybeWhen(
    data: (items) => items,
    orElse: () => const <ShoppingItem>[],
  );
});
