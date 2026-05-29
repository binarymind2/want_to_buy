import 'package:flutter_test/flutter_test.dart';
import 'package:want_to_buy/features/products/domain/utils/product_name_normalizer.dart';

void main() {
  group('formatProductName', () {
    test('removes spaces from the beginning and the end', () {
      final result = formatProductName('  Молоко  ');

      expect(result, 'Молоко');
    });

    test('replaces multiple spaces with one space', () {
      final result = formatProductName('  Молоко     2%  ');

      expect(result, 'Молоко 2%');
    });

    test('keeps user letter case', () {
      final result = formatProductName('  МоЛоКо  ');

      expect(result, 'МоЛоКо');
    });
  });

  group('normalizeProductName', () {
    test('formats name and converts it to lower case', () {
      final result = normalizeProductName('  Молоко     2%  ');

      expect(result, 'молоко 2%');
    });

    test('returns same normalized value for different user inputs', () {
      final values = ['Молоко', 'молоко', '  молоко  ', 'МОЛОКО', 'МоЛоКо'];

      final normalizedValues = values.map(normalizeProductName).toSet();

      expect(normalizedValues.length, 1);
      expect(normalizedValues.first, 'молоко');
    });
  });
}
