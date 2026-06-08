import '../../../products/domain/repositories/known_product_repository.dart';
import '../../../products/domain/entities/known_product.dart';
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
/// 4. если товар уже есть в списке — обновить количество.
///
/// Если писать это прямо в widget-е,
/// экран быстро станет грязным и сложным.
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
  /// 6. Добавляем товар в активные покупки.
  ///
  /// Важно:
  /// ShoppingItemRepository.addOrUpdate сам решает:
  /// - создать новую строку;
  /// - или обновить количество, если товар уже есть в списке.
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
  /// Логика поведения:
  /// 1. Пользователь нажал на строку.
  /// 2. Прошёл 5-секундный отсчёт.
  /// 3. Товар считается купленным.
  /// 4. У KnownProduct обновляется lastPurchasedAt и lastPurchasedQuantity.
  /// 5. ShoppingItem удаляется из активного списка.
  Future<void> completePurchase(ShoppingItem item) async {
    await _knownProductRepository.markPurchased(
      item.knownProductId,
      quantity: item.quantity,
    );

    await _shoppingItemRepository.deleteById(item.id);
  }

  /// Удаляет активную покупку без отметки "куплено".
  ///
  /// Сейчас этот метод не используем,
  /// но он может пригодиться позже для обычного удаления.
  Future<void> deletePurchase(String itemId) async {
    await _shoppingItemRepository.deleteById(itemId);
  }

  /// Возвращает товар из последних покупок в активный список.
  ///
  /// Важно:
  /// здесь мы не создаём новый KnownProduct.
  /// Товар уже есть в базе известных товаров, потому что он пришёл
  /// из секции "Последние покупки".
  ///
  /// Логика:
  /// 1. Пользователь нажал на последнюю покупку.
  /// 2. Берём её KnownProduct.
  /// 3. Добавляем товар в активные покупки.
  /// 4. В качестве количества используем lastPurchasedQuantity.
  Future<void> addRecentPurchase(KnownProduct product) async {
    await _shoppingItemRepository.addOrUpdate(
      product: product,
      quantity: product.lastPurchasedQuantity,
    );
  }
}
