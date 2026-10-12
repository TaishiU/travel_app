import 'package:travel_app/utils/talker.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// logger パッケージとの互換性を保つショートカット拡張。
/// 既存の logger.d/i/w/e() 呼び出しをそのまま維持するために定義。
extension TalkerShortcuts on Talker {
  /// debug ショートカット
  void d({required dynamic message}) => debug(message?.toString());

  /// info ショートカット
  void i({required dynamic message}) => info(message?.toString());

  /// warning ショートカット
  void w({required dynamic message}) => warning(message?.toString());

  /// error ショートカット
  void e({required dynamic message}) => error(message?.toString());
}

/// アプリ全体で使用するロガー（[talker] の別名）。
final Talker logger = talker;
