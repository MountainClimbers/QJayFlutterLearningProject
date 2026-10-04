// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Article {

@JsonKey(fromJson: _intValue) int get id;@JsonKey(fromJson: _plainText) String get title;@JsonKey(fromJson: _stringValue) String get link;@JsonKey(fromJson: _plainText) String get author;@JsonKey(fromJson: _plainText) String get shareUser;@JsonKey(fromJson: _plainText) String get superChapterName;@JsonKey(fromJson: _plainText) String get chapterName;@JsonKey(fromJson: _plainText) String get niceDate;@JsonKey(fromJson: _plainText) String get niceShareDate;
/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArticleCopyWith<Article> get copyWith => _$ArticleCopyWithImpl<Article>(this as Article, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Article;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Article&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.link, _this.link) || other.link == _this.link)&&(identical(other.author, _this.author) || other.author == _this.author)&&(identical(other.shareUser, _this.shareUser) || other.shareUser == _this.shareUser)&&(identical(other.superChapterName, _this.superChapterName) || other.superChapterName == _this.superChapterName)&&(identical(other.chapterName, _this.chapterName) || other.chapterName == _this.chapterName)&&(identical(other.niceDate, _this.niceDate) || other.niceDate == _this.niceDate)&&(identical(other.niceShareDate, _this.niceShareDate) || other.niceShareDate == _this.niceShareDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Article;
  return Object.hash(runtimeType,_this.id,_this.title,_this.link,_this.author,_this.shareUser,_this.superChapterName,_this.chapterName,_this.niceDate,_this.niceShareDate);
}

@override
String toString() {
  final _this = this as Article;
  return 'Article(id: ${_this.id}, title: ${_this.title}, link: ${_this.link}, author: ${_this.author}, shareUser: ${_this.shareUser}, superChapterName: ${_this.superChapterName}, chapterName: ${_this.chapterName}, niceDate: ${_this.niceDate}, niceShareDate: ${_this.niceShareDate})';
}


}

/// @nodoc
abstract mixin class $ArticleCopyWith<$Res>  {
  factory $ArticleCopyWith(Article value, $Res Function(Article) _then) = _$ArticleCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _intValue) int id,@JsonKey(fromJson: _plainText) String title,@JsonKey(fromJson: _stringValue) String link,@JsonKey(fromJson: _plainText) String author,@JsonKey(fromJson: _plainText) String shareUser,@JsonKey(fromJson: _plainText) String superChapterName,@JsonKey(fromJson: _plainText) String chapterName,@JsonKey(fromJson: _plainText) String niceDate,@JsonKey(fromJson: _plainText) String niceShareDate
});




}
/// @nodoc
class _$ArticleCopyWithImpl<$Res>
    implements $ArticleCopyWith<$Res> {
  _$ArticleCopyWithImpl(this._self, this._then);

  final Article _self;
  final $Res Function(Article) _then;

/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? link = null,Object? author = null,Object? shareUser = null,Object? superChapterName = null,Object? chapterName = null,Object? niceDate = null,Object? niceShareDate = null,}) {
  return _then(Article(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,shareUser: null == shareUser ? _self.shareUser : shareUser // ignore: cast_nullable_to_non_nullable
as String,superChapterName: null == superChapterName ? _self.superChapterName : superChapterName // ignore: cast_nullable_to_non_nullable
as String,chapterName: null == chapterName ? _self.chapterName : chapterName // ignore: cast_nullable_to_non_nullable
as String,niceDate: null == niceDate ? _self.niceDate : niceDate // ignore: cast_nullable_to_non_nullable
as String,niceShareDate: null == niceShareDate ? _self.niceShareDate : niceShareDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Article].
extension ArticlePatterns on Article {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Article value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Article() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Article value)  $default,){
final _that = this;
switch (_that) {
case _Article():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Article value)?  $default,){
final _that = this;
switch (_that) {
case _Article() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _intValue)  int id, @JsonKey(fromJson: _plainText)  String title, @JsonKey(fromJson: _stringValue)  String link, @JsonKey(fromJson: _plainText)  String author, @JsonKey(fromJson: _plainText)  String shareUser, @JsonKey(fromJson: _plainText)  String superChapterName, @JsonKey(fromJson: _plainText)  String chapterName, @JsonKey(fromJson: _plainText)  String niceDate, @JsonKey(fromJson: _plainText)  String niceShareDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Article() when $default != null:
return $default(_that.id,_that.title,_that.link,_that.author,_that.shareUser,_that.superChapterName,_that.chapterName,_that.niceDate,_that.niceShareDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _intValue)  int id, @JsonKey(fromJson: _plainText)  String title, @JsonKey(fromJson: _stringValue)  String link, @JsonKey(fromJson: _plainText)  String author, @JsonKey(fromJson: _plainText)  String shareUser, @JsonKey(fromJson: _plainText)  String superChapterName, @JsonKey(fromJson: _plainText)  String chapterName, @JsonKey(fromJson: _plainText)  String niceDate, @JsonKey(fromJson: _plainText)  String niceShareDate)  $default,) {final _that = this;
switch (_that) {
case _Article():
return $default(_that.id,_that.title,_that.link,_that.author,_that.shareUser,_that.superChapterName,_that.chapterName,_that.niceDate,_that.niceShareDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _intValue)  int id, @JsonKey(fromJson: _plainText)  String title, @JsonKey(fromJson: _stringValue)  String link, @JsonKey(fromJson: _plainText)  String author, @JsonKey(fromJson: _plainText)  String shareUser, @JsonKey(fromJson: _plainText)  String superChapterName, @JsonKey(fromJson: _plainText)  String chapterName, @JsonKey(fromJson: _plainText)  String niceDate, @JsonKey(fromJson: _plainText)  String niceShareDate)?  $default,) {final _that = this;
switch (_that) {
case _Article() when $default != null:
return $default(_that.id,_that.title,_that.link,_that.author,_that.shareUser,_that.superChapterName,_that.chapterName,_that.niceDate,_that.niceShareDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createToJson: false)

class _Article extends Article {
  const _Article({@JsonKey(fromJson: _intValue) required this.id, @JsonKey(fromJson: _plainText) required this.title, @JsonKey(fromJson: _stringValue) required this.link, @JsonKey(fromJson: _plainText) this.author = '', @JsonKey(fromJson: _plainText) this.shareUser = '', @JsonKey(fromJson: _plainText) this.superChapterName = '', @JsonKey(fromJson: _plainText) this.chapterName = '', @JsonKey(fromJson: _plainText) this.niceDate = '', @JsonKey(fromJson: _plainText) this.niceShareDate = ''}): super._();
  factory _Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);

@override@JsonKey(fromJson: _intValue) final  int id;
@override@JsonKey(fromJson: _plainText) final  String title;
@override@JsonKey(fromJson: _stringValue) final  String link;
@override@JsonKey(fromJson: _plainText) final  String author;
@override@JsonKey(fromJson: _plainText) final  String shareUser;
@override@JsonKey(fromJson: _plainText) final  String superChapterName;
@override@JsonKey(fromJson: _plainText) final  String chapterName;
@override@JsonKey(fromJson: _plainText) final  String niceDate;
@override@JsonKey(fromJson: _plainText) final  String niceShareDate;

/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArticleCopyWith<_Article> get copyWith => __$ArticleCopyWithImpl<_Article>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Article&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.link, link) || other.link == link)&&(identical(other.author, author) || other.author == author)&&(identical(other.shareUser, shareUser) || other.shareUser == shareUser)&&(identical(other.superChapterName, superChapterName) || other.superChapterName == superChapterName)&&(identical(other.chapterName, chapterName) || other.chapterName == chapterName)&&(identical(other.niceDate, niceDate) || other.niceDate == niceDate)&&(identical(other.niceShareDate, niceShareDate) || other.niceShareDate == niceShareDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,link,author,shareUser,superChapterName,chapterName,niceDate,niceShareDate);
}

