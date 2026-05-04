// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_logs_database.dart';

// ignore_for_file: type=lint
class $AppSessionsTable extends AppSessions
    with TableInfo<$AppSessionsTable, AppSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorCountMeta = const VerificationMeta(
    'errorCount',
  );
  @override
  late final GeneratedColumn<int> errorCount = GeneratedColumn<int>(
    'error_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _warningCountMeta = const VerificationMeta(
    'warningCount',
  );
  @override
  late final GeneratedColumn<int> warningCount = GeneratedColumn<int>(
    'warning_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCountMeta = const VerificationMeta(
    'totalCount',
  );
  @override
  late final GeneratedColumn<int> totalCount = GeneratedColumn<int>(
    'total_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    endedAt,
    appVersion,
    platform,
    errorCount,
    warningCount,
    totalCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('error_count')) {
      context.handle(
        _errorCountMeta,
        errorCount.isAcceptableOrUnknown(data['error_count']!, _errorCountMeta),
      );
    }
    if (data.containsKey('warning_count')) {
      context.handle(
        _warningCountMeta,
        warningCount.isAcceptableOrUnknown(
          data['warning_count']!,
          _warningCountMeta,
        ),
      );
    }
    if (data.containsKey('total_count')) {
      context.handle(
        _totalCountMeta,
        totalCount.isAcceptableOrUnknown(data['total_count']!, _totalCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      ),
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      errorCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}error_count'],
      )!,
      warningCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warning_count'],
      )!,
      totalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_count'],
      )!,
    );
  }

  @override
  $AppSessionsTable createAlias(String alias) {
    return $AppSessionsTable(attachedDatabase, alias);
  }
}

class AppSessionRow extends DataClass implements Insertable<AppSessionRow> {
  final int id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? appVersion;
  final String platform;
  final int errorCount;
  final int warningCount;
  final int totalCount;
  const AppSessionRow({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.appVersion,
    required this.platform,
    required this.errorCount,
    required this.warningCount,
    required this.totalCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || appVersion != null) {
      map['app_version'] = Variable<String>(appVersion);
    }
    map['platform'] = Variable<String>(platform);
    map['error_count'] = Variable<int>(errorCount);
    map['warning_count'] = Variable<int>(warningCount);
    map['total_count'] = Variable<int>(totalCount);
    return map;
  }

