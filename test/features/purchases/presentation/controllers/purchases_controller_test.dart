import 'package:flutter_test/flutter_test.dart';
import 'package:want_to_buy/features/products/domain/entities/known_product.dart';
import 'package:want_to_buy/features/products/domain/repositories/known_product_repository.dart';
import 'package:want_to_buy/features/products/domain/utils/product_name_normalizer.dart';
import 'package:want_to_buy/features/purchases/domain/entities/shopping_item.dart';
import 'package:want_to_buy/features/purchases/domain/repositories/shopping_item_repository.dart';
import 'package:want_to_buy/features/purchases/presentation/controllers/purchases_controller.dart';

void main() {
  group('PurchasesController', () {
    test(
      'addPurchase should create known product and active purchase',
      () async {
        final knownProductRepository = FakeKnownProductRepository();
        final shoppingItemRepository = FakeShoppingItemRepository();

        final controller = PurchasesController(
          knownProductRepository: knownProductRepository,
          shoppingItemRepository: shoppingItemRepository,
        );

        await controller.addPurchase(name: '  Молоко  ', quantity: ' 2 ');

        expect(knownProductRepository.products.length, 1);
        expect(shoppingItemRepository.items.length, 1);

        final product = knownProductRepository.products.single;
        final item = shoppingItemRepository.items.single;

        expect(product.name, 'Молоко');
        expect(product.normalizedName, 'молоко');

        expect(item.knownProductId, product.id);
        expect(item.nameSnapshot, 'Молоко');
        expect(item.quantity, '2');
      },
    );

    test('addPurchase should not create duplicate known product', () async {
      final knownProductRepository = FakeKnownProductRepository();
      final shoppingItemRepository = FakeShoppingItemRepository();

      final controller = PurchasesController(
        knownProductRepository: knownProductRepository,
        shoppingItemRepository: shoppingItemRepository,
      );

      await controller.addPurchase(name: 'Молоко', quantity: '1');
      await controller.addPurchase(name: '  МОЛОКО  ', quantity: '2');

      expect(knownProductRepository.products.length, 1);
      expect(shoppingItemRepository.items.length, 1);

      final item = shoppingItemRepository.items.single;

      expect(item.nameSnapshot, 'Молоко');
      expect(item.quantity, '2');
    });

    test('addPurchase should throw when name is empty', () async {
      final knownProductRepository = FakeKnownProductRepository();
      final shoppingItemRepository = FakeShoppingItemRepository();

      final controller = PurchasesController(
        knownProductRepository: knownProductRepository,
        shoppingItemRepository: shoppingItemRepository,
      );

      expect(
        () => controller.addPurchase(name: '   ', quantity: '2'),
        throwsArgumentError,
      );

      expect(knownProductRepository.products, isEmpty);
      expect(shoppingItemRepository.items, isEmpty);
    });

    test(
      'completePurchase should mark product as purchased and remove item',
      () async {
        final knownProductRepository = FakeKnownProductRepository();
        final shoppingItemRepository = FakeShoppingItemRepository();

        final controller = PurchasesController(
          knownProductRepository: knownProductRepository,
          shoppingItemRepository: shoppingItemRepository,
        );

        final product = await knownProductRepository.getOrCreateByName(
          'Молоко',
        );

        final item = await shoppingItemRepository.addOrUpdate(
          product: product,
          quantity: '2',
        );

        expect(shoppingItemRepository.items.length, 1);

        await controller.completePurchase(item);

        expect(shoppingItemRepository.items, isEmpty);

        final updatedProduct = await knownProductRepository.findById(
          product.id,
        );

        expect(updatedProduct, isNotNull);
        expect(updatedProduct!.lastPurchasedAt, DateTime(2026, 1, 2));
        expect(updatedProduct.lastPurchasedQuantity, '2');
      },
    );
  });

  test(
    'addRecentPurchase should add product with last purchased quantity',
    () async {
      final knownProductRepository = FakeKnownProductRepository();
      final shoppingItemRepository = FakeShoppingItemRepository();

      final controller = PurchasesController(
        knownProductRepository: knownProductRepository,
        shoppingItemRepository: shoppingItemRepository,
      );

      final product = KnownProduct.fromStorage(
        id: 'product-1',
        name: 'Молоко',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
        lastPurchasedAt: DateTime(2026, 1, 2),
        lastPurchasedQuantity: '2',
      );

      await controller.addRecentPurchase(product);

      expect(shoppingItemRepository.items.length, 1);

      final item = shoppingItemRepository.items.single;

      expect(item.knownProductId, product.id);
      expect(item.nameSnapshot, 'Молоко');
      expect(item.quantity, '2');
    },
  );
}

