import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/known_product.dart';
import '../../../products/domain/utils/product_name_normalizer.dart';
import '../../../products/presentation/providers/known_product_providers.dart';
import '../../domain/entities/shopping_item.dart';
import '../providers/shopping_item_providers.dart';

/// Большое модальное окно добавления товара.
///
/// Почему это отдельный виджет:
/// экран покупок отвечает за список покупок,
/// а сценарий добавления теперь достаточно большой:
/// - поля ввода;
/// - фильтрация известных товаров;
/// - отображение товаров, которые уже есть в активном списке;
/// - добавление или обновление товара.
///
/// Если оставить всё это в PurchasesScreen,
/// экран быстро станет слишком большим и сложным.
class AddPurchaseBottomSheet extends ConsumerStatefulWidget {
  const AddPurchaseBottomSheet({super.key});

  @override
  ConsumerState<AddPurchaseBottomSheet> createState() =>
      _AddPurchaseBottomSheetState();
}

class _AddPurchaseBottomSheetState
    extends ConsumerState<AddPurchaseBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();

  bool _isSaving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();

    // После открытия bottom sheet сразу ставим курсор в поле товара.
    // Так пользователь может сразу печатать, не делая лишний тап.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _nameFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();

    _nameFocusNode.dispose();
    _quantityFocusNode.dispose();

    super.dispose();
  }

  Future<void> _onAddPressed() async {
    final name = _nameController.text.trim();
    final quantity = _quantityController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorText = 'Введите название товара';
      });

      _nameFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    try {
      await ref
          .read(purchasesControllerProvider)
          .addPurchase(name: name, quantity: quantity);

      if (!mounted) {
        return;
      }

      // Окно не закрываем специально.
      //
      // Почему:
      // список покупок обычно заполняют пачкой:
      // молоко, хлеб, яйца, сыр.
      //
      // Если закрывать окно после каждого добавления,
      // пользователю придётся каждый раз снова нажимать "+".
      _nameController.clear();
      _quantityController.clear();
      _nameFocusNode.requestFocus();

      setState(() {
        _isSaving = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _errorText = 'Не удалось добавить товар: $error';
      });
    }
  }

  /// Подставляет выбранный товар в поля.
  ///
  /// Если для товара уже есть ShoppingItem,
  /// берём quantity из него.
  ///
  /// Это работает и для активной покупки,
  /// и для последней купленной записи.
  void _selectProduct(
    KnownProduct product,
    Map<String, ShoppingItem> itemsByProductId,
  ) {
    final item = itemsByProductId[product.id];
    final quantity = item?.quantity ?? '';

    _nameController.value = TextEditingValue(
      text: product.name,
      selection: TextSelection.collapsed(offset: product.name.length),
    );

    _quantityController.value = TextEditingValue(
      text: quantity,
      selection: TextSelection.collapsed(offset: quantity.length),
    );

    // После выбора товара удобнее сразу поправить количество.
    _quantityFocusNode.requestFocus();
  }

  /// Фильтрует товары по введённому тексту.
  ///
  /// Если поле пустое — показываем все известные товары.
  /// Если пользователь начал вводить текст — показываем только совпадения.
  List<KnownProduct> _filterProducts({
    required List<KnownProduct> products,
    required String query,
  }) {
    final normalizedQuery = normalizeProductName(query);

    final filteredProducts = normalizedQuery.isEmpty
        ? products.toList()
        : products.where((product) {
            return product.normalizedName.contains(normalizedQuery);
          }).toList();

    filteredProducts.sort((first, second) {
      if (normalizedQuery.isNotEmpty) {
        final firstStartsWithQuery = first.normalizedName.startsWith(
          normalizedQuery,
        );
        final secondStartsWithQuery = second.normalizedName.startsWith(
          normalizedQuery,
        );

        if (firstStartsWithQuery != secondStartsWithQuery) {
          return firstStartsWithQuery ? -1 : 1;
        }
      }

      return first.normalizedName.compareTo(second.normalizedName);
    });

    return filteredProducts;
  }

  /// Делаем быстрый словарь:
  ///
  /// ключ — knownProductId;
  /// значение — ShoppingItem в любом состоянии.
  ///
  /// Так нам легко понять:
  /// есть ли у известного товара уже сохранённое состояние.
  Map<String, ShoppingItem> _createItemsByProductId(List<ShoppingItem> items) {
    return <String, ShoppingItem>{
      for (final item in items) item.knownProductId: item,
    };
  }

  KnownProduct? _findProductByNormalizedName({
    required AsyncValue<List<KnownProduct>> knownProductsAsync,
    required String normalizedName,
  }) {
    if (normalizedName.isEmpty) {
      return null;
    }

    return knownProductsAsync.maybeWhen(
      data: (products) {
        for (final product in products) {
          if (product.normalizedName == normalizedName) {
            return product;
          }
        }

        return null;
      },
      orElse: () => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final knownProductsAsync = ref.watch(knownProductsProvider);
    final allShoppingItemsAsync = ref.watch(allShoppingItemsProvider);

    final itemsByProductId = allShoppingItemsAsync.maybeWhen(
      data: _createItemsByProductId,
      orElse: () => const <String, ShoppingItem>{},
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Material(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Добавить товар',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Закрыть',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: TextField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Товар',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: 'Например: молоко',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) {
                            _quantityFocusNode.requestFocus();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _quantityController,
                          focusNode: _quantityFocusNode,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Кол-во',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: '1',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _onAddPressed(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Товары для выбора',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _nameController,
                      builder: (context, value, child) {
                        return knownProductsAsync.when(
                          data: (products) {
                            final filteredProducts = _filterProducts(
                              products: products,
                              query: value.text,
                            );

                            if (products.isEmpty) {
                              return const _ProductsMessage(
                                icon: Icons.inventory_2_outlined,
                                text: 'В базе пока нет известных товаров',
                              );
                            }

                            if (filteredProducts.isEmpty) {
                              return const _ProductsMessage(
                                icon: Icons.search_off_outlined,
                                text: 'Подходящих товаров не найдено',
                              );
                            }

                            return ListView.separated(
                              controller: scrollController,
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              itemCount: filteredProducts.length,
                              separatorBuilder: (context, index) {
                                return const Divider(height: 1);
                              },
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                final item = itemsByProductId[product.id];
                                final isAlreadyInActiveList =
                                    item?.isActive ?? false;

                                return _KnownProductListTile(
                                  product: product,
                                  item: item,
                                  isAlreadyInActiveList: isAlreadyInActiveList,
                                  onPressed: () {
                                    _selectProduct(product, itemsByProductId);
                                  },
                                );
                              },
                            );
                          },
                          loading: () {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          error: (error, stackTrace) {
                            return _ProductsMessage(
                              icon: Icons.error_outline,
                              text: 'Не удалось загрузить товары: $error',
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_errorText != null) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _errorText!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _nameController,
                    builder: (context, value, child) {
                      final normalizedName = normalizeProductName(value.text);
                      final selectedProduct = _findProductByNormalizedName(
                        knownProductsAsync: knownProductsAsync,
                        normalizedName: normalizedName,
                      );

                      final selectedItem = selectedProduct == null
                          ? null
                          : itemsByProductId[selectedProduct.id];

                      final isAlreadyInActiveList =
                          selectedItem?.isActive ?? false;

                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: normalizedName.isEmpty || _isSaving
                              ? null
                              : _onAddPressed,
                          icon: Icon(
                            isAlreadyInActiveList ? Icons.refresh : Icons.add,
                          ),
                          label: Text(
                            _isSaving
                                ? 'Добавляем...'
                                : isAlreadyInActiveList
                                ? 'Обновить товар'
                                : 'Добавить товар',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _KnownProductListTile extends StatelessWidget {
  const _KnownProductListTile({
    required this.product,
    required this.item,
    required this.isAlreadyInActiveList,
    required this.onPressed,
  });

  final KnownProduct product;
  final ShoppingItem? item;
  final bool isAlreadyInActiveList;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final quantity = item?.quantity;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(product.name),
      subtitle: isAlreadyInActiveList
          ? Text(
              'Уже в списке покупок',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.primary),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (quantity != null && quantity.isNotEmpty) ...[
            Text(
              quantity,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (isAlreadyInActiveList)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'В списке',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      onTap: onPressed,
    );
  }
}

class _ProductsMessage extends StatelessWidget {
  const _ProductsMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
