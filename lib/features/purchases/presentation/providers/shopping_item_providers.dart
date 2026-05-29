import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/isar_provider.dart';
import '../../../products/presentation/providers/known_product_providers.dart';
import '../../data/repositories/isar_shopping_item_repository.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_item_repository.dart';
import '../controllers/purchases_controller.dart';

/// Provider репозитория активных покупок.
///
/// Здесь мы создаём Isar-реализацию ShoppingItemRepository.
final shoppingItemRepositoryProvider = Provider<ShoppingItemRepository>((ref) {
  final isar = ref.watch(isarProvider);

  return IsarShoppingItemRepository(isar: isar);
});

/// Provider активного списка покупок.
///
/// Это StreamProvider:
/// экран будет автоматически обновляться,
/// когда в Isar изменится список ShoppingItem.
final shoppingItemsProvider = StreamProvider<List<ShoppingItem>>((ref) {
  final repository = ref.watch(shoppingItemRepositoryProvider);

  return repository.watchAll();
});

/// Provider controller-а для экрана покупок.
///
/// Controller получает оба репозитория:
/// - KnownProductRepository;
/// - ShoppingItemRepository.
///
/// Почему оба:
/// при добавлении товара нужно сначала найти или создать известный товар,
/// а потом добавить активную покупку.
final purchasesControllerProvider = Provider<PurchasesController>((ref) {
  final knownProductRepository = ref.watch(knownProductRepositoryProvider);
  final shoppingItemRepository = ref.watch(shoppingItemRepositoryProvider);

  return PurchasesController(
    knownProductRepository: knownProductRepository,
    shoppingItemRepository: shoppingItemRepository,
  );
});
