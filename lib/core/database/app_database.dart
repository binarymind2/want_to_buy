import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/products/data/models/known_product_model.dart';
import '../../features/purchases/data/models/shopping_item_model.dart';

/// Класс для открытия локальной базы данных приложения.
///
/// Сейчас здесь только Isar.
///
/// Почему выносим это в отдельный файл:
/// - main.dart не должен знать детали открытия базы;
/// - позже будет проще подключить Riverpod provider;
/// - все схемы Isar собраны в одном месте.
class AppDatabase {
  const AppDatabase._();

  static Isar? _isar;

  /// Открывает базу данных или возвращает уже открытую.
  ///
  /// Isar.open нужно вызвать один раз при старте приложения.
  /// После этого один экземпляр Isar можно использовать в репозиториях.
  static Future<Isar> open() async {
    final currentIsar = _isar;

    if (currentIsar != null) {
      return currentIsar;
    }

    final directory = await getApplicationDocumentsDirectory();

    final isar = await Isar.open([
      KnownProductModelSchema,
      ShoppingItemModelSchema,
    ], directory: directory.path);

    _isar = isar;

    return isar;
  }

  /// Возвращает уже открытую базу.
  ///
  /// Этот метод пригодится позже в репозиториях.
  ///
  /// Если база ещё не открыта, выбрасываем понятную ошибку.
  static Isar get instance {
    final currentIsar = _isar;

    if (currentIsar == null) {
      throw StateError(
        'Isar database is not opened. '
        'Call AppDatabase.open() before using AppDatabase.instance.',
      );
    }

    return currentIsar;
  }

  /// Закрывает базу.
  ///
  /// В обычном приложении это редко нужно,
  /// но метод полезен для тестов и аккуратного завершения.
  static Future<void> close() async {
    final currentIsar = _isar;

    if (currentIsar == null) {
      return;
    }

    await currentIsar.close();
    _isar = null;
  }
}
