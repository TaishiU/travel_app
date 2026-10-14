# BRAZE-011: 環境別設定

## ステータス

完了（2026-10-14）

---

## 目的

API キー・エンドポイント・環境フラグを dev / staging / prod で分離する。
`BRAZE-010` でプレースホルダーとして残した `BrazeConfig` と `braze.xml` の値を、
`--dart-define=FLAVOR=<dev|staging|prod>` によるビルド時注入に切り替える。

---

## 変更ファイル一覧

| ファイル | 種別 | 内容 |
|---|---|---|
| `lib/config/braze_config.dart` | 変更 | `String.fromEnvironment('FLAVOR')` で FLAVOR を読み取り、switch で API キー / エンドポイントを切り替え |
| `android/app/build.gradle.kts` | 変更 | `dart-defines` プロパティをパースして `resValue` で `com_braze_api_key` / `com_braze_custom_endpoint` を注入 |
| `android/app/src/main/res/values/braze.xml` | 変更 | `com_braze_api_key` / `com_braze_custom_endpoint` を削除（build.gradle.kts 側で注入） |

iOS ネイティブ（`AppDelegate.swift`）の変更なし。
API キー / エンドポイントは Dart の `brazePlugin.initialize()` 経由で渡すため、iOS ネイティブ側に直接設定する必要がない。

---

## 設計上の決定事項

### 案A（採用）: `--dart-define` でビルド時注入

#### 選定理由

- Flutter が dart-defines をそのまま Gradle の `dart-defines` プロパティとして渡すため、
  Dart 層と Android ネイティブ層で単一の `FLAVOR` 値を共有できる
- `.env` ファイルや追加ライブラリ（`flutter_config` / `envied`）が不要でセットアップが簡潔
- Android Studio の Run/Debug Configuration → **Additional run args** に
  `--dart-define=FLAVOR=dev` を入力するだけで切り替えられる

#### 案B（不採用）: `flutter_config` / `envied`

- `envied` はコード生成が必要で build_runner の実行コストが増える
- `flutter_config` は非推奨傾向にあり、最新の Flutter バージョンとの互換リスクがある

---

## 実装詳細

### 1. Dart 層 (`lib/config/braze_config.dart`)

`String.fromEnvironment` は **コンパイル時定数**として評価される。
`--dart-define=FLAVOR=dev` を渡さなかった場合は `defaultValue: 'dev'` にフォールバック。

```dart
static const _flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

static String get androidApiKey => switch (_flavor) {
  'prod'    => 'YOUR_PROD_ANDROID_API_KEY',
  'staging' => 'YOUR_STG_ANDROID_API_KEY',
  _         => 'YOUR_DEV_ANDROID_API_KEY',
};
```

### 2. Android ネイティブ層 (`android/app/build.gradle.kts`)

Flutter は `--dart-define` の値を **Base64 エンコードしたカンマ区切り文字列** として
Gradle の `dart-defines` プロパティに渡す。

```kotlin
val dartDefines: Map<String, String> = if (project.hasProperty("dart-defines")) {
    (project.property("dart-defines") as String)
        .split(",")
        .filter { it.isNotEmpty() }
        .associate { encoded ->
            val decoded = String(java.util.Base64.getDecoder().decode(encoded))
            val eqIndex = decoded.indexOf('=')
            if (eqIndex >= 0) decoded.substring(0, eqIndex) to decoded.substring(eqIndex + 1)
            else decoded to ""
        }
} else { emptyMap() }

val flavorName = dartDefines["FLAVOR"] ?: "dev"
```

`defaultConfig` 内で `resValue` を使って XML リソースとして注入する。
`braze.xml` と同名のリソースが重複するとビルドエラーになるため、`braze.xml` 側から削除した。

```kotlin
resValue("string", "com_braze_api_key", brazeAndroidApiKey)
resValue("string", "com_braze_custom_endpoint", brazeEndpoint)
```

### 3. `braze.xml` の変更

`com_braze_api_key` / `com_braze_custom_endpoint` を削除し、
build.gradle.kts の `resValue` から供給する形に一元化した。
FCM 関連設定（`com_braze_firebase_cloud_messaging_registration_enabled` / `com_braze_firebase_cloud_messaging_sender_id`）は
環境によらず共通のため `braze.xml` に残す。

---

## Android Studio でのビルド設定手順

1. エディタ右上の **Run / Debug Configuration** を開く
2. **Edit Configurations...** を選択
3. 対象の Flutter 構成を選択（または `+` で新規作成）
4. **Additional run args** に以下を入力:
   - dev 環境: `--dart-define=FLAVOR=dev`
   - staging 環境: `--dart-define=FLAVOR=staging`
   - prod 環境: `--dart-define=FLAVOR=prod`
5. **Apply → OK** で保存

---

## 動作確認手順（APIキー実値設定後に実施）

1. `lib/config/braze_config.dart` の各 FLAVOR のプレースホルダーを実際の API キーに置き換える
2. `android/app/src/main/res/values/braze.xml` の `com_braze_firebase_cloud_messaging_sender_id` に
   `google-services.json` の `project_number` を設定する
3. Android Studio の Run/Debug Configuration で `--dart-define=FLAVOR=dev` を設定してビルド
4. Braze ダッシュボード（dev ワークスペース）でテスト端末が登録されることを確認
5. `staging` / `prod` で同様に確認し、別ワークスペースに接続されることを確認
6. `flutter analyze` でエラーなし ✅（実施済み）

---

## 未完了・引き継ぎ事項

| 項目 | 引き継ぎ先 |
|---|---|
| 各 FLAVOR の API キー / エンドポイントに実値を設定する | 実機確認フェーズ |
| `com_braze_firebase_cloud_messaging_sender_id` に実値を設定する | 実機確認フェーズ |
| Push 権限要求フロー実装 | BRAZE-012 |
| FCM トークン → Braze 登録確認 | BRAZE-013 |
