import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qjay_flutter_learning/services/secure_cookie_storage.dart';

void main() {
  test('认证 Cookie 可以通过安全存储跨实例恢复', () async {
    final values = <String, String>{};
    final firstStorage = SecureCookieStorage(_MemorySecureStore(values));
    final firstJar = PersistCookieJar(storage: firstStorage);
    await firstJar.saveFromResponse(Uri.parse('https://www.wanandroid.com'), [
      Cookie('loginUserName', 'MountainClimbers')..path = '/',
      Cookie('token_pass', 'secret_token')..path = '/',
    ]);

    final secondStorage = SecureCookieStorage(_MemorySecureStore(values));
    final secondJar = PersistCookieJar(storage: secondStorage);
    final restored = await secondJar.loadForRequest(
      Uri.parse('https://www.wanandroid.com/article/list/0/json'),
    );

    expect(
      restored.map((cookie) => cookie.name),
      containsAll(['loginUserName', 'token_pass']),
    );
    expect(values.keys, everyElement(startsWith('wanandroid_cookie_')));
  });

  test('清理 Cookie 时只删除玩安卓命名空间中的键', () async {
    final values = <String, String>{'unrelated': 'keep'};
    final storage = SecureCookieStorage(_MemorySecureStore(values));
    final jar = PersistCookieJar(storage: storage);
    await jar.saveFromResponse(Uri.parse('https://www.wanandroid.com'), [
      Cookie('token_pass', 'secret_token')..path = '/',
    ]);

    await jar.deleteAll();

    expect(values, {'unrelated': 'keep'});
  });
}

class _MemorySecureStore implements SecureKeyValueStore {
  _MemorySecureStore(this.values);

  final Map<String, String> values;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
