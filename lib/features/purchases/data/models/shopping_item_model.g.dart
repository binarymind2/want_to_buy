// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_item_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetShoppingItemModelCollection on Isar {
  IsarCollection<ShoppingItemModel> get shoppingItemModels => this.collection();
}

const ShoppingItemModelSchema = CollectionSchema(
  name: r'ShoppingItemModel',
  id: -3518571481410747794,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deletedAt': PropertySchema(
      id: 1,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'domainId': PropertySchema(
      id: 2,
      name: r'domainId',
      type: IsarType.string,
    ),
    r'knownProductId': PropertySchema(
      id: 3,
      name: r'knownProductId',
      type: IsarType.string,
    ),
    r'nameSnapshot': PropertySchema(
      id: 4,
      name: r'nameSnapshot',
      type: IsarType.string,
    ),
    r'purchasedAt': PropertySchema(
      id: 5,
      name: r'purchasedAt',
      type: IsarType.dateTime,
    ),
    r'quantity': PropertySchema(
      id: 6,
      name: r'quantity',
      type: IsarType.string,
    ),
    r'sortOrder': PropertySchema(
      id: 7,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'status': PropertySchema(id: 8, name: r'status', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _shoppingItemModelEstimateSize,
  serialize: _shoppingItemModelSerialize,
  deserialize: _shoppingItemModelDeserialize,
  deserializeProp: _shoppingItemModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'domainId': IndexSchema(
      id: -9138809277110658179,
      name: r'domainId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'domainId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'knownProductId': IndexSchema(
      id: 5070535022365461048,
      name: r'knownProductId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'knownProductId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'purchasedAt': IndexSchema(
      id: -5555655174384307330,
      name: r'purchasedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'purchasedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _shoppingItemModelGetId,
  getLinks: _shoppingItemModelGetLinks,
  attach: _shoppingItemModelAttach,
  version: '3.1.0+1',
);

int _shoppingItemModelEstimateSize(
  ShoppingItemModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.domainId.length * 3;
  bytesCount += 3 + object.knownProductId.length * 3;
  bytesCount += 3 + object.nameSnapshot.length * 3;
  {
    final value = object.quantity;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _shoppingItemModelSerialize(
  ShoppingItemModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.deletedAt);
  writer.writeString(offsets[2], object.domainId);
  writer.writeString(offsets[3], object.knownProductId);
  writer.writeString(offsets[4], object.nameSnapshot);
  writer.writeDateTime(offsets[5], object.purchasedAt);
  writer.writeString(offsets[6], object.quantity);
  writer.writeLong(offsets[7], object.sortOrder);
  writer.writeString(offsets[8], object.status);
  writer.writeDateTime(offsets[9], object.updatedAt);
}

ShoppingItemModel _shoppingItemModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ShoppingItemModel();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[1]);
  object.domainId = reader.readString(offsets[2]);
  object.id = id;
  object.knownProductId = reader.readString(offsets[3]);
  object.nameSnapshot = reader.readString(offsets[4]);
  object.purchasedAt = reader.readDateTimeOrNull(offsets[5]);
  object.quantity = reader.readStringOrNull(offsets[6]);
  object.sortOrder = reader.readLong(offsets[7]);
  object.status = reader.readString(offsets[8]);
  object.updatedAt = reader.readDateTime(offsets[9]);
  return object;
}

P _shoppingItemModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _shoppingItemModelGetId(ShoppingItemModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _shoppingItemModelGetLinks(
  ShoppingItemModel object,
) {
  return [];
}

void _shoppingItemModelAttach(
  IsarCollection<dynamic> col,
  Id id,
  ShoppingItemModel object,
) {
  object.id = id;
}

extension ShoppingItemModelByIndex on IsarCollection<ShoppingItemModel> {
  Future<ShoppingItemModel?> getByDomainId(String domainId) {
    return getByIndex(r'domainId', [domainId]);
  }

  ShoppingItemModel? getByDomainIdSync(String domainId) {
    return getByIndexSync(r'domainId', [domainId]);
  }

  Future<bool> deleteByDomainId(String domainId) {
    return deleteByIndex(r'domainId', [domainId]);
  }

  bool deleteByDomainIdSync(String domainId) {
    return deleteByIndexSync(r'domainId', [domainId]);
  }

  Future<List<ShoppingItemModel?>> getAllByDomainId(
    List<String> domainIdValues,
  ) {
    final values = domainIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'domainId', values);
  }

  List<ShoppingItemModel?> getAllByDomainIdSync(List<String> domainIdValues) {
    final values = domainIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'domainId', values);
  }

  Future<int> deleteAllByDomainId(List<String> domainIdValues) {
    final values = domainIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'domainId', values);
  }

  int deleteAllByDomainIdSync(List<String> domainIdValues) {
    final values = domainIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'domainId', values);
  }

  Future<Id> putByDomainId(ShoppingItemModel object) {
    return putByIndex(r'domainId', object);
  }

  Id putByDomainIdSync(ShoppingItemModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'domainId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDomainId(List<ShoppingItemModel> objects) {
    return putAllByIndex(r'domainId', objects);
  }

  List<Id> putAllByDomainIdSync(
    List<ShoppingItemModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'domainId', objects, saveLinks: saveLinks);
  }

  Future<ShoppingItemModel?> getByKnownProductId(String knownProductId) {
    return getByIndex(r'knownProductId', [knownProductId]);
  }

  ShoppingItemModel? getByKnownProductIdSync(String knownProductId) {
    return getByIndexSync(r'knownProductId', [knownProductId]);
  }

  Future<bool> deleteByKnownProductId(String knownProductId) {
    return deleteByIndex(r'knownProductId', [knownProductId]);
  }

  bool deleteByKnownProductIdSync(String knownProductId) {
    return deleteByIndexSync(r'knownProductId', [knownProductId]);
  }

  Future<List<ShoppingItemModel?>> getAllByKnownProductId(
    List<String> knownProductIdValues,
  ) {
    final values = knownProductIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'knownProductId', values);
  }

  List<ShoppingItemModel?> getAllByKnownProductIdSync(
    List<String> knownProductIdValues,
  ) {
    final values = knownProductIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'knownProductId', values);
  }

  Future<int> deleteAllByKnownProductId(List<String> knownProductIdValues) {
    final values = knownProductIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'knownProductId', values);
  }

  int deleteAllByKnownProductIdSync(List<String> knownProductIdValues) {
    final values = knownProductIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'knownProductId', values);
  }

  Future<Id> putByKnownProductId(ShoppingItemModel object) {
    return putByIndex(r'knownProductId', object);
  }

  Id putByKnownProductIdSync(
    ShoppingItemModel object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'knownProductId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKnownProductId(List<ShoppingItemModel> objects) {
    return putAllByIndex(r'knownProductId', objects);
  }

  List<Id> putAllByKnownProductIdSync(
    List<ShoppingItemModel> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'knownProductId', objects, saveLinks: saveLinks);
  }
}

