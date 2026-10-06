// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'downloaded_file_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DownloadedFileEntity {

 int get fileId; String get fileName; String get originalName; String get localPath; int get fileSize; int get downloadedAt; String? get fileType;
/// Create a copy of DownloadedFileEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadedFileEntityCopyWith<DownloadedFileEntity> get copyWith => _$DownloadedFileEntityCopyWithImpl<DownloadedFileEntity>(this as DownloadedFileEntity, _$identity);

  /// Serializes this DownloadedFileEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DownloadedFileEntity;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadedFileEntity&&(identical(other.fileId, _this.fileId) || other.fileId == _this.fileId)&&(identical(other.fileName, _this.fileName) || other.fileName == _this.fileName)&&(identical(other.originalName, _this.originalName) || other.originalName == _this.originalName)&&(identical(other.localPath, _this.localPath) || other.localPath == _this.localPath)&&(identical(other.fileSize, _this.fileSize) || other.fileSize == _this.fileSize)&&(identical(other.downloadedAt, _this.downloadedAt) || other.downloadedAt == _this.downloadedAt)&&(identical(other.fileType, _this.fileType) || other.fileType == _this.fileType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DownloadedFileEntity;
  return Object.hash(runtimeType,_this.fileId,_this.fileName,_this.originalName,_this.localPath,_this.fileSize,_this.downloadedAt,_this.fileType);
}

@override
String toString() {
  final _this = this as DownloadedFileEntity;
  return 'DownloadedFileEntity(fileId: ${_this.fileId}, fileName: ${_this.fileName}, originalName: ${_this.originalName}, localPath: ${_this.localPath}, fileSize: ${_this.fileSize}, downloadedAt: ${_this.downloadedAt}, fileType: ${_this.fileType})';
}


}

/// @nodoc
abstract mixin class $DownloadedFileEntityCopyWith<$Res>  {
  factory $DownloadedFileEntityCopyWith(DownloadedFileEntity value, $Res Function(DownloadedFileEntity) _then) = _$DownloadedFileEntityCopyWithImpl;
@useResult
$Res call({
 int fileId, String fileName, String originalName, String localPath, int fileSize, int downloadedAt, String? fileType
});




}
/// @nodoc
class _$DownloadedFileEntityCopyWithImpl<$Res>
    implements $DownloadedFileEntityCopyWith<$Res> {
  _$DownloadedFileEntityCopyWithImpl(this._self, this._then);

  final DownloadedFileEntity _self;
  final $Res Function(DownloadedFileEntity) _then;

/// Create a copy of DownloadedFileEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fileId = null,Object? fileName = null,Object? originalName = null,Object? localPath = null,Object? fileSize = null,Object? downloadedAt = null,Object? fileType = freezed,}) {
  return _then(DownloadedFileEntity(
fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as int,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,downloadedAt: null == downloadedAt ? _self.downloadedAt : downloadedAt // ignore: cast_nullable_to_non_nullable
as int,fileType: freezed == fileType ? _self.fileType : fileType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DownloadedFileEntity].
extension DownloadedFileEntityPatterns on DownloadedFileEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DownloadedFileEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DownloadedFileEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DownloadedFileEntity value)  $default,){
final _that = this;
switch (_that) {
case _DownloadedFileEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DownloadedFileEntity value)?  $default,){
final _that = this;
switch (_that) {
case _DownloadedFileEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int fileId,  String fileName,  String originalName,  String localPath,  int fileSize,  int downloadedAt,  String? fileType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DownloadedFileEntity() when $default != null:
return $default(_that.fileId,_that.fileName,_that.originalName,_that.localPath,_that.fileSize,_that.downloadedAt,_that.fileType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int fileId,  String fileName,  String originalName,  String localPath,  int fileSize,  int downloadedAt,  String? fileType)  $default,) {final _that = this;
switch (_that) {
case _DownloadedFileEntity():
return $default(_that.fileId,_that.fileName,_that.originalName,_that.localPath,_that.fileSize,_that.downloadedAt,_that.fileType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int fileId,  String fileName,  String originalName,  String localPath,  int fileSize,  int downloadedAt,  String? fileType)?  $default,) {final _that = this;
switch (_that) {
case _DownloadedFileEntity() when $default != null:
return $default(_that.fileId,_that.fileName,_that.originalName,_that.localPath,_that.fileSize,_that.downloadedAt,_that.fileType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DownloadedFileEntity extends DownloadedFileEntity {
  const _DownloadedFileEntity({required this.fileId, required this.fileName, required this.originalName, required this.localPath, required this.fileSize, required this.downloadedAt, this.fileType}): super._();
  factory _DownloadedFileEntity.fromJson(Map<String, dynamic> json) => _$DownloadedFileEntityFromJson(json);

@override final  int fileId;
@override final  String fileName;
@override final  String originalName;
@override final  String localPath;
@override final  int fileSize;
@override final  int downloadedAt;
@override final  String? fileType;

/// Create a copy of DownloadedFileEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DownloadedFileEntityCopyWith<_DownloadedFileEntity> get copyWith => __$DownloadedFileEntityCopyWithImpl<_DownloadedFileEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DownloadedFileEntityToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DownloadedFileEntity&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.downloadedAt, downloadedAt) || other.downloadedAt == downloadedAt)&&(identical(other.fileType, fileType) || other.fileType == fileType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,fileId,fileName,originalName,localPath,fileSize,downloadedAt,fileType);
}

@override
String toString() {
    return 'DownloadedFileEntity(fileId: $fileId, fileName: $fileName, originalName: $originalName, localPath: $localPath, fileSize: $fileSize, downloadedAt: $downloadedAt, fileType: $fileType)';
}


}

/// @nodoc
abstract mixin class _$DownloadedFileEntityCopyWith<$Res> implements $DownloadedFileEntityCopyWith<$Res> {
  factory _$DownloadedFileEntityCopyWith(_DownloadedFileEntity value, $Res Function(_DownloadedFileEntity) _then) = __$DownloadedFileEntityCopyWithImpl;
@override @useResult
$Res call({
 int fileId, String fileName, String originalName, String localPath, int fileSize, int downloadedAt, String? fileType
});




}
/// @nodoc
class __$DownloadedFileEntityCopyWithImpl<$Res>
    implements _$DownloadedFileEntityCopyWith<$Res> {
  __$DownloadedFileEntityCopyWithImpl(this._self, this._then);

  final _DownloadedFileEntity _self;
  final $Res Function(_DownloadedFileEntity) _then;

/// Create a copy of DownloadedFileEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fileId = null,Object? fileName = null,Object? originalName = null,Object? localPath = null,Object? fileSize = null,Object? downloadedAt = null,Object? fileType = freezed,}) {
  return _then(_DownloadedFileEntity(
fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as int,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,downloadedAt: null == downloadedAt ? _self.downloadedAt : downloadedAt // ignore: cast_nullable_to_non_nullable
as int,fileType: freezed == fileType ? _self.fileType : fileType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
