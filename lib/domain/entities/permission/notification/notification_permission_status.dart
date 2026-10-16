/// Push通知権限のドメインレベルの状態。
///
/// OS別の PermissionStatus をドメイン概念に昇華し、
/// 上位層が permission_handler に直接依存しないようにする。
enum NotificationPermissionStatus {
  /// 権限ダイアログ未表示（iOS: not_determined / Android: POST_NOTIFICATIONS 未要求）
  notDetermined,

  /// 通知が許可されている（iOS: granted / Android: granted）
  granted,

  /// 一度拒否済み・再要求可能（iOS: denied / Android: 1st_denied）
  ///
  /// iOS では OS設定への誘導が必要。Android では rationale UI + 再プロンプト可能。
  denied,

  /// 恒久的に拒否（アプリから再要求不可 — OS設定への誘導が必要）
  ///
  /// iOS: ユーザーが拒否済み / Android: 2回目拒否または「今後表示しない」
  permanentlyDenied,
}
