import '../../../products/domain/entities/known_product.dart';
import '../entities/shopping_item.dart';

/// Репозиторий активных покупок.
///
/// Это domain-слой.
///
/// Активная покупка — это строка на экране "Покупки".
///
/// Например:
/// - Молоко    2
/// - Хлеб
/// - Яйца      10
abstract class ShoppingItemRepository {
  /// Следит за активным списком покупок.
  ///
  /// Экран "Покупки" подписывается на этот Stream
  /// и автоматически перестраивается при изменениях.
  Stream<List<ShoppingItem>> watchAll();

  /// Получает активные покупки один раз.
  Future<List<ShoppingItem>> getAll();

  /// Ищет активную покупку по id.
  Future<ShoppingItem?> findById(String id);

  /// Ищет активную покупку по id известного товара.
  ///
  /// Это нужно, чтобы один и тот же товар нельзя было добавить
  /// в активный список два раза.
  Future<ShoppingItem?> findByKnownProductId(String knownProductId);

  /// Добавляет товар в активный список или обновляет существующую строку.
  ///
  /// Почему не просто add:
  /// если пользователь добавил "Молоко", а потом снова добавил "Молоко 2",
  /// мы не хотим получить две строки.
  ///
  /// Вместо этого:
  /// - если товара ещё нет в списке — создаём ShoppingItem;
  /// - если товар уже есть — обновляем количество.
  Future<ShoppingItem> addOrUpdate({
    required KnownProduct product,
    String? quantity,
  });

  /// Удаляет активную покупку из списка.
  ///
  /// Важно:
  /// этот метод удаляет только ShoppingItem.
  /// KnownProduct остаётся в базе известных товаров.
  Future<void> deleteById(String id);
}
