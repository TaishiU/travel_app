# SEC-001: ロガーによる機密情報の漏洩

**対象ファイル**: `lib/utils/talker.dart` / `lib/data/services/web_api/api_client.dart`
**深刻度**: Critical（リスク1〜3） / Medium（リスク4） / Low（リスク5）

---

## 背景

`talker_flutter` パッケージを導入し、Notifier / UseCase / Repository / Service の各レイヤーに `logger.d/i/w/e()` を仕込んでいる。Talker は内部で `debugPrint` → `print` を呼ぶが、Dart の `print()` は debug / profile / **release の全ビルドモードで動作する**。現在 `TalkerFlutter.init()` にリリースモード制御を加えていないため、リリースビルドでもログが出力される状態にある。

---

## リスク一覧

---

### リスク1: Authorization ヘッダー（Bearer token）の平文ログ出力

**深刻度**: Critical

#### 現状の課題

`lib/data/services/web_api/api_client.dart:251-253`

```dart
if (authHeaders.isNotEmpty) {
  logger.d(message: 'リクエストヘッダー: $authHeaders');
}
```

`authHeaders` には `Authorization: Bearer <accessToken>` が含まれる。全 API リクエストのたびにアクセストークンが丸ごとログに出力される。

#### 影響

- Android: `adb logcat` でアクセストークンを読み取れる
- iOS: Xcode Console / クラッシュレポートからトークンが漏洩
- 攻撃者がトークンを取得すると、そのユーザーとして任意の API 操作が可能になる

#### 解決策

1. `talker.dart` でリリースビルド時にログを無効化する（→ 後述の「共通対策」）
2. 恒久対策としてヘッダーログ自体を削除するか、`Authorization` の値をマスクして出力する

```dart
// マスク例
final maskedHeaders = authHeaders.map(
  (key, value) => MapEntry(
    key,
    key == 'Authorization' ? 'Bearer ***' : value,
  ),
);
logger.d(message: 'リクエストヘッダー: $maskedHeaders');
```

---

### リスク2: パスワードの平文ログ出力

**深刻度**: Critical

#### 現状の課題

`lib/data/services/web_api/api_client.dart:254-256`

```dart
if (requestBody != null) {
  logger.d(message: 'リクエストボディ: $requestBody');
}
```

login / register のリクエストボディは `{'email': email, 'password': password}`。ユーザーのパスワードが平文でログに出力される。

#### 影響

- デバイスへの物理アクセスや `adb logcat` でパスワードを取得可能
- 他サービスでのパスワード使い回しがある場合、アカウント乗っ取りに直結

#### 解決策

1. 共通対策（リリースビルドでログ無効化）を適用する
2. 恒久対策としてリクエストボディのログを削除するか、`password` フィールドをマスクして出力する

```dart
// マスク例
final maskedBody = requestBody.map(
  (key, value) => MapEntry(
    key,
    key == 'password' ? '***' : value,
  ),
);
logger.d(message: 'リクエストボディ: $maskedBody');
```

---

### リスク3: レスポンスボディ（トークン）の平文ログ出力

**深刻度**: Critical

#### 現状の課題

`lib/data/services/web_api/api_client.dart:285-286`

```dart
..i(message: 'APIレスポンス受信: ステータスコード ${response.statusCode}')
..i(message: 'レスポンスボディ: ${response.body}');
```

login / register 成功レスポンスのボディには `accessToken` と `refreshToken` が含まれる。info レベルのため debug ビルドに限らず出力レベルが高い。

#### 影響

- アクセストークン・リフレッシュトークンが両方ログに出力される
- リフレッシュトークンが漏洩すると、トークン期限後も不正アクセスが継続可能になる

#### 解決策

1. 共通対策（リリースビルドでログ無効化）を適用する
2. 恒久対策としてレスポンスボディのログをステータスコードのみに絞る

```dart
logger.i(message: 'APIレスポンス受信: ステータスコード ${response.statusCode}');
// レスポンスボディの全体ログは削除
```

---

### リスク4: TalkerView ウィジェットのリリースビルド混入

**深刻度**: Medium

#### 現状の課題

`talker_flutter` パッケージは `TalkerScreen` / `TalkerView` というアプリ内ログビューアウィジェットを提供している。デバッグメニューや隠し画面から遷移できる状態でリリースビルドに混入していると、攻撃者がアプリ内から上記リスク1〜3のログを全て閲覧できる。

#### 影響

- アプリを持っているだけで全ログを参照可能
- 特別なツール（adb 等）なしに機密情報を取得できる

#### 解決策

`TalkerScreen` / `TalkerView` への遷移を `kDebugMode` / `kReleaseMode` で制御する。

```dart
if (kDebugMode)
  ListTile(
    title: const Text('Logs'),
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TalkerScreen(talker: talker)),
    ),
  ),
```

---

### リスク5: HTTP による平文通信（本番環境混入リスク）

**深刻度**: Low（現時点はローカル開発設定のため）

#### 現状の課題

`lib/data/services/web_api/api_client.dart:18`

```dart
return 'http://$host:3000/v1/';
```

localhost 向けの開発設定だが、`https://` の本番 URL がコメントアウトされたまま。リリース時にここを差し替え忘れると全通信が平文になる。

#### 影響

- 通信経路上の傍受（中間者攻撃）で認証情報・レスポンスデータが筒抜けになる
- 上記リスク1〜3と組み合わさると、ネットワーク上からもトークン・パスワードを取得可能

#### 解決策

ビルドフレーバー（`dart-define` または `--flavor`）で環境別の URL を管理し、リリースビルドが誤って `http://` を使わない仕組みを設ける。

```dart
// dart-define で注入する例
const baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'https://api.example.com/v1/');
```

---

## 共通対策: リリースビルドでのログ全無効化

上記リスク1〜3の根本原因は `talker.dart` にリリースモード制御がないこと。最小変更で全リスクを封じる修正は以下の1箇所：

**`lib/utils/talker.dart`**

```dart
import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';

final Talker talker = TalkerFlutter.init(
  settings: TalkerSettings(
    enabled: !kReleaseMode, // リリースビルドでは全ログ無効
  ),
);
```

### 注意点

この対策はリリース時の漏洩を防ぐが、**パスワード・トークンをログに出力するコード自体は残る**。将来 `kReleaseMode` 条件を変更した際や、開発中に `adb logcat` でログを閲覧した外部者による漏洩は防げない。リスク1〜3の恒久対策（マスキングまたはログ削除）と組み合わせることを推奨する。
