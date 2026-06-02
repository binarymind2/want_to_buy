import 'package:flutter/material.dart';

import '../../../products/domain/entities/known_product.dart';

/// Список товаров над полем ввода.
///
/// Этот виджет используется в двух сценариях:
/// 1. "Последние покупки" — когда поле ввода пустое.
/// 2. "Подсказки" — когда пользователь начал вводить текст.
///
/// Почему используем один виджет:
/// визуально это один и тот же список товаров,
/// отличается только заголовок и иконка.
class ProductSuggestionsList extends StatelessWidget {
  const ProductSuggestionsList({
    super.key,
    required this.title,
    required this.icon,
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  final String title;
  final IconData icon;
  final List<KnownProduct> suggestions;
  final ValueChanged<KnownProduct> onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  separatorBuilder: (context, index) {
                    return const Divider(height: 1);
                  },
                  itemBuilder: (context, index) {
                    final product = suggestions[index];

                    return ListTile(
                      dense: true,
                      leading: Icon(icon),
                      title: Text(product.name),
                      onTap: () => onSuggestionSelected(product),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
