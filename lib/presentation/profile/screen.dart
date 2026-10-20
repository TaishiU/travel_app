import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/design_system/components/core_app_bar.dart';
import 'package:travel_app/design_system/components/core_error.dart';
import 'package:travel_app/domain/entities/user/user.dart';
import 'package:travel_app/presentation/login/screen.dart';
import 'package:travel_app/presentation/profile/notifier.dart';
import 'package:travel_app/presentation/profile/state.dart';

/// プロフィール画面
class ProfileScreen extends HookConsumerWidget {
  /// コンストラクタ
  const ProfileScreen({super.key});

  /// パス
  static const path = '/profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(profileScreenProvider);
    final isLoggedIn = switch (viewModel) {
      AsyncData(:final value) => value.isLoggedIn,
      _ => false,
    };

    return Scaffold(
      appBar: CoreAppBar(
        title: 'ProfileScreen',
        actions: [
          if (isLoggedIn)
            IconButton(
              onPressed: () async {
                await ref.read(profileScreenProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout, color: Colors.red),
            )
          else
            IconButton(
              onPressed: () => context.go(LoginScreen.path),
              icon: const Icon(Icons.login),
            ),
        ],
      ),
      body: switch (viewModel) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncData(:final value) => _Body(state: value),
        AsyncError(:final error) => CoreError(
          error: error,
          onPressed: () => ref.read(profileScreenProvider.notifier).refresh(),
        ),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(profileScreenProvider.notifier).refresh(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

/// プロフィール画面本体
class _Body extends HookConsumerWidget {
  const _Body({required this.state});

  final ProfileScreenState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = state.user;
    if (user == null) {
      return _NotLoggedInView(onLoginTap: () => context.go(LoginScreen.path));
    }
    return _ProfileView(user: user);
  }
}

/// 未ログイン時の表示
class _NotLoggedInView extends StatelessWidget {
  const _NotLoggedInView({required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 80,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text('ログインしていません', style: theme.textTheme.titleMedium),
          const SizedBox(height: 24),
          FilledButton(onPressed: onLoginTap, child: const Text('ログイン')),
        ],
      ),
    );
  }
}

/// ログイン済みの表示
class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              (user.displayName ?? user.email).characters.first.toUpperCase(),
              style: theme.textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 16),
          if (user.displayName != null)
            Center(
              child: Text(
                user.displayName!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              user.email,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _InfoRow(label: 'ID', value: user.id),
          _InfoRow(label: 'メール', value: user.email),
          _InfoRow(label: '表示名', value: user.displayName ?? '未設定'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
