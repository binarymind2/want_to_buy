import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/known_product.dart';
import '../../../products/presentation/providers/known_product_providers.dart';

/// Экран настроек.
///
/// Сейчас здесь остаются только те действия, которые реально нужны MVP:
/// - открыть список известных товаров в БД;
/// - посмотреть версию приложения.
///
/// Проверку обновлений убираем, потому что в текущей версии приложения
/// ещё нет сервера, API обновлений и механизма загрузки новой версии.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _showKnownProductsDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final knownProductsAsync = ref.read(knownProductsProvider);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return knownProductsAsync.when(
          data: (products) {
            return _KnownProductsDialog(products: products);
          },
          loading: () {
            return const AlertDialog(
              title: Text('Товары в БД'),
              content: SizedBox(
                height: 96,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          },
          error: (error, stackTrace) {
            return AlertDialog(
              title: const Text('Товары в БД'),
              content: Text('Не удалось загрузить товары: $error'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Закрыть'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(
            title: 'База товаров',
            children: [
              ListTile(
                leading: const Icon(Icons.storage_outlined),
                title: const Text('Показать товары в БД'),
                subtitle: const Text(
                  'Посмотреть товары, которые приложение запомнило',
                ),
                onTap: () => _showKnownProductsDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SettingsSection(
            title: 'О приложении',
            children: [
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Хочу купить'),
                subtitle: Text('Версия 1.0.0'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Небольшой общий виджет для секции настроек.
///
/// Он нужен, чтобы настройки выглядели аккуратно:
/// есть заголовок секции и карточка с пунктами.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// Диалог со списком известных товаров.
///
/// Здесь мы показываем товары, которые приложение уже запомнило.
/// Это нужно для проверки, что автоподсказки и сохранение новых товаров работают.
class _KnownProductsDialog extends StatelessWidget {
  const _KnownProductsDialog({required this.products});

  final List<KnownProduct> products;

  String _getProductPurchaseStatus(KnownProduct product) {
    if (product.wasPurchased) {
      return 'Товар уже покупали';
    }

    return 'Пока не покупали';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Товары в БД'),
      content: SizedBox(
        width: double.maxFinite,
        child: products.isEmpty
            ? const Text('База товаров пока пустая')
            : ListView.separated(
                shrinkWrap: true,
                itemCount: products.length,
                separatorBuilder: (context, index) {
                  return const Divider(height: 1);
                },
                itemBuilder: (context, index) {
                  final product = products[index];

                  return ListTile(
                    dense: true,
                    title: Text(product.name),
                    subtitle: Text(_getProductPurchaseStatus(product)),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }
}
