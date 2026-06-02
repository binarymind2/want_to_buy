import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:want_to_buy/features/products/domain/entities/known_product.dart';
import 'package:want_to_buy/features/products/presentation/providers/known_product_providers.dart';
import 'package:want_to_buy/features/products/presentation/providers/recent_known_product_providers.dart';
import 'package:want_to_buy/features/purchases/domain/entities/shopping_item.dart';
import 'package:want_to_buy/features/purchases/presentation/providers/shopping_item_providers.dart';

void main() {
  group('recentKnownProductsProvider', () {
    test(
      'should return purchased products sorted by lastPurchasedAt desc',
      () async {
        final oldProduct = KnownProduct.fromStorage(
          id: 'product-1',
          name: 'Хлеб',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 2),
          lastPurchasedAt: DateTime(2026, 1, 2),
        );

        final newProduct = KnownProduct.fromStorage(
          id: 'product-2',
          name: 'Молоко',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 3),
          lastPurchasedAt: DateTime(2026, 1, 3),
        );

        final neverPurchasedProduct = KnownProduct.fromStorage(
          id: 'product-3',
          name: 'Сыр',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );

        final container = ProviderContainer(
          overrides: [
            knownProductsProvider.overrideWith((ref) {
              return Stream<List<KnownProduct>>.value([
                oldProduct,
                newProduct,
                neverPurchasedProduct,
              ]);
            }),
            shoppingItemsProvider.overrideWith((ref) {
              return Stream<List<ShoppingItem>>.value(const []);
            }),
          ],
        );

        addTearDown(container.dispose);

        await container.read(knownProductsProvider.future);
        await container.read(shoppingItemsProvider.future);

        final recentProducts = container.read(recentKnownProductsProvider);

        expect(recentProducts, [newProduct, oldProduct]);
      },
    );

    test(
      'should exclude products that are already in active purchases',
      () async {
        final purchasedProduct = KnownProduct.fromStorage(
          id: 'product-1',
          name: 'Молоко',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 2),
          lastPurchasedAt: DateTime(2026, 1, 2),
        );

        final activeItem = ShoppingItem.create(
          id: 'item-1',
          knownProductId: purchasedProduct.id,
          nameSnapshot: purchasedProduct.name,
          sortOrder: 1,
          now: DateTime(2026, 1, 3),
        );

        final container = ProviderContainer(
          overrides: [
            knownProductsProvider.overrideWith((ref) {
              return Stream<List<KnownProduct>>.value([purchasedProduct]);
            }),
            shoppingItemsProvider.overrideWith((ref) {
              return Stream<List<ShoppingItem>>.value([activeItem]);
            }),
          ],
        );

        addTearDown(container.dispose);

        await container.read(knownProductsProvider.future);
        await container.read(shoppingItemsProvider.future);

        final recentProducts = container.read(recentKnownProductsProvider);

        expect(recentProducts, isEmpty);
      },
    );
  });
}
