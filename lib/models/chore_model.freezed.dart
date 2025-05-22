// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chore_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Chore _$ChoreFromJson(Map<String, dynamic> json) {
  return _Chore.fromJson(json);
}

/// @nodoc
mixin _$Chore {
  int get choreId => throw _privateConstructorUsedError;
  String get choreText => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  int get assignedTo => throw _privateConstructorUsedError;
  String get dateAssigned => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;

  /// Serializes this Chore to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Chore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChoreCopyWith<Chore> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChoreCopyWith<$Res> {
  factory $ChoreCopyWith(Chore value, $Res Function(Chore) then) =
      _$ChoreCopyWithImpl<$Res, Chore>;
  @useResult
  $Res call(
      {int choreId,
      String choreText,
      int points,
      int assignedTo,
      String dateAssigned,
      bool completed});
}

/// @nodoc
class _$ChoreCopyWithImpl<$Res, $Val extends Chore>
    implements $ChoreCopyWith<$Res> {
  _$ChoreCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Chore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? choreId = null,
    Object? choreText = null,
    Object? points = null,
    Object? assignedTo = null,
    Object? dateAssigned = null,
    Object? completed = null,
  }) {
    return _then(_value.copyWith(
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
      assignedTo: null == assignedTo
          ? _value.assignedTo
          : assignedTo // ignore: cast_nullable_to_non_nullable
              as int,
      dateAssigned: null == dateAssigned
          ? _value.dateAssigned
          : dateAssigned // ignore: cast_nullable_to_non_nullable
              as String,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChoreImplCopyWith<$Res> implements $ChoreCopyWith<$Res> {
  factory _$$ChoreImplCopyWith(
          _$ChoreImpl value, $Res Function(_$ChoreImpl) then) =
      __$$ChoreImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int choreId,
      String choreText,
      int points,
      int assignedTo,
      String dateAssigned,
      bool completed});
}

/// @nodoc
class __$$ChoreImplCopyWithImpl<$Res>
    extends _$ChoreCopyWithImpl<$Res, _$ChoreImpl>
    implements _$$ChoreImplCopyWith<$Res> {
  __$$ChoreImplCopyWithImpl(
      _$ChoreImpl _value, $Res Function(_$ChoreImpl) _then)
      : super(_value, _then);

  /// Create a copy of Chore
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? choreId = null,
    Object? choreText = null,
    Object? points = null,
    Object? assignedTo = null,
    Object? dateAssigned = null,
    Object? completed = null,
  }) {
    return _then(_$ChoreImpl(
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
      assignedTo: null == assignedTo
          ? _value.assignedTo
          : assignedTo // ignore: cast_nullable_to_non_nullable
              as int,
      dateAssigned: null == dateAssigned
          ? _value.dateAssigned
          : dateAssigned // ignore: cast_nullable_to_non_nullable
              as String,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChoreImpl implements _Chore {
  const _$ChoreImpl(
      {required this.choreId,
      required this.choreText,
      required this.points,
      required this.assignedTo,
      required this.dateAssigned,
      required this.completed});

  factory _$ChoreImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChoreImplFromJson(json);

  @override
  final int choreId;
  @override
  final String choreText;
  @override
  final int points;
  @override
  final int assignedTo;
  @override
  final String dateAssigned;
  @override
  final bool completed;

  @override
  String toString() {
    return 'Chore(choreId: $choreId, choreText: $choreText, points: $points, assignedTo: $assignedTo, dateAssigned: $dateAssigned, completed: $completed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChoreImpl &&
            (identical(other.choreId, choreId) || other.choreId == choreId) &&
            (identical(other.choreText, choreText) ||
                other.choreText == choreText) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.dateAssigned, dateAssigned) ||
                other.dateAssigned == dateAssigned) &&
            (identical(other.completed, completed) ||
                other.completed == completed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, choreId, choreText, points,
      assignedTo, dateAssigned, completed);

  /// Create a copy of Chore
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChoreImplCopyWith<_$ChoreImpl> get copyWith =>
      __$$ChoreImplCopyWithImpl<_$ChoreImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChoreImplToJson(
      this,
    );
  }
}

abstract class _Chore implements Chore {
  const factory _Chore(
      {required final int choreId,
      required final String choreText,
      required final int points,
      required final int assignedTo,
      required final String dateAssigned,
      required final bool completed}) = _$ChoreImpl;

  factory _Chore.fromJson(Map<String, dynamic> json) = _$ChoreImpl.fromJson;

  @override
  int get choreId;
  @override
  String get choreText;
  @override
  int get points;
  @override
  int get assignedTo;
  @override
  String get dateAssigned;
  @override
  bool get completed;

  /// Create a copy of Chore
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChoreImplCopyWith<_$ChoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
