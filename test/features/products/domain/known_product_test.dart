import 'package:flutter_test/flutter_test.dart';
import 'package:want_to_buy/features/products/domain/entities/known_product.dart';

void main() {
  group('KnownProduct', () {
    test('create should format name and store normalizedName', () {
      final now = DateTime(2026, 1, 1);

      final product = KnownProduct.create(
        id: 'product-1',
        name: '  Молоко     2%  ',
        now: now,
      );

      expect(product.id, 'product-1');
      expect(product.name, 'Молоко 2%');
      expect(product.normalizedName, 'молоко 2%');
      expect(product.createdAt, now);
      expect(product.updatedAt, now);
      expect(product.lastPurchasedAt, isNull);
      expect(product.wasPurchased, false);
      expect(product.lastPurchasedQuantity, isNull);
    });

    test('create should keep user letter case in name', () {
      final product = KnownProduct.create(
        id: 'product-1',
        name: '  МоЛоКо  ',
        now: DateTime(2026, 1, 1),
      );

      expect(product.name, 'МоЛоКо');
      expect(product.normalizedName, 'молоко');
    });

    test(
      'markPurchased should update lastPurchasedAt, quantity and updatedAt',
      () {
        final createdAt = DateTime(2026, 1, 1);
        final purchasedAt = DateTime(2026, 1, 2);

        final product = KnownProduct.create(
          id: 'product-1',
          name: 'Молоко',
          now: createdAt,
        );

        final updatedProduct = product.markPurchased(
          purchasedAt: purchasedAt,
          quantity: ' 2 ',
        );

        expect(updatedProduct.lastPurchasedAt, purchasedAt);
        expect(updatedProduct.lastPurchasedQuantity, '2');
        expect(updatedProduct.updatedAt, purchasedAt);
        expect(updatedProduct.wasPurchased, true);

        // Проверяем, что исходный объект не изменился.
        expect(product.lastPurchasedAt, isNull);
        expect(product.lastPurchasedQuantity, isNull);
        expect(product.updatedAt, createdAt);
      },
    );

    test('copyWith should format name and recalculate normalizedName', () {
      final createdAt = DateTime(2026, 1, 1);
      final updatedAt = DateTime(2026, 1, 2);

      final product = KnownProduct.create(
        id: 'product-1',
        name: 'Молоко',
        now: createdAt,
      );

      final updatedProduct = product.copyWith(
        name: '  Хлеб     белый  ',
        updatedAt: updatedAt,
      );

      expect(updatedProduct.id, 'product-1');
      expect(updatedProduct.name, 'Хлеб белый');
      expect(updatedProduct.normalizedName, 'хлеб белый');
      expect(updatedProduct.createdAt, createdAt);
      expect(updatedProduct.updatedAt, updatedAt);
    });
  });

  test('markPurchased should store null when quantity is empty', () {
    final product = KnownProduct.create(
      id: 'product-1',
      name: 'Молоко',
      now: DateTime(2026, 1, 1),
    );

    final updatedProduct = product.markPurchased(
      purchasedAt: DateTime(2026, 1, 2),
      quantity: '   ',
    );

    expect(updatedProduct.lastPurchasedQuantity, isNull);
  });
}
