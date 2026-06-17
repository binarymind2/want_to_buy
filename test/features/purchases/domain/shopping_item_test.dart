import 'package:flutter_test/flutter_test.dart';
import 'package:want_to_buy/features/purchases/domain/entities/shopping_item.dart';

void main() {
  group('ShoppingItem', () {
    test('create should store quantity when quantity is not empty', () {
      final now = DateTime(2026, 1, 1);

      final item = ShoppingItem.create(
        id: 'item-1',
        knownProductId: 'product-1',
        nameSnapshot: 'Молоко',
        quantity: ' 2 ',
        sortOrder: 1,
        now: now,
      );

      expect(item.id, 'item-1');
      expect(item.knownProductId, 'product-1');
      expect(item.nameSnapshot, 'Молоко');
      expect(item.quantity, '2');
      expect(item.hasQuantity, true);
      expect(item.createdAt, now);
      expect(item.sortOrder, 1);
    });

    test('create should store null when quantity is empty', () {
      final item = ShoppingItem.create(
        id: 'item-1',
        knownProductId: 'product-1',
        nameSnapshot: 'Хлеб',
        quantity: '   ',
        sortOrder: 1,
        now: DateTime(2026, 1, 1),
      );

      expect(item.quantity, isNull);
      expect(item.hasQuantity, false);
    });

    test('copyWith should update only passed fields', () {
      final createdAt = DateTime(2026, 1, 1);

      final item = ShoppingItem.create(
        id: 'item-1',
        knownProductId: 'product-1',
        nameSnapshot: 'Молоко',
        quantity: '2',
        sortOrder: 1,
        now: createdAt,
      );

      final updatedItem = item.copyWith(quantity: '3', sortOrder: 2);

      expect(updatedItem.id, 'item-1');
      expect(updatedItem.knownProductId, 'product-1');
      expect(updatedItem.nameSnapshot, 'Молоко');
      expect(updatedItem.quantity, '3');
      expect(updatedItem.createdAt, createdAt);
      expect(updatedItem.sortOrder, 2);
    });
  });

  test('create should create active item', () {
    final now = DateTime(2026, 1, 1);

    final item = ShoppingItem.create(
      id: 'item-1',
      knownProductId: 'product-1',
      nameSnapshot: 'Молоко',
      quantity: ' 2 ',
      sortOrder: 1,
      now: now,
    );

    expect(item.status, ShoppingItemStatus.active);
    expect(item.isActive, true);
    expect(item.isPurchased, false);
    expect(item.isDeleted, false);
    expect(item.quantity, '2');
    expect(item.createdAt, now);
    expect(item.updatedAt, now);
    expect(item.purchasedAt, isNull);
    expect(item.deletedAt, isNull);
  });

  test('markPurchased should change status and set purchasedAt', () {
    final createdAt = DateTime(2026, 1, 1);
    final purchasedAt = DateTime(2026, 1, 2);

    final item = ShoppingItem.create(
      id: 'item-1',
      knownProductId: 'product-1',
      nameSnapshot: 'Молоко',
      quantity: '2',
      sortOrder: 1,
      now: createdAt,
    );

    final purchasedItem = item.markPurchased(purchasedAt: purchasedAt);

    expect(purchasedItem.status, ShoppingItemStatus.purchased);
    expect(purchasedItem.isPurchased, true);
    expect(purchasedItem.purchasedAt, purchasedAt);
    expect(purchasedItem.updatedAt, purchasedAt);
    expect(purchasedItem.deletedAt, isNull);

    // Исходный объект не изменился.
    expect(item.status, ShoppingItemStatus.active);
    expect(item.purchasedAt, isNull);
  });

  test('markDeleted should change status and set deletedAt', () {
    final createdAt = DateTime(2026, 1, 1);
    final deletedAt = DateTime(2026, 1, 2);

    final item = ShoppingItem.create(
      id: 'item-1',
      knownProductId: 'product-1',
      nameSnapshot: 'Молоко',
      quantity: '2',
      sortOrder: 1,
      now: createdAt,
    );

    final deletedItem = item.markDeleted(deletedAt: deletedAt);

    expect(deletedItem.status, ShoppingItemStatus.deleted);
    expect(deletedItem.isDeleted, true);
    expect(deletedItem.deletedAt, deletedAt);
    expect(deletedItem.updatedAt, deletedAt);
  });

  test('activate should return purchased item back to active state', () {
    final createdAt = DateTime(2026, 1, 1);
    final purchasedAt = DateTime(2026, 1, 2);
    final activatedAt = DateTime(2026, 1, 3);

    final item = ShoppingItem.create(
      id: 'item-1',
      knownProductId: 'product-1',
      nameSnapshot: 'Молоко',
      quantity: '2',
      sortOrder: 1,
      now: createdAt,
    ).markPurchased(purchasedAt: purchasedAt);

    final activeItem = item.activate(
      nameSnapshot: 'Молоко',
      quantity: '3',
      sortOrder: 2,
      now: activatedAt,
    );

    expect(activeItem.status, ShoppingItemStatus.active);
    expect(activeItem.quantity, '3');
    expect(activeItem.sortOrder, 2);
    expect(activeItem.updatedAt, activatedAt);

    // purchasedAt сохраняем как дату прошлой покупки.
    expect(activeItem.purchasedAt, purchasedAt);
    expect(activeItem.deletedAt, isNull);
  });
}