extension ShoppingItemModelQueryWhereSort
    on QueryBuilder<ShoppingItemModel, ShoppingItemModel, QWhere> {
  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhere>
  anyPurchasedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'purchasedAt'),
      );
    });
  }
}

extension ShoppingItemModelQueryWhere
    on QueryBuilder<ShoppingItemModel, ShoppingItemModel, QWhereClause> {
  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  domainIdEqualTo(String domainId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'domainId', value: [domainId]),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  domainIdNotEqualTo(String domainId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'domainId',
                lower: [],
                upper: [domainId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'domainId',
                lower: [domainId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'domainId',
                lower: [domainId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'domainId',
                lower: [],
                upper: [domainId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  knownProductIdEqualTo(String knownProductId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'knownProductId',
          value: [knownProductId],
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  knownProductIdNotEqualTo(String knownProductId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'knownProductId',
                lower: [],
                upper: [knownProductId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'knownProductId',
                lower: [knownProductId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'knownProductId',
                lower: [knownProductId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'knownProductId',
                lower: [],
                upper: [knownProductId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'status', value: [status]),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  statusNotEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [],
                upper: [status],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [status],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [status],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'status',
                lower: [],
                upper: [status],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  purchasedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'purchasedAt', value: [null]),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  purchasedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'purchasedAt',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  purchasedAtEqualTo(DateTime? purchasedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'purchasedAt',
          value: [purchasedAt],
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  purchasedAtNotEqualTo(DateTime? purchasedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'purchasedAt',
                lower: [],
                upper: [purchasedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'purchasedAt',
                lower: [purchasedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'purchasedAt',
                lower: [purchasedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'purchasedAt',
                lower: [],
                upper: [purchasedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  purchasedAtGreaterThan(DateTime? purchasedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'purchasedAt',
          lower: [purchasedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  purchasedAtLessThan(DateTime? purchasedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'purchasedAt',
          lower: [],
          upper: [purchasedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterWhereClause>
  purchasedAtBetween(
    DateTime? lowerPurchasedAt,
    DateTime? upperPurchasedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'purchasedAt',
          lower: [lowerPurchasedAt],
          includeLower: includeLower,
          upper: [upperPurchasedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ShoppingItemModelQueryFilter
    on QueryBuilder<ShoppingItemModel, ShoppingItemModel, QFilterCondition> {
  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  deletedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deletedAt', value: value),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  deletedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  deletedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  deletedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deletedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  domainIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  domainIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  domainIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  domainIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'domainId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  domainIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  domainIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  domainIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'domainId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  domainIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'domainId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  domainIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'domainId', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  domainIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'domainId', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  knownProductIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'knownProductId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  knownProductIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'knownProductId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  knownProductIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'knownProductId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  knownProductIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'knownProductId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  knownProductIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'knownProductId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  knownProductIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'knownProductId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  knownProductIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'knownProductId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  knownProductIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'knownProductId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  knownProductIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'knownProductId', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  knownProductIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'knownProductId', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  nameSnapshotEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nameSnapshot',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  nameSnapshotGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nameSnapshot',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  nameSnapshotLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nameSnapshot',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  nameSnapshotBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nameSnapshot',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  nameSnapshotStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nameSnapshot',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  nameSnapshotEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nameSnapshot',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  nameSnapshotContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nameSnapshot',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  nameSnapshotMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nameSnapshot',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  nameSnapshotIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nameSnapshot', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  nameSnapshotIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nameSnapshot', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  purchasedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'purchasedAt'),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  purchasedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'purchasedAt'),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  purchasedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'purchasedAt', value: value),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  purchasedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'purchasedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  purchasedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'purchasedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  purchasedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'purchasedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  quantityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'quantity'),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  quantityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'quantity'),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  quantityEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'quantity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  quantityGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'quantity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  quantityLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'quantity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  quantityBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'quantity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  quantityStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'quantity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  quantityEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'quantity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  quantityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'quantity',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  quantityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'quantity',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  quantityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quantity', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  quantityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'quantity', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  sortOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortOrder', value: value),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  sortOrderGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortOrder',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  sortOrderLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortOrder',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortOrder',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  statusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ShoppingItemModelQueryObject
    on QueryBuilder<ShoppingItemModel, ShoppingItemModel, QFilterCondition> {}

extension ShoppingItemModelQueryLinks
    on QueryBuilder<ShoppingItemModel, ShoppingItemModel, QFilterCondition> {}

extension ShoppingItemModelQuerySortBy
    on QueryBuilder<ShoppingItemModel, ShoppingItemModel, QSortBy> {
  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByKnownProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knownProductId', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByKnownProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knownProductId', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByNameSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameSnapshot', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByNameSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameSnapshot', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByPurchasedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasedAt', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByPurchasedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasedAt', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ShoppingItemModelQuerySortThenBy
    on QueryBuilder<ShoppingItemModel, ShoppingItemModel, QSortThenBy> {
  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByDomainId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByDomainIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'domainId', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByKnownProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knownProductId', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByKnownProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knownProductId', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByNameSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameSnapshot', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByNameSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nameSnapshot', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByPurchasedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasedAt', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByPurchasedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasedAt', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ShoppingItemModelQueryWhereDistinct
    on QueryBuilder<ShoppingItemModel, ShoppingItemModel, QDistinct> {
  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QDistinct>
  distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QDistinct>
  distinctByDomainId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'domainId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QDistinct>
  distinctByKnownProductId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'knownProductId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QDistinct>
  distinctByNameSnapshot({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nameSnapshot', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QDistinct>
  distinctByPurchasedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchasedAt');
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QDistinct>
  distinctByQuantity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QDistinct>
  distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QDistinct>
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ShoppingItemModel, ShoppingItemModel, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ShoppingItemModelQueryProperty
    on QueryBuilder<ShoppingItemModel, ShoppingItemModel, QQueryProperty> {
  QueryBuilder<ShoppingItemModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ShoppingItemModel, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ShoppingItemModel, DateTime?, QQueryOperations>
  deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<ShoppingItemModel, String, QQueryOperations> domainIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'domainId');
    });
  }

  QueryBuilder<ShoppingItemModel, String, QQueryOperations>
  knownProductIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'knownProductId');
    });
  }

  QueryBuilder<ShoppingItemModel, String, QQueryOperations>
  nameSnapshotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nameSnapshot');
    });
  }

  QueryBuilder<ShoppingItemModel, DateTime?, QQueryOperations>
  purchasedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchasedAt');
    });
  }

  QueryBuilder<ShoppingItemModel, String?, QQueryOperations>
  quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<ShoppingItemModel, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<ShoppingItemModel, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<ShoppingItemModel, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
