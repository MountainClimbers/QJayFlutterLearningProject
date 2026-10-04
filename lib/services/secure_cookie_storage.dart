import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 隔离平台插件，测试时可替换为内存实现。
abstract interface class SecureKeyValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  FlutterSecureKeyValueStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// 让 PersistCookieJar 把序列化结果写入 Keychain/Keystore。
class SecureCookieStorage extends Storage {
  const SecureCookieStorage(this._store);

  static const _keyPrefix = 'wanandroid_cookie_';
  final SecureKeyValueStore _store;

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {}

  @override
  Future<String?> read(String key) => _store.read(_storageKey(key));

  @override
  Future<void> write(String key, String value) =>
      _store.write(_storageKey(key), value);

  @override
  Future<void> delete(String key) => _store.delete(_storageKey(key));

  @override
  Future<void> deleteAll(List<String> keys) async {
    await Future.wait(keys.map(delete));
  }

  String _storageKey(String key) => '$_keyPrefix$key';
}
