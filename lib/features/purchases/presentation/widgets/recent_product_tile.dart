import 'package:flutter/material.dart';

import '../../../products/domain/entities/known_product.dart';

/// Строка товара из секции "Последние покупки".
///
/// Это не активная покупка.
/// Поэтому здесь нет:
/// - таймера удаления;
/// - прогресс-бара;
/// - иконок.
///
/// Нажатие на строку означает:
/// "Вернуть этот товар в активный список покупок".
///
/// Показываем не только название, но и последнее количество.
/// Так пользователь заранее видит, что именно вернётся в список:
/// - Молоко 2
/// - Хлеб
/// - Яйца 10
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
    final textTheme = Theme.of(context).textTheme;
    final quantity = product.lastPurchasedQuantity;

    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 64,
              child: Text(
                quantity ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
