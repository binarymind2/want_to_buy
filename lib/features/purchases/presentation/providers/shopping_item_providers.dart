import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/isar_provider.dart';
import '../../../products/presentation/providers/known_product_providers.dart';
import '../../data/repositories/isar_shopping_item_repository.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_item_repository.dart';
import '../controllers/purchases_controller.dart';

/// Provider репозитория товаров в списке покупок.
///
/// Здесь мы создаём Isar-реализацию ShoppingItemRepository.
final shoppingItemRepositoryProvider = Provider<ShoppingItemRepository>((ref) {
  final isar = ref.watch(isarProvider);

  return IsarShoppingItemRepository(isar: isar);
});

/// Provider всех ShoppingItem.
///
/// Здесь есть active, purchased и deleted записи.
/// Используем этот provider там, где нужно знать последнее состояние товара,
/// например в bottom sheet для подстановки последнего quantity.
final allShoppingItemsProvider = StreamProvider<List<ShoppingItem>>((ref) {
  final repository = ref.watch(shoppingItemRepositoryProvider);

  return repository.watchAll();
});

/// Provider активного списка покупок.
///
/// Это StreamProvider:
/// экран будет автоматически обновляться,
/// когда в Isar изменится активный список ShoppingItem.
final shoppingItemsProvider = StreamProvider<List<ShoppingItem>>((ref) {
  final repository = ref.watch(shoppingItemRepositoryProvider);

  return repository.watchActive();
});

/// Provider последних покупок.
///
/// Это ShoppingItem со status == purchased.
final purchasedShoppingItemsProvider = StreamProvider<List<ShoppingItem>>((
  ref,
) {
  final repository = ref.watch(shoppingItemRepositoryProvider);

  return repository.watchPurchased();
});

/// Provider controller-а для экрана покупок.
///
/// Controller получает оба репозитория:
/// - KnownProductRepository;
/// - ShoppingItemRepository.
///
/// Почему оба:
/// при добавлении товара нужно сначала найти или создать известный товар,
/// а потом добавить/активировать ShoppingItem.
final purchasesControllerProvider = Provider<PurchasesController>((ref) {
  final knownProductRepository = ref.watch(knownProductRepositoryProvider);
  final shoppingItemRepository = ref.watch(shoppingItemRepositoryProvider);

  return PurchasesController(
    knownProductRepository: knownProductRepository,
    shoppingItemRepository: shoppingItemRepository,
  );
});
