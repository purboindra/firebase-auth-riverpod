import 'package:fb_auth_riverpod/config/router/route_name.dart';
import 'package:fb_auth_riverpod/constants/firebase_constants.dart';
import 'package:fb_auth_riverpod/models/custom_error.dart';
import 'package:fb_auth_riverpod/pages/content/home/home_provider.dart';
import 'package:fb_auth_riverpod/repositories/auth_repository_provider.dart';
import 'package:fb_auth_riverpod/utils/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = fbAuth.currentUser!.uid;

    final profileState = ref.watch(profileProvider(uid));

    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              onPressed: () async {
                try {
                  await ref.read(authRepositoryProvider).signOut();
                } on CustomError catch (e) {
                  if (!context.mounted) return;
                  errorDialog(context, e.message);
                }
              },
              icon: const Icon(Icons.logout),
            ),
            IconButton(
                onPressed: () {
                  ref.invalidate(profileProvider);
                },
                icon: const Icon(Icons.refresh))
          ],
        ),
        body: profileState.when(
          data: (data) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(data.id),
                const SizedBox(
                  height: 5,
                ),
                Text(data.email),
                const SizedBox(
                  height: 5,
                ),
                Text(data.name),
                const SizedBox(
                  height: 10,
                ),
                OutlinedButton(
                    onPressed: () {
                      GoRouter.of(context).pushNamed(RouteName.changePassword);
                    },
                    child: const Text("Change Password")),
              ],
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Text((error as CustomError).message),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ));
  }
}
