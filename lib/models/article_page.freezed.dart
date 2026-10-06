// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article_page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ArticlePage {

 List<Article> get datas; int get curPage; int get pageCount; bool get over;
/// Create a copy of ArticlePage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArticlePageCopyWith<ArticlePage> get copyWith => _$ArticlePageCopyWithImpl<ArticlePage>(this as ArticlePage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ArticlePage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArticlePage&&const DeepCollectionEquality().equals(other.datas, _this.datas)&&(identical(other.curPage, _this.curPage) || other.curPage == _this.curPage)&&(identical(other.pageCount, _this.pageCount) || other.pageCount == _this.pageCount)&&(identical(other.over, _this.over) || other.over == _this.over));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ArticlePage;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.datas),_this.curPage,_this.pageCount,_this.over);
}

@override
String toString() {
  final _this = this as ArticlePage;
  return 'ArticlePage(datas: ${_this.datas}, curPage: ${_this.curPage}, pageCount: ${_this.pageCount}, over: ${_this.over})';
}


}

/// @nodoc
abstract mixin class $ArticlePageCopyWith<$Res>  {
  factory $ArticlePageCopyWith(ArticlePage value, $Res Function(ArticlePage) _then) = _$ArticlePageCopyWithImpl;
@useResult
$Res call({
 List<Article> datas, int curPage, int pageCount, bool over
});




}
/// @nodoc
class _$ArticlePageCopyWithImpl<$Res>
    implements $ArticlePageCopyWith<$Res> {
  _$ArticlePageCopyWithImpl(this._self, this._then);

  final ArticlePage _self;
  final $Res Function(ArticlePage) _then;

/// Create a copy of ArticlePage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? datas = null,Object? curPage = null,Object? pageCount = null,Object? over = null,}) {
  return _then(ArticlePage(
datas: null == datas ? _self.datas : datas // ignore: cast_nullable_to_non_nullable
as List<Article>,curPage: null == curPage ? _self.curPage : curPage // ignore: cast_nullable_to_non_nullable
as int,pageCount: null == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int,over: null == over ? _self.over : over // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ArticlePage].
extension ArticlePagePatterns on ArticlePage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArticlePage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArticlePage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArticlePage value)  $default,){
final _that = this;
switch (_that) {
case _ArticlePage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArticlePage value)?  $default,){
final _that = this;
switch (_that) {
case _ArticlePage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Article> datas,  int curPage,  int pageCount,  bool over)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArticlePage() when $default != null:
return $default(_that.datas,_that.curPage,_that.pageCount,_that.over);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Article> datas,  int curPage,  int pageCount,  bool over)  $default,) {final _that = this;
switch (_that) {
case _ArticlePage():
return $default(_that.datas,_that.curPage,_that.pageCount,_that.over);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Article> datas,  int curPage,  int pageCount,  bool over)?  $default,) {final _that = this;
switch (_that) {
case _ArticlePage() when $default != null:
return $default(_that.datas,_that.curPage,_that.pageCount,_that.over);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _ArticlePage extends ArticlePage {
  const _ArticlePage({ List<Article> datas = const <Article>[], this.curPage = 0, this.pageCount = 0, this.over = true}): _datas = datas,super._();
  factory _ArticlePage.fromJson(Map<String, dynamic> json) => _$ArticlePageFromJson(json);

 final  List<Article> _datas;
@override@JsonKey() List<Article> get datas {
  if (_datas is EqualUnmodifiableListView) return _datas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_datas);
}

@override@JsonKey() final  int curPage;
@override@JsonKey() final  int pageCount;
@override@JsonKey() final  bool over;

/// Create a copy of ArticlePage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArticlePageCopyWith<_ArticlePage> get copyWith => __$ArticlePageCopyWithImpl<_ArticlePage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArticlePage&&const DeepCollectionEquality().equals(other.datas, _datas)&&(identical(other.curPage, curPage) || other.curPage == curPage)&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount)&&(identical(other.over, over) || other.over == over));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_datas),curPage,pageCount,over);
}

@override
String toString() {
    return 'ArticlePage(datas: $datas, curPage: $curPage, pageCount: $pageCount, over: $over)';
}


}

/// @nodoc
abstract mixin class _$ArticlePageCopyWith<$Res> implements $ArticlePageCopyWith<$Res> {
  factory _$ArticlePageCopyWith(_ArticlePage value, $Res Function(_ArticlePage) _then) = __$ArticlePageCopyWithImpl;
@override @useResult
$Res call({
 List<Article> datas, int curPage, int pageCount, bool over
});




}
/// @nodoc
class __$ArticlePageCopyWithImpl<$Res>
    implements _$ArticlePageCopyWith<$Res> {
  __$ArticlePageCopyWithImpl(this._self, this._then);

  final _ArticlePage _self;
  final $Res Function(_ArticlePage) _then;

/// Create a copy of ArticlePage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? datas = null,Object? curPage = null,Object? pageCount = null,Object? over = null,}) {
  return _then(_ArticlePage(
datas: null == datas ? _self._datas : datas // ignore: cast_nullable_to_non_nullable
as List<Article>,curPage: null == curPage ? _self.curPage : curPage // ignore: cast_nullable_to_non_nullable
as int,pageCount: null == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int,over: null == over ? _self.over : over // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
