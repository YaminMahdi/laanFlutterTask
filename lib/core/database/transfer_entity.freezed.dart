// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transfer_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransferEntity {

 String get id; String get fileName; String get originalName; String get transferType; String get status; int get bytesTransferred; int get totalBytes; int get createdAt; String? get fileUrl; String? get localPath; int get speedBytesPerSecond; String? get errorMessage; int? get completedAt; int? get fileId;
/// Create a copy of TransferEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferEntityCopyWith<TransferEntity> get copyWith => _$TransferEntityCopyWithImpl<TransferEntity>(this as TransferEntity, _$identity);

  /// Serializes this TransferEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TransferEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferEntity&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fileName, _this.fileName) || other.fileName == _this.fileName)&&(identical(other.originalName, _this.originalName) || other.originalName == _this.originalName)&&(identical(other.transferType, _this.transferType) || other.transferType == _this.transferType)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.bytesTransferred, _this.bytesTransferred) || other.bytesTransferred == _this.bytesTransferred)&&(identical(other.totalBytes, _this.totalBytes) || other.totalBytes == _this.totalBytes)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.fileUrl, _this.fileUrl) || other.fileUrl == _this.fileUrl)&&(identical(other.localPath, _this.localPath) || other.localPath == _this.localPath)&&(identical(other.speedBytesPerSecond, _this.speedBytesPerSecond) || other.speedBytesPerSecond == _this.speedBytesPerSecond)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.fileId, _this.fileId) || other.fileId == _this.fileId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TransferEntity;
  return Object.hash(runtimeType,_this.id,_this.fileName,_this.originalName,_this.transferType,_this.status,_this.bytesTransferred,_this.totalBytes,_this.createdAt,_this.fileUrl,_this.localPath,_this.speedBytesPerSecond,_this.errorMessage,_this.completedAt,_this.fileId);
}

@override
String toString() {
  final _this = this as TransferEntity;
  return 'TransferEntity(id: ${_this.id}, fileName: ${_this.fileName}, originalName: ${_this.originalName}, transferType: ${_this.transferType}, status: ${_this.status}, bytesTransferred: ${_this.bytesTransferred}, totalBytes: ${_this.totalBytes}, createdAt: ${_this.createdAt}, fileUrl: ${_this.fileUrl}, localPath: ${_this.localPath}, speedBytesPerSecond: ${_this.speedBytesPerSecond}, errorMessage: ${_this.errorMessage}, completedAt: ${_this.completedAt}, fileId: ${_this.fileId})';
}


}

