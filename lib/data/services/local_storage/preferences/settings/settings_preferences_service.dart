/// アプリケーション設定の永続化サービスを抽象化するインターフェースです。
/// テーマ設定、言語設定、通知設定など、多岐にわたるアプリケーション設定を管理するための契約を定義します。
abstract class SettingsPreferencesService {
  /// アプリケーションのテーマ設定を取得します。
  String getAppTheme();

  /// アプリケーションのテーマ設定を保存します。
  Future<void> setAppTheme({required String theme});

  /// 選択された言語コードを取得します。
  String getLanguageCode();

  /// 選択された言語コードを保存します。
  Future<void> setLanguageCode({required String code});

  /// 利用規約への同意状況を取得します。
  bool getAgreedToTerms();

  /// 利用規約への同意状況を保存します。
  Future<void> setAgreedToTerms({required bool agreed});

  /// 通知設定を取得します。
  bool getNotificationEnabled();

  /// 通知設定を保存します。
  Future<void> setNotificationEnabled({required bool enabled});

  /// 最終ログイン日時を取得します。
  String getLastLoginDate();

  /// 最終ログイン日時を保存します。
  Future<void> setLastLoginDate({required String date});

  /// 設定情報をクリアします。
  Future<bool> clearSettingsData();
}
