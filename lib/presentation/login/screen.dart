import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/design_system/components/core_app_bar.dart';
import 'package:travel_app/design_system/styles/app_text_style.dart';
import 'package:travel_app/presentation/login/notifier.dart';

/// ログイン画面
class LoginScreen extends StatelessWidget {
  /// コンストラクタ
  const LoginScreen({super.key});

  /// パス
  static const path = '/login';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CoreAppBar(
        title: 'LoginScreen',
      ),
      body: SafeArea(
        child: _Body(),
      ),
    );
  }
}

class _Body extends HookConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(loginScreenProvider.notifier);

    return Center(
      child: SizedBox(
        height: 100,
        width: 200,
        child: ElevatedButton(
          onPressed: () async {
            await notifier.login(
              username: 'emilys',
              password: 'emilyspass',
            );
          },
          child: const Text(
            'Login',
            style: AppTextStyle.t26,
          ),
        ),
      ),
    );
  }
}
