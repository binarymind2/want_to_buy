import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../database/app_database.dart';

/// Provider для доступа к открытому экземпляру Isar.
///
/// Почему он нужен:
/// - репозиториям нужна база данных;
/// - UI не должен напрямую обращаться к AppDatabase;
/// - через Riverpod мы сможем удобно передавать Isar туда, где он нужен.
///
/// Важно:
/// AppDatabase.open() уже вызывается в main() до запуска приложения.
/// Поэтому здесь мы просто берём AppDatabase.instance.
final isarProvider = Provider<Isar>((ref) {
  return AppDatabase.instance;
});
