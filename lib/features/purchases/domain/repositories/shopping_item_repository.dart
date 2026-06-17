import '../../../products/domain/entities/known_product.dart';
import '../entities/shopping_item.dart';

/// Репозиторий товаров в списке покупок.
///
/// Это domain-слой.
///
/// Теперь ShoppingItem — это не только активная строка на экране.
/// Это единственное состояние товара относительно списка:
/// - active;
/// - purchased;
/// - deleted.
abstract class ShoppingItemRepository {
  /// Следит за всеми ShoppingItem, включая active, purchased и deleted.
  ///
  /// Это полезно для подсказок:
  /// по KnownProduct можно найти последнюю quantity из ShoppingItem.
  Stream<List<ShoppingItem>> watchAll();

  /// Следит только за активным списком покупок.
  ///
  /// Экран "Покупки" подписывается на этот Stream
  /// и показывает только status == active.
  Stream<List<ShoppingItem>> watchActive();

  /// Следит за последними покупками.
  ///
  /// Это товары со status == purchased,
  /// отсортированные по purchasedAt от новых к старым.
  Stream<List<ShoppingItem>> watchPurchased();

  /// Получает все ShoppingItem один раз.
  Future<List<ShoppingItem>> getAll();

  /// Получает активные покупки один раз.
  Future<List<ShoppingItem>> getActive();

  /// Получает последние покупки один раз.
  Future<List<ShoppingItem>> getPurchased();

  /// Ищет ShoppingItem по id.
  Future<ShoppingItem?> findById(String id);

  /// Ищет ShoppingItem по id известного товара.
  ///
  /// Это нужно, чтобы один KnownProduct имел только один ShoppingItem.
  Future<ShoppingItem?> findByKnownProductId(String knownProductId);

  /// Добавляет товар в активный список или активирует существующую запись.
  ///
  /// Почему не просто add:
  /// если пользователь добавил "Молоко", купил его,
  /// а потом снова добавил "Молоко", мы не создаём вторую запись.
  /// Мы переводим существующий ShoppingItem обратно в status == active.
  Future<ShoppingItem> addOrUpdate({
    required KnownProduct product,
    String? quantity,
  });

  /// Отмечает активную покупку как купленную.
  ///
  /// Запись не удаляется из БД.
  /// Она получает status == purchased и purchasedAt.
  Future<ShoppingItem?> markPurchased(String id);

  /// Помечает товар как удалённый без отметки покупки.
  ///
  /// Это отдельный сценарий:
  /// пользователь мог добавить товар случайно и убрать его из списка.
  Future<ShoppingItem?> markDeleted(String id);
}
