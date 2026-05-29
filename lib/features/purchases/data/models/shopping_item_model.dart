import 'package:isar/isar.dart';

import '../../domain/entities/shopping_item.dart';

part 'shopping_item_model.g.dart';

/// Isar-модель активной покупки.
///
/// Это data-слой.
/// Он отвечает за то, как ShoppingItem хранится в локальной базе.
///
/// ShoppingItemModel — это строка текущего списка покупок:
/// - Молоко 2
/// - Хлеб
/// - Яйца 10
@collection
class ShoppingItemModel {
  /// Локальный технический id Isar.
  Id id = Isar.autoIncrement;

  /// Доменный id активной покупки.
  ///
  /// Отдельный от Isar id.
  @Index(unique: true, replace: false)
  late String domainId;

  /// id известного товара, с которым связана активная покупка.
  ///
  /// Делаем unique index, потому что в активном списке
  /// один известный товар должен быть только один раз.
  @Index(unique: true, replace: false)
  late String knownProductId;

  /// Название товара на момент добавления в список.
  late String nameSnapshot;

  /// Количество.
  ///
  /// Может быть null.
  /// Если null — количество на экране не показываем.
  String? quantity;

  /// Дата добавления в активный список.
  late DateTime createdAt;

  /// Порядок отображения.
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
      ..createdAt = createdAt
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
      createdAt: createdAt,
      sortOrder: sortOrder,
    );
  }
}