  AppSessionsCompanion toCompanion(bool nullToAbsent) {
    return AppSessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      appVersion: appVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(appVersion),
      platform: Value(platform),
      errorCount: Value(errorCount),
      warningCount: Value(warningCount),
      totalCount: Value(totalCount),
    );
  }

  factory AppSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSessionRow(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      appVersion: serializer.fromJson<String?>(json['appVersion']),
      platform: serializer.fromJson<String>(json['platform']),
      errorCount: serializer.fromJson<int>(json['errorCount']),
      warningCount: serializer.fromJson<int>(json['warningCount']),
      totalCount: serializer.fromJson<int>(json['totalCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'appVersion': serializer.toJson<String?>(appVersion),
      'platform': serializer.toJson<String>(platform),
      'errorCount': serializer.toJson<int>(errorCount),
      'warningCount': serializer.toJson<int>(warningCount),
      'totalCount': serializer.toJson<int>(totalCount),
    };
  }

  AppSessionRow copyWith({
    int? id,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<String?> appVersion = const Value.absent(),
    String? platform,
    int? errorCount,
    int? warningCount,
    int? totalCount,
  }) => AppSessionRow(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    appVersion: appVersion.present ? appVersion.value : this.appVersion,
    platform: platform ?? this.platform,
    errorCount: errorCount ?? this.errorCount,
    warningCount: warningCount ?? this.warningCount,
    totalCount: totalCount ?? this.totalCount,
  );
  AppSessionRow copyWithCompanion(AppSessionsCompanion data) {
    return AppSessionRow(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      platform: data.platform.present ? data.platform.value : this.platform,
      errorCount: data.errorCount.present
          ? data.errorCount.value
          : this.errorCount,
      warningCount: data.warningCount.present
          ? data.warningCount.value
          : this.warningCount,
      totalCount: data.totalCount.present
          ? data.totalCount.value
          : this.totalCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSessionRow(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('appVersion: $appVersion, ')
          ..write('platform: $platform, ')
          ..write('errorCount: $errorCount, ')
          ..write('warningCount: $warningCount, ')
          ..write('totalCount: $totalCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    endedAt,
    appVersion,
    platform,
    errorCount,
    warningCount,
    totalCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSessionRow &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.appVersion == this.appVersion &&
          other.platform == this.platform &&
          other.errorCount == this.errorCount &&
          other.warningCount == this.warningCount &&
          other.totalCount == this.totalCount);
}

class AppSessionsCompanion extends UpdateCompanion<AppSessionRow> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String?> appVersion;
  final Value<String> platform;
  final Value<int> errorCount;
  final Value<int> warningCount;
  final Value<int> totalCount;
  const AppSessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.platform = const Value.absent(),
    this.errorCount = const Value.absent(),
    this.warningCount = const Value.absent(),
    this.totalCount = const Value.absent(),
  });
  AppSessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.appVersion = const Value.absent(),
    required String platform,
    this.errorCount = const Value.absent(),
    this.warningCount = const Value.absent(),
    this.totalCount = const Value.absent(),
  }) : startedAt = Value(startedAt),
       platform = Value(platform);
  static Insertable<AppSessionRow> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? appVersion,
    Expression<String>? platform,
    Expression<int>? errorCount,
    Expression<int>? warningCount,
    Expression<int>? totalCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (appVersion != null) 'app_version': appVersion,
      if (platform != null) 'platform': platform,
      if (errorCount != null) 'error_count': errorCount,
      if (warningCount != null) 'warning_count': warningCount,
      if (totalCount != null) 'total_count': totalCount,
    });
  }

  AppSessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String?>? appVersion,
    Value<String>? platform,
    Value<int>? errorCount,
    Value<int>? warningCount,
    Value<int>? totalCount,
  }) {
    return AppSessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      appVersion: appVersion ?? this.appVersion,
      platform: platform ?? this.platform,
      errorCount: errorCount ?? this.errorCount,
      warningCount: warningCount ?? this.warningCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (errorCount.present) {
      map['error_count'] = Variable<int>(errorCount.value);
    }
    if (warningCount.present) {
      map['warning_count'] = Variable<int>(warningCount.value);
    }
    if (totalCount.present) {
      map['total_count'] = Variable<int>(totalCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('appVersion: $appVersion, ')
          ..write('platform: $platform, ')
          ..write('errorCount: $errorCount, ')
          ..write('warningCount: $warningCount, ')
          ..write('totalCount: $totalCount')
          ..write(')'))
        .toString();
  }
}

class $LogEntriesTable extends LogEntries
    with TableInfo<$LogEntriesTable, LogEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES app_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exceptionMeta = const VerificationMeta(
    'exception',
  );
  @override
  late final GeneratedColumn<String> exception = GeneratedColumn<String>(
    'exception',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stackTraceMeta = const VerificationMeta(
    'stackTrace',
  );
  @override
  late final GeneratedColumn<String> stackTrace = GeneratedColumn<String>(
    'stack_trace',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    time,
    level,
    title,
    message,
    exception,
    stackTrace,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LogEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('exception')) {
      context.handle(
        _exceptionMeta,
        exception.isAcceptableOrUnknown(data['exception']!, _exceptionMeta),
      );
    }
    if (data.containsKey('stack_trace')) {
      context.handle(
        _stackTraceMeta,
        stackTrace.isAcceptableOrUnknown(data['stack_trace']!, _stackTraceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LogEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      exception: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exception'],
      ),
      stackTrace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stack_trace'],
      ),
    );
  }

  @override
  $LogEntriesTable createAlias(String alias) {
    return $LogEntriesTable(attachedDatabase, alias);
  }
}

class LogEntryRow extends DataClass implements Insertable<LogEntryRow> {
  final int id;
  final int sessionId;
  final DateTime time;
  final String level;
  final String? title;
  final String message;
  final String? exception;
  final String? stackTrace;
  const LogEntryRow({
    required this.id,
    required this.sessionId,
    required this.time,
    required this.level,
    this.title,
    required this.message,
    this.exception,
    this.stackTrace,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['time'] = Variable<DateTime>(time);
    map['level'] = Variable<String>(level);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || exception != null) {
      map['exception'] = Variable<String>(exception);
    }
    if (!nullToAbsent || stackTrace != null) {
      map['stack_trace'] = Variable<String>(stackTrace);
    }
    return map;
  }

