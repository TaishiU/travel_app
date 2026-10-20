import 'package:braze_plugin/braze_plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [BrazePlugin] のプロバイダー。
/// `main()` でインスタンスを生成し `overrideWithValue` で注入すること。
/// MethodChannel ハンドラーの重複登録を防ぐため、インスタンスは必ず1つにする。
final brazePluginProvider = Provider<BrazePlugin>(
  (_) =>
      throw UnimplementedError('brazePluginProvider は main() で override が必要'),
);
