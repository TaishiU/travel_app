import 'package:flutter/material.dart';
import 'package:travel_app/domain/errors/app_error.dart';

/// 共通エラーコンポーネント
///
/// 画面描画時のAsyncErrorにて、例外の種類に応じたメッセージとUIを表示します。
class CoreError extends StatelessWidget {
  /// コンストラクタ
  const CoreError({
    required this.error,
    required this.onPressed,
    super.key,
  });

  /// 発生したエラーオブジェクト
  final Object error;

  /// 再読み込みボタン押下時のコールバック
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // エラーの種類に応じた表示情報を抽出
    final (message, icon, showRetry) = switch (error) {
      NetworkError() => (
        'インターネットに接続されていません。\n通信環境をご確認ください。',
        Icons.wifi_off,
        true,
      ),
      ServerError() => (
        'サーバーで一時的な不具合が発生しています。\nしばらく経ってからお試しください。',
        Icons.dns,
        true,
      ),
      ClientError(:final statusCode) when statusCode == 404 => (
        '対象のデータが見つかりませんでした。',
        Icons.search_off,
        false,
      ),
      ClientError() => (
        'リクエストが正しくありません。\nアプリのバージョンを確認してください。',
        Icons.error_outline,
        false,
      ),
      _ => (
        '予期せぬエラーが発生しました。\n$error',
        Icons.bug_report,
        true,
      ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (showRetry) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.refresh),
                label: const Text('再読み込み'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
