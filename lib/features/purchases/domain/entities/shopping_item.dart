/// Активная покупка.
///
/// Это строка, которую пользователь видит на экране "Покупки".
///
/// Например:
/// - Молоко    2
/// - Хлеб
/// - Яйца      10
///
/// Важно:
/// ShoppingItem — это НЕ товар в базе известных товаров.
/// Это конкретная позиция в текущем списке покупок.
class ShoppingItem {
  /// Уникальный идентификатор активной покупки.
  final String id;

  /// id известного товара, с которым связана эта покупка.
  ///
  /// Например:
  /// KnownProduct: Молоко
  /// ShoppingItem: Молоко 2
  ///
  /// ShoppingItem хранит ссылку на KnownProduct через knownProductId.
  final String knownProductId;

  /// Название товара на момент добавления в список.
  ///
  /// Почему не брать название только из KnownProduct?
  ///
  /// Сейчас можно было бы брать напрямую.
  /// Но nameSnapshot делает модель надёжнее:
  /// активная покупка знает, какое название показывать на экране.
  final String nameSnapshot;

  /// Количество товара.
  ///
  /// Может быть null.
  ///
  /// Если null или пустое значение — на экране количество не показываем.
  ///
  /// Примеры:
  /// Молоко    2
  /// Хлеб
  /// Яйца      10
  final String? quantity;

  /// Дата добавления товара в активный список.
  final DateTime createdAt;

  /// Порядок сортировки в списке.
  ///
  /// Сейчас можно использовать дату создания.
  /// Но sortOrder пригодится позже, если захочешь ручную сортировку.
  final int sortOrder;

  const ShoppingItem({
    required this.id,
    required this.knownProductId,
    required this.nameSnapshot,
    required this.createdAt,
    required this.sortOrder,
    this.quantity,
  });

  /// Фабричный конструктор для создания активной покупки.
  ///
  /// Здесь мы централизованно обрабатываем quantity:
  /// - если quantity пустое — сохраняем null;
  /// - если не пустое — сохраняем trimmed значение.
  factory ShoppingItem.create({
    required String id,
    required String knownProductId,
    required String nameSnapshot,
    required int sortOrder,
    String? quantity,
    DateTime? now,
  }) {
    return ShoppingItem(
      id: id,
      knownProductId: knownProductId,
      nameSnapshot: nameSnapshot.trim(),
      quantity: _prepareQuantity(quantity),
      createdAt: now ?? DateTime.now(),
      sortOrder: sortOrder,
    );
  }

  /// Восстанавливает активную покупку из хранилища.
  ///
  /// Этот конструктор нужен для слоя data.
  ///
  /// Почему не используем create:
  /// create создаёт новую активную покупку.
  /// А из БД мы читаем уже существующую запись с готовым createdAt.
  factory ShoppingItem.fromStorage({
    required String id,
    required String knownProductId,
    required String nameSnapshot,
    required DateTime createdAt,
    required int sortOrder,
    String? quantity,
  }) {
    return ShoppingItem(
      id: id,
      knownProductId: knownProductId,
      nameSnapshot: nameSnapshot.trim(),
      quantity: _prepareQuantity(quantity),
      createdAt: createdAt,
      sortOrder: sortOrder,
    );
  }

  /// Нужно ли показывать количество на экране.
  bool get hasQuantity => quantity != null && quantity!.isNotEmpty;

  /// Создаёт копию активной покупки с изменёнными полями.
  ShoppingItem copyWith({
    String? id,
    String? knownProductId,
    String? nameSnapshot,
    String? quantity,
    DateTime? createdAt,
    int? sortOrder,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      knownProductId: knownProductId ?? this.knownProductId,
      nameSnapshot: nameSnapshot ?? this.nameSnapshot,
      quantity: quantity == null ? this.quantity : _prepareQuantity(quantity),
      createdAt: createdAt ?? this.createdAt,
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
        'createdAt: $createdAt, '
        'sortOrder: $sortOrder'
        ')';
  }
}

/// Подготавливает количество перед сохранением.
///
/// Если пользователь ничего не ввёл, нам не нужно хранить пустую строку.
/// Лучше хранить null.
///
/// Почему:
/// null явно означает "количества нет".
String? _prepareQuantity(String? value) {
  final trimmed = value?.trim();

  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  return trimmed;
}
