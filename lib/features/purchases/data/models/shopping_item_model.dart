import 'package:isar/isar.dart';

import '../../domain/entities/shopping_item.dart';

part 'shopping_item_model.g.dart';

/// Isar-модель товара в списке покупок.
///
/// Это data-слой.
/// Он отвечает за то, как ShoppingItem хранится в локальной базе.
///
/// ShoppingItemModel больше не является только активной покупкой.
/// Это состояние товара относительно списка:
/// - active;
/// - purchased;
/// - deleted.
@collection
class ShoppingItemModel {
  /// Локальный технический id Isar.
  Id id = Isar.autoIncrement;

  /// Доменный id записи состояния товара.
  ///
  /// Отдельный от Isar id.
  @Index(unique: true, replace: false)
  late String domainId;

  /// id известного товара, с которым связана эта запись.
  ///
  /// Делаем unique index, потому что в рамках списка
  /// один известный товар должен иметь только один ShoppingItem.
  @Index(unique: true, replace: false)
  late String knownProductId;

  /// Название товара на момент последнего добавления в список.
  late String nameSnapshot;

  /// Количество.
  ///
  /// Может быть null.
  /// Если null — количество на экране не показываем.
  String? quantity;

  /// Состояние записи.
  ///
  /// Храним строку, а не индекс enum.
  /// Так база переживёт изменение порядка enum-значений в Dart-коде.
  @Index()
  late String status;

  /// Дата создания записи.
  late DateTime createdAt;

  /// Дата последнего изменения записи.
  late DateTime updatedAt;

  /// Дата последней покупки.
  @Index()
  DateTime? purchasedAt;

  /// Дата удаления из списка.
  DateTime? deletedAt;

  /// Порядок отображения в активном списке.
  late int sortOrder;
}

/// Маппинг из domain-сущности в Isar-модель.
///
/// Domain → Data
extension ShoppingItemToModel on ShoppingItem {
  ShoppingItemModel toModel({Id? isarId}) {
    return ShoppingItemModel()
      ..id = isarId ?? Isar.autoIncrement
      ..domainId = id
      ..knownProductId = knownProductId
      ..nameSnapshot = nameSnapshot
      ..quantity = quantity
      ..status = status.storageValue
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..purchasedAt = purchasedAt
      ..deletedAt = deletedAt
      ..sortOrder = sortOrder;
  }
}

/// Маппинг из Isar-модели в domain-сущность.
///
/// Data → Domain
extension ShoppingItemModelToEntity on ShoppingItemModel {
  ShoppingItem toEntity() {
    return ShoppingItem.fromStorage(
      id: domainId,
      knownProductId: knownProductId,
      nameSnapshot: nameSnapshot,
      quantity: quantity,
      status: ShoppingItemStatusStorage.fromStorage(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
      purchasedAt: purchasedAt,
      deletedAt: deletedAt,
      sortOrder: sortOrder,
    );
  }
}
