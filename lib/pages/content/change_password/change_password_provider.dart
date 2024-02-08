import 'package:fb_auth_riverpod/repositories/auth_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'change_password_provider.g.dart';

@riverpod
class ChangePassword extends _$ChangePassword {
  @override
  FutureOr<void> build() {}

  Future<void> changePassword(String password) async {
    state = const AsyncLoading<void>();

    state = await AsyncValue.guard(() async {
      return ref.read(authRepositoryProvider).changePassword(password);
    });
  }
}
