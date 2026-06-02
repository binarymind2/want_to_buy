import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/presentation/providers/known_product_providers.dart';

/// Экран настроек приложения.
///
/// Сейчас настройки очень простые:
/// - проверка обновлений;
/// - просмотр товаров, которые приложение запомнило в БД;
/// - информация о приложении.
///
/// Почему это отдельный экран:
/// главный экран "Покупки" должен отвечать только за покупки.
/// Всё, что относится к служебным действиям приложения,
/// лучше держать на экране "Настройки".
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Показывает диалог проверки обновлений.
  ///
  /// Сейчас это заглушка.
  ///
  /// Почему заглушка:
  /// у нас ещё нет сервера, API и логики сравнения версий.
  /// Но пункт меню уже можно сделать, чтобы экран настроек был готов
  /// под будущую функциональность.
  void _showUpdateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Проверка обновлений'),
          content: const Text(
            'Позже здесь будет проверка новой версии приложения.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ОК'),
            ),
          ],
        );
      },
    );
  }

  /// Показывает диалог со списком товаров из БД.
  ///
  /// Важно:
  /// это не активные покупки.
  /// Это именно известные товары, которые приложение запомнило
  /// для автоподсказок и последних покупок.
  void _showProductsDatabaseDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return const KnownProductsDatabaseDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: SafeArea(
        child: ListView(
          children: [
            const SettingsSectionTitle(title: 'Обновления'),
            ListTile(
              leading: const Icon(Icons.system_update_outlined),
              title: const Text('Проверить обновления'),
              subtitle: const Text('Позже подключим реальную проверку версии'),
              onTap: () => _showUpdateDialog(context),
            ),
            const Divider(height: 1),

            const SettingsSectionTitle(title: 'База товаров'),
            ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text('Показать товары в БД'),
              subtitle: const Text('Показать сохранённые товары'),
              onTap: () => _showProductsDatabaseDialog(context),
            ),
            const Divider(height: 1),

            const SettingsSectionTitle(title: 'О приложении'),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Want to Buy'),
              subtitle: Text('Минималистичный список покупок'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Диалог со списком известных товаров.
///
/// Почему это отдельный виджет:
/// если оставить весь код внутри showDialog,
/// SettingsScreen быстро станет тяжело читать.
///
/// Этот виджет отвечает только за одно:
/// показать содержимое knownProductsProvider в диалоге.
class KnownProductsDatabaseDialog extends ConsumerWidget {
  const KnownProductsDatabaseDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(knownProductsProvider);

    return AlertDialog(
      title: const Text('Товары в БД'),
      content: SizedBox(
        width: double.maxFinite,
        child: productsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return const Text(
                'База товаров пока пустая.\n'
                'Добавьте товар на экране покупок.',
              );
            }

            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: products.length,
                separatorBuilder: (context, index) {
                  return const Divider(height: 1);
                },
                itemBuilder: (context, index) {
                  final product = products[index];

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(product.name),
                    subtitle: product.wasPurchased
                        ? const Text('Товар уже покупали')
                        : const Text('Пока не покупали'),
                  );
                },
              ),
            );
          },
          loading: () {
            return const SizedBox(
              height: 96,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          error: (error, stackTrace) {
            return Text('Не удалось загрузить товары: $error');
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

/// Заголовок секции на экране настроек.
///
/// Например:
/// - Обновления
/// - База товаров
/// - О приложении
///
/// Почему делаем отдельным виджетом:
/// стиль заголовков будет одинаковый,
/// и если потом мы захотим поменять отступы или цвет,
/// это нужно будет сделать только в одном месте.
class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
