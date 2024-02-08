import 'package:fb_auth_riverpod/config/router/route_name.dart';
import 'package:fb_auth_riverpod/models/custom_error.dart';
import 'package:fb_auth_riverpod/pages/auth/signup/sign_up_provider.dart';
import 'package:fb_auth_riverpod/pages/widgets/buttons.dart';
import 'package:fb_auth_riverpod/pages/widgets/form_fields.dart';
import 'package:fb_auth_riverpod/utils/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
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

    ref.read(signUpProvider.notifier).signUp(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(signUpProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) =>
            errorDialog(context, (error as CustomError).message),
      );
    });

    final signUpState = ref.watch(signUpProvider);

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
                  NameFormField(nameController: _nameController),
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
                  ConfirmPasswordFormField(
                    passwordController: _passwordController,
                    labelText: "Confirm password",
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
                      orElse: () => 'Sign Up',
                      loading: () => 'Submitting...',
                    )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already a member?'),
                      CustomTextButton(
                          onPressed: signUpState.maybeWhen(
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
