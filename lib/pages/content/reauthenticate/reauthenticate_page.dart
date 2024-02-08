import 'package:fb_auth_riverpod/models/custom_error.dart';
import 'package:fb_auth_riverpod/pages/widgets/buttons.dart';
import 'package:fb_auth_riverpod/pages/widgets/form_fields.dart';
import 'package:fb_auth_riverpod/repositories/auth_repository_provider.dart';
import 'package:fb_auth_riverpod/utils/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReauthenticatePage extends ConsumerStatefulWidget {
  const ReauthenticatePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ReauthenticatePageState();
}

class _ReauthenticatePageState extends ConsumerState<ReauthenticatePage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _sumit() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;

    if (form == null || !form.validate()) return;

    setState(() {
      submitting = true;
    });

    try {
      final navigator = Navigator.of(context);

      await ref.read(authRepositoryProvider).reauthenticateWithCredential(
          _emailController.text.trim(), _passwordController.text.trim());

      navigator.pop('Success');
    } on CustomError catch (e) {
      if (!mounted) return;
      errorDialog(context, e.message);
    } finally {
      setState(() {
        submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reauthenticate'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              reverse: true,
              children: [
                const Text(
                    "This is a security sensitive operation\nyou must have recently signed-in!"),
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
                  onPressed: submitting ? null : _sumit,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  child: Text(submitting ? "Submitting..." : "Reauthenticated"),
                ),
                const SizedBox(
                  height: 20,
                ),
              ].reversed.toList(),
            ),
          ),
        ),
      ),
    );
  }
}
