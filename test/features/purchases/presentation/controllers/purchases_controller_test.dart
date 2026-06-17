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
        expect(item.status, ShoppingItemStatus.active);
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
      expect(item.status, ShoppingItemStatus.active);
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

    test('completePurchase should mark item as purchased', () async {
      final knownProductRepository = FakeKnownProductRepository();
      final shoppingItemRepository = FakeShoppingItemRepository();

      final controller = PurchasesController(
        knownProductRepository: knownProductRepository,
        shoppingItemRepository: shoppingItemRepository,
      );

      final product = await knownProductRepository.getOrCreateByName('Молоко');

      final item = await shoppingItemRepository.addOrUpdate(
        product: product,
        quantity: '2',
      );

      expect(shoppingItemRepository.activeItems.length, 1);

      await controller.completePurchase(item);

      expect(shoppingItemRepository.activeItems, isEmpty);
      expect(shoppingItemRepository.purchasedItems.length, 1);

      final updatedItem = await shoppingItemRepository.findById(item.id);

      expect(updatedItem, isNotNull);
      expect(updatedItem!.status, ShoppingItemStatus.purchased);
      expect(updatedItem.purchasedAt, DateTime(2026, 1, 2));
      expect(updatedItem.quantity, '2');
    });

    test('deletePurchase should mark item as deleted', () async {
      final knownProductRepository = FakeKnownProductRepository();
      final shoppingItemRepository = FakeShoppingItemRepository();

      final controller = PurchasesController(
        knownProductRepository: knownProductRepository,
        shoppingItemRepository: shoppingItemRepository,
      );

      final product = await knownProductRepository.getOrCreateByName('Молоко');

      final item = await shoppingItemRepository.addOrUpdate(
        product: product,
        quantity: '2',
      );

      await controller.deletePurchase(item.id);

      final updatedItem = await shoppingItemRepository.findById(item.id);

      expect(updatedItem, isNotNull);
      expect(updatedItem!.status, ShoppingItemStatus.deleted);
      expect(updatedItem.deletedAt, DateTime(2026, 1, 3));
      expect(shoppingItemRepository.activeItems, isEmpty);
    });

    test(
      'addRecentPurchase should activate purchased item with quantity',
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

        await shoppingItemRepository.markPurchased(item.id);

        final purchasedItem = await shoppingItemRepository.findById(item.id);

        await controller.addRecentPurchase(purchasedItem!);

        expect(shoppingItemRepository.items.length, 1);
        expect(shoppingItemRepository.activeItems.length, 1);

        final activeItem = shoppingItemRepository.activeItems.single;

        expect(activeItem.knownProductId, product.id);
        expect(activeItem.nameSnapshot, 'Молоко');
        expect(activeItem.quantity, '2');
        expect(activeItem.status, ShoppingItemStatus.active);
        expect(activeItem.purchasedAt, DateTime(2026, 1, 2));
      },
    );
  });
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

  List<ShoppingItem> get activeItems {
    return items.where((item) => item.isActive).toList();
  }

  List<ShoppingItem> get purchasedItems {
    return items.where((item) => item.isPurchased).toList();
  }

  @override
  Future<ShoppingItem> addOrUpdate({
    required KnownProduct product,
    String? quantity,
  }) async {
    final existingItem = _itemsByKnownProductId[product.id];

    if (existingItem != null) {
      final updatedItem = existingItem.activate(
        nameSnapshot: product.name,
        quantity: quantity,
        sortOrder: existingItem.sortOrder,
        now: DateTime(2026, 1, 4),
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
  Future<ShoppingItem?> markPurchased(String id) async {
    final item = await findById(id);

    if (item == null) {
      return null;
    }

    final updatedItem = item.markPurchased(purchasedAt: DateTime(2026, 1, 2));

    _itemsByKnownProductId[updatedItem.knownProductId] = updatedItem;

    return updatedItem;
  }

  @override
  Future<ShoppingItem?> markDeleted(String id) async {
    final item = await findById(id);

    if (item == null) {
      return null;
    }

    final updatedItem = item.markDeleted(deletedAt: DateTime(2026, 1, 3));

    _itemsByKnownProductId[updatedItem.knownProductId] = updatedItem;

    return updatedItem;
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
  Future<List<ShoppingItem>> getActive() async {
    return activeItems;
  }

  @override
  Future<List<ShoppingItem>> getPurchased() async {
    return purchasedItems;
  }

  @override
  Stream<List<ShoppingItem>> watchAll() {
    return Stream.value(items);
  }

  @override
  Stream<List<ShoppingItem>> watchActive() {
    return Stream.value(activeItems);
  }

  @override
  Stream<List<ShoppingItem>> watchPurchased() {
    return Stream.value(purchasedItems);
  }
}
