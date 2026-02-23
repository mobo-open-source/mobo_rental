// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAccountEntityCollection on Isar {
  IsarCollection<AccountEntity> get accountEntitys => this.collection();
}

const AccountEntitySchema = CollectionSchema(
  name: r'AccountEntity',
  id: -996322080142432925,
  properties: {
    r'companyId': PropertySchema(
      id: 0,
      name: r'companyId',
      type: IsarType.string,
    ),
    r'dbName': PropertySchema(id: 1, name: r'dbName', type: IsarType.string),
    r'image': PropertySchema(id: 2, name: r'image', type: IsarType.string),
    r'isSystem': PropertySchema(id: 3, name: r'isSystem', type: IsarType.bool),
    r'lastLogin': PropertySchema(
      id: 4,
      name: r'lastLogin',
      type: IsarType.dateTime,
    ),
    r'partnerId': PropertySchema(
      id: 5,
      name: r'partnerId',
      type: IsarType.string,
    ),
    r'password': PropertySchema(
      id: 6,
      name: r'password',
      type: IsarType.string,
    ),
    r'serverVersion': PropertySchema(
      id: 7,
      name: r'serverVersion',
      type: IsarType.string,
    ),
    r'sessionId': PropertySchema(
      id: 8,
      name: r'sessionId',
      type: IsarType.string,
    ),
    r'url': PropertySchema(id: 9, name: r'url', type: IsarType.string),
    r'userId': PropertySchema(id: 10, name: r'userId', type: IsarType.string),
    r'userLang': PropertySchema(
      id: 11,
      name: r'userLang',
      type: IsarType.string,
    ),
    r'userLogin': PropertySchema(
      id: 12,
      name: r'userLogin',
      type: IsarType.string,
    ),
    r'userName': PropertySchema(
      id: 13,
      name: r'userName',
      type: IsarType.string,
    ),
    r'userTimezone': PropertySchema(
      id: 14,
      name: r'userTimezone',
      type: IsarType.string,
    ),
  },

  estimateSize: _accountEntityEstimateSize,
  serialize: _accountEntitySerialize,
  deserialize: _accountEntityDeserialize,
  deserializeProp: _accountEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId_dbName_url': IndexSchema(
      id: -4044975007751933095,
      name: r'userId_dbName_url',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'dbName',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'url',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'url': IndexSchema(
      id: -5756857009679432345,
      name: r'url',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'url',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'dbName': IndexSchema(
      id: 5598209709233656108,
      name: r'dbName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dbName',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _accountEntityGetId,
  getLinks: _accountEntityGetLinks,
  attach: _accountEntityAttach,
  version: '3.3.0',
);

int _accountEntityEstimateSize(
  AccountEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.companyId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dbName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.image;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.partnerId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.password;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.serverVersion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sessionId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.url;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.userId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.userLang;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.userLogin;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.userName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.userTimezone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _accountEntitySerialize(
  AccountEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.companyId);
  writer.writeString(offsets[1], object.dbName);
  writer.writeString(offsets[2], object.image);
  writer.writeBool(offsets[3], object.isSystem);
  writer.writeDateTime(offsets[4], object.lastLogin);
  writer.writeString(offsets[5], object.partnerId);
  writer.writeString(offsets[6], object.password);
  writer.writeString(offsets[7], object.serverVersion);
  writer.writeString(offsets[8], object.sessionId);
  writer.writeString(offsets[9], object.url);
  writer.writeString(offsets[10], object.userId);
  writer.writeString(offsets[11], object.userLang);
  writer.writeString(offsets[12], object.userLogin);
  writer.writeString(offsets[13], object.userName);
  writer.writeString(offsets[14], object.userTimezone);
}

AccountEntity _accountEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AccountEntity();
  object.companyId = reader.readStringOrNull(offsets[0]);
  object.dbName = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.image = reader.readStringOrNull(offsets[2]);
  object.isSystem = reader.readBoolOrNull(offsets[3]);
  object.lastLogin = reader.readDateTimeOrNull(offsets[4]);
  object.partnerId = reader.readStringOrNull(offsets[5]);
  object.password = reader.readStringOrNull(offsets[6]);
  object.serverVersion = reader.readStringOrNull(offsets[7]);
  object.sessionId = reader.readStringOrNull(offsets[8]);
  object.url = reader.readStringOrNull(offsets[9]);
  object.userId = reader.readStringOrNull(offsets[10]);
  object.userLang = reader.readStringOrNull(offsets[11]);
  object.userLogin = reader.readStringOrNull(offsets[12]);
  object.userName = reader.readStringOrNull(offsets[13]);
  object.userTimezone = reader.readStringOrNull(offsets[14]);
  return object;
}

P _accountEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _accountEntityGetId(AccountEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _accountEntityGetLinks(AccountEntity object) {
  return [];
}

void _accountEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  AccountEntity object,
) {
  object.id = id;
}

extension AccountEntityByIndex on IsarCollection<AccountEntity> {
  Future<AccountEntity?> getByUserIdDbNameUrl(
    String? userId,
    String? dbName,
    String? url,
  ) {
    return getByIndex(r'userId_dbName_url', [userId, dbName, url]);
  }

  AccountEntity? getByUserIdDbNameUrlSync(
    String? userId,
    String? dbName,
    String? url,
  ) {
    return getByIndexSync(r'userId_dbName_url', [userId, dbName, url]);
  }

  Future<bool> deleteByUserIdDbNameUrl(
    String? userId,
    String? dbName,
    String? url,
  ) {
    return deleteByIndex(r'userId_dbName_url', [userId, dbName, url]);
  }

  bool deleteByUserIdDbNameUrlSync(
    String? userId,
    String? dbName,
    String? url,
  ) {
    return deleteByIndexSync(r'userId_dbName_url', [userId, dbName, url]);
  }

  Future<List<AccountEntity?>> getAllByUserIdDbNameUrl(
    List<String?> userIdValues,
    List<String?> dbNameValues,
    List<String?> urlValues,
  ) {
    final len = userIdValues.length;
    assert(
      dbNameValues.length == len && urlValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([userIdValues[i], dbNameValues[i], urlValues[i]]);
    }

    return getAllByIndex(r'userId_dbName_url', values);
  }

  List<AccountEntity?> getAllByUserIdDbNameUrlSync(
    List<String?> userIdValues,
    List<String?> dbNameValues,
    List<String?> urlValues,
  ) {
    final len = userIdValues.length;
    assert(
      dbNameValues.length == len && urlValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([userIdValues[i], dbNameValues[i], urlValues[i]]);
    }

    return getAllByIndexSync(r'userId_dbName_url', values);
  }

  Future<int> deleteAllByUserIdDbNameUrl(
    List<String?> userIdValues,
    List<String?> dbNameValues,
    List<String?> urlValues,
  ) {
    final len = userIdValues.length;
    assert(
      dbNameValues.length == len && urlValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([userIdValues[i], dbNameValues[i], urlValues[i]]);
    }

    return deleteAllByIndex(r'userId_dbName_url', values);
  }

  int deleteAllByUserIdDbNameUrlSync(
    List<String?> userIdValues,
    List<String?> dbNameValues,
    List<String?> urlValues,
  ) {
    final len = userIdValues.length;
    assert(
      dbNameValues.length == len && urlValues.length == len,
      'All index values must have the same length',
    );
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([userIdValues[i], dbNameValues[i], urlValues[i]]);
    }

    return deleteAllByIndexSync(r'userId_dbName_url', values);
  }

  Future<Id> putByUserIdDbNameUrl(AccountEntity object) {
    return putByIndex(r'userId_dbName_url', object);
  }

  Id putByUserIdDbNameUrlSync(AccountEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'userId_dbName_url', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUserIdDbNameUrl(List<AccountEntity> objects) {
    return putAllByIndex(r'userId_dbName_url', objects);
  }

  List<Id> putAllByUserIdDbNameUrlSync(
    List<AccountEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(
      r'userId_dbName_url',
      objects,
      saveLinks: saveLinks,
    );
  }
}

extension AccountEntityQueryWhereSort
    on QueryBuilder<AccountEntity, AccountEntity, QWhere> {
  QueryBuilder<AccountEntity, AccountEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AccountEntityQueryWhere
    on QueryBuilder<AccountEntity, AccountEntity, QWhereClause> {
  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause>
  userIdIsNullAnyDbNameUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'userId_dbName_url',
          value: [null],
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause>
  userIdIsNotNullAnyDbNameUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'userId_dbName_url',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause>
  userIdEqualToAnyDbNameUrl(String? userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'userId_dbName_url',
          value: [userId],
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause>
  userIdNotEqualToAnyDbNameUrl(String? userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId_dbName_url',
                lower: [],
                upper: [userId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId_dbName_url',
                lower: [userId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId_dbName_url',
                lower: [userId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId_dbName_url',
                lower: [],
                upper: [userId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause>
  userIdEqualToDbNameIsNullAnyUrl(String? userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'userId_dbName_url',
          value: [userId, null],
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause>
  userIdEqualToDbNameIsNotNullAnyUrl(String? userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'userId_dbName_url',
          lower: [userId, null],
          includeLower: false,
          upper: [userId],
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause>
  userIdDbNameEqualToAnyUrl(String? userId, String? dbName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'userId_dbName_url',
          value: [userId, dbName],
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause>
  userIdEqualToDbNameNotEqualToAnyUrl(String? userId, String? dbName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId_dbName_url',
                lower: [userId],
                upper: [userId, dbName],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId_dbName_url',
                lower: [userId, dbName],
                includeLower: false,
                upper: [userId],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId_dbName_url',
                lower: [userId, dbName],
                includeLower: false,
                upper: [userId],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId_dbName_url',
                lower: [userId],
                upper: [userId, dbName],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause>
  userIdDbNameEqualToUrlIsNull(String? userId, String? dbName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'userId_dbName_url',
          value: [userId, dbName, null],
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause>
  userIdDbNameEqualToUrlIsNotNull(String? userId, String? dbName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'userId_dbName_url',
          lower: [userId, dbName, null],
          includeLower: false,
          upper: [userId, dbName],
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause>
  userIdDbNameUrlEqualTo(String? userId, String? dbName, String? url) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'userId_dbName_url',
          value: [userId, dbName, url],
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause>
  userIdDbNameEqualToUrlNotEqualTo(
    String? userId,
    String? dbName,
    String? url,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId_dbName_url',
                lower: [userId, dbName],
                upper: [userId, dbName, url],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId_dbName_url',
                lower: [userId, dbName, url],
                includeLower: false,
                upper: [userId, dbName],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId_dbName_url',
                lower: [userId, dbName, url],
                includeLower: false,
                upper: [userId, dbName],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'userId_dbName_url',
                lower: [userId, dbName],
                upper: [userId, dbName, url],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause> urlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'url', value: [null]),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause> urlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'url',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause> urlEqualTo(
    String? url,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'url', value: [url]),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause> urlNotEqualTo(
    String? url,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'url',
                lower: [],
                upper: [url],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'url',
                lower: [url],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'url',
                lower: [url],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'url',
                lower: [],
                upper: [url],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause> dbNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'dbName', value: [null]),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause>
  dbNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dbName',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause> dbNameEqualTo(
    String? dbName,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'dbName', value: [dbName]),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterWhereClause>
  dbNameNotEqualTo(String? dbName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dbName',
                lower: [],
                upper: [dbName],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dbName',
                lower: [dbName],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dbName',
                lower: [dbName],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dbName',
                lower: [],
                upper: [dbName],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension AccountEntityQueryFilter
    on QueryBuilder<AccountEntity, AccountEntity, QFilterCondition> {
  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  companyIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'companyId'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  companyIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'companyId'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  companyIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'companyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  companyIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'companyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  companyIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'companyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  companyIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'companyId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  companyIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'companyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  companyIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'companyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  companyIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'companyId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  companyIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'companyId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  companyIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'companyId', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  companyIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'companyId', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  dbNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'dbName'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  dbNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'dbName'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  dbNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dbName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  dbNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dbName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  dbNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dbName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  dbNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dbName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  dbNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'dbName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  dbNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'dbName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  dbNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'dbName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  dbNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'dbName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  dbNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dbName', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  dbNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'dbName', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
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

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  imageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'image'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  imageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'image'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  imageEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  imageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  imageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  imageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'image',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  imageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  imageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  imageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'image',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  imageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'image',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  imageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'image', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  imageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'image', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  isSystemIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'isSystem'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  isSystemIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'isSystem'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  isSystemEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isSystem', value: value),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  lastLoginIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastLogin'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  lastLoginIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastLogin'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  lastLoginEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastLogin', value: value),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  lastLoginGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastLogin',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  lastLoginLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastLogin',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  lastLoginBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastLogin',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  partnerIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'partnerId'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  partnerIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'partnerId'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  partnerIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'partnerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  partnerIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'partnerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  partnerIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'partnerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  partnerIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'partnerId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  partnerIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'partnerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  partnerIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'partnerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  partnerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'partnerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  partnerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'partnerId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  partnerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'partnerId', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  partnerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'partnerId', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  passwordIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'password'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  passwordIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'password'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  passwordEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'password',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  passwordGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'password',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  passwordLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'password',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  passwordBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'password',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  passwordStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'password',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  passwordEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'password',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  passwordContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'password',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  passwordMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'password',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  passwordIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'password', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  passwordIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'password', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  serverVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'serverVersion'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  serverVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'serverVersion'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  serverVersionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'serverVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  serverVersionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'serverVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  serverVersionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'serverVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  serverVersionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'serverVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  serverVersionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'serverVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  serverVersionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'serverVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  serverVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'serverVersion',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  serverVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'serverVersion',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  serverVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'serverVersion', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  serverVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'serverVersion', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  sessionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'sessionId'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  sessionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'sessionId'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  sessionIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  sessionIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  sessionIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  sessionIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sessionId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  sessionIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  sessionIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  sessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sessionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  sessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sessionId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sessionId', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sessionId', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  urlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'url'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  urlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'url'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition> urlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  urlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition> urlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition> urlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'url',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  urlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition> urlContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition> urlMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'url',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'url', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'url', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'userId'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'userId'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'userId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'userId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userId', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'userId', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLangIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'userLang'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLangIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'userLang'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLangEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'userLang',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLangGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userLang',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLangLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'userLang',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLangBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userLang',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLangStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'userLang',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLangEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'userLang',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLangContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'userLang',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLangMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'userLang',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLangIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userLang', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLangIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'userLang', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLoginIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'userLogin'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLoginIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'userLogin'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLoginEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'userLogin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLoginGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userLogin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLoginLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'userLogin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLoginBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userLogin',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLoginStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'userLogin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLoginEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'userLogin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLoginContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'userLogin',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLoginMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'userLogin',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLoginIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userLogin', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userLoginIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'userLogin', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'userName'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'userName'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'userName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'userName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'userName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'userName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'userName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'userName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userName', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'userName', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userTimezoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'userTimezone'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userTimezoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'userTimezone'),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userTimezoneEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'userTimezone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userTimezoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userTimezone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userTimezoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'userTimezone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userTimezoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userTimezone',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userTimezoneStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'userTimezone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userTimezoneEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'userTimezone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userTimezoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'userTimezone',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userTimezoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'userTimezone',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userTimezoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userTimezone', value: ''),
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterFilterCondition>
  userTimezoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'userTimezone', value: ''),
      );
    });
  }
}

extension AccountEntityQueryObject
    on QueryBuilder<AccountEntity, AccountEntity, QFilterCondition> {}

extension AccountEntityQueryLinks
    on QueryBuilder<AccountEntity, AccountEntity, QFilterCondition> {}

extension AccountEntityQuerySortBy
    on QueryBuilder<AccountEntity, AccountEntity, QSortBy> {
  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortByCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  sortByCompanyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortByDbName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbName', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortByDbNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbName', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortByImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortByImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortByIsSystem() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSystem', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  sortByIsSystemDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSystem', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortByLastLogin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLogin', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  sortByLastLoginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLogin', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortByPartnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerId', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  sortByPartnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerId', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortByPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  sortByPasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  sortByServerVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverVersion', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  sortByServerVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverVersion', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortByUserLang() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userLang', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  sortByUserLangDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userLang', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortByUserLogin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userLogin', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  sortByUserLoginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userLogin', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> sortByUserName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userName', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  sortByUserNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userName', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  sortByUserTimezone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userTimezone', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  sortByUserTimezoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userTimezone', Sort.desc);
    });
  }
}

extension AccountEntityQuerySortThenBy
    on QueryBuilder<AccountEntity, AccountEntity, QSortThenBy> {
  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  thenByCompanyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByDbName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbName', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByDbNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dbName', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByImage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByImageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'image', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByIsSystem() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSystem', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  thenByIsSystemDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSystem', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByLastLogin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLogin', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  thenByLastLoginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastLogin', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByPartnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerId', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  thenByPartnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partnerId', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  thenByPasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  thenByServerVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverVersion', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  thenByServerVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverVersion', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByUserLang() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userLang', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  thenByUserLangDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userLang', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByUserLogin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userLogin', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  thenByUserLoginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userLogin', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy> thenByUserName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userName', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  thenByUserNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userName', Sort.desc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  thenByUserTimezone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userTimezone', Sort.asc);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QAfterSortBy>
  thenByUserTimezoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userTimezone', Sort.desc);
    });
  }
}

