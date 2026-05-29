import '../utils/product_name_normalizer.dart';

/// Известный товар.
///
/// Это товар, который приложение запомнило для:
/// - автоподсказок;
/// - контроля уникальности;
/// - просмотра товаров в БД;
/// - будущей истории последних покупок.
///
/// Важно:
/// KnownProduct — это не активная покупка на экране.
/// Это запись в базе известных товаров.
class KnownProduct {
  /// Уникальный идентификатор товара.
  final String id;

  /// Имя товара для отображения пользователю.
  ///
  /// Мы сохраняем пользовательский регистр букв,
  /// но убираем лишние пробелы.
  ///
  /// Пример:
  /// ввод: "  Молоко     2%  "
  /// name: "Молоко 2%"
  final String name;

  /// Нормализованное имя товара.
  ///
  /// Это техническое поле.
  /// Оно нужно для поиска и контроля уникальности.
  ///
  /// Пример:
  /// name: "Молоко 2%"
  /// normalizedName: "молоко 2%"
  final String normalizedName;

  /// Дата создания товара.
  final DateTime createdAt;

  /// Дата последнего изменения товара.
  final DateTime updatedAt;

  /// Дата последней покупки товара.
  ///
  /// Если null — этот товар ещё не покупали через приложение.
  final DateTime? lastPurchasedAt;

  /// Приватный конструктор.
  ///
  /// Почему приватный:
  /// мы не хотим, чтобы объект создавали напрямую и случайно передавали
  /// неправильную пару name / normalizedName.
  ///
  /// Создавать KnownProduct нужно через factory KnownProduct.create.
  const KnownProduct._({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.createdAt,
    required this.updatedAt,
    this.lastPurchasedAt,
  });

  /// Создаёт новый известный товар из пользовательского ввода.
  ///
  /// Здесь мы сразу приводим данные к правильному виду:
  /// - name очищаем, но сохраняем регистр;
  /// - normalizedName очищаем и приводим к нижнему регистру.
  factory KnownProduct.create({
    required String id,
    required String name,
    DateTime? now,
  }) {
    final dateTime = now ?? DateTime.now();
    final formattedName = formatProductName(name);

    return KnownProduct._(
      id: id,
      name: formattedName,
      normalizedName: normalizeProductName(formattedName),
      createdAt: dateTime,
      updatedAt: dateTime,
    );
  }

  /// Восстанавливает известный товар из хранилища.
  ///
  /// Этот конструктор нужен для слоя data.
  ///
  /// Почему не используем create:
  /// create создаёт новый товар и сам выставляет createdAt / updatedAt.
  ///
  /// А при чтении из БД товар уже существует,
  /// поэтому мы должны восстановить его настоящие даты.
  factory KnownProduct.fromStorage({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastPurchasedAt,
  }) {
    final formattedName = formatProductName(name);

    return KnownProduct._(
      id: id,
      name: formattedName,
      normalizedName: normalizeProductName(formattedName),
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastPurchasedAt: lastPurchasedAt,
    );
  }

  /// Был ли товар когда-либо куплен.
  bool get wasPurchased => lastPurchasedAt != null;

  /// Отмечает товар как купленный.
  ///
  /// Это не удаляет товар из базы известных товаров.
  /// Мы просто запоминаем дату последней покупки.
  KnownProduct markPurchased({DateTime? purchasedAt}) {
    final dateTime = purchasedAt ?? DateTime.now();

    return copyWith(lastPurchasedAt: dateTime, updatedAt: dateTime);
  }

  /// Возвращает копию товара с изменёнными полями.
  ///
  /// Если меняется name, мы обязательно пересчитываем normalizedName.
  /// Это важно, чтобы данные не разъехались.
  KnownProduct copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastPurchasedAt,
  }) {
    final formattedName = name == null ? this.name : formatProductName(name);

    return KnownProduct._(
      id: id ?? this.id,
      name: formattedName,
      normalizedName: normalizeProductName(formattedName),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastPurchasedAt: lastPurchasedAt ?? this.lastPurchasedAt,
    );
  }

  @override
  String toString() {
    return 'KnownProduct('
        'id: $id, '
        'name: $name, '
        'normalizedName: $normalizedName, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'lastPurchasedAt: $lastPurchasedAt'
        ')';
  }
}
