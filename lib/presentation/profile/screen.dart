import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/design_system/components/core_app_bar.dart';
import 'package:travel_app/design_system/components/core_error.dart';
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

    return Scaffold(
      appBar: CoreAppBar(
        title: 'ProfileScreen',
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(profileScreenProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout),
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
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => ref.read(profileScreenProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // ヘッダーセクション
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha(50),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(user.image),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(height: 16),
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${user.username}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(user.role.toUpperCase()),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(title: '基本情報', icon: Icons.person),
                _InfoCard(
                  items: [
                    _InfoItem(label: '年齢', value: '${user.age}歳'),
                    _InfoItem(label: '性別', value: user.gender),
                    _InfoItem(label: '誕生日', value: user.birthDate),
                    _InfoItem(label: '血液型', value: user.bloodGroup),
                    _InfoItem(label: '身長', value: '${user.height}cm'),
                    _InfoItem(label: '体重', value: '${user.weight}kg'),
                  ],
                ),
                const SizedBox(height: 16),
                const _SectionTitle(title: '連絡先', icon: Icons.contact_mail),
                _InfoCard(
                  items: [
                    _InfoItem(
                      label: 'メール',
                      value: user.email,
                      isCopyable: true,
                    ),
                    _InfoItem(label: '電話番号', value: user.phone),
                  ],
                ),
                const SizedBox(height: 16),
                const _SectionTitle(title: '仕事・学歴', icon: Icons.work),
                _InfoCard(
                  items: [
                    _InfoItem(label: '会社', value: user.company.name),
                    _InfoItem(label: '部署', value: user.company.department),
                    _InfoItem(label: '役職', value: user.company.title),
                    _InfoItem(label: '大学', value: user.university),
                  ],
                ),
                const SizedBox(height: 16),
                const _SectionTitle(title: '住所', icon: Icons.location_on),
                _InfoCard(
                  items: [
                    _InfoItem(
                      label: '住所',
                      value:
                          '${user.address.address}, ${user.address.city}, '
                          '${user.address.state}, ${user.address.country}',
                    ),
                    _InfoItem(label: '郵便番号', value: user.address.postalCode),
                  ],
                ),
                const SizedBox(height: 100), // 下部の余白
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// セクションタイトル
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 情報カード
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.items});

  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: items),
      ),
    );
  }
}

/// 個別情報項目
class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.label,
    required this.value,
    this.isCopyable = false,
  });

  final String label;
  final String value;
  final bool isCopyable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (isCopyable)
            Icon(
              Icons.copy,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }
}
