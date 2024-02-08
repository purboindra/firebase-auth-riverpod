import 'package:fb_auth_riverpod/config/router/route_name.dart';
import 'package:fb_auth_riverpod/models/custom_error.dart';
import 'package:fb_auth_riverpod/pages/content/change_password/change_password_provider.dart';
import 'package:fb_auth_riverpod/pages/content/reauthenticate/reauthenticate_page.dart';
import 'package:fb_auth_riverpod/pages/widgets/buttons.dart';
import 'package:fb_auth_riverpod/pages/widgets/form_fields.dart';
import 'package:fb_auth_riverpod/repositories/auth_repository_provider.dart';
import 'package:fb_auth_riverpod/utils/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;

    if (form == null || !form.validate()) return;

    ref.read(changePasswordProvider.notifier).changePassword(
          _passwordController.text.trim(),
        );
  }

  void processSuccessCase() async {
    void showDialogError(String errMsg) {
      errorDialog(context, errMsg);
    }

    try {
      await ref.read(authRepositoryProvider).signOut();
    } on CustomError catch (e) {
      showDialogError(e.message);
    }
  }

  void processRequiresRecentLogin() async {
    final scaffoldMessanger = ScaffoldMessenger.of(context);

    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return const ReauthenticatePage();
      },
    ));

    if (result == 'success') {
      scaffoldMessanger.showSnackBar(
          const SnackBar(content: Text("Successfully reauthenticated")));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(changePasswordProvider, (previous, next) {
      next.whenOrNull(error: (error, stackTrace) {
        final e = error as CustomError;
        if (e.code == 'required-recent-login') {
          processRequiresRecentLogin();
        } else {
          errorDialog(context, (error).message);
        }
      }, data: (_) {
        processSuccessCase();
      });
    });

    final changePasswordState = ref.watch(changePasswordProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: ListView(
                shrinkWrap: true,
                reverse: true,
                children: [
                  const FlutterLogo(
                    size: 150,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('If you change passwrd, you will be signed out!'),
                  const SizedBox(
                    height: 10,
                  ),
                  PasswordFormField(
                      passwordController: _passwordController,
                      labelText: "New Password"),
                  const SizedBox(
                    height: 10,
                  ),
                  ConfirmPasswordFormField(
                      passwordController: _passwordController,
                      labelText: "Confirm New Password"),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomFilledButton(
                    onPressed: changePasswordState.maybeWhen(
                      orElse: () => _submit,
                      loading: () => null,
                    ),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    child: Text(changePasswordState.maybeWhen(
                      orElse: () => 'Change Password',
                      loading: () => 'Submitting...',
                    )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Remember password?'),
                      CustomTextButton(
                          onPressed: changePasswordState.maybeWhen(
                              orElse: () => () => GoRouter.of(context)
                                  .goNamed(RouteName.signin),
                              loading: () => null),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          child: const Text('Sign In')),
                    ],
                  ),
                ].reversed.toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
