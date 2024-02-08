import 'package:fb_auth_riverpod/config/router/route_name.dart';
import 'package:fb_auth_riverpod/models/custom_error.dart';
import 'package:fb_auth_riverpod/pages/auth/signin/sign_in_provider.dart';
import 'package:fb_auth_riverpod/pages/widgets/buttons.dart';
import 'package:fb_auth_riverpod/pages/widgets/form_fields.dart';
import 'package:fb_auth_riverpod/utils/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SigninPage extends ConsumerStatefulWidget {
  const SigninPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SigninPageState();
}

class _SigninPageState extends ConsumerState<SigninPage> {
  final _formKey = GlobalKey<FormState>();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;

    if (form == null || !form.validate()) return;

    ref.read(signInProvider.notifier).signIn(
        email: _emailController.text, password: _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(signInProvider, (previous, next) {
      print("REF LISTEN");

      next.whenOrNull(
        error: (error, stackTrace) =>
            errorDialog(context, (error as CustomError).message),
      );
    });

    final signUpState = ref.watch(signInProvider);

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
                  PasswordFormField(
                    passwordController: _passwordController,
                    labelText: 'Password',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomFilledButton(
                    onPressed: signUpState.maybeWhen(
                      orElse: () => _submit,
                      loading: () => null,
                    ),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    child: Text(signUpState.maybeWhen(
                      orElse: () => 'Sign In',
                      loading: () => 'Submitting...',
                    )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Havent became a member?'),
                      CustomTextButton(
                          onPressed: signUpState.maybeWhen(
                              orElse: () => () => GoRouter.of(context)
                                  .goNamed(RouteName.signup),
                              loading: () => null),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          child: const Text('Sign Up')),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextButton(
                      onPressed: signUpState.maybeWhen(
                          orElse: () => () => GoRouter.of(context)
                              .goNamed(RouteName.resetPassword),
                          loading: () => null),
                      fontSize: 18,
                      foregroundColor: Colors.red,
                      fontWeight: FontWeight.bold,
                      child: const Text('Forgot Password')),
                ].reversed.toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
