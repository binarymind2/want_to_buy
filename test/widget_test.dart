import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:want_to_buy/features/products/domain/entities/known_product.dart';
import 'package:want_to_buy/features/products/presentation/providers/known_product_providers.dart';
import 'package:want_to_buy/features/products/presentation/providers/recent_known_product_providers.dart';
import 'package:want_to_buy/features/purchases/domain/entities/shopping_item.dart';
import 'package:want_to_buy/features/purchases/presentation/providers/shopping_item_providers.dart';
import 'package:want_to_buy/main.dart';

void main() {
  Widget createTestApp({
    List<ShoppingItem> shoppingItems = const <ShoppingItem>[],
    List<KnownProduct> knownProducts = const <KnownProduct>[],
    List<ShoppingItem>? recentItems,
  }) {
    final purchasedItems = recentItems ?? const <ShoppingItem>[];

    return ProviderScope(
      overrides: [
        shoppingItemsProvider.overrideWith((ref) {
          return Stream<List<ShoppingItem>>.value(shoppingItems);
        }),

        allShoppingItemsProvider.overrideWith((ref) {
          return Stream<List<ShoppingItem>>.value([
            ...shoppingItems,
            ...purchasedItems,
          ]);
        }),

        purchasedShoppingItemsProvider.overrideWith((ref) {
          return Stream<List<ShoppingItem>>.value(purchasedItems);
        }),

        knownProductsProvider.overrideWith((ref) {
          return Stream<List<KnownProduct>>.value(knownProducts);
        }),

        if (recentItems != null)
          recentShoppingItemsProvider.overrideWithValue(recentItems),
      ],
      child: const WantToBuyApp(),
    );
  }

  testWidgets('WantToBuyApp should start from purchases screen', (
    tester,
  ) async {
    await tester.pumpWidget(createTestApp());

    // Даём Riverpod обработать StreamProvider.
    await tester.pump();

    expect(find.text('Покупки'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Настройки'), findsNothing);
  });

  testWidgets('Purchases screen should show empty state and add button', (
    tester,
  ) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();

    expect(find.text('Список покупок пуст'), findsOneWidget);
    expect(find.text('Нажмите +, чтобы добавить товар'), findsOneWidget);

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byTooltip('Добавить товар'), findsOneWidget);

    expect(find.text('Товар'), findsNothing);
    expect(find.text('Кол-во'), findsNothing);
  });

  testWidgets('Add bottom sheet should show product suggestions while typing', (
    tester,
  ) async {
    final knownProducts = [
      KnownProduct.create(
        id: 'product-1',
        name: 'Молоко',
        now: DateTime(2026, 1, 1),
      ),
      KnownProduct.create(
        id: 'product-2',
        name: 'Хлеб',
        now: DateTime(2026, 1, 1),
      ),
    ];

    await tester.pumpWidget(createTestApp(knownProducts: knownProducts));
    await tester.pump();

    await tester.tap(find.byTooltip('Добавить товар'));
    await tester.pumpAndSettle();

    expect(find.text('Товары для выбора'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'мо');
    await tester.pump();

    expect(find.text('Молоко'), findsOneWidget);
    expect(find.text('Хлеб'), findsNothing);
  });

  testWidgets('Add bottom sheet should mark already active products', (
    tester,
  ) async {
    final shoppingItems = [
      ShoppingItem.create(
        id: 'item-1',
        knownProductId: 'product-1',
        nameSnapshot: 'Молоко',
        quantity: '2',
        sortOrder: 1,
        now: DateTime(2026, 1, 1),
      ),
    ];

    final knownProducts = [
      KnownProduct.create(
        id: 'product-1',
        name: 'Молоко',
        now: DateTime(2026, 1, 1),
      ),
      KnownProduct.create(
        id: 'product-2',
        name: 'Хлеб',
        now: DateTime(2026, 1, 1),
      ),
    ];

    await tester.pumpWidget(
      createTestApp(shoppingItems: shoppingItems, knownProducts: knownProducts),
    );

    await tester.pump();

    await tester.tap(find.byTooltip('Добавить товар'));
    await tester.pumpAndSettle();

    expect(find.text('Молоко'), findsWidgets);
    expect(find.text('Уже в списке покупок'), findsOneWidget);
    expect(find.text('В списке'), findsOneWidget);

    await tester.tap(find.text('Молоко').last);
    await tester.pump();

    expect(find.text('Обновить товар'), findsOneWidget);
  });

  testWidgets(
    'Add bottom sheet should use quantity from purchased shopping item',
    (tester) async {
      final knownProducts = [
        KnownProduct.create(
          id: 'product-1',
          name: 'Молоко',
          now: DateTime(2026, 1, 1),
        ),
      ];

      final recentItems = [
        ShoppingItem.create(
          id: 'item-1',
          knownProductId: 'product-1',
          nameSnapshot: 'Молоко',
          quantity: '2',
          sortOrder: 1,
          now: DateTime(2026, 1, 1),
        ).markPurchased(purchasedAt: DateTime(2026, 1, 2)),
      ];

      await tester.pumpWidget(
        createTestApp(knownProducts: knownProducts, recentItems: recentItems),
      );

      await tester.pump();

      await tester.tap(find.byTooltip('Добавить товар'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Молоко').last);
      await tester.pump();

      expect(find.text('Добавить товар'), findsWidgets);

      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      final quantityField = textFields.elementAt(1);

      expect(quantityField.controller?.text, '2');
    },
  );

  testWidgets('Tap on shopping item should show removal progress', (
    tester,
  ) async {
    final shoppingItems = [
      ShoppingItem.create(
        id: 'item-1',
        knownProductId: 'product-1',
        nameSnapshot: 'Молоко',
        quantity: '2',
        sortOrder: 1,
        now: DateTime(2026, 1, 1),
      ),
    ];

    await tester.pumpWidget(createTestApp(shoppingItems: shoppingItems));
    await tester.pump();

    expect(find.text('Молоко'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await tester.tap(find.text('Молоко'));
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Second tap on shopping item should cancel removal progress', (
    tester,
  ) async {
    final shoppingItems = [
      ShoppingItem.create(
        id: 'item-1',
        knownProductId: 'product-1',
        nameSnapshot: 'Молоко',
        quantity: '2',
        sortOrder: 1,
        now: DateTime(2026, 1, 1),
      ),
    ];

    await tester.pumpWidget(createTestApp(shoppingItems: shoppingItems));
    await tester.pump();

    await tester.tap(find.text('Молоко'));
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    await tester.tap(find.text('Молоко'));
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets(
    'Purchases screen should show recent items after active purchases',
    (tester) async {
      final shoppingItems = [
        ShoppingItem.create(
          id: 'item-1',
          knownProductId: 'product-1',
          nameSnapshot: 'Хлеб',
          quantity: '1',
          sortOrder: 1,
          now: DateTime(2026, 1, 1),
        ),
      ];

      final recentItems = [
        ShoppingItem.create(
          id: 'item-2',
          knownProductId: 'product-2',
          nameSnapshot: 'Молоко',
          quantity: '2',
          sortOrder: 2,
          now: DateTime(2026, 1, 1),
        ).markPurchased(purchasedAt: DateTime(2026, 1, 2)),
      ];

      await tester.pumpWidget(
        createTestApp(shoppingItems: shoppingItems, recentItems: recentItems),
      );

      await tester.pump();

      expect(find.text('Хлеб'), findsOneWidget);
      expect(find.text('Последние покупки'), findsOneWidget);
      expect(find.text('Молоко'), findsOneWidget);

      final activeItemTop = tester.getTopLeft(find.text('Хлеб')).dy;
      final recentTitleTop = tester
          .getTopLeft(find.text('Последние покупки'))
          .dy;
      final recentItemTop = tester.getTopLeft(find.text('Молоко')).dy;

      expect(activeItemTop < recentTitleTop, isTrue);
      expect(recentTitleTop < recentItemTop, isTrue);
    },
  );

  testWidgets('Recent item should show purchased quantity', (tester) async {
    final recentItems = [
      ShoppingItem.create(
        id: 'item-1',
        knownProductId: 'product-1',
        nameSnapshot: 'Молоко',
        quantity: '2',
        sortOrder: 1,
        now: DateTime(2026, 1, 1),
      ).markPurchased(purchasedAt: DateTime(2026, 1, 2)),
    ];

    await tester.pumpWidget(createTestApp(recentItems: recentItems));
    await tester.pump();

    expect(find.text('Молоко'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('Settings screen should show settings actions', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('База товаров'), findsOneWidget);
    expect(find.text('Показать товары в БД'), findsOneWidget);
    expect(find.text('О приложении'), findsOneWidget);
    expect(find.text('Хочу купить'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Покупки'), findsOneWidget);
    expect(find.text('База товаров'), findsNothing);
  });

  testWidgets('Settings screen should show known products database dialog', (
    tester,
  ) async {
    final knownProducts = [
      KnownProduct.fromStorage(
        id: 'product-1',
        name: 'Молоко',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
      ),
      KnownProduct.fromStorage(
        id: 'product-2',
        name: 'Хлеб',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    ];

    await tester.pumpWidget(createTestApp(knownProducts: knownProducts));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Показать товары в БД'));
    await tester.pumpAndSettle();

    expect(find.text('Товары в БД'), findsOneWidget);
    expect(find.text('Молоко'), findsOneWidget);
    expect(find.text('Хлеб'), findsOneWidget);

    // KnownProduct теперь является только справочником.
    // Поэтому экран настроек больше не показывает:
    // "Товар уже покупали" / "Пока не покупали".
    //
    // Вместо этого в subtitle показываем normalizedName.
    expect(find.text('молоко'), findsOneWidget);
    expect(find.text('хлеб'), findsOneWidget);

    expect(find.text('Товар уже покупали'), findsNothing);
    expect(find.text('Пока не покупали'), findsNothing);
  });

  testWidgets('Purchases screen should show all recent items without icons', (
    tester,
  ) async {
    final recentItems = List.generate(6, (index) {
      final day = index + 1;

      return ShoppingItem.create(
        id: 'item-$day',
        knownProductId: 'product-$day',
        nameSnapshot: 'Товар $day',
        quantity: null,
        sortOrder: day,
        now: DateTime(2026, 1, 1),
      ).markPurchased(purchasedAt: DateTime(2026, 1, day));
    });

    await tester.pumpWidget(createTestApp(recentItems: recentItems));
    await tester.pump();

    expect(find.text('Последние покупки'), findsOneWidget);

    expect(find.text('Товар 1'), findsOneWidget);
    expect(find.text('Товар 2'), findsOneWidget);
    expect(find.text('Товар 3'), findsOneWidget);
    expect(find.text('Товар 4'), findsOneWidget);
    expect(find.text('Товар 5'), findsOneWidget);
    expect(find.text('Товар 6'), findsOneWidget);

    expect(find.byIcon(Icons.history), findsNothing);
    expect(find.byIcon(Icons.add_circle_outline), findsNothing);
  });
}
