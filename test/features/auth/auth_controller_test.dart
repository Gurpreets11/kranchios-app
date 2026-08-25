import 'package:core_package/core_package.dart';
import 'package:kranchios_app/features/auth/domain/entities/auth_user.dart';
import 'package:kranchios_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:kranchios_app/features/auth/domain/usecases/change_password_use_case.dart';
import 'package:kranchios_app/features/auth/domain/usecases/login_use_case.dart';
import 'package:kranchios_app/features/auth/domain/usecases/logout_use_case.dart';
import 'package:kranchios_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:kranchios_app/features/auth/presentation/providers/auth_state.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late AuthController controller;

  const user = AuthUser(id: '1', name: 'Jane', email: 'jane@example.com');

  setUp(() {
    repository = _MockAuthRepository();
    when(() => repository.currentUser()).thenAnswer((_) async => null);

    controller = AuthController(
      loginUseCase: LoginUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
      changePasswordUseCase: ChangePasswordUseCase(repository),
      readCurrentUser: repository.currentUser,
    );
  });

  group('AuthController._checkSession (constructor)', () {
    test(
      'sets status to unauthenticated when no session is persisted',
      () async {
        await Future<void>.delayed(Duration.zero);
        expect(controller.state.status, AuthStatus.unauthenticated);
        expect(controller.state.user, isNull);
      },
    );
  });

  group('AuthController.login', () {
    test('sets authenticated status and user on success', () async {
      when(
        () => repository.login('jane@example.com', 'password123'),
      ).thenAnswer((_) async => const Result.success(user));

      await controller.login('jane@example.com', 'password123');

      expect(controller.state.status, AuthStatus.authenticated);
      expect(controller.state.user, user);
      expect(controller.state.isLoading, isFalse);
    });

    test(
      'sets an error message and stays unauthenticated on failure',
      () async {
        when(
          () => repository.login('jane@example.com', 'bad'),
        ).thenAnswer(
          (_) async => const Result.failure(
            ValidationFailure('Password must be at least 8 characters.'),
          ),
        );

        await controller.login('jane@example.com', 'bad');

        expect(controller.state.status, isNot(AuthStatus.authenticated));
        expect(controller.state.errorMessage, isNotNull);
        expect(controller.state.isLoading, isFalse);
      },
    );
  });

  group('AuthController.logout', () {
    test('resets to a fresh unauthenticated state on success', () async {
      when(() => repository.logout()).thenAnswer(
        (_) async => const Result.success(null),
      );

      await controller.logout();

      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(controller.state.user, isNull);
    });
  });

  group('AuthController.changePassword', () {
    test('returns true and clears loading on success', () async {
      when(
        () => repository.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Result.success(null));

      final result = await controller.changePassword(
        currentPassword: 'old12345',
        newPassword: 'new12345',
      );

      expect(result, isTrue);
      expect(controller.state.isLoading, isFalse);
    });

    test('returns false and sets an error message on failure', () async {
      when(
        () => repository.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(
          ValidationFailure('New password must be at least 8 characters.'),
        ),
      );

      final result = await controller.changePassword(
        currentPassword: 'old12345',
        newPassword: 'bad',
      );

      expect(result, isFalse);
      expect(controller.state.errorMessage, isNotNull);
    });
  });
}
