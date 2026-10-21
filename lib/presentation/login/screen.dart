import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/design_system/styles/app_color.dart';
import 'package:travel_app/domain/errors/app_error.dart';
import 'package:travel_app/presentation/login/notifier.dart';

/// ログイン画面
class LoginScreen extends StatelessWidget {
  /// コンストラクタ
  const LoginScreen({super.key});

  /// パス
  static const path = '/login';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('アカウント'),
          centerTitle: true,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'ログイン'),
              Tab(text: '新規登録'),
            ],
          ),
        ),
        body: const SafeArea(child: _Body()),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(loginScreenProvider);

    final isLoading = switch (asyncState) {
      AsyncLoading() => true,
      AsyncData(:final value) => value.isLoading,
      AsyncError() => false,
    };

    final errorMessage = switch (asyncState) {
      AsyncError(:final error) => _toErrorMessage(error: error),
      _ => null,
    };

    return Stack(
      children: [
        TabBarView(
          children: [
            _LoginForm(errorMessage: errorMessage),
            _RegisterForm(errorMessage: errorMessage),
          ],
        ),
        if (isLoading)
          const Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: Colors.black54,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
      ],
    );
  }

  String _toErrorMessage({required Object error}) => switch (error) {
    UnauthorizedError() => 'メールアドレスまたはパスワードが正しくありません',
    ClientError(statusCode: 409) => 'このメールアドレスはすでに登録されています',
    ClientError(statusCode: 422) => '入力内容を確認してください',
    NetworkError() => '通信エラーが発生しました。再度お試しください',
    _ => 'しばらく時間をおいてから再度お試しください',
  };
}

class _LoginForm extends HookConsumerWidget {
  const _LoginForm({required this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController(text: 'test3@example.com');
    final passwordController = useTextEditingController(text: 'password123');
    final notifier = ref.watch(loginScreenProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (errorMessage != null) ...[
            _ErrorBanner(message: errorMessage!),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'メールアドレス'),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'パスワード'),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await notifier.login(
                email: emailController.text,
                password: passwordController.text,
              );
            },
            child: const Text('ログイン'),
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends HookConsumerWidget {
  const _RegisterForm({required this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController(text: 'test3@example.com');
    final passwordController = useTextEditingController(text: 'password123');
    final displayNameController = useTextEditingController();
    final notifier = ref.watch(loginScreenProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (errorMessage != null) ...[
            _ErrorBanner(message: errorMessage!),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'メールアドレス'),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'パスワード'),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: displayNameController,
            decoration: const InputDecoration(labelText: '表示名（任意）'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final displayName = displayNameController.text.isEmpty
                  ? null
                  : displayNameController.text;
              await notifier.register(
                email: emailController.text,
                password: passwordController.text,
                displayName: displayName,
              );
            },
            child: const Text('登録する'),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColor.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColor.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColor.error, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
