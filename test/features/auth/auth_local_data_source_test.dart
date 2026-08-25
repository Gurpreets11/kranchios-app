import 'package:core_package/core_package.dart';
import 'package:kranchios_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:kranchios_app/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fully in-memory fake — no platform channel involved, unlike the
/// real `flutter_secure_storage`-backed implementation.
class _FakeSecureStorageService implements SecureStorageService {
  final Map<String, String> _values = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<String?> read({required String key}) async => _values[key];

  @override
  Future<void> delete({required String key}) async => _values.remove(key);

  @override
  Future<void> deleteAll() async => _values.clear();
}

void main() {
  late _FakeSecureStorageService storage;
  late AuthLocalDataSource dataSource;

  const user = AuthUser(id: '1', name: 'Jane', email: 'jane@example.com');

  setUp(() {
    storage = _FakeSecureStorageService();
    dataSource = AuthLocalDataSource(storage: storage);
  });

  group('AuthLocalDataSource', () {
    test(
      'readToken/readUser return null before any session is saved',
      () async {
        expect(await dataSource.readToken(), isNull);
        expect(await dataSource.readUser(), isNull);
      },
    );

    test('saveSession persists both the token and the user', () async {
      await dataSource.saveSession(token: 'abc123', user: user);

      expect(await dataSource.readToken(), 'abc123');
      final readBack = await dataSource.readUser();
      expect(readBack, isNotNull);
      expect(readBack!.id, user.id);
      expect(readBack.name, user.name);
      expect(readBack.email, user.email);
    });

    test('clearSession removes both the token and the user', () async {
      await dataSource.saveSession(token: 'abc123', user: user);
      await dataSource.clearSession();

      expect(await dataSource.readToken(), isNull);
      expect(await dataSource.readUser(), isNull);
    });
  });
}
