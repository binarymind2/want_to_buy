import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/isar_provider.dart';
import '../../data/repositories/isar_known_product_repository.dart';
import '../../domain/entities/known_product.dart';
import '../../domain/repositories/known_product_repository.dart';

/// Provider репозитория известных товаров.
///
/// Почему возвращаем тип KnownProductRepository, а не IsarKnownProductRepository:
/// UI и controller должны зависеть от абстракции, а не от конкретной БД.
///
/// Сейчас внутри используется Isar.
/// В будущем можно будет заменить реализацию на другую,
/// а остальной код менять почти не придётся.
final knownProductRepositoryProvider = Provider<KnownProductRepository>((ref) {
  final isar = ref.watch(isarProvider);

  return IsarKnownProductRepository(isar: isar);
});

/// Provider списка всех известных товаров.
///
/// Это StreamProvider, потому что репозиторий отдаёт Stream.
///
/// Почему Stream:
/// если в базе появится новый товар,
/// UI автоматически получит обновлённый список.
final knownProductsProvider = StreamProvider<List<KnownProduct>>((ref) {
  final repository = ref.watch(knownProductRepositoryProvider);

  return repository.watchAll();
});
