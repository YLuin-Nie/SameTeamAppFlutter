// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'completed_chore_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CompletedChore _$CompletedChoreFromJson(Map<String, dynamic> json) {
  return _CompletedChore.fromJson(json);
}

/// @nodoc
mixin _$CompletedChore {
  int get completedId => throw _privateConstructorUsedError;
  int get choreId => throw _privateConstructorUsedError;
  String get choreText => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  int? get assignedTo => throw _privateConstructorUsedError;
  String get dateAssigned => throw _privateConstructorUsedError;
  String get completionDate => throw _privateConstructorUsedError;

  /// Serializes this CompletedChore to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompletedChore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompletedChoreCopyWith<CompletedChore> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompletedChoreCopyWith<$Res> {
  factory $CompletedChoreCopyWith(
          CompletedChore value, $Res Function(CompletedChore) then) =
      _$CompletedChoreCopyWithImpl<$Res, CompletedChore>;
  @useResult
  $Res call(
      {int completedId,
      int choreId,
      String choreText,
      int points,
      int? assignedTo,
      String dateAssigned,
      String completionDate});
}

/// @nodoc
class _$CompletedChoreCopyWithImpl<$Res, $Val extends CompletedChore>
    implements $CompletedChoreCopyWith<$Res> {
  _$CompletedChoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompletedChore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completedId = null,
    Object? choreId = null,
    Object? choreText = null,
    Object? points = null,
    Object? assignedTo = freezed,
    Object? dateAssigned = null,
    Object? completionDate = null,
  }) {
    return _then(_value.copyWith(
      completedId: null == completedId
          ? _value.completedId
          : completedId // ignore: cast_nullable_to_non_nullable
              as int,
      choreId: null == choreId
          ? _value.choreId
          : choreId // ignore: cast_nullable_to_non_nullable
              as int,
      choreText: null == choreText
          ? _value.choreText
          : choreText // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      assignedTo: freezed == assignedTo
          ? _value.assignedTo
          : assignedTo // ignore: cast_nullable_to_non_nullable
              as int?,
      dateAssigned: null == dateAssigned
          ? _value.dateAssigned
          : dateAssigned // ignore: cast_nullable_to_non_nullable
              as String,
      completionDate: null == completionDate
          ? _value.completionDate
          : completionDate // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompletedChoreImplCopyWith<$Res>
    implements $CompletedChoreCopyWith<$Res> {
  factory _$$CompletedChoreImplCopyWith(_$CompletedChoreImpl value,
          $Res Function(_$CompletedChoreImpl) then) =
      __$$CompletedChoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int completedId,
      int choreId,
      String choreText,
      int points,
      int? assignedTo,
      String dateAssigned,
      String completionDate});
}

/// @nodoc
class __$$CompletedChoreImplCopyWithImpl<$Res>
    extends _$CompletedChoreCopyWithImpl<$Res, _$CompletedChoreImpl>
    implements _$$CompletedChoreImplCopyWith<$Res> {
  __$$CompletedChoreImplCopyWithImpl(
      _$CompletedChoreImpl _value, $Res Function(_$CompletedChoreImpl) _then)
      : super(_value, _then);

  /// Create a copy of CompletedChore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completedId = null,
    Object? choreId = null,
    Object? choreText = null,
    Object? points = null,
    Object? assignedTo = freezed,
    Object? dateAssigned = null,
    Object? completionDate = null,
  }) {
    return _then(_$CompletedChoreImpl(
      completedId: null == completedId
          ? _value.completedId
          : completedId // ignore: cast_nullable_to_non_nullable
              as int,
      choreId: null == choreId
          ? _value.choreId
          : choreId // ignore: cast_nullable_to_non_nullable
              as int,
      choreText: null == choreText
          ? _value.choreText
          : choreText // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      assignedTo: freezed == assignedTo
          ? _value.assignedTo
          : assignedTo // ignore: cast_nullable_to_non_nullable
              as int?,
      dateAssigned: null == dateAssigned
          ? _value.dateAssigned
          : dateAssigned // ignore: cast_nullable_to_non_nullable
              as String,
      completionDate: null == completionDate
          ? _value.completionDate
          : completionDate // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompletedChoreImpl implements _CompletedChore {
  const _$CompletedChoreImpl(
      {required this.completedId,
      required this.choreId,
      required this.choreText,
      required this.points,
      this.assignedTo,
      required this.dateAssigned,
      required this.completionDate});

  factory _$CompletedChoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompletedChoreImplFromJson(json);

  @override
  final int completedId;
  @override
  final int choreId;
  @override
  final String choreText;
  @override
  final int points;
  @override
  final int? assignedTo;
  @override
  final String dateAssigned;
  @override
  final String completionDate;

  @override
  String toString() {
    return 'CompletedChore(completedId: $completedId, choreId: $choreId, choreText: $choreText, points: $points, assignedTo: $assignedTo, dateAssigned: $dateAssigned, completionDate: $completionDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompletedChoreImpl &&
            (identical(other.completedId, completedId) ||
                other.completedId == completedId) &&
            (identical(other.choreId, choreId) || other.choreId == choreId) &&
            (identical(other.choreText, choreText) ||
                other.choreText == choreText) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.dateAssigned, dateAssigned) ||
                other.dateAssigned == dateAssigned) &&
            (identical(other.completionDate, completionDate) ||
                other.completionDate == completionDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, completedId, choreId, choreText,
      points, assignedTo, dateAssigned, completionDate);

  /// Create a copy of CompletedChore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompletedChoreImplCopyWith<_$CompletedChoreImpl> get copyWith =>
      __$$CompletedChoreImplCopyWithImpl<_$CompletedChoreImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompletedChoreImplToJson(
      this,
    );
  }
}

abstract class _CompletedChore implements CompletedChore {
  const factory _CompletedChore(
      {required final int completedId,
      required final int choreId,
      required final String choreText,
      required final int points,
      final int? assignedTo,
      required final String dateAssigned,
      required final String completionDate}) = _$CompletedChoreImpl;

  factory _CompletedChore.fromJson(Map<String, dynamic> json) =
      _$CompletedChoreImpl.fromJson;

  @override
  int get completedId;
  @override
  int get choreId;
  @override
  String get choreText;
  @override
  int get points;
  @override
  int? get assignedTo;
  @override
  String get dateAssigned;
  @override
  String get completionDate;

  /// Create a copy of CompletedChore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompletedChoreImplCopyWith<_$CompletedChoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
