/// Состояние товара относительно списка покупок.
///
/// Почему нужен статус:
/// раньше ShoppingItem физически удалялся после покупки.
/// Это удобно для маленькой локальной версии, но плохо для истории
/// и будущей синхронизации.
///
/// Теперь ShoppingItem не удаляется сразу, а меняет состояние:
/// - active — товар сейчас нужно купить;
/// - purchased — товар куплен и находится в последних покупках;
/// - deleted — товар удалён пользователем.
enum ShoppingItemStatus { active, purchased, deleted }

extension ShoppingItemStatusStorage on ShoppingItemStatus {
  /// Строковое значение для хранения в Isar.
  ///
  /// Мы специально храним status как строку, а не как индекс enum.
  /// Почему:
  /// если позже поменять порядок enum-значений,
  /// старые данные в базе не сломаются.
  String get storageValue {
    return name;
  }

  static ShoppingItemStatus fromStorage(String value) {
    return ShoppingItemStatus.values.firstWhere(
      (status) => status.storageValue == value,
      orElse: () => ShoppingItemStatus.active,
    );
  }
}

/// Товар в списке покупок.
///
/// Важно:
/// ShoppingItem теперь не означает только "активная покупка".
/// Это единственная запись состояния товара в рамках списка.
///
/// Правило:
/// один KnownProduct должен иметь только один ShoppingItem.
///
/// Примеры состояний:
/// - Молоко, quantity 2, status active
/// - Молоко, quantity 2, status purchased, purchasedAt 2026-06-17
/// - Молоко, quantity 2, status deleted, deletedAt 2026-06-17
class ShoppingItem {
  static const Object _unset = Object();

  /// Уникальный идентификатор записи состояния товара.
  final String id;

  /// id известного товара, с которым связана эта запись.
  final String knownProductId;

  /// Название товара на момент последнего добавления в список.
  ///
  /// Почему не брать название только из KnownProduct?
  /// Сейчас можно было бы брать напрямую, но nameSnapshot делает модель
  /// надёжнее: ShoppingItem сам знает, какое название показывать.
  final String nameSnapshot;

  /// Количество товара.
  ///
  /// Может быть null.
  ///
  /// Если null или пустое значение — на экране количество не показываем.
  final String? quantity;

  /// Состояние записи.
  final ShoppingItemStatus status;

  /// Дата создания записи состояния товара.
  final DateTime createdAt;

  /// Дата последнего изменения записи.
  ///
  /// Это поле важно перед будущей синхронизацией:
  /// backend и клиенту нужно понимать, когда состояние менялось.
  final DateTime updatedAt;

  /// Дата последней покупки этого товара.
  ///
  /// Если status == purchased, это дата покупки.
  /// Если status == active, здесь может оставаться дата прошлой покупки.
  /// Это удобно для подсказок и последних количеств.
  final DateTime? purchasedAt;

  /// Дата удаления товара из списка.
  ///
  /// Это не покупка. Это отдельное действие пользователя:
  /// "я не хочу видеть этот товар в списке".
  final DateTime? deletedAt;

  /// Порядок сортировки в активном списке.
  ///
  /// Сейчас можно использовать дату создания.
  /// Но sortOrder пригодится позже, если захочешь ручную сортировку.
  final int sortOrder;

  const ShoppingItem._({
    required this.id,
    required this.knownProductId,
    required this.nameSnapshot,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.sortOrder,
    this.quantity,
    this.purchasedAt,
    this.deletedAt,
  });

  /// Фабричный конструктор для создания нового товара в списке.
  ///
  /// Новая запись всегда создаётся активной.
  factory ShoppingItem.create({
    required String id,
    required String knownProductId,
    required String nameSnapshot,
    required int sortOrder,
    String? quantity,
    DateTime? now,
  }) {
    final dateTime = now ?? DateTime.now();

    return ShoppingItem._(
      id: id,
      knownProductId: knownProductId,
      nameSnapshot: nameSnapshot.trim(),
      quantity: _prepareQuantity(quantity),
      status: ShoppingItemStatus.active,
      createdAt: dateTime,
      updatedAt: dateTime,
      sortOrder: sortOrder,
    );
  }