  LogEntriesCompanion toCompanion(bool nullToAbsent) {
    return LogEntriesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      time: Value(time),
      level: Value(level),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      message: Value(message),
      exception: exception == null && nullToAbsent
          ? const Value.absent()
          : Value(exception),
      stackTrace: stackTrace == null && nullToAbsent
          ? const Value.absent()
          : Value(stackTrace),
    );
  }

  factory LogEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogEntryRow(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      time: serializer.fromJson<DateTime>(json['time']),
      level: serializer.fromJson<String>(json['level']),
      title: serializer.fromJson<String?>(json['title']),
      message: serializer.fromJson<String>(json['message']),
      exception: serializer.fromJson<String?>(json['exception']),
      stackTrace: serializer.fromJson<String?>(json['stackTrace']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'time': serializer.toJson<DateTime>(time),
      'level': serializer.toJson<String>(level),
      'title': serializer.toJson<String?>(title),
      'message': serializer.toJson<String>(message),
      'exception': serializer.toJson<String?>(exception),
      'stackTrace': serializer.toJson<String?>(stackTrace),
    };
  }

  LogEntryRow copyWith({
    int? id,
    int? sessionId,
    DateTime? time,
    String? level,
    Value<String?> title = const Value.absent(),
    String? message,
    Value<String?> exception = const Value.absent(),
    Value<String?> stackTrace = const Value.absent(),
  }) => LogEntryRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    time: time ?? this.time,
    level: level ?? this.level,
    title: title.present ? title.value : this.title,
    message: message ?? this.message,
    exception: exception.present ? exception.value : this.exception,
    stackTrace: stackTrace.present ? stackTrace.value : this.stackTrace,
  );
  LogEntryRow copyWithCompanion(LogEntriesCompanion data) {
    return LogEntryRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      time: data.time.present ? data.time.value : this.time,
      level: data.level.present ? data.level.value : this.level,
      title: data.title.present ? data.title.value : this.title,
      message: data.message.present ? data.message.value : this.message,
      exception: data.exception.present ? data.exception.value : this.exception,
      stackTrace: data.stackTrace.present
          ? data.stackTrace.value
          : this.stackTrace,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogEntryRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('time: $time, ')
          ..write('level: $level, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('exception: $exception, ')
          ..write('stackTrace: $stackTrace')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    time,
    level,
    title,
    message,
    exception,
    stackTrace,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogEntryRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.time == this.time &&
          other.level == this.level &&
          other.title == this.title &&
          other.message == this.message &&
          other.exception == this.exception &&
          other.stackTrace == this.stackTrace);
}

