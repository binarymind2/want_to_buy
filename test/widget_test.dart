import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:want_to_buy/features/products/domain/entities/known_product.dart';
import 'package:want_to_buy/features/products/presentation/providers/known_product_providers.dart';
import 'package:want_to_buy/features/purchases/domain/entities/shopping_item.dart';
import 'package:want_to_buy/features/purchases/presentation/providers/shopping_item_providers.dart';
import 'package:want_to_buy/main.dart';

void main() {
  Widget createTestApp() {
    return ProviderScope(
      overrides: [
        shoppingItemsProvider.overrideWith((ref) {
          return Stream<List<ShoppingItem>>.value(const <ShoppingItem>[]);
        }),
        knownProductsProvider.overrideWith((ref) {
          return Stream<List<KnownProduct>>.value(const <KnownProduct>[]);
        }),
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
}
