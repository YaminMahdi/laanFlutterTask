// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_download_storage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PublicDownloadedFile {

 String get path; int get size; String? get uri;
/// Create a copy of PublicDownloadedFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicDownloadedFileCopyWith<PublicDownloadedFile> get copyWith => _$PublicDownloadedFileCopyWithImpl<PublicDownloadedFile>(this as PublicDownloadedFile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PublicDownloadedFile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicDownloadedFile&&(identical(other.path, _this.path) || other.path == _this.path)&&(identical(other.size, _this.size) || other.size == _this.size)&&(identical(other.uri, _this.uri) || other.uri == _this.uri));
}


@override
int get hashCode {
  final _this = this as PublicDownloadedFile;
  return Object.hash(runtimeType,_this.path,_this.size,_this.uri);
}

@override
String toString() {
  final _this = this as PublicDownloadedFile;
  return 'PublicDownloadedFile(path: ${_this.path}, size: ${_this.size}, uri: ${_this.uri})';
}


}

/// @nodoc
abstract mixin class $PublicDownloadedFileCopyWith<$Res>  {
  factory $PublicDownloadedFileCopyWith(PublicDownloadedFile value, $Res Function(PublicDownloadedFile) _then) = _$PublicDownloadedFileCopyWithImpl;
@useResult
$Res call({
 String path, int size, String? uri
});




}
/// @nodoc
class _$PublicDownloadedFileCopyWithImpl<$Res>
    implements $PublicDownloadedFileCopyWith<$Res> {
  _$PublicDownloadedFileCopyWithImpl(this._self, this._then);

  final PublicDownloadedFile _self;
  final $Res Function(PublicDownloadedFile) _then;

/// Create a copy of PublicDownloadedFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? size = null,Object? uri = freezed,}) {
  return _then(PublicDownloadedFile(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicDownloadedFile].
extension PublicDownloadedFilePatterns on PublicDownloadedFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicDownloadedFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicDownloadedFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicDownloadedFile value)  $default,){
final _that = this;
switch (_that) {
case _PublicDownloadedFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicDownloadedFile value)?  $default,){
final _that = this;
switch (_that) {
case _PublicDownloadedFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  int size,  String? uri)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicDownloadedFile() when $default != null:
return $default(_that.path,_that.size,_that.uri);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  int size,  String? uri)  $default,) {final _that = this;
switch (_that) {
case _PublicDownloadedFile():
return $default(_that.path,_that.size,_that.uri);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  int size,  String? uri)?  $default,) {final _that = this;
switch (_that) {
case _PublicDownloadedFile() when $default != null:
return $default(_that.path,_that.size,_that.uri);case _:
  return null;

}
}

}

/// @nodoc


class _PublicDownloadedFile implements PublicDownloadedFile {
  const _PublicDownloadedFile({required this.path, required this.size, this.uri});
  

@override final  String path;
@override final  int size;
@override final  String? uri;

/// Create a copy of PublicDownloadedFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicDownloadedFileCopyWith<_PublicDownloadedFile> get copyWith => __$PublicDownloadedFileCopyWithImpl<_PublicDownloadedFile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicDownloadedFile&&(identical(other.path, path) || other.path == path)&&(identical(other.size, size) || other.size == size)&&(identical(other.uri, uri) || other.uri == uri));
}


@override
int get hashCode {
    return Object.hash(runtimeType,path,size,uri);
}

@override
String toString() {
    return 'PublicDownloadedFile(path: $path, size: $size, uri: $uri)';
}


}

/// @nodoc
abstract mixin class _$PublicDownloadedFileCopyWith<$Res> implements $PublicDownloadedFileCopyWith<$Res> {
  factory _$PublicDownloadedFileCopyWith(_PublicDownloadedFile value, $Res Function(_PublicDownloadedFile) _then) = __$PublicDownloadedFileCopyWithImpl;
@override @useResult
$Res call({
 String path, int size, String? uri
});




}
/// @nodoc
class __$PublicDownloadedFileCopyWithImpl<$Res>
    implements _$PublicDownloadedFileCopyWith<$Res> {
  __$PublicDownloadedFileCopyWithImpl(this._self, this._then);

  final _PublicDownloadedFile _self;
  final $Res Function(_PublicDownloadedFile) _then;

/// Create a copy of PublicDownloadedFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? size = null,Object? uri = freezed,}) {
  return _then(_PublicDownloadedFile(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
