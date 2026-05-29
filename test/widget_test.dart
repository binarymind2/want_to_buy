import 'package:flutter_test/flutter_test.dart';
import 'package:want_to_buy/main.dart';

void main() {
  testWidgets('WantToBuyApp should show main navigation', (tester) async {
    await tester.pumpWidget(const WantToBuyApp());

    expect(find.text('Покупки'), findsWidgets);
    expect(find.text('Настройки'), findsWidgets);
  });

  testWidgets('Purchases screen should show empty state and add panel', (
    tester,
  ) async {
    await tester.pumpWidget(const WantToBuyApp());

    expect(find.text('Список покупок пуст'), findsOneWidget);
    expect(find.text('Добавьте товар внизу экрана'), findsOneWidget);
    expect(find.text('Товар'), findsOneWidget);
    expect(find.text('Кол-во'), findsOneWidget);
  });
}