class LogEntriesCompanion extends UpdateCompanion<LogEntryRow> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<DateTime> time;
  final Value<String> level;
  final Value<String?> title;
  final Value<String> message;
  final Value<String?> exception;
  final Value<String?> stackTrace;
  const LogEntriesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.time = const Value.absent(),
    this.level = const Value.absent(),
    this.title = const Value.absent(),
    this.message = const Value.absent(),
    this.exception = const Value.absent(),
    this.stackTrace = const Value.absent(),
  });
  LogEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required DateTime time,
    required String level,
    this.title = const Value.absent(),
    required String message,
    this.exception = const Value.absent(),
    this.stackTrace = const Value.absent(),
  }) : sessionId = Value(sessionId),
       time = Value(time),
       level = Value(level),
       message = Value(message);
  static Insertable<LogEntryRow> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<DateTime>? time,
    Expression<String>? level,
    Expression<String>? title,
    Expression<String>? message,
    Expression<String>? exception,
    Expression<String>? stackTrace,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (time != null) 'time': time,
      if (level != null) 'level': level,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (exception != null) 'exception': exception,
      if (stackTrace != null) 'stack_trace': stackTrace,
    });
  }

  LogEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<DateTime>? time,
    Value<String>? level,
    Value<String?>? title,
    Value<String>? message,
    Value<String?>? exception,
    Value<String?>? stackTrace,
  }) {
    return LogEntriesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      time: time ?? this.time,
      level: level ?? this.level,
      title: title ?? this.title,
      message: message ?? this.message,
      exception: exception ?? this.exception,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (exception.present) {
      map['exception'] = Variable<String>(exception.value);
    }
    if (stackTrace.present) {
      map['stack_trace'] = Variable<String>(stackTrace.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('time: $time, ')
          ..write('level: $level, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('exception: $exception, ')
          ..write('stackTrace: $stackTrace')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppLogsDatabase extends GeneratedDatabase {
  _$AppLogsDatabase(QueryExecutor e) : super(e);
  $AppLogsDatabaseManager get managers => $AppLogsDatabaseManager(this);
  late final $AppSessionsTable appSessions = $AppSessionsTable(this);
  late final $LogEntriesTable logEntries = $LogEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [appSessions, logEntries];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'app_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('log_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AppSessionsTableCreateCompanionBuilder =
    AppSessionsCompanion Function({
      Value<int> id,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<String?> appVersion,
      required String platform,
      Value<int> errorCount,
      Value<int> warningCount,
      Value<int> totalCount,
    });
typedef $$AppSessionsTableUpdateCompanionBuilder =
    AppSessionsCompanion Function({
      Value<int> id,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<String?> appVersion,
      Value<String> platform,
      Value<int> errorCount,
      Value<int> warningCount,
      Value<int> totalCount,
    });

final class $$AppSessionsTableReferences
    extends
        BaseReferences<_$AppLogsDatabase, $AppSessionsTable, AppSessionRow> {
  $$AppSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LogEntriesTable, List<LogEntryRow>>
  _logEntriesRefsTable(_$AppLogsDatabase db) => MultiTypedResultKey.fromTable(
    db.logEntries,
    aliasName: $_aliasNameGenerator(db.appSessions.id, db.logEntries.sessionId),
  );

  $$LogEntriesTableProcessedTableManager get logEntriesRefs {
    final manager = $$LogEntriesTableTableManager(
      $_db,
      $_db.logEntries,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_logEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AppSessionsTableFilterComposer
    extends Composer<_$AppLogsDatabase, $AppSessionsTable> {
  $$AppSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warningCount => $composableBuilder(
    column: $table.warningCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> logEntriesRefs(
    Expression<bool> Function($$LogEntriesTableFilterComposer f) f,
  ) {
    final $$LogEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.logEntries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LogEntriesTableFilterComposer(
            $db: $db,
            $table: $db.logEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppSessionsTableOrderingComposer
    extends Composer<_$AppLogsDatabase, $AppSessionsTable> {
  $$AppSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warningCount => $composableBuilder(
    column: $table.warningCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSessionsTableAnnotationComposer
    extends Composer<_$AppLogsDatabase, $AppSessionsTable> {
  $$AppSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get warningCount => $composableBuilder(
    column: $table.warningCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCount => $composableBuilder(
    column: $table.totalCount,
    builder: (column) => column,
  );

  Expression<T> logEntriesRefs<T extends Object>(
    Expression<T> Function($$LogEntriesTableAnnotationComposer a) f,
  ) {
    final $$LogEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.logEntries,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LogEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.logEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppSessionsTableTableManager
    extends
        RootTableManager<
          _$AppLogsDatabase,
          $AppSessionsTable,
          AppSessionRow,
          $$AppSessionsTableFilterComposer,
          $$AppSessionsTableOrderingComposer,
          $$AppSessionsTableAnnotationComposer,
          $$AppSessionsTableCreateCompanionBuilder,
          $$AppSessionsTableUpdateCompanionBuilder,
          (AppSessionRow, $$AppSessionsTableReferences),
          AppSessionRow,
          PrefetchHooks Function({bool logEntriesRefs})
        > {
  $$AppSessionsTableTableManager(_$AppLogsDatabase db, $AppSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> appVersion = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<int> errorCount = const Value.absent(),
                Value<int> warningCount = const Value.absent(),
                Value<int> totalCount = const Value.absent(),
              }) => AppSessionsCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                appVersion: appVersion,
                platform: platform,
                errorCount: errorCount,
                warningCount: warningCount,
                totalCount: totalCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> appVersion = const Value.absent(),
                required String platform,
                Value<int> errorCount = const Value.absent(),
                Value<int> warningCount = const Value.absent(),
                Value<int> totalCount = const Value.absent(),
              }) => AppSessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                appVersion: appVersion,
                platform: platform,
                errorCount: errorCount,
                warningCount: warningCount,
                totalCount: totalCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AppSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({logEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (logEntriesRefs) db.logEntries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (logEntriesRefs)
                    await $_getPrefetchedData<
                      AppSessionRow,
                      $AppSessionsTable,
                      LogEntryRow
                    >(
                      currentTable: table,
                      referencedTable: $$AppSessionsTableReferences
                          ._logEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AppSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).logEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AppSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppLogsDatabase,
      $AppSessionsTable,
      AppSessionRow,
      $$AppSessionsTableFilterComposer,
      $$AppSessionsTableOrderingComposer,
      $$AppSessionsTableAnnotationComposer,
      $$AppSessionsTableCreateCompanionBuilder,
      $$AppSessionsTableUpdateCompanionBuilder,
      (AppSessionRow, $$AppSessionsTableReferences),
      AppSessionRow,
      PrefetchHooks Function({bool logEntriesRefs})
    >;
typedef $$LogEntriesTableCreateCompanionBuilder =
    LogEntriesCompanion Function({
      Value<int> id,
      required int sessionId,
      required DateTime time,
      required String level,
      Value<String?> title,
      required String message,
      Value<String?> exception,
      Value<String?> stackTrace,
    });
typedef $$LogEntriesTableUpdateCompanionBuilder =
    LogEntriesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<DateTime> time,
      Value<String> level,
      Value<String?> title,
      Value<String> message,
      Value<String?> exception,
      Value<String?> stackTrace,
    });

final class $$LogEntriesTableReferences
    extends BaseReferences<_$AppLogsDatabase, $LogEntriesTable, LogEntryRow> {
  $$LogEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AppSessionsTable _sessionIdTable(_$AppLogsDatabase db) =>
      db.appSessions.createAlias(
        $_aliasNameGenerator(db.logEntries.sessionId, db.appSessions.id),
      );

  $$AppSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$AppSessionsTableTableManager(
      $_db,
      $_db.appSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LogEntriesTableFilterComposer
    extends Composer<_$AppLogsDatabase, $LogEntriesTable> {
  $$LogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exception => $composableBuilder(
    column: $table.exception,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => ColumnFilters(column),
  );

  $$AppSessionsTableFilterComposer get sessionId {
    final $$AppSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.appSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppSessionsTableFilterComposer(
            $db: $db,
            $table: $db.appSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LogEntriesTableOrderingComposer
    extends Composer<_$AppLogsDatabase, $LogEntriesTable> {
  $$LogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exception => $composableBuilder(
    column: $table.exception,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppSessionsTableOrderingComposer get sessionId {
    final $$AppSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.appSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.appSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LogEntriesTableAnnotationComposer
    extends Composer<_$AppLogsDatabase, $LogEntriesTable> {
  $$LogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get exception =>
      $composableBuilder(column: $table.exception, builder: (column) => column);

  GeneratedColumn<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => column,
  );

  $$AppSessionsTableAnnotationComposer get sessionId {
    final $$AppSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.appSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.appSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LogEntriesTableTableManager
    extends
        RootTableManager<
          _$AppLogsDatabase,
          $LogEntriesTable,
          LogEntryRow,
          $$LogEntriesTableFilterComposer,
          $$LogEntriesTableOrderingComposer,
          $$LogEntriesTableAnnotationComposer,
          $$LogEntriesTableCreateCompanionBuilder,
          $$LogEntriesTableUpdateCompanionBuilder,
          (LogEntryRow, $$LogEntriesTableReferences),
          LogEntryRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$LogEntriesTableTableManager(_$AppLogsDatabase db, $LogEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String?> exception = const Value.absent(),
                Value<String?> stackTrace = const Value.absent(),
              }) => LogEntriesCompanion(
                id: id,
                sessionId: sessionId,
                time: time,
                level: level,
                title: title,
                message: message,
                exception: exception,
                stackTrace: stackTrace,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required DateTime time,
                required String level,
                Value<String?> title = const Value.absent(),
                required String message,
                Value<String?> exception = const Value.absent(),
                Value<String?> stackTrace = const Value.absent(),
              }) => LogEntriesCompanion.insert(
                id: id,
                sessionId: sessionId,
                time: time,
                level: level,
                title: title,
                message: message,
                exception: exception,
                stackTrace: stackTrace,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LogEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$LogEntriesTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$LogEntriesTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LogEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppLogsDatabase,
      $LogEntriesTable,
      LogEntryRow,
      $$LogEntriesTableFilterComposer,
      $$LogEntriesTableOrderingComposer,
      $$LogEntriesTableAnnotationComposer,
      $$LogEntriesTableCreateCompanionBuilder,
      $$LogEntriesTableUpdateCompanionBuilder,
      (LogEntryRow, $$LogEntriesTableReferences),
      LogEntryRow,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppLogsDatabaseManager {
  final _$AppLogsDatabase _db;
  $AppLogsDatabaseManager(this._db);
  $$AppSessionsTableTableManager get appSessions =>
      $$AppSessionsTableTableManager(_db, _db.appSessions);
  $$LogEntriesTableTableManager get logEntries =>
      $$LogEntriesTableTableManager(_db, _db.logEntries);
}