class FakeKnownProductRepository implements KnownProductRepository {
  final Map<String, KnownProduct> _productsByNormalizedName = {};
  int _nextId = 1;

  List<KnownProduct> get products => _productsByNormalizedName.values.toList();

  @override
  Future<KnownProduct> getOrCreateByName(String name) async {
    final normalizedName = normalizeProductName(name);

    final existingProduct = _productsByNormalizedName[normalizedName];

    if (existingProduct != null) {
      return existingProduct;
    }

    final product = KnownProduct.create(
      id: 'product-${_nextId++}',
      name: name,
      now: DateTime(2026, 1, 1),
    );

    _productsByNormalizedName[product.normalizedName] = product;

    return product;
  }

  @override
  Future<List<KnownProduct>> getAll() async {
    return products;
  }

  @override
  Future<KnownProduct?> findById(String id) async {
    for (final product in products) {
      if (product.id == id) {
        return product;
      }
    }

    return null;
  }

  @override
  Future<KnownProduct?> findByNormalizedName(String normalizedName) async {
    return _productsByNormalizedName[normalizedName];
  }

  @override
  Future<KnownProduct?> markPurchased(
    String productId, {
    String? quantity,
  }) async {
    final product = await findById(productId);

    if (product == null) {
      return null;
    }

    final updatedProduct = product.markPurchased(
      purchasedAt: DateTime(2026, 1, 2),
      quantity: quantity,
    );

    _productsByNormalizedName[updatedProduct.normalizedName] = updatedProduct;

    return updatedProduct;
  }

  @override
  Future<void> save(KnownProduct product) async {
    _productsByNormalizedName[product.normalizedName] = product;
  }

  @override
  Future<List<KnownProduct>> searchSuggestions(
    String query, {
    int limit = 10,
  }) async {
    final normalizedQuery = normalizeProductName(query);

    return products
        .where((product) => product.normalizedName.contains(normalizedQuery))
        .take(limit)
        .toList();
  }

  @override
  Stream<List<KnownProduct>> watchAll() {
    return Stream.value(products);
  }
}

class FakeShoppingItemRepository implements ShoppingItemRepository {
  final Map<String, ShoppingItem> _itemsByKnownProductId = {};
  int _nextId = 1;

  List<ShoppingItem> get items => _itemsByKnownProductId.values.toList();

  @override
  Future<ShoppingItem> addOrUpdate({
    required KnownProduct product,
    String? quantity,
  }) async {
    final existingItem = _itemsByKnownProductId[product.id];

    if (existingItem != null) {
      final updatedItem = ShoppingItem.fromStorage(
        id: existingItem.id,
        knownProductId: existingItem.knownProductId,
        nameSnapshot: product.name,
        quantity: quantity,
        createdAt: existingItem.createdAt,
        sortOrder: existingItem.sortOrder,
      );

      _itemsByKnownProductId[product.id] = updatedItem;

      return updatedItem;
    }

    final item = ShoppingItem.create(
      id: 'item-${_nextId++}',
      knownProductId: product.id,
      nameSnapshot: product.name,
      quantity: quantity,
      sortOrder: _nextId,
      now: DateTime(2026, 1, 1),
    );

    _itemsByKnownProductId[product.id] = item;

    return item;
  }

  @override
  Future<void> deleteById(String id) async {
    _itemsByKnownProductId.removeWhere((key, item) {
      return item.id == id;
    });
  }

  @override
  Future<ShoppingItem?> findById(String id) async {
    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  @override
  Future<ShoppingItem?> findByKnownProductId(String knownProductId) async {
    return _itemsByKnownProductId[knownProductId];
  }

  @override
  Future<List<ShoppingItem>> getAll() async {
    return items;
  }

  @override
  Stream<List<ShoppingItem>> watchAll() {
    return Stream.value(items);
  }
}
