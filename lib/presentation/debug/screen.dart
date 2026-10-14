import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:travel_app/data/services/web_api/stub_api_enabled_provider.dart';
import 'package:travel_app/utils/talker.dart';

/// デバッグメニュー画面（kDebugMode 限定）
class DebugMenuScreen extends ConsumerWidget {
  /// コンストラクタ
  const DebugMenuScreen({super.key});

  /// パス
  static const path = '/debug';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStub = ref.watch<bool>(isStubApiEnabledProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('デバッグメニュー')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('ログ表示'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TalkerScreen(talker: talker),
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.cloud_off_outlined),
            title: const Text('スタブ切り替え'),
            subtitle: Text(isStub ? 'スタブ' : '実API'),
            value: isStub,
            onChanged: kDebugMode
                ? (value) =>
                      ref.read(isStubApiEnabledProvider.notifier).enabled =
                          value
                : null,
          ),
        ],
      ),
    );
  }
}
