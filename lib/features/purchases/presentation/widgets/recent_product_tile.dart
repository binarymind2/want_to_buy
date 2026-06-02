import 'package:flutter/material.dart';

import '../../../products/domain/entities/known_product.dart';

/// Строка товара из секции "Последние покупки".
///
/// Это не активная покупка.
/// Поэтому здесь нет:
/// - таймера удаления;
/// - прогресс-бара;
/// - количества;
/// - иконок.
///
/// Нажатие на строку означает:
/// "Я хочу снова добавить этот товар в список покупок".
///
/// Мы оставляем только текст,
/// чтобы последние покупки выглядели как обычный спокойный список.
class RecentProductTile extends StatelessWidget {
  const RecentProductTile({
    super.key,
    required this.product,
    required this.onPressed,
  });

  final KnownProduct product;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
