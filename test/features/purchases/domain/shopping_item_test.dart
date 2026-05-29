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
}
