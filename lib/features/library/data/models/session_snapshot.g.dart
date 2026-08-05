// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_snapshot.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSessionSnapshotCollection on Isar {
  IsarCollection<SessionSnapshot> get sessionSnapshots => this.collection();
}

const SessionSnapshotSchema = CollectionSchema(
  name: r'SessionSnapshot',
  id: 4987300122062958038,
  properties: {
    r'currentIndex': PropertySchema(
      id: 0,
      name: r'currentIndex',
      type: IsarType.long,
    ),
    r'positionMs': PropertySchema(
      id: 1,
      name: r'positionMs',
      type: IsarType.long,
    ),
    r'queue': PropertySchema(
      id: 2,
      name: r'queue',
      type: IsarType.stringList,
    ),
    r'repeatMode': PropertySchema(
      id: 3,
      name: r'repeatMode',
      type: IsarType.string,
    ),
    r'shuffleEnabled': PropertySchema(
      id: 4,
      name: r'shuffleEnabled',
      type: IsarType.bool,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _sessionSnapshotEstimateSize,
  serialize: _sessionSnapshotSerialize,
  deserialize: _sessionSnapshotDeserialize,
  deserializeProp: _sessionSnapshotDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _sessionSnapshotGetId,
  getLinks: _sessionSnapshotGetLinks,
  attach: _sessionSnapshotAttach,
  version: '3.1.0+1',
);

int _sessionSnapshotEstimateSize(
  SessionSnapshot object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.queue.length * 3;
  {
    for (var i = 0; i < object.queue.length; i++) {
      final value = object.queue[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.repeatMode.length * 3;
  return bytesCount;
}

void _sessionSnapshotSerialize(
  SessionSnapshot object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.currentIndex);
  writer.writeLong(offsets[1], object.positionMs);
  writer.writeStringList(offsets[2], object.queue);
  writer.writeString(offsets[3], object.repeatMode);
  writer.writeBool(offsets[4], object.shuffleEnabled);
  writer.writeDateTime(offsets[5], object.updatedAt);
}

SessionSnapshot _sessionSnapshotDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SessionSnapshot();
  object.currentIndex = reader.readLong(offsets[0]);
  object.id = id;
  object.positionMs = reader.readLong(offsets[1]);
  object.queue = reader.readStringList(offsets[2]) ?? [];
  object.repeatMode = reader.readString(offsets[3]);
  object.shuffleEnabled = reader.readBool(offsets[4]);
  object.updatedAt = reader.readDateTime(offsets[5]);
  return object;
}

P _sessionSnapshotDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sessionSnapshotGetId(SessionSnapshot object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sessionSnapshotGetLinks(SessionSnapshot object) {
  return [];
}

void _sessionSnapshotAttach(
    IsarCollection<dynamic> col, Id id, SessionSnapshot object) {
  object.id = id;
}

extension SessionSnapshotQueryWhereSort
    on QueryBuilder<SessionSnapshot, SessionSnapshot, QWhere> {
  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SessionSnapshotQueryWhere
    on QueryBuilder<SessionSnapshot, SessionSnapshot, QWhereClause> {
  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterWhereClause>
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

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SessionSnapshotQueryFilter
    on QueryBuilder<SessionSnapshot, SessionSnapshot, QFilterCondition> {
  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      currentIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      currentIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      currentIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      currentIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      positionMsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'positionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      positionMsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'positionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      positionMsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'positionMs',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      positionMsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'positionMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      queueElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'queue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      queueElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'queue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      queueElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'queue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      queueElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'queue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      queueElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'queue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      queueElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'queue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      queueElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'queue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      queueElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'queue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      queueElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'queue',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      queueElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'queue',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      queueLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queue',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      queueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queue',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      queueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queue',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      queueLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queue',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      queueLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queue',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      queueLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'queue',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      repeatModeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      repeatModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      repeatModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      repeatModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'repeatMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      repeatModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      repeatModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      repeatModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'repeatMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      repeatModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'repeatMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      repeatModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'repeatMode',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      repeatModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'repeatMode',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      shuffleEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shuffleEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SessionSnapshotQueryObject
    on QueryBuilder<SessionSnapshot, SessionSnapshot, QFilterCondition> {}

extension SessionSnapshotQueryLinks
    on QueryBuilder<SessionSnapshot, SessionSnapshot, QFilterCondition> {}

extension SessionSnapshotQuerySortBy
    on QueryBuilder<SessionSnapshot, SessionSnapshot, QSortBy> {
  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      sortByCurrentIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIndex', Sort.asc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      sortByCurrentIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIndex', Sort.desc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      sortByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.asc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      sortByPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.desc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      sortByRepeatMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.asc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      sortByRepeatModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.desc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      sortByShuffleEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffleEnabled', Sort.asc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      sortByShuffleEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffleEnabled', Sort.desc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SessionSnapshotQuerySortThenBy
    on QueryBuilder<SessionSnapshot, SessionSnapshot, QSortThenBy> {
  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      thenByCurrentIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIndex', Sort.asc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      thenByCurrentIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIndex', Sort.desc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      thenByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.asc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      thenByPositionMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'positionMs', Sort.desc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      thenByRepeatMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.asc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      thenByRepeatModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repeatMode', Sort.desc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      thenByShuffleEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffleEnabled', Sort.asc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      thenByShuffleEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shuffleEnabled', Sort.desc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SessionSnapshotQueryWhereDistinct
    on QueryBuilder<SessionSnapshot, SessionSnapshot, QDistinct> {
  QueryBuilder<SessionSnapshot, SessionSnapshot, QDistinct>
      distinctByCurrentIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentIndex');
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QDistinct>
      distinctByPositionMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'positionMs');
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QDistinct> distinctByQueue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'queue');
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QDistinct>
      distinctByRepeatMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repeatMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QDistinct>
      distinctByShuffleEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shuffleEnabled');
    });
  }

  QueryBuilder<SessionSnapshot, SessionSnapshot, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SessionSnapshotQueryProperty
    on QueryBuilder<SessionSnapshot, SessionSnapshot, QQueryProperty> {
  QueryBuilder<SessionSnapshot, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SessionSnapshot, int, QQueryOperations> currentIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentIndex');
    });
  }

  QueryBuilder<SessionSnapshot, int, QQueryOperations> positionMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'positionMs');
    });
  }

  QueryBuilder<SessionSnapshot, List<String>, QQueryOperations>
      queueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'queue');
    });
  }

  QueryBuilder<SessionSnapshot, String, QQueryOperations> repeatModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repeatMode');
    });
  }

  QueryBuilder<SessionSnapshot, bool, QQueryOperations>
      shuffleEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shuffleEnabled');
    });
  }

  QueryBuilder<SessionSnapshot, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
