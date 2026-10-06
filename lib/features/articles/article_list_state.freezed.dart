// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ArticleListState {

 List<List<Article>> get pages; int get nextPage; bool get hasMore; bool get isLoading; Object? get error;
/// Create a copy of ArticleListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArticleListStateCopyWith<ArticleListState> get copyWith => _$ArticleListStateCopyWithImpl<ArticleListState>(this as ArticleListState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ArticleListState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArticleListState&&const DeepCollectionEquality().equals(other.pages, _this.pages)&&(identical(other.nextPage, _this.nextPage) || other.nextPage == _this.nextPage)&&(identical(other.hasMore, _this.hasMore) || other.hasMore == _this.hasMore)&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&const DeepCollectionEquality().equals(other.error, _this.error));
}


@override
int get hashCode {
  final _this = this as ArticleListState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.pages),_this.nextPage,_this.hasMore,_this.isLoading,const DeepCollectionEquality().hash(_this.error));
}

@override
String toString() {
  final _this = this as ArticleListState;
  return 'ArticleListState(pages: ${_this.pages}, nextPage: ${_this.nextPage}, hasMore: ${_this.hasMore}, isLoading: ${_this.isLoading}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $ArticleListStateCopyWith<$Res>  {
  factory $ArticleListStateCopyWith(ArticleListState value, $Res Function(ArticleListState) _then) = _$ArticleListStateCopyWithImpl;
@useResult
$Res call({
 List<List<Article>> pages, int nextPage, bool hasMore, bool isLoading, Object? error
});




}
/// @nodoc
class _$ArticleListStateCopyWithImpl<$Res>
    implements $ArticleListStateCopyWith<$Res> {
  _$ArticleListStateCopyWithImpl(this._self, this._then);

  final ArticleListState _self;
  final $Res Function(ArticleListState) _then;

/// Create a copy of ArticleListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pages = null,Object? nextPage = null,Object? hasMore = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(ArticleListState(
pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as List<List<Article>>,nextPage: null == nextPage ? _self.nextPage : nextPage // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,
  ));
}

}


/// Adds pattern-matching-related methods to [ArticleListState].
extension ArticleListStatePatterns on ArticleListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArticleListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArticleListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArticleListState value)  $default,){
final _that = this;
switch (_that) {
case _ArticleListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArticleListState value)?  $default,){
final _that = this;
switch (_that) {
case _ArticleListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<List<Article>> pages,  int nextPage,  bool hasMore,  bool isLoading,  Object? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArticleListState() when $default != null:
return $default(_that.pages,_that.nextPage,_that.hasMore,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<List<Article>> pages,  int nextPage,  bool hasMore,  bool isLoading,  Object? error)  $default,) {final _that = this;
switch (_that) {
case _ArticleListState():
return $default(_that.pages,_that.nextPage,_that.hasMore,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<List<Article>> pages,  int nextPage,  bool hasMore,  bool isLoading,  Object? error)?  $default,) {final _that = this;
switch (_that) {
case _ArticleListState() when $default != null:
return $default(_that.pages,_that.nextPage,_that.hasMore,_that.isLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ArticleListState extends ArticleListState {
  const _ArticleListState({ List<List<Article>> pages = const <List<Article>>[], this.nextPage = 0, this.hasMore = true, this.isLoading = false, this.error}): _pages = pages,super._();
  

 final  List<List<Article>> _pages;
@override@JsonKey() List<List<Article>> get pages {
  if (_pages is EqualUnmodifiableListView) return _pages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pages);
}

@override@JsonKey() final  int nextPage;
@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  bool isLoading;
@override final  Object? error;

/// Create a copy of ArticleListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArticleListStateCopyWith<_ArticleListState> get copyWith => __$ArticleListStateCopyWithImpl<_ArticleListState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArticleListState&&const DeepCollectionEquality().equals(other.pages, _pages)&&(identical(other.nextPage, nextPage) || other.nextPage == nextPage)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.error, error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_pages),nextPage,hasMore,isLoading,const DeepCollectionEquality().hash(error));
}

@override
String toString() {
    return 'ArticleListState(pages: $pages, nextPage: $nextPage, hasMore: $hasMore, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ArticleListStateCopyWith<$Res> implements $ArticleListStateCopyWith<$Res> {
  factory _$ArticleListStateCopyWith(_ArticleListState value, $Res Function(_ArticleListState) _then) = __$ArticleListStateCopyWithImpl;
@override @useResult
$Res call({
 List<List<Article>> pages, int nextPage, bool hasMore, bool isLoading, Object? error
});




}
/// @nodoc
class __$ArticleListStateCopyWithImpl<$Res>
    implements _$ArticleListStateCopyWith<$Res> {
  __$ArticleListStateCopyWithImpl(this._self, this._then);

  final _ArticleListState _self;
  final $Res Function(_ArticleListState) _then;

/// Create a copy of ArticleListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pages = null,Object? nextPage = null,Object? hasMore = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_ArticleListState(
pages: null == pages ? _self._pages : pages // ignore: cast_nullable_to_non_nullable
as List<List<Article>>,nextPage: null == nextPage ? _self.nextPage : nextPage // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error ,
  ));
}


}

// dart format on
