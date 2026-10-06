// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CollectionState {

 String? get identity; List<Article> get articles; Map<String, bool> get confirmed; Set<String> get busyKeys; bool get isLoading; bool get isRefreshing; String? get errorMessage;
/// Create a copy of CollectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionStateCopyWith<CollectionState> get copyWith => _$CollectionStateCopyWithImpl<CollectionState>(this as CollectionState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CollectionState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionState&&(identical(other.identity, _this.identity) || other.identity == _this.identity)&&const DeepCollectionEquality().equals(other.articles, _this.articles)&&const DeepCollectionEquality().equals(other.confirmed, _this.confirmed)&&const DeepCollectionEquality().equals(other.busyKeys, _this.busyKeys)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.isRefreshing, _this.isRefreshing) || other.isRefreshing == _this.isRefreshing)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}


@override
int get hashCode {
  final _this = this as CollectionState;
  return Object.hash(runtimeType,_this.identity,const DeepCollectionEquality().hash(_this.articles),const DeepCollectionEquality().hash(_this.confirmed),const DeepCollectionEquality().hash(_this.busyKeys),_this.isLoading,_this.isRefreshing,_this.errorMessage);
}

@override
String toString() {
  final _this = this as CollectionState;
  return 'CollectionState(identity: ${_this.identity}, articles: ${_this.articles}, confirmed: ${_this.confirmed}, busyKeys: ${_this.busyKeys}, isLoading: ${_this.isLoading}, isRefreshing: ${_this.isRefreshing}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $CollectionStateCopyWith<$Res>  {
  factory $CollectionStateCopyWith(CollectionState value, $Res Function(CollectionState) _then) = _$CollectionStateCopyWithImpl;
@useResult
$Res call({
 String? identity, List<Article> articles, Map<String, bool> confirmed, Set<String> busyKeys, bool isLoading, bool isRefreshing, String? errorMessage
});




}
/// @nodoc
class _$CollectionStateCopyWithImpl<$Res>
    implements $CollectionStateCopyWith<$Res> {
  _$CollectionStateCopyWithImpl(this._self, this._then);

  final CollectionState _self;
  final $Res Function(CollectionState) _then;

/// Create a copy of CollectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identity = freezed,Object? articles = null,Object? confirmed = null,Object? busyKeys = null,Object? isLoading = null,Object? isRefreshing = null,Object? errorMessage = freezed,}) {
  return _then(CollectionState(
identity: freezed == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as String?,articles: null == articles ? _self.articles : articles // ignore: cast_nullable_to_non_nullable
as List<Article>,confirmed: null == confirmed ? _self.confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,busyKeys: null == busyKeys ? _self.busyKeys : busyKeys // ignore: cast_nullable_to_non_nullable
as Set<String>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CollectionState].
extension CollectionStatePatterns on CollectionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionState value)  $default,){
final _that = this;
switch (_that) {
case _CollectionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionState value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? identity,  List<Article> articles,  Map<String, bool> confirmed,  Set<String> busyKeys,  bool isLoading,  bool isRefreshing,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionState() when $default != null:
return $default(_that.identity,_that.articles,_that.confirmed,_that.busyKeys,_that.isLoading,_that.isRefreshing,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? identity,  List<Article> articles,  Map<String, bool> confirmed,  Set<String> busyKeys,  bool isLoading,  bool isRefreshing,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _CollectionState():
return $default(_that.identity,_that.articles,_that.confirmed,_that.busyKeys,_that.isLoading,_that.isRefreshing,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? identity,  List<Article> articles,  Map<String, bool> confirmed,  Set<String> busyKeys,  bool isLoading,  bool isRefreshing,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _CollectionState() when $default != null:
return $default(_that.identity,_that.articles,_that.confirmed,_that.busyKeys,_that.isLoading,_that.isRefreshing,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _CollectionState implements CollectionState {
  const _CollectionState({this.identity,  List<Article> articles = const <Article>[],  Map<String, bool> confirmed = const <String, bool>{},  Set<String> busyKeys = const <String>{}, this.isLoading = false, this.isRefreshing = false, this.errorMessage}): _articles = articles,_confirmed = confirmed,_busyKeys = busyKeys;


@override final  String? identity;
 final  List<Article> _articles;
@override@JsonKey() List<Article> get articles {
  if (_articles is EqualUnmodifiableListView) return _articles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_articles);
}

 final  Map<String, bool> _confirmed;
@override@JsonKey() Map<String, bool> get confirmed {
  if (_confirmed is EqualUnmodifiableMapView) return _confirmed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_confirmed);
}

 final  Set<String> _busyKeys;
@override@JsonKey() Set<String> get busyKeys {
  if (_busyKeys is EqualUnmodifiableSetView) return _busyKeys;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_busyKeys);
}

@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isRefreshing;
@override final  String? errorMessage;

/// Create a copy of CollectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionStateCopyWith<_CollectionState> get copyWith => __$CollectionStateCopyWithImpl<_CollectionState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionState&&(identical(other.identity, identity) || other.identity == identity)&&const DeepCollectionEquality().equals(other.articles, _articles)&&const DeepCollectionEquality().equals(other.confirmed, _confirmed)&&const DeepCollectionEquality().equals(other.busyKeys, _busyKeys)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,identity,const DeepCollectionEquality().hash(_articles),const DeepCollectionEquality().hash(_confirmed),const DeepCollectionEquality().hash(_busyKeys),isLoading,isRefreshing,errorMessage);
}

@override
String toString() {
    return 'CollectionState(identity: $identity, articles: $articles, confirmed: $confirmed, busyKeys: $busyKeys, isLoading: $isLoading, isRefreshing: $isRefreshing, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$CollectionStateCopyWith<$Res> implements $CollectionStateCopyWith<$Res> {
  factory _$CollectionStateCopyWith(_CollectionState value, $Res Function(_CollectionState) _then) = __$CollectionStateCopyWithImpl;
@override @useResult
$Res call({
 String? identity, List<Article> articles, Map<String, bool> confirmed, Set<String> busyKeys, bool isLoading, bool isRefreshing, String? errorMessage
});




}
/// @nodoc
class __$CollectionStateCopyWithImpl<$Res>
    implements _$CollectionStateCopyWith<$Res> {
  __$CollectionStateCopyWithImpl(this._self, this._then);

  final _CollectionState _self;
  final $Res Function(_CollectionState) _then;

/// Create a copy of CollectionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identity = freezed,Object? articles = null,Object? confirmed = null,Object? busyKeys = null,Object? isLoading = null,Object? isRefreshing = null,Object? errorMessage = freezed,}) {
  return _then(_CollectionState(
identity: freezed == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as String?,articles: null == articles ? _self._articles : articles // ignore: cast_nullable_to_non_nullable
as List<Article>,confirmed: null == confirmed ? _self._confirmed : confirmed // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,busyKeys: null == busyKeys ? _self._busyKeys : busyKeys // ignore: cast_nullable_to_non_nullable
as Set<String>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
