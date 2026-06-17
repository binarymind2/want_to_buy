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

    test('fromStorage should restore known product and normalize name', () {
      final createdAt = DateTime(2026, 1, 1);
      final updatedAt = DateTime(2026, 1, 2);

      final product = KnownProduct.fromStorage(
        id: 'product-1',
        name: '  Молоко     2%  ',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(product.id, 'product-1');
      expect(product.name, 'Молоко 2%');
      expect(product.normalizedName, 'молоко 2%');
      expect(product.createdAt, createdAt);
      expect(product.updatedAt, updatedAt);
    });
  });
}
