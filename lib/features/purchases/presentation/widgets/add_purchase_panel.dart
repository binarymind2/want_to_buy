import 'package:flutter/material.dart';

import '../../../products/domain/entities/known_product.dart';
import '../../../products/domain/utils/product_name_normalizer.dart';
import 'product_suggestions_list.dart';

/// Нижняя панель добавления товара.
///
/// Здесь есть:
/// - поле названия товара;
/// - поле количества;
/// - кнопка "+";
/// - последние покупки;
/// - подсказки известных товаров.
///
/// Этот виджет ничего не знает про Isar и Riverpod.
/// Он получает готовые данные и callback-и от PurchasesScreen.
class AddPurchasePanel extends StatelessWidget {
  const AddPurchasePanel({
    super.key,
    required this.nameController,
    required this.quantityController,
    required this.nameFocusNode,
    required this.knownProducts,
    required this.recentProducts,
    required this.activeKnownProductIds,
    required this.onAddPressed,
  });

  final TextEditingController nameController;
  final TextEditingController quantityController;
  final FocusNode nameFocusNode;

  /// Все известные товары из БД.
  ///
  /// Именно из них мы строим подсказки во время ввода.
  final List<KnownProduct> knownProducts;

  /// Последние купленные товары.
  ///
  /// Они показываются тогда, когда поле названия пустое.
  ///
  /// Почему так:
  /// если пользователь ещё ничего не вводит,
  /// скорее всего ему удобно быстро вернуть в список
  /// что-то из недавно купленного.
  final List<KnownProduct> recentProducts;

  /// id товаров, которые уже есть в активном списке покупок.
  ///
  /// Зачем нужно:
  /// если товар уже добавлен в покупки, не нужно снова предлагать его
  /// в подсказках.
  final Set<String> activeKnownProductIds;

  final VoidCallback onAddPressed;

  /// Ищет подсказки для текущего текста в поле названия.
  ///
  /// Пример:
  /// query: "мо"
  ///
  /// knownProducts:
  /// - Молоко
  /// - Морковь
  /// - Хлеб
  ///
  /// результат:
  /// - Молоко
  /// - Морковь
  List<KnownProduct> _findSuggestions(String query) {
    final normalizedQuery = normalizeProductName(query);

    if (normalizedQuery.isEmpty) {
      return const <KnownProduct>[];
    }

    final suggestions = knownProducts.where((product) {
      final isAlreadyInActiveList = activeKnownProductIds.contains(product.id);

      if (isAlreadyInActiveList) {
        return false;
      }

      return product.normalizedName.contains(normalizedQuery);
    }).toList();

    suggestions.sort((first, second) {
      final firstStartsWithQuery = first.normalizedName.startsWith(
        normalizedQuery,
      );
      final secondStartsWithQuery = second.normalizedName.startsWith(
        normalizedQuery,
      );

      if (firstStartsWithQuery != secondStartsWithQuery) {
        return firstStartsWithQuery ? -1 : 1;
      }

      return first.normalizedName.compareTo(second.normalizedName);
    });

    return suggestions.take(5).toList();
  }

  /// Подставляет выбранный товар в поле названия.
  ///
  /// Мы не добавляем товар сразу после нажатия на подсказку.
  /// Мы только заполняем поле.
  ///
  /// Почему:
  /// пользователь может захотеть указать количество перед нажатием "+".
  void _selectProduct(KnownProduct product) {
    nameController.value = TextEditingValue(
      text: product.name,
      selection: TextSelection.collapsed(offset: product.name.length),
    );

    nameFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: nameController,
              builder: (context, value, child) {
                final query = value.text;
                final normalizedQuery = normalizeProductName(query);

                if (normalizedQuery.isEmpty) {
                  if (recentProducts.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return ProductSuggestionsList(
                    title: 'Последние покупки',
                    icon: Icons.history,
                    suggestions: recentProducts,
                    onSuggestionSelected: _selectProduct,
                  );
                }

                final suggestions = _findSuggestions(query);

                if (suggestions.isEmpty) {
                  return const SizedBox.shrink();
                }

                return ProductSuggestionsList(
                  title: 'Подсказки',
                  icon: Icons.search,
                  suggestions: suggestions,
                  onSuggestionSelected: _selectProduct,
                );
              },
            ),
            Row(
              children: [
                Expanded(
                  flex: 7,
                  child: TextField(
                    controller: nameController,
                    focusNode: nameFocusNode,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Товар',
                      hintText: 'Например: молоко',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Кол-во',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => onAddPressed(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  width: 48,
                  child: FilledButton(
                    onPressed: onAddPressed,
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
