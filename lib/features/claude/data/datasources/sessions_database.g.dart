// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions_database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encodedPathMeta = const VerificationMeta(
    'encodedPath',
  );
  @override
  late final GeneratedColumn<String> encodedPath = GeneratedColumn<String>(
    'encoded_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _firstMessageAtMeta = const VerificationMeta(
    'firstMessageAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstMessageAt =
      GeneratedColumn<DateTime>(
        'first_message_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lastMessageAtMeta = const VerificationMeta(
    'lastMessageAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastMessageAt =
      GeneratedColumn<DateTime>(
        'last_message_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _messageCountMeta = const VerificationMeta(
    'messageCount',
  );
  @override
  late final GeneratedColumn<int> messageCount = GeneratedColumn<int>(
    'message_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileMtimeMeta = const VerificationMeta(
    'fileMtime',
  );
  @override
  late final GeneratedColumn<DateTime> fileMtime = GeneratedColumn<DateTime>(
    'file_mtime',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    encodedPath,
    title,
    firstMessageAt,
    lastMessageAt,
    messageCount,
    fileSize,
    fileMtime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('encoded_path')) {
      context.handle(
        _encodedPathMeta,
        encodedPath.isAcceptableOrUnknown(
          data['encoded_path']!,
          _encodedPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encodedPathMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('first_message_at')) {
      context.handle(
        _firstMessageAtMeta,
        firstMessageAt.isAcceptableOrUnknown(
          data['first_message_at']!,
          _firstMessageAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstMessageAtMeta);
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
        _lastMessageAtMeta,
        lastMessageAt.isAcceptableOrUnknown(
          data['last_message_at']!,
          _lastMessageAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastMessageAtMeta);
    }
    if (data.containsKey('message_count')) {
      context.handle(
        _messageCountMeta,
        messageCount.isAcceptableOrUnknown(
          data['message_count']!,
          _messageCountMeta,
        ),
      );
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('file_mtime')) {
      context.handle(
        _fileMtimeMeta,
        fileMtime.isAcceptableOrUnknown(data['file_mtime']!, _fileMtimeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileMtimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      encodedPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encoded_path'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      firstMessageAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_message_at'],
      )!,
      lastMessageAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_message_at'],
      )!,
      messageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_count'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      fileMtime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}file_mtime'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String id;
  final String workspaceId;
  final String encodedPath;
  final String title;
  final DateTime firstMessageAt;
  final DateTime lastMessageAt;
  final int messageCount;
  final int fileSize;
  final DateTime fileMtime;
  const SessionRow({
    required this.id,
    required this.workspaceId,
    required this.encodedPath,
    required this.title,
    required this.firstMessageAt,
    required this.lastMessageAt,
    required this.messageCount,
    required this.fileSize,
    required this.fileMtime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    map['encoded_path'] = Variable<String>(encodedPath);
    map['title'] = Variable<String>(title);
    map['first_message_at'] = Variable<DateTime>(firstMessageAt);
    map['last_message_at'] = Variable<DateTime>(lastMessageAt);
    map['message_count'] = Variable<int>(messageCount);
    map['file_size'] = Variable<int>(fileSize);
    map['file_mtime'] = Variable<DateTime>(fileMtime);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      encodedPath: Value(encodedPath),
      title: Value(title),
      firstMessageAt: Value(firstMessageAt),
      lastMessageAt: Value(lastMessageAt),
      messageCount: Value(messageCount),
      fileSize: Value(fileSize),
      fileMtime: Value(fileMtime),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      encodedPath: serializer.fromJson<String>(json['encodedPath']),
      title: serializer.fromJson<String>(json['title']),
      firstMessageAt: serializer.fromJson<DateTime>(json['firstMessageAt']),
      lastMessageAt: serializer.fromJson<DateTime>(json['lastMessageAt']),
      messageCount: serializer.fromJson<int>(json['messageCount']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      fileMtime: serializer.fromJson<DateTime>(json['fileMtime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'encodedPath': serializer.toJson<String>(encodedPath),
      'title': serializer.toJson<String>(title),
      'firstMessageAt': serializer.toJson<DateTime>(firstMessageAt),
      'lastMessageAt': serializer.toJson<DateTime>(lastMessageAt),
      'messageCount': serializer.toJson<int>(messageCount),
      'fileSize': serializer.toJson<int>(fileSize),
      'fileMtime': serializer.toJson<DateTime>(fileMtime),
    };
  }

  SessionRow copyWith({
    String? id,
    String? workspaceId,
    String? encodedPath,
    String? title,
    DateTime? firstMessageAt,
    DateTime? lastMessageAt,
    int? messageCount,
    int? fileSize,
    DateTime? fileMtime,
  }) => SessionRow(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    encodedPath: encodedPath ?? this.encodedPath,
    title: title ?? this.title,
    firstMessageAt: firstMessageAt ?? this.firstMessageAt,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    messageCount: messageCount ?? this.messageCount,
    fileSize: fileSize ?? this.fileSize,
    fileMtime: fileMtime ?? this.fileMtime,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      encodedPath: data.encodedPath.present
          ? data.encodedPath.value
          : this.encodedPath,
      title: data.title.present ? data.title.value : this.title,
      firstMessageAt: data.firstMessageAt.present
          ? data.firstMessageAt.value
          : this.firstMessageAt,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
      messageCount: data.messageCount.present
          ? data.messageCount.value
          : this.messageCount,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      fileMtime: data.fileMtime.present ? data.fileMtime.value : this.fileMtime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('encodedPath: $encodedPath, ')
          ..write('title: $title, ')
          ..write('firstMessageAt: $firstMessageAt, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('messageCount: $messageCount, ')
          ..write('fileSize: $fileSize, ')
          ..write('fileMtime: $fileMtime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    encodedPath,
    title,
    firstMessageAt,
    lastMessageAt,
    messageCount,
    fileSize,
    fileMtime,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.encodedPath == this.encodedPath &&
          other.title == this.title &&
          other.firstMessageAt == this.firstMessageAt &&
          other.lastMessageAt == this.lastMessageAt &&
          other.messageCount == this.messageCount &&
          other.fileSize == this.fileSize &&
          other.fileMtime == this.fileMtime);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String> encodedPath;
  final Value<String> title;
  final Value<DateTime> firstMessageAt;
  final Value<DateTime> lastMessageAt;
  final Value<int> messageCount;
  final Value<int> fileSize;
  final Value<DateTime> fileMtime;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.encodedPath = const Value.absent(),
    this.title = const Value.absent(),
    this.firstMessageAt = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.messageCount = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.fileMtime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String workspaceId,
    required String encodedPath,
    this.title = const Value.absent(),
    required DateTime firstMessageAt,
    required DateTime lastMessageAt,
    this.messageCount = const Value.absent(),
    required int fileSize,
    required DateTime fileMtime,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       encodedPath = Value(encodedPath),
       firstMessageAt = Value(firstMessageAt),
       lastMessageAt = Value(lastMessageAt),
       fileSize = Value(fileSize),
       fileMtime = Value(fileMtime);
  static Insertable<SessionRow> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? encodedPath,
    Expression<String>? title,
    Expression<DateTime>? firstMessageAt,
    Expression<DateTime>? lastMessageAt,
    Expression<int>? messageCount,
    Expression<int>? fileSize,
    Expression<DateTime>? fileMtime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (encodedPath != null) 'encoded_path': encodedPath,
      if (title != null) 'title': title,
      if (firstMessageAt != null) 'first_message_at': firstMessageAt,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (messageCount != null) 'message_count': messageCount,
      if (fileSize != null) 'file_size': fileSize,
      if (fileMtime != null) 'file_mtime': fileMtime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String>? encodedPath,
    Value<String>? title,
    Value<DateTime>? firstMessageAt,
    Value<DateTime>? lastMessageAt,
    Value<int>? messageCount,
    Value<int>? fileSize,
    Value<DateTime>? fileMtime,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      encodedPath: encodedPath ?? this.encodedPath,
      title: title ?? this.title,
      firstMessageAt: firstMessageAt ?? this.firstMessageAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      messageCount: messageCount ?? this.messageCount,
      fileSize: fileSize ?? this.fileSize,
      fileMtime: fileMtime ?? this.fileMtime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (encodedPath.present) {
      map['encoded_path'] = Variable<String>(encodedPath.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (firstMessageAt.present) {
      map['first_message_at'] = Variable<DateTime>(firstMessageAt.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt.value);
    }
    if (messageCount.present) {
      map['message_count'] = Variable<int>(messageCount.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (fileMtime.present) {
      map['file_mtime'] = Variable<DateTime>(fileMtime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('encodedPath: $encodedPath, ')
          ..write('title: $title, ')
          ..write('firstMessageAt: $firstMessageAt, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('messageCount: $messageCount, ')
          ..write('fileSize: $fileSize, ')
          ..write('fileMtime: $fileMtime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$SessionsDatabase extends GeneratedDatabase {
  _$SessionsDatabase(QueryExecutor e) : super(e);
  $SessionsDatabaseManager get managers => $SessionsDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sessions];
}

typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String id,
      required String workspaceId,
      required String encodedPath,
      Value<String> title,
      required DateTime firstMessageAt,
      required DateTime lastMessageAt,
      Value<int> messageCount,
      required int fileSize,
      required DateTime fileMtime,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String> encodedPath,
      Value<String> title,
      Value<DateTime> firstMessageAt,
      Value<DateTime> lastMessageAt,
      Value<int> messageCount,
      Value<int> fileSize,
      Value<DateTime> fileMtime,
      Value<int> rowid,
    });

class $$SessionsTableFilterComposer
    extends Composer<_$SessionsDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encodedPath => $composableBuilder(
    column: $table.encodedPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstMessageAt => $composableBuilder(
    column: $table.firstMessageAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get messageCount => $composableBuilder(
    column: $table.messageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fileMtime => $composableBuilder(
    column: $table.fileMtime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$SessionsDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encodedPath => $composableBuilder(
    column: $table.encodedPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstMessageAt => $composableBuilder(
    column: $table.firstMessageAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get messageCount => $composableBuilder(
    column: $table.messageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fileMtime => $composableBuilder(
    column: $table.fileMtime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$SessionsDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get encodedPath => $composableBuilder(
    column: $table.encodedPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get firstMessageAt => $composableBuilder(
    column: $table.firstMessageAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get messageCount => $composableBuilder(
    column: $table.messageCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<DateTime> get fileMtime =>
      $composableBuilder(column: $table.fileMtime, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$SessionsDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (
            SessionRow,
            BaseReferences<_$SessionsDatabase, $SessionsTable, SessionRow>,
          ),
          SessionRow,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$SessionsDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String> encodedPath = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> firstMessageAt = const Value.absent(),
                Value<DateTime> lastMessageAt = const Value.absent(),
                Value<int> messageCount = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<DateTime> fileMtime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                workspaceId: workspaceId,
                encodedPath: encodedPath,
                title: title,
                firstMessageAt: firstMessageAt,
                lastMessageAt: lastMessageAt,
                messageCount: messageCount,
                fileSize: fileSize,
                fileMtime: fileMtime,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                required String encodedPath,
                Value<String> title = const Value.absent(),
                required DateTime firstMessageAt,
                required DateTime lastMessageAt,
                Value<int> messageCount = const Value.absent(),
                required int fileSize,
                required DateTime fileMtime,
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                encodedPath: encodedPath,
                title: title,
                firstMessageAt: firstMessageAt,
                lastMessageAt: lastMessageAt,
                messageCount: messageCount,
                fileSize: fileSize,
                fileMtime: fileMtime,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$SessionsDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (
        SessionRow,
        BaseReferences<_$SessionsDatabase, $SessionsTable, SessionRow>,
      ),
      SessionRow,
      PrefetchHooks Function()
    >;

class $SessionsDatabaseManager {
  final _$SessionsDatabase _db;
  $SessionsDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
}
