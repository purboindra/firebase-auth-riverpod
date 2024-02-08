import 'package:fb_auth_riverpod/config/router/route_name.dart';
import 'package:fb_auth_riverpod/models/custom_error.dart';
import 'package:fb_auth_riverpod/pages/auth/reset_password/reset_password_provider.dart';
import 'package:fb_auth_riverpod/pages/widgets/buttons.dart';
import 'package:fb_auth_riverpod/pages/widgets/form_fields.dart';
import 'package:fb_auth_riverpod/utils/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;

    if (form == null || !form.validate()) return;

    ref.read(resetPasswordProvider.notifier).resetPassword(
          email: _emailController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(resetPasswordProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) =>
            errorDialog(context, (error as CustomError).message),
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Password resel email has been sent")));
          GoRouter.of(context).goNamed(RouteName.signin);
        },
      );
    });

    final resetPasswordState = ref.watch(resetPasswordProvider);

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
                  EmailFormField(emailController: _emailController),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomFilledButton(
                    onPressed: resetPasswordState.maybeWhen(
                      orElse: () => _submit,
                      loading: () => null,
                    ),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    child: Text(resetPasswordState.maybeWhen(
                      orElse: () => 'Reset Password',
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
                          onPressed: resetPasswordState.maybeWhen(
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
