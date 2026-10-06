// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_file_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RemoteFileItem {

 int get id; String get name;@JsonKey(name: 'original_name', readValue: _readOriginalName) String get originalName; int get size; String get type;@JsonKey(name: 'uploaded_at', fromJson: _parseDateTime) DateTime get uploadedAt; String get url;
/// Create a copy of RemoteFileItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteFileItemCopyWith<RemoteFileItem> get copyWith => _$RemoteFileItemCopyWithImpl<RemoteFileItem>(this as RemoteFileItem, _$identity);

  /// Serializes this RemoteFileItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RemoteFileItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteFileItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.originalName, _this.originalName) || other.originalName == _this.originalName)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.uploadedAt, _this.uploadedAt) || other.uploadedAt == _this.uploadedAt)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RemoteFileItem;
  return Object.hash(runtimeType,_this.id,_this.name,_this.originalName,_this.size,_this.type,_this.uploadedAt,_this.url);
}

@override
String toString() {
  final _this = this as RemoteFileItem;
  return 'RemoteFileItem(id: ${_this.id}, name: ${_this.name}, originalName: ${_this.originalName}, size: ${_this.size}, type: ${_this.type}, uploadedAt: ${_this.uploadedAt}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $RemoteFileItemCopyWith<$Res>  {
  factory $RemoteFileItemCopyWith(RemoteFileItem value, $Res Function(RemoteFileItem) _then) = _$RemoteFileItemCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'original_name', readValue: _readOriginalName) String originalName, int size, String type,@JsonKey(name: 'uploaded_at', fromJson: _parseDateTime) DateTime uploadedAt, String url
});




}
/// @nodoc
class _$RemoteFileItemCopyWithImpl<$Res>
    implements $RemoteFileItemCopyWith<$Res> {
  _$RemoteFileItemCopyWithImpl(this._self, this._then);

  final RemoteFileItem _self;
  final $Res Function(RemoteFileItem) _then;

/// Create a copy of RemoteFileItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? originalName = null,Object? size = null,Object? type = null,Object? uploadedAt = null,Object? url = null,}) {
  return _then(RemoteFileItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteFileItem].
extension RemoteFileItemPatterns on RemoteFileItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteFileItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteFileItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteFileItem value)  $default,){
final _that = this;
switch (_that) {
case _RemoteFileItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteFileItem value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteFileItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'original_name', readValue: _readOriginalName)  String originalName,  int size,  String type, @JsonKey(name: 'uploaded_at', fromJson: _parseDateTime)  DateTime uploadedAt,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteFileItem() when $default != null:
return $default(_that.id,_that.name,_that.originalName,_that.size,_that.type,_that.uploadedAt,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'original_name', readValue: _readOriginalName)  String originalName,  int size,  String type, @JsonKey(name: 'uploaded_at', fromJson: _parseDateTime)  DateTime uploadedAt,  String url)  $default,) {final _that = this;
switch (_that) {
case _RemoteFileItem():
return $default(_that.id,_that.name,_that.originalName,_that.size,_that.type,_that.uploadedAt,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'original_name', readValue: _readOriginalName)  String originalName,  int size,  String type, @JsonKey(name: 'uploaded_at', fromJson: _parseDateTime)  DateTime uploadedAt,  String url)?  $default,) {final _that = this;
switch (_that) {
case _RemoteFileItem() when $default != null:
return $default(_that.id,_that.name,_that.originalName,_that.size,_that.type,_that.uploadedAt,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RemoteFileItem extends RemoteFileItem {
  const _RemoteFileItem({required this.id, required this.name, @JsonKey(name: 'original_name', readValue: _readOriginalName) required this.originalName, this.size = 0, this.type = 'application/octet-stream', @JsonKey(name: 'uploaded_at', fromJson: _parseDateTime) required this.uploadedAt, required this.url}): super._();
  factory _RemoteFileItem.fromJson(Map<String, dynamic> json) => _$RemoteFileItemFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey(name: 'original_name', readValue: _readOriginalName) final  String originalName;
@override@JsonKey() final  int size;
@override@JsonKey() final  String type;
@override@JsonKey(name: 'uploaded_at', fromJson: _parseDateTime) final  DateTime uploadedAt;
@override final  String url;

/// Create a copy of RemoteFileItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteFileItemCopyWith<_RemoteFileItem> get copyWith => __$RemoteFileItemCopyWithImpl<_RemoteFileItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RemoteFileItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteFileItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.size, size) || other.size == size)&&(identical(other.type, type) || other.type == type)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,originalName,size,type,uploadedAt,url);
}

@override
String toString() {
    return 'RemoteFileItem(id: $id, name: $name, originalName: $originalName, size: $size, type: $type, uploadedAt: $uploadedAt, url: $url)';
}


}

/// @nodoc
abstract mixin class _$RemoteFileItemCopyWith<$Res> implements $RemoteFileItemCopyWith<$Res> {
  factory _$RemoteFileItemCopyWith(_RemoteFileItem value, $Res Function(_RemoteFileItem) _then) = __$RemoteFileItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'original_name', readValue: _readOriginalName) String originalName, int size, String type,@JsonKey(name: 'uploaded_at', fromJson: _parseDateTime) DateTime uploadedAt, String url
});




}
/// @nodoc
class __$RemoteFileItemCopyWithImpl<$Res>
    implements _$RemoteFileItemCopyWith<$Res> {
  __$RemoteFileItemCopyWithImpl(this._self, this._then);

  final _RemoteFileItem _self;
  final $Res Function(_RemoteFileItem) _then;

/// Create a copy of RemoteFileItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? originalName = null,Object? size = null,Object? type = null,Object? uploadedAt = null,Object? url = null,}) {
  return _then(_RemoteFileItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
