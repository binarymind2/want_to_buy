import '../../../products/domain/repositories/known_product_repository.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_item_repository.dart';

/// Controller экрана покупок.
///
/// Это слой между UI и репозиториями.
///
/// Почему он нужен:
/// UI не должен знать всю бизнес-логику добавления товара.
///
/// Например, при нажатии на "+" нужно:
/// 1. проверить название;
/// 2. найти или создать известный товар;
/// 3. добавить его в активный список;
/// 4. если ShoppingItem уже есть — перевести его в active и обновить quantity.
class PurchasesController {
  const PurchasesController({
    required KnownProductRepository knownProductRepository,
    required ShoppingItemRepository shoppingItemRepository,
  }) : _knownProductRepository = knownProductRepository,
       _shoppingItemRepository = shoppingItemRepository;

  final KnownProductRepository _knownProductRepository;
  final ShoppingItemRepository _shoppingItemRepository;

  /// Добавляет товар в активный список покупок.
  ///
  /// Логика:
  /// 1. Берём название, которое ввёл пользователь.
  /// 2. Убираем пробелы по краям.
  /// 3. Проверяем, что название не пустое.
  /// 4. Ищем известный товар в БД.
  /// 5. Если такого товара нет — создаём его.
  /// 6. Добавляем или активируем ShoppingItem.
  ///
  /// Важно:
  /// ShoppingItemRepository.addOrUpdate сам решает:
  /// - создать новую запись;
  /// - обновить активную запись;
  /// - вернуть купленную/удалённую запись обратно в active.
  Future<void> addPurchase({required String name, String? quantity}) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Название товара не может быть пустым');
    }

    final product = await _knownProductRepository.getOrCreateByName(
      trimmedName,
    );

    await _shoppingItemRepository.addOrUpdate(
      product: product,
      quantity: quantity,
    );
  }

  /// Завершает покупку.
  ///
  /// Новая логика:
  /// 1. Пользователь нажал на строку.
  /// 2. Прошёл 5-секундный отсчёт.
  /// 3. ShoppingItem получает status == purchased.
  /// 4. ShoppingItem получает purchasedAt.
  /// 5. Запись не удаляется из БД.
  /// 6. Активный список обновляется через фильтр status == active.
  Future<void> completePurchase(ShoppingItem item) async {
    await _shoppingItemRepository.markPurchased(item.id);
  }

  /// Удаляет товар из списка без отметки "куплено".
  ///
  /// Это отдельное действие от покупки.
  /// Например, пользователь добавил товар ошибочно и хочет убрать его.
  Future<void> deletePurchase(String itemId) async {
    await _shoppingItemRepository.markDeleted(itemId);
  }

  /// Возвращает товар из последних покупок в активный список.
  ///
  /// Последняя покупка теперь приходит как ShoppingItem со status == purchased.
  /// Чтобы вернуть её в активный список, нам нужно:
  /// 1. найти KnownProduct по knownProductId;
  /// 2. активировать существующий ShoppingItem;
  /// 3. использовать quantity из последней покупки.
  Future<void> addRecentPurchase(ShoppingItem item) async {
    final product = await _knownProductRepository.findById(item.knownProductId);

    if (product == null) {
      throw StateError('Известный товар не найден: ${item.knownProductId}');
    }

    await _shoppingItemRepository.addOrUpdate(
      product: product,
      quantity: item.quantity,
    );
  }
}
