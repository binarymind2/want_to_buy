import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../products/domain/entities/known_product.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_item_repository.dart';
import '../models/shopping_item_model.dart';

/// Isar-реализация репозитория активных покупок.
///
/// Это data-слой.
///
/// Здесь мы работаем с ShoppingItemModel,
/// но наружу возвращаем чистую domain-сущность ShoppingItem.
class IsarShoppingItemRepository implements ShoppingItemRepository {
  IsarShoppingItemRepository({required Isar isar, Uuid? uuid})
    : _isar = isar,
      _uuid = uuid ?? const Uuid();

  final Isar _isar;
  final Uuid _uuid;

  @override
  Stream<List<ShoppingItem>> watchAll() {
    return _isar.shoppingItemModels
        .where()
        .sortBySortOrder()
        .watch(fireImmediately: true)
        .map((models) {
          return models.map((model) => model.toEntity()).toList();
        });
  }

  @override
  Future<List<ShoppingItem>> getAll() async {
    final models = await _isar.shoppingItemModels
        .where()
        .sortBySortOrder()
        .findAll();

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ShoppingItem?> findById(String id) async {
    final model = await _isar.shoppingItemModels.getByDomainId(id);

    return model?.toEntity();
  }

  @override
  Future<ShoppingItem?> findByKnownProductId(String knownProductId) async {
    final model = await _isar.shoppingItemModels.getByKnownProductId(
      knownProductId,
    );

    return model?.toEntity();
  }

  @override
  Future<ShoppingItem> addOrUpdate({
    required KnownProduct product,
    String? quantity,
  }) async {
    return _isar.writeTxn(() async {
      final existingModel = await _isar.shoppingItemModels.getByKnownProductId(
        product.id,
      );

      if (existingModel != null) {
        final updatedItem = ShoppingItem.fromStorage(
          id: existingModel.domainId,
          knownProductId: existingModel.knownProductId,
          nameSnapshot: product.name,
          quantity: quantity,
          createdAt: existingModel.createdAt,
          sortOrder: existingModel.sortOrder,
        );

        await _isar.shoppingItemModels.put(
          updatedItem.toModel(isarId: existingModel.id),
        );

        return updatedItem;
      }

      final nextSortOrder = await _getNextSortOrder();

      final newItem = ShoppingItem.create(
        id: _uuid.v4(),
        knownProductId: product.id,
        nameSnapshot: product.name,
        quantity: quantity,
        sortOrder: nextSortOrder,
      );

      await _isar.shoppingItemModels.put(newItem.toModel());

      return newItem;
    });
  }

  @override
  Future<void> deleteById(String id) async {
    await _isar.writeTxn(() async {
      final existingModel = await _isar.shoppingItemModels.getByDomainId(id);

      if (existingModel == null) {
        return;
      }

      await _isar.shoppingItemModels.delete(existingModel.id);
    });
  }

  /// Возвращает следующий sortOrder для новой активной покупки.
  ///
  /// Сейчас мы просто берём максимальный sortOrder в списке
  /// и прибавляем 1.
  ///
  /// Пример:
  /// уже есть:
  /// - Молоко, sortOrder = 1
  /// - Хлеб, sortOrder = 2
  ///
  /// новый товар получит sortOrder = 3.
  Future<int> _getNextSortOrder() async {
    final lastItem = await _isar.shoppingItemModels
        .where()
        .sortBySortOrderDesc()
        .findFirst();

    return (lastItem?.sortOrder ?? 0) + 1;
  }
}
