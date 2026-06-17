import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:want_to_buy/features/products/presentation/providers/recent_known_product_providers.dart';
import 'package:want_to_buy/features/purchases/domain/entities/shopping_item.dart';
import 'package:want_to_buy/features/purchases/presentation/providers/shopping_item_providers.dart';

void main() {
  group('recentShoppingItemsProvider', () {
    test('should return purchased items sorted by purchasedAt desc', () async {
      final oldItem = ShoppingItem.create(
        id: 'item-1',
        knownProductId: 'product-1',
        nameSnapshot: 'Хлеб',
        quantity: '1',
        sortOrder: 1,
        now: DateTime(2026, 1, 1),
      ).markPurchased(purchasedAt: DateTime(2026, 1, 2));

      final newItem = ShoppingItem.create(
        id: 'item-2',
        knownProductId: 'product-2',
        nameSnapshot: 'Молоко',
        quantity: '2',
        sortOrder: 2,
        now: DateTime(2026, 1, 1),
      ).markPurchased(purchasedAt: DateTime(2026, 1, 3));

      final container = ProviderContainer(
        overrides: [
          purchasedShoppingItemsProvider.overrideWith((ref) {
            return Stream<List<ShoppingItem>>.value([newItem, oldItem]);
          }),
        ],
      );

      addTearDown(container.dispose);

      await container.read(purchasedShoppingItemsProvider.future);

      final recentItems = container.read(recentShoppingItemsProvider);

      expect(recentItems, [newItem, oldItem]);
    });

    test('should return empty list while purchased items are loading', () {
      final container = ProviderContainer(
        overrides: [
          purchasedShoppingItemsProvider.overrideWith((ref) {
            return const Stream<List<ShoppingItem>>.empty();
          }),
        ],
      );

      addTearDown(container.dispose);

      final recentItems = container.read(recentShoppingItemsProvider);

      expect(recentItems, isEmpty);
    });

    test('should return all purchased items without limit', () async {
      final items = List.generate(6, (index) {
        final day = index + 1;

        return ShoppingItem.create(
          id: 'item-$day',
          knownProductId: 'product-$day',
          nameSnapshot: 'Товар $day',
          sortOrder: day,
          now: DateTime(2026, 1, 1),
        ).markPurchased(purchasedAt: DateTime(2026, 1, day));
      }).reversed.toList();

      final container = ProviderContainer(
        overrides: [
          purchasedShoppingItemsProvider.overrideWith((ref) {
            return Stream<List<ShoppingItem>>.value(items);
          }),
        ],
      );

      addTearDown(container.dispose);

      await container.read(purchasedShoppingItemsProvider.future);

      final recentItems = container.read(recentShoppingItemsProvider);

      expect(recentItems.length, 6);
      expect(recentItems.map((item) => item.nameSnapshot), [
        'Товар 6',
        'Товар 5',
        'Товар 4',
        'Товар 3',
        'Товар 2',
        'Товар 1',
      ]);
    });
  });
}
