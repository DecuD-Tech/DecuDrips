// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PoolsTableTable extends PoolsTable
    with TableInfo<$PoolsTableTable, PoolsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PoolsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _repoFullNameMeta =
      const VerificationMeta('repoFullName');
  @override
  late final GeneratedColumn<String> repoFullName = GeneratedColumn<String>(
      'repo_full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fundingAmountMeta =
      const VerificationMeta('fundingAmount');
  @override
  late final GeneratedColumn<double> fundingAmount = GeneratedColumn<double>(
      'funding_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _baseRateMeta =
      const VerificationMeta('baseRate');
  @override
  late final GeneratedColumn<double> baseRate = GeneratedColumn<double>(
      'base_rate', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalDrippedMeta =
      const VerificationMeta('totalDripped');
  @override
  late final GeneratedColumn<double> totalDripped = GeneratedColumn<double>(
      'total_dripped', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, repoFullName, fundingAmount, baseRate, totalDripped, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pools_table';
  @override
  VerificationContext validateIntegrity(Insertable<PoolsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('repo_full_name')) {
      context.handle(
          _repoFullNameMeta,
          repoFullName.isAcceptableOrUnknown(
              data['repo_full_name']!, _repoFullNameMeta));
    } else if (isInserting) {
      context.missing(_repoFullNameMeta);
    }
    if (data.containsKey('funding_amount')) {
      context.handle(
          _fundingAmountMeta,
          fundingAmount.isAcceptableOrUnknown(
              data['funding_amount']!, _fundingAmountMeta));
    } else if (isInserting) {
      context.missing(_fundingAmountMeta);
    }
    if (data.containsKey('base_rate')) {
      context.handle(_baseRateMeta,
          baseRate.isAcceptableOrUnknown(data['base_rate']!, _baseRateMeta));
    } else if (isInserting) {
      context.missing(_baseRateMeta);
    }
    if (data.containsKey('total_dripped')) {
      context.handle(
          _totalDrippedMeta,
          totalDripped.isAcceptableOrUnknown(
              data['total_dripped']!, _totalDrippedMeta));
    } else if (isInserting) {
      context.missing(_totalDrippedMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PoolsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PoolsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      repoFullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repo_full_name'])!,
      fundingAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}funding_amount'])!,
      baseRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}base_rate'])!,
      totalDripped: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_dripped'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $PoolsTableTable createAlias(String alias) {
    return $PoolsTableTable(attachedDatabase, alias);
  }
}

class PoolsTableData extends DataClass implements Insertable<PoolsTableData> {
  final String id;
  final String repoFullName;
  final double fundingAmount;
  final double baseRate;
  final double totalDripped;
  final String status;
  const PoolsTableData(
      {required this.id,
      required this.repoFullName,
      required this.fundingAmount,
      required this.baseRate,
      required this.totalDripped,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['repo_full_name'] = Variable<String>(repoFullName);
    map['funding_amount'] = Variable<double>(fundingAmount);
    map['base_rate'] = Variable<double>(baseRate);
    map['total_dripped'] = Variable<double>(totalDripped);
    map['status'] = Variable<String>(status);
    return map;
  }

  PoolsTableCompanion toCompanion(bool nullToAbsent) {
    return PoolsTableCompanion(
      id: Value(id),
      repoFullName: Value(repoFullName),
      fundingAmount: Value(fundingAmount),
      baseRate: Value(baseRate),
      totalDripped: Value(totalDripped),
      status: Value(status),
    );
  }

  factory PoolsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PoolsTableData(
      id: serializer.fromJson<String>(json['id']),
      repoFullName: serializer.fromJson<String>(json['repoFullName']),
      fundingAmount: serializer.fromJson<double>(json['fundingAmount']),
      baseRate: serializer.fromJson<double>(json['baseRate']),
      totalDripped: serializer.fromJson<double>(json['totalDripped']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'repoFullName': serializer.toJson<String>(repoFullName),
      'fundingAmount': serializer.toJson<double>(fundingAmount),
      'baseRate': serializer.toJson<double>(baseRate),
      'totalDripped': serializer.toJson<double>(totalDripped),
      'status': serializer.toJson<String>(status),
    };
  }

  PoolsTableData copyWith(
          {String? id,
          String? repoFullName,
          double? fundingAmount,
          double? baseRate,
          double? totalDripped,
          String? status}) =>
      PoolsTableData(
        id: id ?? this.id,
        repoFullName: repoFullName ?? this.repoFullName,
        fundingAmount: fundingAmount ?? this.fundingAmount,
        baseRate: baseRate ?? this.baseRate,
        totalDripped: totalDripped ?? this.totalDripped,
        status: status ?? this.status,
      );
  PoolsTableData copyWithCompanion(PoolsTableCompanion data) {
    return PoolsTableData(
      id: data.id.present ? data.id.value : this.id,
      repoFullName: data.repoFullName.present
          ? data.repoFullName.value
          : this.repoFullName,
      fundingAmount: data.fundingAmount.present
          ? data.fundingAmount.value
          : this.fundingAmount,
      baseRate: data.baseRate.present ? data.baseRate.value : this.baseRate,
      totalDripped: data.totalDripped.present
          ? data.totalDripped.value
          : this.totalDripped,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PoolsTableData(')
          ..write('id: $id, ')
          ..write('repoFullName: $repoFullName, ')
          ..write('fundingAmount: $fundingAmount, ')
          ..write('baseRate: $baseRate, ')
          ..write('totalDripped: $totalDripped, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, repoFullName, fundingAmount, baseRate, totalDripped, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PoolsTableData &&
          other.id == this.id &&
          other.repoFullName == this.repoFullName &&
          other.fundingAmount == this.fundingAmount &&
          other.baseRate == this.baseRate &&
          other.totalDripped == this.totalDripped &&
          other.status == this.status);
}

class PoolsTableCompanion extends UpdateCompanion<PoolsTableData> {
  final Value<String> id;
  final Value<String> repoFullName;
  final Value<double> fundingAmount;
  final Value<double> baseRate;
  final Value<double> totalDripped;
  final Value<String> status;
  final Value<int> rowid;
  const PoolsTableCompanion({
    this.id = const Value.absent(),
    this.repoFullName = const Value.absent(),
    this.fundingAmount = const Value.absent(),
    this.baseRate = const Value.absent(),
    this.totalDripped = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PoolsTableCompanion.insert({
    required String id,
    required String repoFullName,
    required double fundingAmount,
    required double baseRate,
    required double totalDripped,
    required String status,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        repoFullName = Value(repoFullName),
        fundingAmount = Value(fundingAmount),
        baseRate = Value(baseRate),
        totalDripped = Value(totalDripped),
        status = Value(status);
  static Insertable<PoolsTableData> custom({
    Expression<String>? id,
    Expression<String>? repoFullName,
    Expression<double>? fundingAmount,
    Expression<double>? baseRate,
    Expression<double>? totalDripped,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (repoFullName != null) 'repo_full_name': repoFullName,
      if (fundingAmount != null) 'funding_amount': fundingAmount,
      if (baseRate != null) 'base_rate': baseRate,
      if (totalDripped != null) 'total_dripped': totalDripped,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PoolsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? repoFullName,
      Value<double>? fundingAmount,
      Value<double>? baseRate,
      Value<double>? totalDripped,
      Value<String>? status,
      Value<int>? rowid}) {
    return PoolsTableCompanion(
      id: id ?? this.id,
      repoFullName: repoFullName ?? this.repoFullName,
      fundingAmount: fundingAmount ?? this.fundingAmount,
      baseRate: baseRate ?? this.baseRate,
      totalDripped: totalDripped ?? this.totalDripped,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (repoFullName.present) {
      map['repo_full_name'] = Variable<String>(repoFullName.value);
    }
    if (fundingAmount.present) {
      map['funding_amount'] = Variable<double>(fundingAmount.value);
    }
    if (baseRate.present) {
      map['base_rate'] = Variable<double>(baseRate.value);
    }
    if (totalDripped.present) {
      map['total_dripped'] = Variable<double>(totalDripped.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PoolsTableCompanion(')
          ..write('id: $id, ')
          ..write('repoFullName: $repoFullName, ')
          ..write('fundingAmount: $fundingAmount, ')
          ..write('baseRate: $baseRate, ')
          ..write('totalDripped: $totalDripped, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StreamsTableTable extends StreamsTable
    with TableInfo<$StreamsTableTable, StreamsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreamsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _poolIdMeta = const VerificationMeta('poolId');
  @override
  late final GeneratedColumn<String> poolId = GeneratedColumn<String>(
      'pool_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorUsernameMeta =
      const VerificationMeta('authorUsername');
  @override
  late final GeneratedColumn<String> authorUsername = GeneratedColumn<String>(
      'author_username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _characterCountMeta =
      const VerificationMeta('characterCount');
  @override
  late final GeneratedColumn<int> characterCount = GeneratedColumn<int>(
      'character_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
      'locale', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accumulatedMeta =
      const VerificationMeta('accumulated');
  @override
  late final GeneratedColumn<double> accumulated = GeneratedColumn<double>(
      'accumulated', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _flowRatePerSecondMeta =
      const VerificationMeta('flowRatePerSecond');
  @override
  late final GeneratedColumn<double> flowRatePerSecond =
      GeneratedColumn<double>('flow_rate_per_second', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _approvalRatioMeta =
      const VerificationMeta('approvalRatio');
  @override
  late final GeneratedColumn<double> approvalRatio = GeneratedColumn<double>(
      'approval_ratio', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        poolId,
        authorUsername,
        filePath,
        characterCount,
        locale,
        accumulated,
        flowRatePerSecond,
        approvalRatio,
        status,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streams_table';
  @override
  VerificationContext validateIntegrity(Insertable<StreamsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pool_id')) {
      context.handle(_poolIdMeta,
          poolId.isAcceptableOrUnknown(data['pool_id']!, _poolIdMeta));
    } else if (isInserting) {
      context.missing(_poolIdMeta);
    }
    if (data.containsKey('author_username')) {
      context.handle(
          _authorUsernameMeta,
          authorUsername.isAcceptableOrUnknown(
              data['author_username']!, _authorUsernameMeta));
    } else if (isInserting) {
      context.missing(_authorUsernameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('character_count')) {
      context.handle(
          _characterCountMeta,
          characterCount.isAcceptableOrUnknown(
              data['character_count']!, _characterCountMeta));
    } else if (isInserting) {
      context.missing(_characterCountMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(_localeMeta,
          locale.isAcceptableOrUnknown(data['locale']!, _localeMeta));
    } else if (isInserting) {
      context.missing(_localeMeta);
    }
    if (data.containsKey('accumulated')) {
      context.handle(
          _accumulatedMeta,
          accumulated.isAcceptableOrUnknown(
              data['accumulated']!, _accumulatedMeta));
    } else if (isInserting) {
      context.missing(_accumulatedMeta);
    }
    if (data.containsKey('flow_rate_per_second')) {
      context.handle(
          _flowRatePerSecondMeta,
          flowRatePerSecond.isAcceptableOrUnknown(
              data['flow_rate_per_second']!, _flowRatePerSecondMeta));
    } else if (isInserting) {
      context.missing(_flowRatePerSecondMeta);
    }
    if (data.containsKey('approval_ratio')) {
      context.handle(
          _approvalRatioMeta,
          approvalRatio.isAcceptableOrUnknown(
              data['approval_ratio']!, _approvalRatioMeta));
    } else if (isInserting) {
      context.missing(_approvalRatioMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StreamsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreamsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      poolId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pool_id'])!,
      authorUsername: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}author_username'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      characterCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}character_count'])!,
      locale: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}locale'])!,
      accumulated: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accumulated'])!,
      flowRatePerSecond: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}flow_rate_per_second'])!,
      approvalRatio: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}approval_ratio'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $StreamsTableTable createAlias(String alias) {
    return $StreamsTableTable(attachedDatabase, alias);
  }
}

class StreamsTableData extends DataClass
    implements Insertable<StreamsTableData> {
  final String id;
  final String poolId;
  final String authorUsername;
  final String filePath;
  final int characterCount;
  final String locale;
  final double accumulated;
  final double flowRatePerSecond;
  final double approvalRatio;
  final String status;
  final DateTime createdAt;
  const StreamsTableData(
      {required this.id,
      required this.poolId,
      required this.authorUsername,
      required this.filePath,
      required this.characterCount,
      required this.locale,
      required this.accumulated,
      required this.flowRatePerSecond,
      required this.approvalRatio,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pool_id'] = Variable<String>(poolId);
    map['author_username'] = Variable<String>(authorUsername);
    map['file_path'] = Variable<String>(filePath);
    map['character_count'] = Variable<int>(characterCount);
    map['locale'] = Variable<String>(locale);
    map['accumulated'] = Variable<double>(accumulated);
    map['flow_rate_per_second'] = Variable<double>(flowRatePerSecond);
    map['approval_ratio'] = Variable<double>(approvalRatio);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StreamsTableCompanion toCompanion(bool nullToAbsent) {
    return StreamsTableCompanion(
      id: Value(id),
      poolId: Value(poolId),
      authorUsername: Value(authorUsername),
      filePath: Value(filePath),
      characterCount: Value(characterCount),
      locale: Value(locale),
      accumulated: Value(accumulated),
      flowRatePerSecond: Value(flowRatePerSecond),
      approvalRatio: Value(approvalRatio),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory StreamsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StreamsTableData(
      id: serializer.fromJson<String>(json['id']),
      poolId: serializer.fromJson<String>(json['poolId']),
      authorUsername: serializer.fromJson<String>(json['authorUsername']),
      filePath: serializer.fromJson<String>(json['filePath']),
      characterCount: serializer.fromJson<int>(json['characterCount']),
      locale: serializer.fromJson<String>(json['locale']),
      accumulated: serializer.fromJson<double>(json['accumulated']),
      flowRatePerSecond: serializer.fromJson<double>(json['flowRatePerSecond']),
      approvalRatio: serializer.fromJson<double>(json['approvalRatio']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'poolId': serializer.toJson<String>(poolId),
      'authorUsername': serializer.toJson<String>(authorUsername),
      'filePath': serializer.toJson<String>(filePath),
      'characterCount': serializer.toJson<int>(characterCount),
      'locale': serializer.toJson<String>(locale),
      'accumulated': serializer.toJson<double>(accumulated),
      'flowRatePerSecond': serializer.toJson<double>(flowRatePerSecond),
      'approvalRatio': serializer.toJson<double>(approvalRatio),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StreamsTableData copyWith(
          {String? id,
          String? poolId,
          String? authorUsername,
          String? filePath,
          int? characterCount,
          String? locale,
          double? accumulated,
          double? flowRatePerSecond,
          double? approvalRatio,
          String? status,
          DateTime? createdAt}) =>
      StreamsTableData(
        id: id ?? this.id,
        poolId: poolId ?? this.poolId,
        authorUsername: authorUsername ?? this.authorUsername,
        filePath: filePath ?? this.filePath,
        characterCount: characterCount ?? this.characterCount,
        locale: locale ?? this.locale,
        accumulated: accumulated ?? this.accumulated,
        flowRatePerSecond: flowRatePerSecond ?? this.flowRatePerSecond,
        approvalRatio: approvalRatio ?? this.approvalRatio,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  StreamsTableData copyWithCompanion(StreamsTableCompanion data) {
    return StreamsTableData(
      id: data.id.present ? data.id.value : this.id,
      poolId: data.poolId.present ? data.poolId.value : this.poolId,
      authorUsername: data.authorUsername.present
          ? data.authorUsername.value
          : this.authorUsername,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      characterCount: data.characterCount.present
          ? data.characterCount.value
          : this.characterCount,
      locale: data.locale.present ? data.locale.value : this.locale,
      accumulated:
          data.accumulated.present ? data.accumulated.value : this.accumulated,
      flowRatePerSecond: data.flowRatePerSecond.present
          ? data.flowRatePerSecond.value
          : this.flowRatePerSecond,
      approvalRatio: data.approvalRatio.present
          ? data.approvalRatio.value
          : this.approvalRatio,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreamsTableData(')
          ..write('id: $id, ')
          ..write('poolId: $poolId, ')
          ..write('authorUsername: $authorUsername, ')
          ..write('filePath: $filePath, ')
          ..write('characterCount: $characterCount, ')
          ..write('locale: $locale, ')
          ..write('accumulated: $accumulated, ')
          ..write('flowRatePerSecond: $flowRatePerSecond, ')
          ..write('approvalRatio: $approvalRatio, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      poolId,
      authorUsername,
      filePath,
      characterCount,
      locale,
      accumulated,
      flowRatePerSecond,
      approvalRatio,
      status,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreamsTableData &&
          other.id == this.id &&
          other.poolId == this.poolId &&
          other.authorUsername == this.authorUsername &&
          other.filePath == this.filePath &&
          other.characterCount == this.characterCount &&
          other.locale == this.locale &&
          other.accumulated == this.accumulated &&
          other.flowRatePerSecond == this.flowRatePerSecond &&
          other.approvalRatio == this.approvalRatio &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class StreamsTableCompanion extends UpdateCompanion<StreamsTableData> {
  final Value<String> id;
  final Value<String> poolId;
  final Value<String> authorUsername;
  final Value<String> filePath;
  final Value<int> characterCount;
  final Value<String> locale;
  final Value<double> accumulated;
  final Value<double> flowRatePerSecond;
  final Value<double> approvalRatio;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StreamsTableCompanion({
    this.id = const Value.absent(),
    this.poolId = const Value.absent(),
    this.authorUsername = const Value.absent(),
    this.filePath = const Value.absent(),
    this.characterCount = const Value.absent(),
    this.locale = const Value.absent(),
    this.accumulated = const Value.absent(),
    this.flowRatePerSecond = const Value.absent(),
    this.approvalRatio = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StreamsTableCompanion.insert({
    required String id,
    required String poolId,
    required String authorUsername,
    required String filePath,
    required int characterCount,
    required String locale,
    required double accumulated,
    required double flowRatePerSecond,
    required double approvalRatio,
    required String status,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        poolId = Value(poolId),
        authorUsername = Value(authorUsername),
        filePath = Value(filePath),
        characterCount = Value(characterCount),
        locale = Value(locale),
        accumulated = Value(accumulated),
        flowRatePerSecond = Value(flowRatePerSecond),
        approvalRatio = Value(approvalRatio),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<StreamsTableData> custom({
    Expression<String>? id,
    Expression<String>? poolId,
    Expression<String>? authorUsername,
    Expression<String>? filePath,
    Expression<int>? characterCount,
    Expression<String>? locale,
    Expression<double>? accumulated,
    Expression<double>? flowRatePerSecond,
    Expression<double>? approvalRatio,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (poolId != null) 'pool_id': poolId,
      if (authorUsername != null) 'author_username': authorUsername,
      if (filePath != null) 'file_path': filePath,
      if (characterCount != null) 'character_count': characterCount,
      if (locale != null) 'locale': locale,
      if (accumulated != null) 'accumulated': accumulated,
      if (flowRatePerSecond != null) 'flow_rate_per_second': flowRatePerSecond,
      if (approvalRatio != null) 'approval_ratio': approvalRatio,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StreamsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? poolId,
      Value<String>? authorUsername,
      Value<String>? filePath,
      Value<int>? characterCount,
      Value<String>? locale,
      Value<double>? accumulated,
      Value<double>? flowRatePerSecond,
      Value<double>? approvalRatio,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return StreamsTableCompanion(
      id: id ?? this.id,
      poolId: poolId ?? this.poolId,
      authorUsername: authorUsername ?? this.authorUsername,
      filePath: filePath ?? this.filePath,
      characterCount: characterCount ?? this.characterCount,
      locale: locale ?? this.locale,
      accumulated: accumulated ?? this.accumulated,
      flowRatePerSecond: flowRatePerSecond ?? this.flowRatePerSecond,
      approvalRatio: approvalRatio ?? this.approvalRatio,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (poolId.present) {
      map['pool_id'] = Variable<String>(poolId.value);
    }
    if (authorUsername.present) {
      map['author_username'] = Variable<String>(authorUsername.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (characterCount.present) {
      map['character_count'] = Variable<int>(characterCount.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (accumulated.present) {
      map['accumulated'] = Variable<double>(accumulated.value);
    }
    if (flowRatePerSecond.present) {
      map['flow_rate_per_second'] = Variable<double>(flowRatePerSecond.value);
    }
    if (approvalRatio.present) {
      map['approval_ratio'] = Variable<double>(approvalRatio.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreamsTableCompanion(')
          ..write('id: $id, ')
          ..write('poolId: $poolId, ')
          ..write('authorUsername: $authorUsername, ')
          ..write('filePath: $filePath, ')
          ..write('characterCount: $characterCount, ')
          ..write('locale: $locale, ')
          ..write('accumulated: $accumulated, ')
          ..write('flowRatePerSecond: $flowRatePerSecond, ')
          ..write('approvalRatio: $approvalRatio, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClaimsTableTable extends ClaimsTable
    with TableInfo<$ClaimsTableTable, ClaimsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClaimsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _streamIdMeta =
      const VerificationMeta('streamId');
  @override
  late final GeneratedColumn<String> streamId = GeneratedColumn<String>(
      'stream_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _providerTxRefMeta =
      const VerificationMeta('providerTxRef');
  @override
  late final GeneratedColumn<String> providerTxRef = GeneratedColumn<String>(
      'provider_tx_ref', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _claimedAtMeta =
      const VerificationMeta('claimedAt');
  @override
  late final GeneratedColumn<DateTime> claimedAt = GeneratedColumn<DateTime>(
      'claimed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, streamId, userId, amount, status, providerTxRef, claimedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'claims_table';
  @override
  VerificationContext validateIntegrity(Insertable<ClaimsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('stream_id')) {
      context.handle(_streamIdMeta,
          streamId.isAcceptableOrUnknown(data['stream_id']!, _streamIdMeta));
    } else if (isInserting) {
      context.missing(_streamIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('provider_tx_ref')) {
      context.handle(
          _providerTxRefMeta,
          providerTxRef.isAcceptableOrUnknown(
              data['provider_tx_ref']!, _providerTxRefMeta));
    }
    if (data.containsKey('claimed_at')) {
      context.handle(_claimedAtMeta,
          claimedAt.isAcceptableOrUnknown(data['claimed_at']!, _claimedAtMeta));
    } else if (isInserting) {
      context.missing(_claimedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClaimsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClaimsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      streamId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stream_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      providerTxRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider_tx_ref']),
      claimedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}claimed_at'])!,
    );
  }

  @override
  $ClaimsTableTable createAlias(String alias) {
    return $ClaimsTableTable(attachedDatabase, alias);
  }
}

class ClaimsTableData extends DataClass implements Insertable<ClaimsTableData> {
  final String id;
  final String streamId;
  final String userId;
  final double amount;
  final String status;
  final String? providerTxRef;
  final DateTime claimedAt;
  const ClaimsTableData(
      {required this.id,
      required this.streamId,
      required this.userId,
      required this.amount,
      required this.status,
      this.providerTxRef,
      required this.claimedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['stream_id'] = Variable<String>(streamId);
    map['user_id'] = Variable<String>(userId);
    map['amount'] = Variable<double>(amount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || providerTxRef != null) {
      map['provider_tx_ref'] = Variable<String>(providerTxRef);
    }
    map['claimed_at'] = Variable<DateTime>(claimedAt);
    return map;
  }

  ClaimsTableCompanion toCompanion(bool nullToAbsent) {
    return ClaimsTableCompanion(
      id: Value(id),
      streamId: Value(streamId),
      userId: Value(userId),
      amount: Value(amount),
      status: Value(status),
      providerTxRef: providerTxRef == null && nullToAbsent
          ? const Value.absent()
          : Value(providerTxRef),
      claimedAt: Value(claimedAt),
    );
  }

  factory ClaimsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClaimsTableData(
      id: serializer.fromJson<String>(json['id']),
      streamId: serializer.fromJson<String>(json['streamId']),
      userId: serializer.fromJson<String>(json['userId']),
      amount: serializer.fromJson<double>(json['amount']),
      status: serializer.fromJson<String>(json['status']),
      providerTxRef: serializer.fromJson<String?>(json['providerTxRef']),
      claimedAt: serializer.fromJson<DateTime>(json['claimedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'streamId': serializer.toJson<String>(streamId),
      'userId': serializer.toJson<String>(userId),
      'amount': serializer.toJson<double>(amount),
      'status': serializer.toJson<String>(status),
      'providerTxRef': serializer.toJson<String?>(providerTxRef),
      'claimedAt': serializer.toJson<DateTime>(claimedAt),
    };
  }

  ClaimsTableData copyWith(
          {String? id,
          String? streamId,
          String? userId,
          double? amount,
          String? status,
          Value<String?> providerTxRef = const Value.absent(),
          DateTime? claimedAt}) =>
      ClaimsTableData(
        id: id ?? this.id,
        streamId: streamId ?? this.streamId,
        userId: userId ?? this.userId,
        amount: amount ?? this.amount,
        status: status ?? this.status,
        providerTxRef:
            providerTxRef.present ? providerTxRef.value : this.providerTxRef,
        claimedAt: claimedAt ?? this.claimedAt,
      );
  ClaimsTableData copyWithCompanion(ClaimsTableCompanion data) {
    return ClaimsTableData(
      id: data.id.present ? data.id.value : this.id,
      streamId: data.streamId.present ? data.streamId.value : this.streamId,
      userId: data.userId.present ? data.userId.value : this.userId,
      amount: data.amount.present ? data.amount.value : this.amount,
      status: data.status.present ? data.status.value : this.status,
      providerTxRef: data.providerTxRef.present
          ? data.providerTxRef.value
          : this.providerTxRef,
      claimedAt: data.claimedAt.present ? data.claimedAt.value : this.claimedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClaimsTableData(')
          ..write('id: $id, ')
          ..write('streamId: $streamId, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('status: $status, ')
          ..write('providerTxRef: $providerTxRef, ')
          ..write('claimedAt: $claimedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, streamId, userId, amount, status, providerTxRef, claimedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClaimsTableData &&
          other.id == this.id &&
          other.streamId == this.streamId &&
          other.userId == this.userId &&
          other.amount == this.amount &&
          other.status == this.status &&
          other.providerTxRef == this.providerTxRef &&
          other.claimedAt == this.claimedAt);
}

class ClaimsTableCompanion extends UpdateCompanion<ClaimsTableData> {
  final Value<String> id;
  final Value<String> streamId;
  final Value<String> userId;
  final Value<double> amount;
  final Value<String> status;
  final Value<String?> providerTxRef;
  final Value<DateTime> claimedAt;
  final Value<int> rowid;
  const ClaimsTableCompanion({
    this.id = const Value.absent(),
    this.streamId = const Value.absent(),
    this.userId = const Value.absent(),
    this.amount = const Value.absent(),
    this.status = const Value.absent(),
    this.providerTxRef = const Value.absent(),
    this.claimedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClaimsTableCompanion.insert({
    required String id,
    required String streamId,
    required String userId,
    required double amount,
    required String status,
    this.providerTxRef = const Value.absent(),
    required DateTime claimedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        streamId = Value(streamId),
        userId = Value(userId),
        amount = Value(amount),
        status = Value(status),
        claimedAt = Value(claimedAt);
  static Insertable<ClaimsTableData> custom({
    Expression<String>? id,
    Expression<String>? streamId,
    Expression<String>? userId,
    Expression<double>? amount,
    Expression<String>? status,
    Expression<String>? providerTxRef,
    Expression<DateTime>? claimedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (streamId != null) 'stream_id': streamId,
      if (userId != null) 'user_id': userId,
      if (amount != null) 'amount': amount,
      if (status != null) 'status': status,
      if (providerTxRef != null) 'provider_tx_ref': providerTxRef,
      if (claimedAt != null) 'claimed_at': claimedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClaimsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? streamId,
      Value<String>? userId,
      Value<double>? amount,
      Value<String>? status,
      Value<String?>? providerTxRef,
      Value<DateTime>? claimedAt,
      Value<int>? rowid}) {
    return ClaimsTableCompanion(
      id: id ?? this.id,
      streamId: streamId ?? this.streamId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      providerTxRef: providerTxRef ?? this.providerTxRef,
      claimedAt: claimedAt ?? this.claimedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (streamId.present) {
      map['stream_id'] = Variable<String>(streamId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (providerTxRef.present) {
      map['provider_tx_ref'] = Variable<String>(providerTxRef.value);
    }
    if (claimedAt.present) {
      map['claimed_at'] = Variable<DateTime>(claimedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClaimsTableCompanion(')
          ..write('id: $id, ')
          ..write('streamId: $streamId, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('status: $status, ')
          ..write('providerTxRef: $providerTxRef, ')
          ..write('claimedAt: $claimedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineActionsTableTable extends OfflineActionsTable
    with TableInfo<$OfflineActionsTableTable, OfflineActionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineActionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _actionTypeMeta =
      const VerificationMeta('actionType');
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
      'action_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, actionType, payload, status, retryCount, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_actions_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<OfflineActionsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action_type')) {
      context.handle(
          _actionTypeMeta,
          actionType.isAcceptableOrUnknown(
              data['action_type']!, _actionTypeMeta));
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineActionsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineActionsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      actionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_type'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OfflineActionsTableTable createAlias(String alias) {
    return $OfflineActionsTableTable(attachedDatabase, alias);
  }
}

class OfflineActionsTableData extends DataClass
    implements Insertable<OfflineActionsTableData> {
  final int id;
  final String actionType;
  final String payload;
  final String status;
  final int retryCount;
  final DateTime createdAt;
  const OfflineActionsTableData(
      {required this.id,
      required this.actionType,
      required this.payload,
      required this.status,
      required this.retryCount,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action_type'] = Variable<String>(actionType);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OfflineActionsTableCompanion toCompanion(bool nullToAbsent) {
    return OfflineActionsTableCompanion(
      id: Value(id),
      actionType: Value(actionType),
      payload: Value(payload),
      status: Value(status),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
    );
  }

  factory OfflineActionsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineActionsTableData(
      id: serializer.fromJson<int>(json['id']),
      actionType: serializer.fromJson<String>(json['actionType']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'actionType': serializer.toJson<String>(actionType),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OfflineActionsTableData copyWith(
          {int? id,
          String? actionType,
          String? payload,
          String? status,
          int? retryCount,
          DateTime? createdAt}) =>
      OfflineActionsTableData(
        id: id ?? this.id,
        actionType: actionType ?? this.actionType,
        payload: payload ?? this.payload,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        createdAt: createdAt ?? this.createdAt,
      );
  OfflineActionsTableData copyWithCompanion(OfflineActionsTableCompanion data) {
    return OfflineActionsTableData(
      id: data.id.present ? data.id.value : this.id,
      actionType:
          data.actionType.present ? data.actionType.value : this.actionType,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineActionsTableData(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, actionType, payload, status, retryCount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineActionsTableData &&
          other.id == this.id &&
          other.actionType == this.actionType &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt);
}

class OfflineActionsTableCompanion
    extends UpdateCompanion<OfflineActionsTableData> {
  final Value<int> id;
  final Value<String> actionType;
  final Value<String> payload;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  const OfflineActionsTableCompanion({
    this.id = const Value.absent(),
    this.actionType = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OfflineActionsTableCompanion.insert({
    this.id = const Value.absent(),
    required String actionType,
    required String payload,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    required DateTime createdAt,
  })  : actionType = Value(actionType),
        payload = Value(payload),
        createdAt = Value(createdAt);
  static Insertable<OfflineActionsTableData> custom({
    Expression<int>? id,
    Expression<String>? actionType,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionType != null) 'action_type': actionType,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OfflineActionsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? actionType,
      Value<String>? payload,
      Value<String>? status,
      Value<int>? retryCount,
      Value<DateTime>? createdAt}) {
    return OfflineActionsTableCompanion(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineActionsTableCompanion(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SessionTableTable extends SessionTable
    with TableInfo<$SessionTableTable, SessionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _jwtTokenMeta =
      const VerificationMeta('jwtToken');
  @override
  late final GeneratedColumn<String> jwtToken = GeneratedColumn<String>(
      'jwt_token', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, jwtToken, username, role, expiresAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_table';
  @override
  VerificationContext validateIntegrity(Insertable<SessionTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('jwt_token')) {
      context.handle(_jwtTokenMeta,
          jwtToken.isAcceptableOrUnknown(data['jwt_token']!, _jwtTokenMeta));
    } else if (isInserting) {
      context.missing(_jwtTokenMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      jwtToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}jwt_token'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at'])!,
    );
  }

  @override
  $SessionTableTable createAlias(String alias) {
    return $SessionTableTable(attachedDatabase, alias);
  }
}

class SessionTableData extends DataClass
    implements Insertable<SessionTableData> {
  final int id;
  final String jwtToken;
  final String username;
  final String role;
  final DateTime expiresAt;
  const SessionTableData(
      {required this.id,
      required this.jwtToken,
      required this.username,
      required this.role,
      required this.expiresAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['jwt_token'] = Variable<String>(jwtToken);
    map['username'] = Variable<String>(username);
    map['role'] = Variable<String>(role);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  SessionTableCompanion toCompanion(bool nullToAbsent) {
    return SessionTableCompanion(
      id: Value(id),
      jwtToken: Value(jwtToken),
      username: Value(username),
      role: Value(role),
      expiresAt: Value(expiresAt),
    );
  }

  factory SessionTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionTableData(
      id: serializer.fromJson<int>(json['id']),
      jwtToken: serializer.fromJson<String>(json['jwtToken']),
      username: serializer.fromJson<String>(json['username']),
      role: serializer.fromJson<String>(json['role']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jwtToken': serializer.toJson<String>(jwtToken),
      'username': serializer.toJson<String>(username),
      'role': serializer.toJson<String>(role),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  SessionTableData copyWith(
          {int? id,
          String? jwtToken,
          String? username,
          String? role,
          DateTime? expiresAt}) =>
      SessionTableData(
        id: id ?? this.id,
        jwtToken: jwtToken ?? this.jwtToken,
        username: username ?? this.username,
        role: role ?? this.role,
        expiresAt: expiresAt ?? this.expiresAt,
      );
  SessionTableData copyWithCompanion(SessionTableCompanion data) {
    return SessionTableData(
      id: data.id.present ? data.id.value : this.id,
      jwtToken: data.jwtToken.present ? data.jwtToken.value : this.jwtToken,
      username: data.username.present ? data.username.value : this.username,
      role: data.role.present ? data.role.value : this.role,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionTableData(')
          ..write('id: $id, ')
          ..write('jwtToken: $jwtToken, ')
          ..write('username: $username, ')
          ..write('role: $role, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, jwtToken, username, role, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionTableData &&
          other.id == this.id &&
          other.jwtToken == this.jwtToken &&
          other.username == this.username &&
          other.role == this.role &&
          other.expiresAt == this.expiresAt);
}

class SessionTableCompanion extends UpdateCompanion<SessionTableData> {
  final Value<int> id;
  final Value<String> jwtToken;
  final Value<String> username;
  final Value<String> role;
  final Value<DateTime> expiresAt;
  const SessionTableCompanion({
    this.id = const Value.absent(),
    this.jwtToken = const Value.absent(),
    this.username = const Value.absent(),
    this.role = const Value.absent(),
    this.expiresAt = const Value.absent(),
  });
  SessionTableCompanion.insert({
    this.id = const Value.absent(),
    required String jwtToken,
    required String username,
    required String role,
    required DateTime expiresAt,
  })  : jwtToken = Value(jwtToken),
        username = Value(username),
        role = Value(role),
        expiresAt = Value(expiresAt);
  static Insertable<SessionTableData> custom({
    Expression<int>? id,
    Expression<String>? jwtToken,
    Expression<String>? username,
    Expression<String>? role,
    Expression<DateTime>? expiresAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jwtToken != null) 'jwt_token': jwtToken,
      if (username != null) 'username': username,
      if (role != null) 'role': role,
      if (expiresAt != null) 'expires_at': expiresAt,
    });
  }

  SessionTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? jwtToken,
      Value<String>? username,
      Value<String>? role,
      Value<DateTime>? expiresAt}) {
    return SessionTableCompanion(
      id: id ?? this.id,
      jwtToken: jwtToken ?? this.jwtToken,
      username: username ?? this.username,
      role: role ?? this.role,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jwtToken.present) {
      map['jwt_token'] = Variable<String>(jwtToken.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionTableCompanion(')
          ..write('id: $id, ')
          ..write('jwtToken: $jwtToken, ')
          ..write('username: $username, ')
          ..write('role: $role, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PoolsTableTable poolsTable = $PoolsTableTable(this);
  late final $StreamsTableTable streamsTable = $StreamsTableTable(this);
  late final $ClaimsTableTable claimsTable = $ClaimsTableTable(this);
  late final $OfflineActionsTableTable offlineActionsTable =
      $OfflineActionsTableTable(this);
  late final $SessionTableTable sessionTable = $SessionTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        poolsTable,
        streamsTable,
        claimsTable,
        offlineActionsTable,
        sessionTable
      ];
}

typedef $$PoolsTableTableCreateCompanionBuilder = PoolsTableCompanion Function({
  required String id,
  required String repoFullName,
  required double fundingAmount,
  required double baseRate,
  required double totalDripped,
  required String status,
  Value<int> rowid,
});
typedef $$PoolsTableTableUpdateCompanionBuilder = PoolsTableCompanion Function({
  Value<String> id,
  Value<String> repoFullName,
  Value<double> fundingAmount,
  Value<double> baseRate,
  Value<double> totalDripped,
  Value<String> status,
  Value<int> rowid,
});

class $$PoolsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PoolsTableTable> {
  $$PoolsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repoFullName => $composableBuilder(
      column: $table.repoFullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fundingAmount => $composableBuilder(
      column: $table.fundingAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get baseRate => $composableBuilder(
      column: $table.baseRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalDripped => $composableBuilder(
      column: $table.totalDripped, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$PoolsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PoolsTableTable> {
  $$PoolsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repoFullName => $composableBuilder(
      column: $table.repoFullName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fundingAmount => $composableBuilder(
      column: $table.fundingAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get baseRate => $composableBuilder(
      column: $table.baseRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalDripped => $composableBuilder(
      column: $table.totalDripped,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$PoolsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PoolsTableTable> {
  $$PoolsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get repoFullName => $composableBuilder(
      column: $table.repoFullName, builder: (column) => column);

  GeneratedColumn<double> get fundingAmount => $composableBuilder(
      column: $table.fundingAmount, builder: (column) => column);

  GeneratedColumn<double> get baseRate =>
      $composableBuilder(column: $table.baseRate, builder: (column) => column);

  GeneratedColumn<double> get totalDripped => $composableBuilder(
      column: $table.totalDripped, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$PoolsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PoolsTableTable,
    PoolsTableData,
    $$PoolsTableTableFilterComposer,
    $$PoolsTableTableOrderingComposer,
    $$PoolsTableTableAnnotationComposer,
    $$PoolsTableTableCreateCompanionBuilder,
    $$PoolsTableTableUpdateCompanionBuilder,
    (
      PoolsTableData,
      BaseReferences<_$AppDatabase, $PoolsTableTable, PoolsTableData>
    ),
    PoolsTableData,
    PrefetchHooks Function()> {
  $$PoolsTableTableTableManager(_$AppDatabase db, $PoolsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PoolsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PoolsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PoolsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> repoFullName = const Value.absent(),
            Value<double> fundingAmount = const Value.absent(),
            Value<double> baseRate = const Value.absent(),
            Value<double> totalDripped = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PoolsTableCompanion(
            id: id,
            repoFullName: repoFullName,
            fundingAmount: fundingAmount,
            baseRate: baseRate,
            totalDripped: totalDripped,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String repoFullName,
            required double fundingAmount,
            required double baseRate,
            required double totalDripped,
            required String status,
            Value<int> rowid = const Value.absent(),
          }) =>
              PoolsTableCompanion.insert(
            id: id,
            repoFullName: repoFullName,
            fundingAmount: fundingAmount,
            baseRate: baseRate,
            totalDripped: totalDripped,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PoolsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PoolsTableTable,
    PoolsTableData,
    $$PoolsTableTableFilterComposer,
    $$PoolsTableTableOrderingComposer,
    $$PoolsTableTableAnnotationComposer,
    $$PoolsTableTableCreateCompanionBuilder,
    $$PoolsTableTableUpdateCompanionBuilder,
    (
      PoolsTableData,
      BaseReferences<_$AppDatabase, $PoolsTableTable, PoolsTableData>
    ),
    PoolsTableData,
    PrefetchHooks Function()>;
typedef $$StreamsTableTableCreateCompanionBuilder = StreamsTableCompanion
    Function({
  required String id,
  required String poolId,
  required String authorUsername,
  required String filePath,
  required int characterCount,
  required String locale,
  required double accumulated,
  required double flowRatePerSecond,
  required double approvalRatio,
  required String status,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$StreamsTableTableUpdateCompanionBuilder = StreamsTableCompanion
    Function({
  Value<String> id,
  Value<String> poolId,
  Value<String> authorUsername,
  Value<String> filePath,
  Value<int> characterCount,
  Value<String> locale,
  Value<double> accumulated,
  Value<double> flowRatePerSecond,
  Value<double> approvalRatio,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$StreamsTableTableFilterComposer
    extends Composer<_$AppDatabase, $StreamsTableTable> {
  $$StreamsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poolId => $composableBuilder(
      column: $table.poolId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorUsername => $composableBuilder(
      column: $table.authorUsername,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get characterCount => $composableBuilder(
      column: $table.characterCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locale => $composableBuilder(
      column: $table.locale, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accumulated => $composableBuilder(
      column: $table.accumulated, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get flowRatePerSecond => $composableBuilder(
      column: $table.flowRatePerSecond,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get approvalRatio => $composableBuilder(
      column: $table.approvalRatio, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$StreamsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $StreamsTableTable> {
  $$StreamsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poolId => $composableBuilder(
      column: $table.poolId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorUsername => $composableBuilder(
      column: $table.authorUsername,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get characterCount => $composableBuilder(
      column: $table.characterCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locale => $composableBuilder(
      column: $table.locale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accumulated => $composableBuilder(
      column: $table.accumulated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get flowRatePerSecond => $composableBuilder(
      column: $table.flowRatePerSecond,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get approvalRatio => $composableBuilder(
      column: $table.approvalRatio,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$StreamsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreamsTableTable> {
  $$StreamsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get poolId =>
      $composableBuilder(column: $table.poolId, builder: (column) => column);

  GeneratedColumn<String> get authorUsername => $composableBuilder(
      column: $table.authorUsername, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get characterCount => $composableBuilder(
      column: $table.characterCount, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<double> get accumulated => $composableBuilder(
      column: $table.accumulated, builder: (column) => column);

  GeneratedColumn<double> get flowRatePerSecond => $composableBuilder(
      column: $table.flowRatePerSecond, builder: (column) => column);

  GeneratedColumn<double> get approvalRatio => $composableBuilder(
      column: $table.approvalRatio, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StreamsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StreamsTableTable,
    StreamsTableData,
    $$StreamsTableTableFilterComposer,
    $$StreamsTableTableOrderingComposer,
    $$StreamsTableTableAnnotationComposer,
    $$StreamsTableTableCreateCompanionBuilder,
    $$StreamsTableTableUpdateCompanionBuilder,
    (
      StreamsTableData,
      BaseReferences<_$AppDatabase, $StreamsTableTable, StreamsTableData>
    ),
    StreamsTableData,
    PrefetchHooks Function()> {
  $$StreamsTableTableTableManager(_$AppDatabase db, $StreamsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreamsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreamsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreamsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> poolId = const Value.absent(),
            Value<String> authorUsername = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<int> characterCount = const Value.absent(),
            Value<String> locale = const Value.absent(),
            Value<double> accumulated = const Value.absent(),
            Value<double> flowRatePerSecond = const Value.absent(),
            Value<double> approvalRatio = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StreamsTableCompanion(
            id: id,
            poolId: poolId,
            authorUsername: authorUsername,
            filePath: filePath,
            characterCount: characterCount,
            locale: locale,
            accumulated: accumulated,
            flowRatePerSecond: flowRatePerSecond,
            approvalRatio: approvalRatio,
            status: status,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String poolId,
            required String authorUsername,
            required String filePath,
            required int characterCount,
            required String locale,
            required double accumulated,
            required double flowRatePerSecond,
            required double approvalRatio,
            required String status,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              StreamsTableCompanion.insert(
            id: id,
            poolId: poolId,
            authorUsername: authorUsername,
            filePath: filePath,
            characterCount: characterCount,
            locale: locale,
            accumulated: accumulated,
            flowRatePerSecond: flowRatePerSecond,
            approvalRatio: approvalRatio,
            status: status,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StreamsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StreamsTableTable,
    StreamsTableData,
    $$StreamsTableTableFilterComposer,
    $$StreamsTableTableOrderingComposer,
    $$StreamsTableTableAnnotationComposer,
    $$StreamsTableTableCreateCompanionBuilder,
    $$StreamsTableTableUpdateCompanionBuilder,
    (
      StreamsTableData,
      BaseReferences<_$AppDatabase, $StreamsTableTable, StreamsTableData>
    ),
    StreamsTableData,
    PrefetchHooks Function()>;
typedef $$ClaimsTableTableCreateCompanionBuilder = ClaimsTableCompanion
    Function({
  required String id,
  required String streamId,
  required String userId,
  required double amount,
  required String status,
  Value<String?> providerTxRef,
  required DateTime claimedAt,
  Value<int> rowid,
});
typedef $$ClaimsTableTableUpdateCompanionBuilder = ClaimsTableCompanion
    Function({
  Value<String> id,
  Value<String> streamId,
  Value<String> userId,
  Value<double> amount,
  Value<String> status,
  Value<String?> providerTxRef,
  Value<DateTime> claimedAt,
  Value<int> rowid,
});

class $$ClaimsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ClaimsTableTable> {
  $$ClaimsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get streamId => $composableBuilder(
      column: $table.streamId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get providerTxRef => $composableBuilder(
      column: $table.providerTxRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get claimedAt => $composableBuilder(
      column: $table.claimedAt, builder: (column) => ColumnFilters(column));
}

class $$ClaimsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ClaimsTableTable> {
  $$ClaimsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get streamId => $composableBuilder(
      column: $table.streamId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get providerTxRef => $composableBuilder(
      column: $table.providerTxRef,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get claimedAt => $composableBuilder(
      column: $table.claimedAt, builder: (column) => ColumnOrderings(column));
}

class $$ClaimsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClaimsTableTable> {
  $$ClaimsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get streamId =>
      $composableBuilder(column: $table.streamId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get providerTxRef => $composableBuilder(
      column: $table.providerTxRef, builder: (column) => column);

  GeneratedColumn<DateTime> get claimedAt =>
      $composableBuilder(column: $table.claimedAt, builder: (column) => column);
}

class $$ClaimsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClaimsTableTable,
    ClaimsTableData,
    $$ClaimsTableTableFilterComposer,
    $$ClaimsTableTableOrderingComposer,
    $$ClaimsTableTableAnnotationComposer,
    $$ClaimsTableTableCreateCompanionBuilder,
    $$ClaimsTableTableUpdateCompanionBuilder,
    (
      ClaimsTableData,
      BaseReferences<_$AppDatabase, $ClaimsTableTable, ClaimsTableData>
    ),
    ClaimsTableData,
    PrefetchHooks Function()> {
  $$ClaimsTableTableTableManager(_$AppDatabase db, $ClaimsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClaimsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClaimsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClaimsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> streamId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> providerTxRef = const Value.absent(),
            Value<DateTime> claimedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClaimsTableCompanion(
            id: id,
            streamId: streamId,
            userId: userId,
            amount: amount,
            status: status,
            providerTxRef: providerTxRef,
            claimedAt: claimedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String streamId,
            required String userId,
            required double amount,
            required String status,
            Value<String?> providerTxRef = const Value.absent(),
            required DateTime claimedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ClaimsTableCompanion.insert(
            id: id,
            streamId: streamId,
            userId: userId,
            amount: amount,
            status: status,
            providerTxRef: providerTxRef,
            claimedAt: claimedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ClaimsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClaimsTableTable,
    ClaimsTableData,
    $$ClaimsTableTableFilterComposer,
    $$ClaimsTableTableOrderingComposer,
    $$ClaimsTableTableAnnotationComposer,
    $$ClaimsTableTableCreateCompanionBuilder,
    $$ClaimsTableTableUpdateCompanionBuilder,
    (
      ClaimsTableData,
      BaseReferences<_$AppDatabase, $ClaimsTableTable, ClaimsTableData>
    ),
    ClaimsTableData,
    PrefetchHooks Function()>;
typedef $$OfflineActionsTableTableCreateCompanionBuilder
    = OfflineActionsTableCompanion Function({
  Value<int> id,
  required String actionType,
  required String payload,
  Value<String> status,
  Value<int> retryCount,
  required DateTime createdAt,
});
typedef $$OfflineActionsTableTableUpdateCompanionBuilder
    = OfflineActionsTableCompanion Function({
  Value<int> id,
  Value<String> actionType,
  Value<String> payload,
  Value<String> status,
  Value<int> retryCount,
  Value<DateTime> createdAt,
});

class $$OfflineActionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineActionsTableTable> {
  $$OfflineActionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OfflineActionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineActionsTableTable> {
  $$OfflineActionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OfflineActionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineActionsTableTable> {
  $$OfflineActionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OfflineActionsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OfflineActionsTableTable,
    OfflineActionsTableData,
    $$OfflineActionsTableTableFilterComposer,
    $$OfflineActionsTableTableOrderingComposer,
    $$OfflineActionsTableTableAnnotationComposer,
    $$OfflineActionsTableTableCreateCompanionBuilder,
    $$OfflineActionsTableTableUpdateCompanionBuilder,
    (
      OfflineActionsTableData,
      BaseReferences<_$AppDatabase, $OfflineActionsTableTable,
          OfflineActionsTableData>
    ),
    OfflineActionsTableData,
    PrefetchHooks Function()> {
  $$OfflineActionsTableTableTableManager(
      _$AppDatabase db, $OfflineActionsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineActionsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineActionsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineActionsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> actionType = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OfflineActionsTableCompanion(
            id: id,
            actionType: actionType,
            payload: payload,
            status: status,
            retryCount: retryCount,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String actionType,
            required String payload,
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            required DateTime createdAt,
          }) =>
              OfflineActionsTableCompanion.insert(
            id: id,
            actionType: actionType,
            payload: payload,
            status: status,
            retryCount: retryCount,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OfflineActionsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OfflineActionsTableTable,
    OfflineActionsTableData,
    $$OfflineActionsTableTableFilterComposer,
    $$OfflineActionsTableTableOrderingComposer,
    $$OfflineActionsTableTableAnnotationComposer,
    $$OfflineActionsTableTableCreateCompanionBuilder,
    $$OfflineActionsTableTableUpdateCompanionBuilder,
    (
      OfflineActionsTableData,
      BaseReferences<_$AppDatabase, $OfflineActionsTableTable,
          OfflineActionsTableData>
    ),
    OfflineActionsTableData,
    PrefetchHooks Function()>;
typedef $$SessionTableTableCreateCompanionBuilder = SessionTableCompanion
    Function({
  Value<int> id,
  required String jwtToken,
  required String username,
  required String role,
  required DateTime expiresAt,
});
typedef $$SessionTableTableUpdateCompanionBuilder = SessionTableCompanion
    Function({
  Value<int> id,
  Value<String> jwtToken,
  Value<String> username,
  Value<String> role,
  Value<DateTime> expiresAt,
});

class $$SessionTableTableFilterComposer
    extends Composer<_$AppDatabase, $SessionTableTable> {
  $$SessionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jwtToken => $composableBuilder(
      column: $table.jwtToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));
}

class $$SessionTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionTableTable> {
  $$SessionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jwtToken => $composableBuilder(
      column: $table.jwtToken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));
}

class $$SessionTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionTableTable> {
  $$SessionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jwtToken =>
      $composableBuilder(column: $table.jwtToken, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$SessionTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionTableTable,
    SessionTableData,
    $$SessionTableTableFilterComposer,
    $$SessionTableTableOrderingComposer,
    $$SessionTableTableAnnotationComposer,
    $$SessionTableTableCreateCompanionBuilder,
    $$SessionTableTableUpdateCompanionBuilder,
    (
      SessionTableData,
      BaseReferences<_$AppDatabase, $SessionTableTable, SessionTableData>
    ),
    SessionTableData,
    PrefetchHooks Function()> {
  $$SessionTableTableTableManager(_$AppDatabase db, $SessionTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> jwtToken = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<DateTime> expiresAt = const Value.absent(),
          }) =>
              SessionTableCompanion(
            id: id,
            jwtToken: jwtToken,
            username: username,
            role: role,
            expiresAt: expiresAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String jwtToken,
            required String username,
            required String role,
            required DateTime expiresAt,
          }) =>
              SessionTableCompanion.insert(
            id: id,
            jwtToken: jwtToken,
            username: username,
            role: role,
            expiresAt: expiresAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SessionTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionTableTable,
    SessionTableData,
    $$SessionTableTableFilterComposer,
    $$SessionTableTableOrderingComposer,
    $$SessionTableTableAnnotationComposer,
    $$SessionTableTableCreateCompanionBuilder,
    $$SessionTableTableUpdateCompanionBuilder,
    (
      SessionTableData,
      BaseReferences<_$AppDatabase, $SessionTableTable, SessionTableData>
    ),
    SessionTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PoolsTableTableTableManager get poolsTable =>
      $$PoolsTableTableTableManager(_db, _db.poolsTable);
  $$StreamsTableTableTableManager get streamsTable =>
      $$StreamsTableTableTableManager(_db, _db.streamsTable);
  $$ClaimsTableTableTableManager get claimsTable =>
      $$ClaimsTableTableTableManager(_db, _db.claimsTable);
  $$OfflineActionsTableTableTableManager get offlineActionsTable =>
      $$OfflineActionsTableTableTableManager(_db, _db.offlineActionsTable);
  $$SessionTableTableTableManager get sessionTable =>
      $$SessionTableTableTableManager(_db, _db.sessionTable);
}
