import 'package:flutter/material.dart';

import '../../domain/entities/shopping_item.dart';

/// Одна строка активной покупки.
///
/// Строка умеет не только отображать товар, но и показывать
/// состояние ожидания удаления.
///
/// Когда пользователь нажал на товар:
/// - строка становится полупрозрачной;
/// - под строкой появляется progress bar;
/// - повторное нажатие отменяет удаление.
class ShoppingItemTile extends StatelessWidget {
  const ShoppingItemTile({
    super.key,
    required this.item,
    required this.isPendingRemoval,
    required this.removalDelay,
    required this.onPressed,
  });

  final ShoppingItem item;
  final bool isPendingRemoval;
  final Duration removalDelay;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onPressed,
      child: AnimatedOpacity(
        opacity: isPendingRemoval ? 0.55 : 1,
        duration: const Duration(milliseconds: 180),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.nameSnapshot,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  if (item.hasQuantity) ...[
                    const SizedBox(width: 12),
                    Text(
                      item.quantity!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isPendingRemoval)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('removal-progress-${item.id}'),
                  tween: Tween<double>(begin: 1, end: 0),
                  duration: removalDelay,
                  curve: Curves.linear,
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 3,
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.08,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary.withValues(alpha: 0.35),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
