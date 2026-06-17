import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../products/domain/entities/known_product.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_item_repository.dart';
import '../models/shopping_item_model.dart';

/// Isar-реализация репозитория товаров в списке покупок.
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
  Stream<List<ShoppingItem>> watchActive() {
    return _isar.shoppingItemModels
        .where()
        .filter()
        .statusEqualTo(ShoppingItemStatus.active.storageValue)
        .sortBySortOrder()
        .watch(fireImmediately: true)
        .map((models) {
          return models.map((model) => model.toEntity()).toList();
        });
  }

  @override
  Stream<List<ShoppingItem>> watchPurchased() {
    return _isar.shoppingItemModels
        .where()
        .filter()
        .statusEqualTo(ShoppingItemStatus.purchased.storageValue)
        .sortByPurchasedAtDesc()
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
  Future<List<ShoppingItem>> getActive() async {
    final models = await _isar.shoppingItemModels
        .where()
        .filter()
        .statusEqualTo(ShoppingItemStatus.active.storageValue)
        .sortBySortOrder()
        .findAll();

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<ShoppingItem>> getPurchased() async {
    final models = await _isar.shoppingItemModels
        .where()
        .filter()
        .statusEqualTo(ShoppingItemStatus.purchased.storageValue)
        .sortByPurchasedAtDesc()
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
        final existingItem = existingModel.toEntity();

        final sortOrder = existingItem.isActive
            ? existingItem.sortOrder
            : await _getNextSortOrder();

        final updatedItem = existingItem.activate(
          nameSnapshot: product.name,
          quantity: quantity,
          sortOrder: sortOrder,
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
  Future<ShoppingItem?> markPurchased(String id) async {
    return _isar.writeTxn(() async {
      final existingModel = await _isar.shoppingItemModels.getByDomainId(id);

      if (existingModel == null) {
        return null;
      }

      final updatedItem = existingModel.toEntity().markPurchased();

      await _isar.shoppingItemModels.put(
        updatedItem.toModel(isarId: existingModel.id),
      );

      return updatedItem;
    });
  }

  @override
  Future<ShoppingItem?> markDeleted(String id) async {
    return _isar.writeTxn(() async {
      final existingModel = await _isar.shoppingItemModels.getByDomainId(id);

      if (existingModel == null) {
        return null;
      }

      final updatedItem = existingModel.toEntity().markDeleted();

      await _isar.shoppingItemModels.put(
        updatedItem.toModel(isarId: existingModel.id),
      );

      return updatedItem;
    });
  }

  /// Возвращает следующий sortOrder для новой активной покупки.
  ///
  /// Важно:
  /// считаем только активные товары.
  /// Если товар был куплен и снова вернулся в список,
  /// он должен попасть вниз активного списка.
  Future<int> _getNextSortOrder() async {
    final lastItem = await _isar.shoppingItemModels
        .where()
        .filter()
        .statusEqualTo(ShoppingItemStatus.active.storageValue)
        .sortBySortOrderDesc()
        .findFirst();

    return (lastItem?.sortOrder ?? 0) + 1;
  }
}
