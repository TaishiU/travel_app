# BRAZE-013: Pushトークン登録

## ステータス

完了（2026-10-18）、不具合対応（2026-10-19）

---

## 目的

FCMトークン（Android）/ APNsトークン（iOS）をBrazeに登録する。  
アプリ起動時に `RegisterPushTokenUseCase.register()` を呼び出すインフラを構築する。

---

## 変更ファイル一覧

| ファイル | 種別 | 内容 |
|---|---|---|
| `lib/data/services/braze/push_token/push_token_service.dart` | 新規 | Pushトークン登録のサービスインターフェース |
| `lib/data/services/braze/push_token/push_token_service_impl.dart` | 新規 | FCMトークン取得 → Braze登録の実装 + Provider |
| `lib/data/services/braze/push_token/stub_push_token_service_impl.dart` | 新規 | スタブ実装（テスト・ローカル開発用） + Provider |
| `lib/domain/interfaces/push_token/push_token_repository.dart` | 新規 | Pushトークン登録のRepositoryインターフェース |
| `lib/data/repositories/push_token/push_token_repository_impl.dart` | 新規 | Repository実装 + Provider |
| `lib/domain/use_cases/push_token/register_push_token_use_case.dart` | 新規 | ドメインユースケース + Provider |
| `lib/main.dart` | 変更 | `ProviderScope` → `ProviderContainer` + `UncontrolledProviderScope` へ移行。起動時に `RegisterPushTokenUseCase.register()` を呼ぶ。例外をキャッチしてアプリ起動継続（後述） |
| `android/app/src/main/AndroidManifest.xml` | 変更 | Braze SDK が注入する `firebase_messaging_installation_id_enabled=true` を `tools:replace` でオーバーライド（後述） |

---

## 実装詳細

### 1. プラットフォーム別のトークン登録方式

| プラットフォーム | 方式 | 実装 |
|---|---|---|
| **iOS** | `push.automation = true`（BRAZE-010設定済み）でAPNsトークン取得・Braze登録を自動処理 | `register()` は no-op |
| **Android** | `FirebaseMessaging.instance.getToken()` でFCMトークンを取得 → `brazePlugin.registerPushToken(token)` | Dart層で明示的に登録 |

iOSは `AppDelegate.swift` の `BrazePlugin.configure { configuration.push.automation = true }` がAPNsトークン取得・Braze転送をすべて担うため、追加実装不要。

### 2. Service層 (`PushTokenServiceImpl`)

```dart
class PushTokenServiceImpl implements PushTokenService {
  PushTokenServiceImpl({required BrazePlugin brazePlugin})
      : _brazePlugin = brazePlugin {
    if (Platform.isAndroid) {
      // トークン更新時にBrazeへ再登録
      FirebaseMessaging.instance.onTokenRefresh.listen(
        _brazePlugin.registerPushToken,
      );
    }
  }

  @override
  Future<void> register() async {
    if (!Platform.isAndroid) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      _brazePlugin.registerPushToken(token);
    }
  }
}
```

- **初回登録**: `register()` でFCMトークンを取得してBrazeに登録
- **更新フォロー**: コンストラクタで `onTokenRefresh.listen()` を設定。インスタンス生成時（Provider初期化時）に1回だけ登録されるため多重購読なし
- サブスクリプションはアプリライフタイム中保持（意図した設計 — キャンセル不要）

`braze.xml` に `com_braze_firebase_cloud_messaging_registration_enabled: true` が設定されているため、BrazeがAndroid側でFCMを自動処理しようとする。Dart層でも明示的に登録することで確実性を高めている（冪等）。

### 3. main.dart の変更（`ProviderContainer` + `UncontrolledProviderScope`）

BRAZE-013以前: `ProviderScope` でアプリ起動

```dart
runApp(ProviderScope(observers: [...], overrides: [...], child: const MyApp()));
```

BRAZE-013以降: `ProviderContainer` を先に作り、UseCase呼び出し後に `UncontrolledProviderScope` へ渡す