@override
String toString() {
    return 'Article(id: $id, title: $title, link: $link, author: $author, shareUser: $shareUser, superChapterName: $superChapterName, chapterName: $chapterName, niceDate: $niceDate, niceShareDate: $niceShareDate)';
}


}

/// @nodoc
abstract mixin class _$ArticleCopyWith<$Res> implements $ArticleCopyWith<$Res> {
  factory _$ArticleCopyWith(_Article value, $Res Function(_Article) _then) = __$ArticleCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _intValue) int id,@JsonKey(fromJson: _plainText) String title,@JsonKey(fromJson: _stringValue) String link,@JsonKey(fromJson: _plainText) String author,@JsonKey(fromJson: _plainText) String shareUser,@JsonKey(fromJson: _plainText) String superChapterName,@JsonKey(fromJson: _plainText) String chapterName,@JsonKey(fromJson: _plainText) String niceDate,@JsonKey(fromJson: _plainText) String niceShareDate
});




}
/// @nodoc
class __$ArticleCopyWithImpl<$Res>
    implements _$ArticleCopyWith<$Res> {
  __$ArticleCopyWithImpl(this._self, this._then);

  final _Article _self;
  final $Res Function(_Article) _then;

/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? link = null,Object? author = null,Object? shareUser = null,Object? superChapterName = null,Object? chapterName = null,Object? niceDate = null,Object? niceShareDate = null,}) {
  return _then(_Article(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,shareUser: null == shareUser ? _self.shareUser : shareUser // ignore: cast_nullable_to_non_nullable
as String,superChapterName: null == superChapterName ? _self.superChapterName : superChapterName // ignore: cast_nullable_to_non_nullable
as String,chapterName: null == chapterName ? _self.chapterName : chapterName // ignore: cast_nullable_to_non_nullable
as String,niceDate: null == niceDate ? _self.niceDate : niceDate // ignore: cast_nullable_to_non_nullable
as String,niceShareDate: null == niceShareDate ? _self.niceShareDate : niceShareDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
