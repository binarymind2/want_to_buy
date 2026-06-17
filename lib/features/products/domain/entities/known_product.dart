import '../utils/product_name_normalizer.dart';

/// Известный товар.
///
/// Это справочник товаров, которые приложение уже встречало.
///
/// Важно:
/// KnownProduct больше не хранит факт покупки.
/// Он отвечает только за то, что товар существует как справочная запись:
/// - название;
/// - нормализованное название;
/// - даты создания и изменения.
///
/// Состояние товара в списке покупок хранится в ShoppingItem.
class KnownProduct {
  /// Уникальный доменный идентификатор товара.
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

  /// Дата создания товара в справочнике.
  final DateTime createdAt;

  /// Дата последнего изменения справочной записи.
  final DateTime updatedAt;

  /// Приватный конструктор.
  ///
  /// Почему приватный:
  /// мы не хотим, чтобы объект создавали напрямую и случайно передавали
  /// неправильную пару name / normalizedName.
  ///
  /// Создавать KnownProduct нужно через factory KnownProduct.create
  /// или восстанавливать через KnownProduct.fromStorage.
  const KnownProduct._({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.createdAt,
    required this.updatedAt,
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
  }) {
    final formattedName = formatProductName(name);

    return KnownProduct._(
      id: id,
      name: formattedName,
      normalizedName: normalizeProductName(formattedName),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
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
  }) {
    final formattedName = name == null ? this.name : formatProductName(name);

    return KnownProduct._(
      id: id ?? this.id,
      name: formattedName,
      normalizedName: normalizeProductName(formattedName),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'KnownProduct('
        'id: $id, '
        'name: $name, '
        'normalizedName: $normalizedName, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}
