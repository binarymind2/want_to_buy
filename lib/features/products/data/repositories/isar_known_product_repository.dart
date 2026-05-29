import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/known_product.dart';
import '../../domain/repositories/known_product_repository.dart';
import '../../domain/utils/product_name_normalizer.dart';
import '../models/known_product_model.dart';

/// Isar-реализация репозитория известных товаров.
///
/// Это data-слой.
///
/// Здесь мы уже знаем:
/// - что данные хранятся в Isar;
/// - что есть KnownProductModel;
/// - что записи нужно читать и сохранять через транзакции.
class IsarKnownProductRepository implements KnownProductRepository {
  IsarKnownProductRepository({required Isar isar, Uuid? uuid})
    : _isar = isar,
      _uuid = uuid ?? const Uuid();

  final Isar _isar;
  final Uuid _uuid;

  @override
  Stream<List<KnownProduct>> watchAll() {
    return _isar.knownProductModels
        .where()
        .sortByNormalizedName()
        .watch(fireImmediately: true)
        .map((models) {
          return models.map((model) => model.toEntity()).toList();
        });
  }

  @override
  Future<List<KnownProduct>> getAll() async {
    final models = await _isar.knownProductModels
        .where()
        .sortByNormalizedName()
        .findAll();

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<KnownProduct?> findById(String id) async {
    final model = await _isar.knownProductModels.getByDomainId(id);

    return model?.toEntity();
  }

  @override
  Future<KnownProduct?> findByNormalizedName(String normalizedName) async {
    final model = await _isar.knownProductModels.getByNormalizedName(
      normalizedName,
    );

    return model?.toEntity();
  }

  @override
  Future<KnownProduct> getOrCreateByName(String name) async {
    final normalizedName = normalizeProductName(name);

    final existingModel = await _isar.knownProductModels.getByNormalizedName(
      normalizedName,
    );

    if (existingModel != null) {
      return existingModel.toEntity();
    }

    final product = KnownProduct.create(id: _uuid.v4(), name: name);

    await save(product);

    return product;
  }

  @override
  Future<List<KnownProduct>> searchSuggestions(
    String query, {
    int limit = 10,
  }) async {
    final normalizedQuery = normalizeProductName(query);

    if (normalizedQuery.isEmpty) {
      return [];
    }

    final models = await _isar.knownProductModels
        .where()
        .filter()
        .normalizedNameContains(normalizedQuery)
        .sortByNormalizedName()
        .limit(limit)
        .findAll();

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> save(KnownProduct product) async {
    await _isar.writeTxn(() async {
      final existingModel = await _isar.knownProductModels.getByDomainId(
        product.id,
      );

      final model = product.toModel(isarId: existingModel?.id);

      await _isar.knownProductModels.put(model);
    });
  }

  @override
  Future<KnownProduct?> markPurchased(String productId) async {
    return _isar.writeTxn(() async {
      final existingModel = await _isar.knownProductModels.getByDomainId(
        productId,
      );

      if (existingModel == null) {
        return null;
      }

      final updatedProduct = existingModel.toEntity().markPurchased();
      final updatedModel = updatedProduct.toModel(isarId: existingModel.id);

      await _isar.knownProductModels.put(updatedModel);

      return updatedProduct;
    });
  }
}