/// @nodoc
abstract mixin class $TransferEntityCopyWith<$Res>  {
  factory $TransferEntityCopyWith(TransferEntity value, $Res Function(TransferEntity) _then) = _$TransferEntityCopyWithImpl;
@useResult
$Res call({
 String id, String fileName, String originalName, String transferType, String status, int bytesTransferred, int totalBytes, int createdAt, String? fileUrl, String? localPath, int speedBytesPerSecond, String? errorMessage, int? completedAt, int? fileId
});




}
/// @nodoc
class _$TransferEntityCopyWithImpl<$Res>
    implements $TransferEntityCopyWith<$Res> {
  _$TransferEntityCopyWithImpl(this._self, this._then);

  final TransferEntity _self;
  final $Res Function(TransferEntity) _then;

/// Create a copy of TransferEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fileName = null,Object? originalName = null,Object? transferType = null,Object? status = null,Object? bytesTransferred = null,Object? totalBytes = null,Object? createdAt = null,Object? fileUrl = freezed,Object? localPath = freezed,Object? speedBytesPerSecond = null,Object? errorMessage = freezed,Object? completedAt = freezed,Object? fileId = freezed,}) {
  return _then(TransferEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,transferType: null == transferType ? _self.transferType : transferType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,bytesTransferred: null == bytesTransferred ? _self.bytesTransferred : bytesTransferred // ignore: cast_nullable_to_non_nullable
as int,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,speedBytesPerSecond: null == speedBytesPerSecond ? _self.speedBytesPerSecond : speedBytesPerSecond // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as int?,fileId: freezed == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransferEntity].
extension TransferEntityPatterns on TransferEntity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransferEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransferEntity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransferEntity value)  $default,){
final _that = this;
switch (_that) {
case _TransferEntity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransferEntity value)?  $default,){
final _that = this;
switch (_that) {
case _TransferEntity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fileName,  String originalName,  String transferType,  String status,  int bytesTransferred,  int totalBytes,  int createdAt,  String? fileUrl,  String? localPath,  int speedBytesPerSecond,  String? errorMessage,  int? completedAt,  int? fileId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransferEntity() when $default != null:
return $default(_that.id,_that.fileName,_that.originalName,_that.transferType,_that.status,_that.bytesTransferred,_that.totalBytes,_that.createdAt,_that.fileUrl,_that.localPath,_that.speedBytesPerSecond,_that.errorMessage,_that.completedAt,_that.fileId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fileName,  String originalName,  String transferType,  String status,  int bytesTransferred,  int totalBytes,  int createdAt,  String? fileUrl,  String? localPath,  int speedBytesPerSecond,  String? errorMessage,  int? completedAt,  int? fileId)  $default,) {final _that = this;
switch (_that) {
case _TransferEntity():
return $default(_that.id,_that.fileName,_that.originalName,_that.transferType,_that.status,_that.bytesTransferred,_that.totalBytes,_that.createdAt,_that.fileUrl,_that.localPath,_that.speedBytesPerSecond,_that.errorMessage,_that.completedAt,_that.fileId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fileName,  String originalName,  String transferType,  String status,  int bytesTransferred,  int totalBytes,  int createdAt,  String? fileUrl,  String? localPath,  int speedBytesPerSecond,  String? errorMessage,  int? completedAt,  int? fileId)?  $default,) {final _that = this;
switch (_that) {
case _TransferEntity() when $default != null:
return $default(_that.id,_that.fileName,_that.originalName,_that.transferType,_that.status,_that.bytesTransferred,_that.totalBytes,_that.createdAt,_that.fileUrl,_that.localPath,_that.speedBytesPerSecond,_that.errorMessage,_that.completedAt,_that.fileId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransferEntity extends TransferEntity {
  const _TransferEntity({required this.id, required this.fileName, required this.originalName, required this.transferType, required this.status, required this.bytesTransferred, required this.totalBytes, required this.createdAt, this.fileUrl, this.localPath, this.speedBytesPerSecond = 0, this.errorMessage, this.completedAt, this.fileId}): super._();
  factory _TransferEntity.fromJson(Map<String, dynamic> json) => _$TransferEntityFromJson(json);

@override final  String id;
@override final  String fileName;
@override final  String originalName;
@override final  String transferType;
@override final  String status;
@override final  int bytesTransferred;
@override final  int totalBytes;
@override final  int createdAt;
@override final  String? fileUrl;
@override final  String? localPath;
@override@JsonKey() final  int speedBytesPerSecond;
@override final  String? errorMessage;
@override final  int? completedAt;
@override final  int? fileId;

/// Create a copy of TransferEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransferEntityCopyWith<_TransferEntity> get copyWith => __$TransferEntityCopyWithImpl<_TransferEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransferEntityToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransferEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.transferType, transferType) || other.transferType == transferType)&&(identical(other.status, status) || other.status == status)&&(identical(other.bytesTransferred, bytesTransferred) || other.bytesTransferred == bytesTransferred)&&(identical(other.totalBytes, totalBytes) || other.totalBytes == totalBytes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.speedBytesPerSecond, speedBytesPerSecond) || other.speedBytesPerSecond == speedBytesPerSecond)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.fileId, fileId) || other.fileId == fileId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,fileName,originalName,transferType,status,bytesTransferred,totalBytes,createdAt,fileUrl,localPath,speedBytesPerSecond,errorMessage,completedAt,fileId);
}

@override
String toString() {
    return 'TransferEntity(id: $id, fileName: $fileName, originalName: $originalName, transferType: $transferType, status: $status, bytesTransferred: $bytesTransferred, totalBytes: $totalBytes, createdAt: $createdAt, fileUrl: $fileUrl, localPath: $localPath, speedBytesPerSecond: $speedBytesPerSecond, errorMessage: $errorMessage, completedAt: $completedAt, fileId: $fileId)';
}


}

/// @nodoc
abstract mixin class _$TransferEntityCopyWith<$Res> implements $TransferEntityCopyWith<$Res> {
  factory _$TransferEntityCopyWith(_TransferEntity value, $Res Function(_TransferEntity) _then) = __$TransferEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String fileName, String originalName, String transferType, String status, int bytesTransferred, int totalBytes, int createdAt, String? fileUrl, String? localPath, int speedBytesPerSecond, String? errorMessage, int? completedAt, int? fileId
});




}
/// @nodoc
class __$TransferEntityCopyWithImpl<$Res>
    implements _$TransferEntityCopyWith<$Res> {
  __$TransferEntityCopyWithImpl(this._self, this._then);

  final _TransferEntity _self;
  final $Res Function(_TransferEntity) _then;

/// Create a copy of TransferEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fileName = null,Object? originalName = null,Object? transferType = null,Object? status = null,Object? bytesTransferred = null,Object? totalBytes = null,Object? createdAt = null,Object? fileUrl = freezed,Object? localPath = freezed,Object? speedBytesPerSecond = null,Object? errorMessage = freezed,Object? completedAt = freezed,Object? fileId = freezed,}) {
  return _then(_TransferEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,transferType: null == transferType ? _self.transferType : transferType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,bytesTransferred: null == bytesTransferred ? _self.bytesTransferred : bytesTransferred // ignore: cast_nullable_to_non_nullable
as int,totalBytes: null == totalBytes ? _self.totalBytes : totalBytes // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,speedBytesPerSecond: null == speedBytesPerSecond ? _self.speedBytesPerSecond : speedBytesPerSecond // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as int?,fileId: freezed == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
