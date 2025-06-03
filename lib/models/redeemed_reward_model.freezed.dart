// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'redeemed_reward_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RedeemedReward _$RedeemedRewardFromJson(Map<String, dynamic> json) {
  return _RedeemedReward.fromJson(json);
}

/// @nodoc
mixin _$RedeemedReward {
  int get redemptionId => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  int get rewardId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get pointsSpent => throw _privateConstructorUsedError;
  String get dateRedeemed => throw _privateConstructorUsedError;

  /// Serializes this RedeemedReward to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RedeemedReward
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RedeemedRewardCopyWith<RedeemedReward> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RedeemedRewardCopyWith<$Res> {
  factory $RedeemedRewardCopyWith(
          RedeemedReward value, $Res Function(RedeemedReward) then) =
      _$RedeemedRewardCopyWithImpl<$Res, RedeemedReward>;
  @useResult
  $Res call(
      {int redemptionId,
      int userId,
      int rewardId,
      String name,
      int pointsSpent,
      String dateRedeemed});
}

/// @nodoc
class _$RedeemedRewardCopyWithImpl<$Res, $Val extends RedeemedReward>
    implements $RedeemedRewardCopyWith<$Res> {
  _$RedeemedRewardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RedeemedReward
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? redemptionId = null,
    Object? userId = null,
    Object? rewardId = null,
    Object? name = null,
    Object? pointsSpent = null,
    Object? dateRedeemed = null,
  }) {
    return _then(_value.copyWith(
      redemptionId: null == redemptionId
          ? _value.redemptionId
          : redemptionId // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      rewardId: null == rewardId
          ? _value.rewardId
          : rewardId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      pointsSpent: null == pointsSpent
          ? _value.pointsSpent
          : pointsSpent // ignore: cast_nullable_to_non_nullable
              as int,
      dateRedeemed: null == dateRedeemed
          ? _value.dateRedeemed
          : dateRedeemed // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RedeemedRewardImplCopyWith<$Res>
    implements $RedeemedRewardCopyWith<$Res> {
  factory _$$RedeemedRewardImplCopyWith(_$RedeemedRewardImpl value,
          $Res Function(_$RedeemedRewardImpl) then) =
      __$$RedeemedRewardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int redemptionId,
      int userId,
      int rewardId,
      String name,
      int pointsSpent,
      String dateRedeemed});
}

/// @nodoc
class __$$RedeemedRewardImplCopyWithImpl<$Res>
    extends _$RedeemedRewardCopyWithImpl<$Res, _$RedeemedRewardImpl>
    implements _$$RedeemedRewardImplCopyWith<$Res> {
  __$$RedeemedRewardImplCopyWithImpl(
      _$RedeemedRewardImpl _value, $Res Function(_$RedeemedRewardImpl) _then)
      : super(_value, _then);

  /// Create a copy of RedeemedReward
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? redemptionId = null,
    Object? userId = null,
    Object? rewardId = null,
    Object? name = null,
    Object? pointsSpent = null,
    Object? dateRedeemed = null,
  }) {
    return _then(_$RedeemedRewardImpl(
      redemptionId: null == redemptionId
          ? _value.redemptionId
          : redemptionId // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      rewardId: null == rewardId
          ? _value.rewardId
          : rewardId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      pointsSpent: null == pointsSpent
          ? _value.pointsSpent
          : pointsSpent // ignore: cast_nullable_to_non_nullable
              as int,
      dateRedeemed: null == dateRedeemed
          ? _value.dateRedeemed
          : dateRedeemed // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RedeemedRewardImpl implements _RedeemedReward {
  const _$RedeemedRewardImpl(
      {required this.redemptionId,
      required this.userId,
      required this.rewardId,
      required this.name,
      required this.pointsSpent,
      required this.dateRedeemed});

  factory _$RedeemedRewardImpl.fromJson(Map<String, dynamic> json) =>
      _$$RedeemedRewardImplFromJson(json);

  @override
  final int redemptionId;
  @override
  final int userId;
  @override
  final int rewardId;
  @override
  final String name;
  @override
  final int pointsSpent;
  @override
  final String dateRedeemed;

  @override
  String toString() {
    return 'RedeemedReward(redemptionId: $redemptionId, userId: $userId, rewardId: $rewardId, name: $name, pointsSpent: $pointsSpent, dateRedeemed: $dateRedeemed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RedeemedRewardImpl &&
            (identical(other.redemptionId, redemptionId) ||
                other.redemptionId == redemptionId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.rewardId, rewardId) ||
                other.rewardId == rewardId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.pointsSpent, pointsSpent) ||
                other.pointsSpent == pointsSpent) &&
            (identical(other.dateRedeemed, dateRedeemed) ||
                other.dateRedeemed == dateRedeemed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, redemptionId, userId, rewardId,
      name, pointsSpent, dateRedeemed);

  /// Create a copy of RedeemedReward
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RedeemedRewardImplCopyWith<_$RedeemedRewardImpl> get copyWith =>
      __$$RedeemedRewardImplCopyWithImpl<_$RedeemedRewardImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RedeemedRewardImplToJson(
      this,
    );
  }
}

abstract class _RedeemedReward implements RedeemedReward {
  const factory _RedeemedReward(
      {required final int redemptionId,
      required final int userId,
      required final int rewardId,
      required final String name,
      required final int pointsSpent,
      required final String dateRedeemed}) = _$RedeemedRewardImpl;

  factory _RedeemedReward.fromJson(Map<String, dynamic> json) =
      _$RedeemedRewardImpl.fromJson;

  @override
  int get redemptionId;
  @override
  int get userId;
  @override
  int get rewardId;
  @override
  String get name;
  @override
  int get pointsSpent;
  @override
  String get dateRedeemed;

  /// Create a copy of RedeemedReward
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RedeemedRewardImplCopyWith<_$RedeemedRewardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