extension AccountEntityQueryWhereDistinct
    on QueryBuilder<AccountEntity, AccountEntity, QDistinct> {
  QueryBuilder<AccountEntity, AccountEntity, QDistinct> distinctByCompanyId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'companyId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QDistinct> distinctByDbName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dbName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QDistinct> distinctByImage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'image', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QDistinct> distinctByIsSystem() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSystem');
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QDistinct> distinctByLastLogin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastLogin');
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QDistinct> distinctByPartnerId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'partnerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QDistinct> distinctByPassword({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'password', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QDistinct>
  distinctByServerVersion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'serverVersion',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QDistinct> distinctBySessionId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QDistinct> distinctByUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QDistinct> distinctByUserId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QDistinct> distinctByUserLang({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userLang', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QDistinct> distinctByUserLogin({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userLogin', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QDistinct> distinctByUserName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountEntity, AccountEntity, QDistinct> distinctByUserTimezone({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userTimezone', caseSensitive: caseSensitive);
    });
  }
}

extension AccountEntityQueryProperty
    on QueryBuilder<AccountEntity, AccountEntity, QQueryProperty> {
  QueryBuilder<AccountEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AccountEntity, String?, QQueryOperations> companyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'companyId');
    });
  }

  QueryBuilder<AccountEntity, String?, QQueryOperations> dbNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dbName');
    });
  }

  QueryBuilder<AccountEntity, String?, QQueryOperations> imageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'image');
    });
  }

  QueryBuilder<AccountEntity, bool?, QQueryOperations> isSystemProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSystem');
    });
  }

  QueryBuilder<AccountEntity, DateTime?, QQueryOperations> lastLoginProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastLogin');
    });
  }

  QueryBuilder<AccountEntity, String?, QQueryOperations> partnerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'partnerId');
    });
  }

  QueryBuilder<AccountEntity, String?, QQueryOperations> passwordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'password');
    });
  }

  QueryBuilder<AccountEntity, String?, QQueryOperations>
  serverVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverVersion');
    });
  }

  QueryBuilder<AccountEntity, String?, QQueryOperations> sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<AccountEntity, String?, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }

  QueryBuilder<AccountEntity, String?, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<AccountEntity, String?, QQueryOperations> userLangProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userLang');
    });
  }

  QueryBuilder<AccountEntity, String?, QQueryOperations> userLoginProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userLogin');
    });
  }

  QueryBuilder<AccountEntity, String?, QQueryOperations> userNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userName');
    });
  }

  QueryBuilder<AccountEntity, String?, QQueryOperations>
  userTimezoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userTimezone');
    });
  }
}
