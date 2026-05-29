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
/// 1. найти или создать известный товар;
/// 2. добавить его в активный список;
/// 3. если товар уже есть в списке — обновить количество.
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
  /// 2. Проверяем, что оно не пустое.
  /// 3. Ищем известный товар в БД.
  /// 4. Если такого товара нет — создаём.
  /// 5. Добавляем товар в активные покупки.
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
  /// Этот метод пригодится позже,
  /// когда мы будем делать удаление через 5 секунд.
  ///
  /// Логика будущего поведения:
  /// 1. Пользователь нажал на строку.
  /// 2. Прошёл 5-секундный отсчёт.
  /// 3. Товар считается купленным.
  /// 4. У KnownProduct обновляется lastPurchasedAt.
  /// 5. ShoppingItem удаляется из активного списка.
  Future<void> completePurchase(ShoppingItem item) async {
    await _knownProductRepository.markPurchased(item.knownProductId);
    await _shoppingItemRepository.deleteById(item.id);
  }

  /// Удаляет активную покупку без отметки "куплено".
  ///
  /// Сейчас этот метод не используем,
  /// но он может пригодиться позже для обычного удаления.
  Future<void> deletePurchase(String itemId) async {
    await _shoppingItemRepository.deleteById(itemId);
  }
}
