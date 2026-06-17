import 'package:flutter/material.dart';

import '../../../products/domain/entities/known_product.dart';
import '../../domain/entities/shopping_item.dart';
import 'recent_product_tile.dart';
import 'shopping_item_tile.dart';

/// Общий список на экране покупок.
///
/// В одном ListView идут:
/// 1. активные покупки;
/// 2. последние покупки.
///
/// Это важно:
/// последние покупки больше не являются отдельной нижней карточкой.
/// Они находятся в общем списке ниже активных покупок.
class ShoppingItemsList extends StatelessWidget {
  const ShoppingItemsList({
    super.key,
    required this.items,
    required this.recentProducts,
    required this.pendingRemovalItemIds,
    required this.removalDelay,
    required this.onItemPressed,
    required this.onRecentProductPressed,
  });

  final List<ShoppingItem> items;
  final List<KnownProduct> recentProducts;

  final Set<String> pendingRemovalItemIds;
  final Duration removalDelay;

  final ValueChanged<ShoppingItem> onItemPressed;
  final ValueChanged<KnownProduct> onRecentProductPressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 96),
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0) const Divider(height: 1),
          ShoppingItemTile(
            key: ValueKey(items[index].id),
            item: items[index],
            isPendingRemoval: pendingRemovalItemIds.contains(items[index].id),
            removalDelay: removalDelay,
            onPressed: () => onItemPressed(items[index]),
          ),
        ],
        if (recentProducts.isNotEmpty) ...[
          if (items.isNotEmpty) const Divider(height: 1),
          const _ListSectionHeader(title: 'Последние покупки'),
          for (var index = 0; index < recentProducts.length; index++) ...[
            if (index > 0) const Divider(height: 1),
            RecentProductTile(
              key: ValueKey('recent-product-${recentProducts[index].id}'),
              product: recentProducts[index],
              onPressed: () => onRecentProductPressed(recentProducts[index]),
            ),
          ],
        ],
      ],
    );
  }
}

class _ListSectionHeader extends StatelessWidget {
  const _ListSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
