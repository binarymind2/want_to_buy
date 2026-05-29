import 'package:isar/isar.dart';

import '../../domain/entities/known_product.dart';

part 'known_product_model.g.dart';

/// Isar-модель известного товара.
///
/// Это data-слой.
/// Он отвечает за то, как KnownProduct хранится в локальной базе.
///
/// Важно:
/// KnownProductModel — это НЕ бизнес-сущность.
/// Бизнес-сущность находится в domain/entities/known_product.dart.
@collection
class KnownProductModel {
  /// Локальный технический id Isar.
  ///
  /// Это id нужен самой базе данных.
  /// Его не показываем пользователю и не используем как бизнес-id.
  Id id = Isar.autoIncrement;

  /// Доменный id товара.
  ///
  /// Это id из KnownProduct.
  ///
  /// Почему отдельно от Isar id:
  /// - Isar id является локальным техническим числом;
  /// - доменный id может быть строкой;
  /// - в будущем доменный id удобно синхронизировать с сервером.
  @Index(unique: true, replace: false)
  late String domainId;

  /// Название товара для отображения.
  ///
  /// Пример:
  /// "Молоко 2%"
  late String name;

  /// Нормализованное название товара.
  ///
  /// Используем для поиска и контроля уникальности.
  ///
  /// Пример:
  /// name: "Молоко 2%"
  /// normalizedName: "молоко 2%"
  @Index(unique: true, replace: false)
  late String normalizedName;

  /// Дата создания товара.
  late DateTime createdAt;

  /// Дата последнего изменения товара.
  late DateTime updatedAt;

  /// Дата последней покупки.
  ///
  /// Если null — товар ещё не покупали.
  DateTime? lastPurchasedAt;
}

/// Маппинг из domain-сущности в Isar-модель.
///
/// Domain → Data
///
/// Используем, когда хотим сохранить KnownProduct в базу.
extension KnownProductToModel on KnownProduct {
  KnownProductModel toModel({Id? isarId}) {
    return KnownProductModel()
      ..id = isarId ?? Isar.autoIncrement
      ..domainId = id
      ..name = name
      ..normalizedName = normalizedName
      ..createdAt = createdAt
      ..updatedAt = updatedAt
      ..lastPurchasedAt = lastPurchasedAt;
  }
}

/// Маппинг из Isar-модели в domain-сущность.
///
/// Data → Domain
///
/// Используем, когда читаем KnownProductModel из базы
/// и хотим получить чистый KnownProduct для остального приложения.
extension KnownProductModelToEntity on KnownProductModel {
  KnownProduct toEntity() {
    return KnownProduct.fromStorage(
      id: domainId,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastPurchasedAt: lastPurchasedAt,
    );
  }
}
