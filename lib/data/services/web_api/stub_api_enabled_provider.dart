import 'package:hooks_riverpod/hooks_riverpod.dart';

/// スタブ切り替えフラグのProvider
final NotifierProvider<StubApiEnabledNotifier, bool> isStubApiEnabledProvider =
    NotifierProvider<StubApiEnabledNotifier, bool>(
      StubApiEnabledNotifier.new,
    );

/// スタブ切り替えフラグのNotifier
class StubApiEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// 現在のフラグ値
  bool get enabled => state;

  /// フラグを更新
  set enabled(bool value) => state = value;
}
