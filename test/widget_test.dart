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
    List<KnownProduct>? recentProducts,
  }) {
    return ProviderScope(
      overrides: [
        shoppingItemsProvider.overrideWith((ref) {
          return Stream<List<ShoppingItem>>.value(shoppingItems);
        }),
        knownProductsProvider.overrideWith((ref) {
          return Stream<List<KnownProduct>>.value(knownProducts);
        }),
        if (recentProducts != null)
          recentKnownProductsProvider.overrideWithValue(recentProducts),
      ],
      child: const WantToBuyApp(),
    );
  }

  testWidgets('WantToBuyApp should show main navigation', (tester) async {
    await tester.pumpWidget(createTestApp());

    // Даём Riverpod обработать StreamProvider.
    await tester.pump();

    expect(find.text('Покупки'), findsWidgets);
    expect(find.text('Настройки'), findsWidgets);
  });

  testWidgets('Purchases screen should show empty state and add panel', (
    tester,
  ) async {
    await tester.pumpWidget(createTestApp());

    // Важно:
    // shoppingItemsProvider — это StreamProvider.
    // Даже если мы отдаём Stream.value([]),
    // данные приходят не в самый первый кадр.
    //
    // Первый pumpWidget строит приложение.
    // Второй pump даёт StreamProvider перейти из loading в data.
    await tester.pump();

    expect(find.text('Список покупок пуст'), findsOneWidget);
    expect(find.text('Добавьте товар внизу экрана'), findsOneWidget);
    expect(find.text('Товар'), findsOneWidget);
    expect(find.text('Кол-во'), findsOneWidget);
  });

  testWidgets('Add panel should show product suggestions while typing', (
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

    await tester.enterText(find.byType(TextField).first, 'мо');
    await tester.pump();

    expect(find.text('Молоко'), findsOneWidget);
    expect(find.text('Хлеб'), findsNothing);
  });

  testWidgets('Tap on suggestion should fill product name field', (
    tester,
  ) async {
    final knownProducts = [
      KnownProduct.create(
        id: 'product-1',
        name: 'Молоко',
        now: DateTime(2026, 1, 1),
      ),
    ];

    await tester.pumpWidget(createTestApp(knownProducts: knownProducts));
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, 'мо');
    await tester.pump();

    await tester.tap(find.text('Молоко'));
    await tester.pump();

    final nameField = tester.widget<TextField>(find.byType(TextField).first);

    expect(nameField.controller?.text, 'Молоко');
  });

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
    'Purchases screen should show recent products after active purchases',
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

      final recentProducts = [
        KnownProduct.fromStorage(
          id: 'product-2',
          name: 'Молоко',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 2),
          lastPurchasedAt: DateTime(2026, 1, 2),
        ),
      ];

      await tester.pumpWidget(
        createTestApp(
          shoppingItems: shoppingItems,
          recentProducts: recentProducts,
        ),
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

  testWidgets('Tap on recent product should fill product name field', (
    tester,
  ) async {
    final recentProducts = [
      KnownProduct.fromStorage(
        id: 'product-1',
        name: 'Молоко',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
        lastPurchasedAt: DateTime(2026, 1, 2),
      ),
    ];

    await tester.pumpWidget(createTestApp(recentProducts: recentProducts));
    await tester.pump();

    await tester.tap(find.text('Молоко'));
    await tester.pump();

    final nameField = tester.widget<TextField>(find.byType(TextField).first);

    expect(nameField.controller?.text, 'Молоко');
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
        lastPurchasedAt: DateTime(2026, 1, 2),
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
    expect(find.text('Товар уже покупали'), findsOneWidget);
    expect(find.text('Пока не покупали'), findsOneWidget);
  });

  testWidgets(
    'Purchases screen should show all recent products without icons',
    (tester) async {
      final recentProducts = List.generate(6, (index) {
        final day = index + 1;

        return KnownProduct.fromStorage(
          id: 'product-$day',
          name: 'Товар $day',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, day),
          lastPurchasedAt: DateTime(2026, 1, day),
        );
      });

      await tester.pumpWidget(createTestApp(recentProducts: recentProducts));
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
    },
  );
}
