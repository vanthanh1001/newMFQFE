// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Challenge _$ChallengeFromJson(Map<String, dynamic> json) {
  return _Challenge.fromJson(json);
}

/// @nodoc
mixin _$Challenge {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  int get participantCount => throw _privateConstructorUsedError;
  String? get rewardDescription => throw _privateConstructorUsedError;
  int? get rewardPoints => throw _privateConstructorUsedError;
  bool get hasJoined => throw _privateConstructorUsedError;
  int get totalTasks => throw _privateConstructorUsedError;
  int get completedTasks => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChallengeCopyWith<Challenge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeCopyWith<$Res> {
  factory $ChallengeCopyWith(Challenge value, $Res Function(Challenge) then) =
      _$ChallengeCopyWithImpl<$Res, Challenge>;
  @useResult
  $Res call(
      {int id,
      String name,
      String description,
      DateTime startDate,
      DateTime endDate,
      int participantCount,
      String? rewardDescription,
      int? rewardPoints,
      bool hasJoined,
      int totalTasks,
      int completedTasks});
}

/// @nodoc
class _$ChallengeCopyWithImpl<$Res, $Val extends Challenge>
    implements $ChallengeCopyWith<$Res> {
  _$ChallengeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? participantCount = null,
    Object? rewardDescription = freezed,
    Object? rewardPoints = freezed,
    Object? hasJoined = null,
    Object? totalTasks = null,
    Object? completedTasks = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      participantCount: null == participantCount
          ? _value.participantCount
          : participantCount // ignore: cast_nullable_to_non_nullable
              as int,
      rewardDescription: freezed == rewardDescription
          ? _value.rewardDescription
          : rewardDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      rewardPoints: freezed == rewardPoints
          ? _value.rewardPoints
          : rewardPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      hasJoined: null == hasJoined
          ? _value.hasJoined
          : hasJoined // ignore: cast_nullable_to_non_nullable
              as bool,
      totalTasks: null == totalTasks
          ? _value.totalTasks
          : totalTasks // ignore: cast_nullable_to_non_nullable
              as int,
      completedTasks: null == completedTasks
          ? _value.completedTasks
          : completedTasks // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeImplCopyWith<$Res>
    implements $ChallengeCopyWith<$Res> {
  factory _$$ChallengeImplCopyWith(
          _$ChallengeImpl value, $Res Function(_$ChallengeImpl) then) =
      __$$ChallengeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String description,
      DateTime startDate,
      DateTime endDate,
      int participantCount,
      String? rewardDescription,
      int? rewardPoints,
      bool hasJoined,
      int totalTasks,
      int completedTasks});
}

/// @nodoc
class __$$ChallengeImplCopyWithImpl<$Res>
    extends _$ChallengeCopyWithImpl<$Res, _$ChallengeImpl>
    implements _$$ChallengeImplCopyWith<$Res> {
  __$$ChallengeImplCopyWithImpl(
      _$ChallengeImpl _value, $Res Function(_$ChallengeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? participantCount = null,
    Object? rewardDescription = freezed,
    Object? rewardPoints = freezed,
    Object? hasJoined = null,
    Object? totalTasks = null,
    Object? completedTasks = null,
  }) {
    return _then(_$ChallengeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      participantCount: null == participantCount
          ? _value.participantCount
          : participantCount // ignore: cast_nullable_to_non_nullable
              as int,
      rewardDescription: freezed == rewardDescription
          ? _value.rewardDescription
          : rewardDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      rewardPoints: freezed == rewardPoints
          ? _value.rewardPoints
          : rewardPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      hasJoined: null == hasJoined
          ? _value.hasJoined
          : hasJoined // ignore: cast_nullable_to_non_nullable
              as bool,
      totalTasks: null == totalTasks
          ? _value.totalTasks
          : totalTasks // ignore: cast_nullable_to_non_nullable
              as int,
      completedTasks: null == completedTasks
          ? _value.completedTasks
          : completedTasks // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeImpl extends _Challenge with DiagnosticableTreeMixin {
  const _$ChallengeImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.startDate,
      required this.endDate,
      this.participantCount = 0,
      this.rewardDescription,
      this.rewardPoints,
      this.hasJoined = false,
      this.totalTasks = 0,
      this.completedTasks = 0})
      : super._();

  factory _$ChallengeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String description;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  @JsonKey()
  final int participantCount;
  @override
  final String? rewardDescription;
  @override
  final int? rewardPoints;
  @override
  @JsonKey()
  final bool hasJoined;
  @override
  @JsonKey()
  final int totalTasks;
  @override
  @JsonKey()
  final int completedTasks;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Challenge(id: $id, name: $name, description: $description, startDate: $startDate, endDate: $endDate, participantCount: $participantCount, rewardDescription: $rewardDescription, rewardPoints: $rewardPoints, hasJoined: $hasJoined, totalTasks: $totalTasks, completedTasks: $completedTasks)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Challenge'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('startDate', startDate))
      ..add(DiagnosticsProperty('endDate', endDate))
      ..add(DiagnosticsProperty('participantCount', participantCount))
      ..add(DiagnosticsProperty('rewardDescription', rewardDescription))
      ..add(DiagnosticsProperty('rewardPoints', rewardPoints))
      ..add(DiagnosticsProperty('hasJoined', hasJoined))
      ..add(DiagnosticsProperty('totalTasks', totalTasks))
      ..add(DiagnosticsProperty('completedTasks', completedTasks));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.participantCount, participantCount) ||
                other.participantCount == participantCount) &&
            (identical(other.rewardDescription, rewardDescription) ||
                other.rewardDescription == rewardDescription) &&
            (identical(other.rewardPoints, rewardPoints) ||
                other.rewardPoints == rewardPoints) &&
            (identical(other.hasJoined, hasJoined) ||
                other.hasJoined == hasJoined) &&
            (identical(other.totalTasks, totalTasks) ||
                other.totalTasks == totalTasks) &&
            (identical(other.completedTasks, completedTasks) ||
                other.completedTasks == completedTasks));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      startDate,
      endDate,
      participantCount,
      rewardDescription,
      rewardPoints,
      hasJoined,
      totalTasks,
      completedTasks);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeImplCopyWith<_$ChallengeImpl> get copyWith =>
      __$$ChallengeImplCopyWithImpl<_$ChallengeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeImplToJson(
      this,
    );
  }
}

abstract class _Challenge extends Challenge {
  const factory _Challenge(
      {required final int id,
      required final String name,
      required final String description,
      required final DateTime startDate,
      required final DateTime endDate,
      final int participantCount,
      final String? rewardDescription,
      final int? rewardPoints,
      final bool hasJoined,
      final int totalTasks,
      final int completedTasks}) = _$ChallengeImpl;
  const _Challenge._() : super._();

  factory _Challenge.fromJson(Map<String, dynamic> json) =
      _$ChallengeImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get description;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  int get participantCount;
  @override
  String? get rewardDescription;
  @override
  int? get rewardPoints;
  @override
  bool get hasJoined;
  @override
  int get totalTasks;
  @override
  int get completedTasks;
  @override
  @JsonKey(ignore: true)
  _$$ChallengeImplCopyWith<_$ChallengeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
