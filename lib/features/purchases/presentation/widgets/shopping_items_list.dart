import 'package:flutter/material.dart';

import '../../domain/entities/shopping_item.dart';
import 'shopping_item_tile.dart';

/// Список активных покупок.
///
/// Этот виджет отвечает только за отображение списка.
/// Он не хранит таймеры и не удаляет товары сам.
class ShoppingItemsList extends StatelessWidget {
  const ShoppingItemsList({
    super.key,
    required this.items,
    required this.pendingRemovalItemIds,
    required this.removalDelay,
    required this.onItemPressed,
  });

  final List<ShoppingItem> items;
  final Set<String> pendingRemovalItemIds;
  final Duration removalDelay;
  final ValueChanged<ShoppingItem> onItemPressed;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      separatorBuilder: (context, index) {
        return const Divider(height: 1);
      },
      itemBuilder: (context, index) {
        final item = items[index];

        return ShoppingItemTile(
          key: ValueKey(item.id),
          item: item,
          isPendingRemoval: pendingRemovalItemIds.contains(item.id),
          removalDelay: removalDelay,
          onPressed: () => onItemPressed(item),
        );
      },
    );
  }
}