  /// Восстанавливает ShoppingItem из хранилища.
  ///
  /// Этот конструктор нужен для слоя data.
  factory ShoppingItem.fromStorage({
    required String id,
    required String knownProductId,
    required String nameSnapshot,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int sortOrder,
    required ShoppingItemStatus status,
    String? quantity,
    DateTime? purchasedAt,
    DateTime? deletedAt,
  }) {
    return ShoppingItem._(
      id: id,
      knownProductId: knownProductId,
      nameSnapshot: nameSnapshot.trim(),
      quantity: _prepareQuantity(quantity),
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      purchasedAt: purchasedAt,
      deletedAt: deletedAt,
      sortOrder: sortOrder,
    );
  }

  /// Нужно ли показывать количество на экране.
  bool get hasQuantity => quantity != null && quantity!.isNotEmpty;

  bool get isActive => status == ShoppingItemStatus.active;

  bool get isPurchased => status == ShoppingItemStatus.purchased;

  bool get isDeleted => status == ShoppingItemStatus.deleted;

  /// Возвращает товар в активный список.
  ///
  /// Используем, когда пользователь:
  /// - добавил новый товар;
  /// - повторно добавил товар из последних покупок;
  /// - добавил товар, который раньше был удалён.
  ///
  /// purchasedAt специально не очищаем.
  /// Почему:
  /// если товар сейчас снова активен, purchasedAt всё ещё может означать
  /// "когда его покупали в прошлый раз".
  ShoppingItem activate({
    required String nameSnapshot,
    required int sortOrder,
    String? quantity,
    DateTime? now,
  }) {
    final dateTime = now ?? DateTime.now();

    return copyWith(
      nameSnapshot: nameSnapshot,
      quantity: quantity,
      status: ShoppingItemStatus.active,
      updatedAt: dateTime,
      deletedAt: null,
      sortOrder: sortOrder,
    );
  }

  /// Отмечает товар как купленный.
  ///
  /// Это не удаляет запись из БД.
  /// Товар просто пропадает из активного списка,
  /// потому что активный список фильтруется по status == active.
  ShoppingItem markPurchased({DateTime? purchasedAt}) {
    final dateTime = purchasedAt ?? DateTime.now();

    return copyWith(
      status: ShoppingItemStatus.purchased,
      updatedAt: dateTime,
      purchasedAt: dateTime,
      deletedAt: null,
    );
  }

  /// Помечает товар как удалённый.
  ///
  /// Это отличается от покупки:
  /// пользователь мог добавить товар случайно и удалить его,
  /// но это не значит, что товар был куплен.
  ShoppingItem markDeleted({DateTime? deletedAt}) {
    final dateTime = deletedAt ?? DateTime.now();

    return copyWith(
      status: ShoppingItemStatus.deleted,
      updatedAt: dateTime,
      deletedAt: dateTime,
    );
  }

  /// Создаёт копию записи с изменёнными полями.
  ///
  /// Здесь используется _unset, чтобы можно было отличить два случая:
  /// - поле вообще не передали, значит оставляем старое значение;
  /// - поле передали как null, значит действительно очищаем значение.
  ShoppingItem copyWith({
    String? id,
    String? knownProductId,
    String? nameSnapshot,
    Object? quantity = _unset,
    ShoppingItemStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? purchasedAt = _unset,
    Object? deletedAt = _unset,
    int? sortOrder,
  }) {
    return ShoppingItem._(
      id: id ?? this.id,
      knownProductId: knownProductId ?? this.knownProductId,
      nameSnapshot: nameSnapshot?.trim() ?? this.nameSnapshot,
      quantity: identical(quantity, _unset)
          ? this.quantity
          : _prepareQuantity(quantity as String?),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      purchasedAt: identical(purchasedAt, _unset)
          ? this.purchasedAt
          : purchasedAt as DateTime?,
      deletedAt: identical(deletedAt, _unset)
          ? this.deletedAt
          : deletedAt as DateTime?,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  String toString() {
    return 'ShoppingItem('
        'id: $id, '
        'knownProductId: $knownProductId, '
        'nameSnapshot: $nameSnapshot, '
        'quantity: $quantity, '
        'status: $status, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'purchasedAt: $purchasedAt, '
        'deletedAt: $deletedAt, '
        'sortOrder: $sortOrder'
        ')';
  }
}

/// Подготавливает количество перед сохранением.
///
/// Если пользователь ничего не ввёл, нам не нужно хранить пустую строку.
/// Лучше хранить null.
String? _prepareQuantity(String? value) {
  final trimmed = value?.trim();

  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  return trimmed;
}
