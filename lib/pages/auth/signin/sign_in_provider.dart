import 'package:fb_auth_riverpod/repositories/auth_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_in_provider.g.dart';

@riverpod
class SignIn extends _$SignIn {
  @override
  FutureOr<void> build() {
    print('BUILDD');
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard<void>(() async {
      return ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
    });
  }
}