```dart
final container = ProviderContainer(observers: [...], overrides: [...]);
try {
  await container.read(registerPushTokenUseCaseProvider).register();
} on Exception catch (error) {
  talker.warning('Push token registration failed. App continues without push token.', error);
}
runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
```

**移行理由**: `runApp` 前にProviderにアクセスするためには `ProviderContainer` を直接生成する必要がある。`ProviderScope` は `Widget` のため `runApp` 前に使えない。`UncontrolledProviderScope` は既存の `container` を `Widget` ツリーに expose する標準パターン。

**try-catch 追加理由**: `register()` 呼び出しチェーン全体（UseCase → Repository → Service）に例外処理がなく、`FirebaseMessaging.getToken()` がネットワーク不達・FCMサービス不可等で例外を投げると `runApp` に到達せずアプリ起動不能になる。プッシュトークン登録失敗はアプリ起動をブロックすべきでないため、`main()` でキャッチして継続する。

### 4. AndroidManifest.xml — Braze SDK によるマニフェスト汚染の回避

**事象**: Android実機で `FirebaseMessaging.getToken()` が以下の例外を投げてトークン取得不能。

```
java.lang.IllegalStateException: API disabled. Please use register() instead or
enable this API by removing <meta-data android:name="firebase_messaging_installation_id_enabled"
android:value="true" /> from your app's manifest.
```

**原因**: Braze Android SDK (`android-sdk-ui-43.1.1`) が自身の `AndroidManifest.xml` に `firebase_messaging_installation_id_enabled=true` を注入する。この値が `true` の場合、Firebase Messaging の新 API（Firebase Installations API）が無効化され `getToken()` が `IllegalStateException` を投げる。

**対応**: アプリの `AndroidManifest.xml` で `tools:replace="android:value"` を使って `false` で上書き。

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
  <application ...>
    <!-- Braze Android SDK が firebase_messaging_installation_id_enabled=true を注入するため上書き。
         true のままだと FirebaseMessaging.getToken() が IllegalStateException を投げる。 -->
    <meta-data
        android:name="firebase_messaging_installation_id_enabled"
        android:value="false"
        tools:replace="android:value" />
  </application>
</manifest>
```

この回避方法は Braze SDK 自身の `AndroidManifest.xml` コメントにも明記されている公式手順。  
適用後は `flutter clean && flutter run` によるクリーンビルドが必要（インクリメンタルビルドでは merged manifest が更新されない）。

---

### 5. UseCase / Repository は薄いパススルー

```
RegisterPushTokenUseCase.register()
  → PushTokenRepository.register()
    → PushTokenService.register()
```

ドメインユースケース / Repositoryパターンへの準拠のため各層を実装。現時点でロジックは薄いが、将来の拡張（ユーザー識別後のトークン更新通知、エラーハンドリング追加等）に対応できる構造を確保している。

---

## 設計上の決定事項

### `onTokenRefresh` リスナーの配置場所

**コンストラクタで設定**（`register()` 内ではなく）。

理由:
- `register()` は複数回呼ばれうるが、コンストラクタはProviderが生成される1回のみ実行される → 多重購読を防ぐ
- `register()` が呼ばれる前にトークン更新が発生しても捕捉できる

### iOSでの no-op 判断

iOS側は `push.automation = true` によりBrazeが自動でAPNsトークン登録を処理する。Dart層で `FirebaseMessaging.instance.getAPNSToken()` を呼んで手動登録することも可能だが、Brazeの自動処理と二重になるため不採用。

### `ProviderContainer` の `observers` はProviderScopeと同一

`ProviderScope.observers` と `ProviderContainer.observers` は同じ `List<ProviderObserver>` を受け付ける。`UnauthorizedErrorObserver` / `TalkerRiverpodObserver` はそのまま移行可能。

---

## 未完了・引き継ぎ事項

| 項目 | 引き継ぎ先 |
|---|---|
| ログイン時の `changeUser()` 実装（トークンとユーザーの紐付け） | BRAZE-014 |
| `push_permission_status` 属性送信（トークン登録と権限状態をBrazeに通知） | BRAZE-015 |
