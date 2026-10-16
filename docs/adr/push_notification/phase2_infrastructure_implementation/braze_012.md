# BRAZE-012: Push権限管理

## ステータス

完了（2026-10-14）

---

## 目的

`push_permission_status` の取得・権限要求・権限変更検知を実装する。
iOS / Android 13+ で通知権限状態を正しく取得できる状態を作り、
後続チケット（BRAZE-015）での `push_permission_status` 属性送信の基盤を提供する。

---

## 変更ファイル一覧

| ファイル | 種別 | 内容 |
|---|---|---|
| `pubspec.yaml` | 変更 | `permission_handler: ^13.0.2` 追加 |
| `android/app/src/main/AndroidManifest.xml` | 変更 | `POST_NOTIFICATIONS` 権限追加（Android 13+） |
| `android/gradle.properties` | 変更 | `android.enableJetifier=true` 追加（v13 必須要件） |
| `ios/Podfile` | 変更 | `PERMISSION_NOTIFICATIONS=1` preprocessor macro 追加 |
| `lib/domain/entities/permission/notification/notification_permission_status.dart` | 新規 | 権限状態のドメイン enum（`permission_handler` 非依存） |
| `lib/domain/interfaces/permission/notification/notification_permission_repository.dart` | 新規 | 権限管理リポジトリインターフェース |
| `lib/data/services/permission/notification/notification_permission_service.dart` | 新規 | 権限取得・要求のサービスインターフェース |
| `lib/data/services/permission/notification/notification_permission_service_impl.dart` | 新規 | `permission_handler` を用いた実装（iOS / Android をクラス分離）+ Provider |
| `lib/data/services/permission/notification/stub_notification_permission_service_impl.dart` | 新規 | スタブ実装（テスト・ローカル開発用）+ Provider |
| `lib/data/services/local_storage/preferences/permission/notification/android_notification_permission_preferences_service.dart` | 新規 | Android 権限フラグ永続化サービスインターフェース（iOS はフラグ管理不要のため Android 専用） |
| `lib/data/services/local_storage/preferences/permission/notification/android_notification_permission_preferences_service_impl.dart` | 新規 | SharedPreferences によるフラグ永続化実装 + Provider |
| `lib/data/repositories/permission/notification/notification_permission_repository_impl.dart` | 新規 | 権限管理リポジトリ実装 + Provider |
| `lib/domain/use_cases/permission/notification/notification_permission_use_case.dart` | 新規 | 権限管理ドメインユースケース + Provider |

---

## 実装詳細

### 1. 依存パッケージ

```yaml
# pubspec.yaml
permission_handler: ^13.0.2  # 解決バージョン: 13.0.2
```

### 2. Android: POST_NOTIFICATIONS 権限（Android 13+ / API 33+）

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

- API 33 未満では通知は自動的に許可されるため、このエントリがあっても古い端末では権限ダイアログは出ない
- `permission_handler` が API 33+ のみ実行時権限を要求する

### 3. Android: gradle.properties（v13 必須要件）

```properties
android.useAndroidX=true   # 既存
android.enableJetifier=true  # v13 docs で必須と明記 → 追加
```

`compileSdkVersion` については `flutter.compileSdkVersion = 36`（v13 要件の 35 を満たす）のため `build.gradle.kts` の変更は不要。

### 4. iOS: Podfile preprocessor macro

```ruby
# ios/Podfile
target.build_configurations.each do |config|
  config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
    '$(inherited)',
    'PERMISSION_NOTIFICATIONS=1',
  ]
end
```

`permission_handler` v13 では CocoaPods 利用時に `GCC_PREPROCESSOR_DEFINITIONS` で使用する権限を明示する必要がある。
`PERMISSION_NOTIFICATIONS=1` を追加しないと `Permission.notification.status` が常に `denied` を返す。

> **補足（v13 SPM）**: Swift Package Manager 経由では `PERMISSION_NOTIFICATIONS` はデフォルト有効のためマクロ不要。
> 本プロジェクトは CocoaPods を使用しているため、マクロの明示が必要。

### 5. ドメイン enum: `NotificationPermissionStatus`

`permission_handler` の `PermissionStatus` をドメイン概念に変換し、上位層が `permission_handler` に直接依存しないようにする。

| ドメイン値 | 対応する `PermissionStatus` | 意味 |
|---|---|---|
| `notDetermined` | `denied`（iOS: `UNAuthorizationStatus.notDetermined` / Android: flag = false） | 権限ダイアログ未表示。iOS 未要求 / Android `POST_NOTIFICATIONS` 未要求 |
| `granted` | `granted` | 通知が許可されている |
| `denied` | `denied`（Android: flag = true） / `provisional` / その他 | 1回目拒否済み（Android のみ）。再要求可能 |
| `permanentlyDenied` | `permanentlyDenied`（`request()` 戻り値のみ） / `restricted` | 恒久的に拒否（OS設定への誘導が必要） |

> **`provisional` の扱い**: braze_005.md で「Provisional Authorization は採用しない」と決定済み。
> `PermissionStatus.provisional` が返った場合は `denied` として扱い、アプリからフル権限の取得を促す。
>
> **`notDetermined` の生成ロジック**:
> iOS は `PermissionStatus.denied` = `UNAuthorizationStatus.notDetermined`（未要求）と1対1のため直接 `notDetermined` を返す。iOS でユーザーが拒否した場合は `permanentlyDenied` が返るため、`denied` は必ず未要求を意味する。
> Android は **`.status` による確認**では `PermissionStatus.denied` が「未要求」「1回目拒否」「恒久拒否」のすべてで返る（`permanentlyDenied` は `.request()` の戻り値でのみ返る）。そのため `shouldShowRequestRationale` では区別できない（`false` が未要求と恒久拒否の両方に該当する）。代わりに SharedPreferences の2フラグ（`notification_permission_requested` / `notification_permission_permanently_denied`）で3状態を区別する。詳細は「設計上の決定事項」参照。

### 6. レイヤー構成

```
NotificationPermissionUseCase                        ← ドメイン層
  ↓ repository（コンストラクタ注入）
NotificationPermissionRepository（interface）        ← ドメイン層
  ↑ implements
NotificationPermissionRepositoryImpl                 ← データ層
  ↓ NotificationPermissionService（interface）
_IosNotificationPermissionServiceImpl                ← データ層（iOS 専用）
_AndroidNotificationPermissionServiceImpl            ← データ層（Android 専用）
  ↓（Android のみ）AndroidNotificationPermissionPreferencesService（interface）
AndroidNotificationPermissionPreferencesServiceImpl  ← データ層（SharedPreferences フラグ管理・Android 専用）
```

UseCase はインターフェース（`NotificationPermissionRepository`）のみに依存し、`permission_handler` および `SharedPreferences` に直接依存しない。iOS / Android の分岐は `notificationPermissionServiceImplProvider` の構築時点に集約され、各クラス内に Platform 分岐を持たない。

### 7. iOS Push権限と `push.automation = true` の関係

BRAZE-010 で設定した `BrazePlugin.configure { configuration.push.automation = true }` は
APNs への**デバイストークン登録**（`registerForRemoteNotifications`）を自動化するが、
**権限ダイアログの表示**は行わない。

- `permission_handler` が `UNUserNotificationCenter.requestAuthorization()` を呼び出して権限ダイアログを表示する
- ユーザーが許可 → iOS が APNs に登録 → `didRegisterForRemoteNotificationsWithDeviceToken` を呼び出す
- Braze の automation がこのコールバックを捕捉し、APNs トークンを Braze に自動登録する

`permission_handler` と `push.automation` は役割が異なるため**競合しない**。

---

## 設計上の決定事項

### `permission_handler` 採用 vs Braze SDK の `requestPushPermission`

| 案 | 内容 | 採用 |
|---|---|---|
| A: `permission_handler`（採用） | クロスプラットフォーム対応・permission_handler の PermissionStatus を Domain に変換して上位層を疎結合に保つ | ✅ |
| B: Braze SDK の `requestPushPermission()` | iOS に特化・Braze 依存が UseCase 層まで伝播する | ❌ |

案Aにより、UseCase が Braze SDK に依存せず、将来の SDK 切り替えに対して柔軟になる。

### `PermissionStatus.denied` の iOS / Android 別解釈と `notDetermined` の生成方針

`permission_handler` の `PermissionStatus.denied` は iOS と Android で意味が異なる。

| OS | `PermissionStatus.denied` の意味 | `notDetermined` の区別方法 |
|---|---|---|
| iOS | `UNAuthorizationStatus.notDetermined`（未要求）のみ | 1対1で対応。`denied` → 直接 `notDetermined` を返す |
| Android | `.status` では未要求 / 1回目拒否 / 恒久拒否のすべてが `denied`（`.request()` のみ `permanentlyDenied` を返す） | SharedPreferences フラグ（後述） |

iOS でユーザーが拒否した場合は `PermissionStatus.permanentlyDenied` が返るため、iOS の `denied` は必ず未要求を意味する。

#### `shouldShowRequestRationale` を使わない理由

`shouldShowRequestRationale == false` は「未要求」と「恒久拒否」の両方に該当するため、`notDetermined` の判定に使えない。

| `shouldShowRequestRationale` 値 | 該当状態 |
|---|---|
| `true` | 1回目拒否済み（説明 UI を出すべき） |
| `false` | 未要求 **または** 恒久拒否（区別不可） |

#### Android: SharedPreferences 2フラグによる状態管理

Android の `.status` は未要求・1回目拒否・恒久拒否のすべてで `denied` を返すため、2つのフラグで3状態を区別する。フラグの読み書きは `NotificationPermissionPreferencesService` インターフェース（実装: `NotificationPermissionPreferencesServiceImpl`）に委譲し、`_AndroidNotificationPermissionServiceImpl` は `SharedPreferences` に直接依存しない。

| フラグキー | 役割 | セットタイミング | リセットタイミング |
|---|---|---|---|
| `notification_permission_requested` | `request()` を呼び出したか | `requestPermission()` の `request()` 呼び出し前 | なし |
| `notification_permission_permanently_denied` | `request()` が `permanentlyDenied` を返したか | `requestPermission()` が `permanentlyDenied` を返したとき | `checkStatus()` で `granted` を確認したとき |

`requestPermission()` は `request()` 呼び出し**前**に `_requestedKey` をセットする。`request()` 後に立てると、OS がダイアログを表示しなかった場合にフラグが立たず、次回 `checkStatus()` で `notDetermined` が返り続けるため。

**`checkStatus()` 判定ロジック（Android + `PermissionStatus.denied` の場合）:**

| `_requestedKey` | `_permanentlyDeniedKey` | 返り値 |
|---|---|---|
| false | — | `notDetermined` |
| true | false | `denied`（1回目拒否済み） |
| true | true | `permanentlyDenied` |

#### Android: `_permanentlyDeniedKey` が必要な理由とフロー分析

**ケース1: 未要求 → 1回目拒否 → 2回目拒否（正常系）**

```
checkStatus()
  .status = denied, _requestedKey = false
  → notDetermined ✅

requestPermission() // 1回目
  _requestedKey = true にセット
  request() → ダイアログ表示
  ユーザー「拒否」→ denied
  _toStatus(denied) on Android → denied ✅

checkStatus()
  .status = denied, _requestedKey = true
  → denied ✅（1回目拒否）

requestPermission() // 2回目
  request() → ダイアログ表示（2回目）
  ユーザー「拒否」→ permanentlyDenied
  _toStatus(permanentlyDenied) → permanentlyDenied ✅
  _permanentlyDeniedKey = true にセット ✅
```

**ケース2（修正前の穴）: 永久拒否後の checkStatus**

```
// _permanentlyDeniedKey がなかった場合
checkStatus()
  .status = denied（永久拒否でも denied を返す）
  _requestedKey = true
  → denied ❌（本来は permanentlyDenied）

// アプリが誤って rationale UI を表示 → ユーザーが「許可」をタップ
requestPermission()
  request() → ダイアログなし・即座に permanentlyDenied を返す
  → permanentlyDenied ✅（UX は回復するが次回起動でも繰り返される）
```

**穴の整理:**

| チェック | 判定 | 詳細 |
|---|---|---|
| 無限ダイアログ問題 | なし | `request()` は永久拒否でダイアログを出さない |
| 1回目拒否の `checkStatus` | 正常 | `_requestedKey = true` → `denied` |
| 永久拒否後の `checkStatus`（修正前） | ⚠️ 穴 | `_requestedKey = true` のみでは `denied` を返す |
| 永久拒否後の `requestPermission` | 正常 | ダイアログなし即 `permanentlyDenied` |

**ケース2（修正後）: 永久拒否後の checkStatus**

```
checkStatus()
  .status = denied, _requestedKey = true, _permanentlyDeniedKey = true
  → permanentlyDenied ✅（settings 誘導を正しく表示）
```

### 状態マッピング（`checkStatus` + `requestPermission` + SharedPreferences）

Android は `.status` が3状態をすべて `denied` で返すため、2フラグと組み合わせてドメイン enum を決定する。

| `PermissionStatus` | OS | `_requestedKey` | `_permanentlyDeniedKey` | ドメイン返り値 |
|---|---|---|---|---|
| `granted` | any | — | false にリセット（Android） | `granted` |
| `permanentlyDenied` / `restricted` | any | — | — | `permanentlyDenied` |
| `denied` | iOS | — | — | `notDetermined`（iOS denied は常に未要求） |
| `denied` | Android | false | — | `notDetermined` |
| `denied` | Android | true | false | `denied`（1回目拒否済み） |
| `denied` | Android | true | true | `permanentlyDenied` |
| `permanentlyDenied`（`.request()` 戻り値のみ） | Android | — | true にセット | `permanentlyDenied` |
| その他（`provisional` 等） | any | — | — | `denied`（braze_005.md で provisional 不採用） |

> **注意**: Android の `.status` は `permanentlyDenied` を返さない（`permission_handler` ソースに明記）。恒久拒否の検出は `requestPermission()` の戻り値のみで可能。`checkStatus()` は `_permanentlyDeniedKey` フラグで補完する。

---

## 動作確認手順

### iOS シミュレーター

1. `flutter run` でアプリを起動
2. `notificationPermissionUseCaseProvider` 経由で `checkStatus()` を呼び出す
3. 初回: `notDetermined` が返ることを確認
4. `requestPermission()` を呼び出す → OS 権限ダイアログが表示される
5. 「許可」 → `granted` が返ることを確認
6. 「許可しない」 → `permanentlyDenied` が返ることを確認

### Android エミュレーター（API 33+）

1. `flutter run` でアプリを起動
2. `checkStatus()` → `notDetermined` 確認
3. `requestPermission()` → ダイアログ表示確認
4. 「Allow」 → `granted` 確認
5. 「Don't allow」 → `denied` 確認（1回目）→ 再度要求 → `permanentlyDenied` 確認

### Android エミュレーター（API 32 以下）

- `checkStatus()` → `granted`（自動許可）
- `requestPermission()` → `granted`（ダイアログなし）

### `flutter analyze`

エラーなし ✅（実施済み）

---

## テスト方針

### Unit × Small（各レイヤー単体）vs Integration × Small の違い

#### Unit × Small（基本方針）

各レイヤーを **1層ずつ** テストし、隣接層はすべてスタブで代替する。

```
UseCase test:    UseCase (real) → StubRepository
Repository test: Repository (real) → StubService
Service test:    (テスト対象外)
```

**問題**: UseCase と Repository を繋いだとき「本当に正しく連携するか」は確認できない。各レイヤーが単体で正しくても、組み合わせて初めて現れるバグは検出できない。

#### Integration × Small（方針）

**I/O 境界（Service レイヤー）でのみスタブを差し替え**、その上の実装クラスはすべて本物を動かす。

```
UseCase (real)
  → RepositoryImpl (real)
  → StubNotificationPermissionService  ← ここだけスタブ
```

`ProviderContainer` で Service のみオーバーライドする：

```dart
final container = ProviderContainer(
  overrides: [
    notificationPermissionServiceImplProvider.overrideWithValue(
      StubNotificationPermissionServiceImpl(),
    ),
  ],
);

final useCase = container.read(notificationPermissionUseCaseProvider);
final result = await useCase.checkStatus();
expect(result, equals(NotificationPermissionStatus.notDetermined));
```

UseCase・RepositoryImpl・Interface の全コードが**実際に実行される**。

---

### なぜ「Integration × Small」と呼ぶか

| 軸 | 意味 | 本テストでの該当 |
|---|---|---|
| Integration | 複数レイヤーを横断して連結 | UseCase + Interface + RepositoryImpl が連結 |
| Small | 1プロセス内で完結・I/O なし | StubService で OS 権限 API を遮断 → `flutter_test` で動く |

---

### スタブ境界の特定

通知権限の実装で I/O が発生する箇所は2つ：

```
1. NotificationPermissionService
   └ Permission.notification.status/request() → OS 権限 API（実 I/O）

2. AndroidNotificationPermissionPreferencesService
   └ SharedPreferences → ストレージ（実 I/O）
```

この2つをスタブに置き換えることで Small に保てる。

---

### Integration × Small で検証できること

Unit × Small では確認できなかった「層間の連携」が検証対象になる：

| テストケース | 検証される連携 |
|---|---|
| StubService が `granted` を返す → `useCase.checkStatus()` が `granted` を返す | RepositoryImpl の委譲 + UseCase の委譲 |
| StubService が `denied` を返す（iOS 想定）→ `notDetermined` が返る | `_IosNotificationPermissionServiceImpl` の変換ロジック |
| StubService が `denied` を返す（Android 想定）+ Prefs 未セット → `notDetermined` | Android PreferencesService のフラグ判定 + Repository の委譲 |

---

### Android 固有の考慮点

`_AndroidNotificationPermissionServiceImpl` は `AndroidNotificationPermissionPreferencesService` に依存している。Android の3状態判定ロジックを Integration × Small でテストするには、PreferencesService もスタブ化が必要：

```dart
// Android Integration テストの構成
final container = ProviderContainer(
  overrides: [
    // OS 権限 API をスタブ化
    notificationPermissionServiceImplProvider.overrideWithValue(
      StubNotificationPermissionServiceImpl(),
    ),
    // SharedPreferences をスタブ化（StubAndroidNotificationPermissionPreferencesServiceImpl が必要）
    androidNotificationPermissionPreferencesServiceImplProvider.overrideWithValue(
      StubAndroidNotificationPermissionPreferencesServiceImpl(),
    ),
  ],
);
```

ただし `StubNotificationPermissionServiceImpl` はプラットフォーム分岐を持たないため、
Android 固有のフラグ管理ロジックを検証しない場合（Stub で代替する場合）は上記2つを重ねる必要はない。
Android のフラグ管理ロジック（`getRequested` / `getPermanentlyDenied` の組み合わせ判定）を検証したい場合のみ、
`StubAndroidNotificationPermissionPreferencesServiceImpl` を追加で用意する。

---

### Unit × Small との住み分けまとめ

| テスト | 目的 | スタブ境界 |
|---|---|---|
| Unit × Small（Repository 単体） | DTO→Entity 変換・エラー変換の詳細 | StubService |
| Unit × Small（UseCase 単体） | ドメインロジックの詳細 | StubRepository |
| **Integration × Small** | UseCase + Repository の連携・エンドツーエンドの状態マッピング | StubService のみ |

「各レイヤーが個別に正しい」を Unit × Small が担保し、「繋げても正しい」を Integration × Small が担保する。この組み合わせがテストガイドラインの「コスパの良いピラミッド」の実体。

---

### 全件テスト網羅の具体案

#### 「ただし StubService はフラグ管理ロジックをバイパスする」の意味

`StubNotificationPermissionServiceImpl` を注入した場合の実行経路：

```
UseCase → RepositoryImpl → StubNotificationPermissionServiceImpl
                                ↑
                         ここで終わり。
                         _AndroidNotificationPermissionServiceImpl は一切起動しない
                         → AndroidNotificationPermissionPreferencesService も呼ばれない
```

StubService は「まるごと置き換え」なので、内部のフラグ判定ロジックがバイパスされる。PreferencesService を追加でスタブ化しても、そもそも呼ばれないため意味がない。

Android のフラグ管理ロジック（`_handleDenied()` 内の3状態判定）を検証するには、**`AndroidNotificationPermissionServiceImpl` が実際に起動する経路**が必要になる。

---

#### 2層テスト構成

| 層 | 目的 | スタブ構成 | 検証できること |
|---|---|---|---|
| **Tier 1**: Integration | 層間の配線確認 | StubService のみ | UseCase → RepositoryImpl の委譲が正しいか |
| **Tier 2**: Android Service Unit | フラグ管理ロジック確認 | StubPreferences + MethodChannel mock | `_handleDenied()` の3状態判定 |

Tier 1 だけでは「Stub が返した値がそのまま流れるか」しか確認できない。Android のフラグ条件分岐は Tier 2 で初めてカバーできる。

---

#### Tier 1: Integration × Small（UseCase → RepositoryImpl → StubService）

StubService に「返す値を外から指定できる設計」が必要。

```dart
class StubNotificationPermissionServiceImpl
    implements NotificationPermissionService {
  StubNotificationPermissionServiceImpl({
    this.statusResult = NotificationPermissionStatus.notDetermined,
    this.requestResult = NotificationPermissionStatus.granted,
  });

  final NotificationPermissionStatus statusResult;
  final NotificationPermissionStatus requestResult;

  @override
  Future<NotificationPermissionStatus> checkStatus() async => statusResult;

  @override
  Future<NotificationPermissionStatus> requestPermission() async => requestResult;
}
```

`statusResult` / `requestResult` を差し替えるだけで4状態すべてを網羅できる。

---

#### Tier 2: Android Service Unit（フラグ管理ロジック）

**必要なもの①: `StubAndroidNotificationPermissionPreferencesServiceImpl`（in-memory）**

```dart
class StubAndroidNotificationPermissionPreferencesServiceImpl
    implements AndroidNotificationPermissionPreferencesService {
  StubAndroidNotificationPermissionPreferencesServiceImpl({
    this.requested = false,
    this.permanentlyDenied = false,
  });

  bool requested;
  bool permanentlyDenied;

  @override
  bool getRequested() => requested;

  @override
  Future<void> setRequested({required bool value}) async => requested = value;

  @override
  bool getPermanentlyDenied() => permanentlyDenied;

  @override
  Future<void> setPermanentlyDenied({required bool value}) async =>
      permanentlyDenied = value;
}
```

> **注意（実装時の修正点）**: 当初 `this._requested` / `this._permanentlyDenied` と記述していたが、Dart の private named parameter はライブラリ外から指定できないため、`test/` ファイルからコンストラクタ引数を渡せなかった。フィールドを公開（`requested` / `permanentlyDenied`）に変更し、`this.requested` / `this.permanentlyDenied` の initializing formal を使用した。

**必要なもの②: `permission_handler` の MethodChannel mock**

`Permission.notification.status/request()` は OS API のためそのままでは呼べない。`flutter_test` の MethodChannel mock で制御する。

```dart
// テスト内 setUp で設定
const channel = MethodChannel('flutter.baseflow.com/permissions/methods');
TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    .setMockMethodCallHandler(channel, (call) async {
  switch (call.method) {
    case 'checkPermissionStatus':
      return 0; // 0 = denied（PermissionStatus.denied.value）
    case 'requestPermissions':
      return {17: 4}; // 17 = notification, 4 = permanentlyDenied
    default:
      return null;
  }
});
```

> **内部コード一覧（`permission_handler_platform_interface` ソースから確認）**
>
> | 値 | `Permission` | 値 | `PermissionStatus` |
> |---|---|---|---|
> | 17 | `Permission.notification` | 0 | `denied` |
> | — | — | 1 | `granted` |
> | — | — | 2 | `restricted` |
> | — | — | 3 | `limited` |
> | — | — | 4 | `permanentlyDenied` |
> | — | — | 5 | `provisional` |

**必要なもの③: `AndroidNotificationPermissionServiceImpl` / `IosNotificationPermissionServiceImpl` のテスト可能化（実装済み）**

`notification_permission_service_impl.dart` から切り出して別ファイル化し、プライベート解除済み。

```
lib/data/services/permission/notification/
  notification_permission_service.dart                  ← interface
  notification_permission_service_impl.dart             ← Provider のみ（Platform 判定）
  android_notification_permission_service_impl.dart     ← Android impl（切り出し済み）
  ios_notification_permission_service_impl.dart         ← iOS impl（切り出し済み）
  stub_notification_permission_service_impl.dart        ← Stub（Tier 1 用・要改修）
```

---

#### テストケース全網羅

**Tier 1（Integration）: 4状態 × checkStatus / requestPermission**

| ケース | StubService の設定 | 期待する戻り値 |
|---|---|---|
| `checkStatus` → granted | `statusResult: granted` | `granted` |
| `checkStatus` → notDetermined | `statusResult: notDetermined` | `notDetermined` |
| `checkStatus` → denied | `statusResult: denied` | `denied` |
| `checkStatus` → permanentlyDenied | `statusResult: permanentlyDenied` | `permanentlyDenied` |
| `requestPermission` → granted | `requestResult: granted` | `granted` |
| `requestPermission` → notDetermined | `requestResult: notDetermined` | `notDetermined` |
| `requestPermission` → denied | `requestResult: denied` | `denied` |
| `requestPermission` → permanentlyDenied | `requestResult: permanentlyDenied` | `permanentlyDenied` |

**Tier 2（Android Service Unit）: OS ステータス × フラグ組み合わせ**

| MethodChannel の OS ステータス | requested | permanentlyDenied | 期待する戻り値 |
|---|---|---|---|
| `denied` | false | false | `notDetermined` |
| `denied` | true | false | `denied` |
| `denied` | true | true | `permanentlyDenied` |
| `granted` | — | true（リセット確認） | `granted`（かつ flag が false にリセット） |
| `requestPermission` → `denied` | — | — | `denied`（setRequested=true になる） |
| `requestPermission` → `permanentlyDenied` | — | — | `permanentlyDenied`（setPermanentlyDenied=true になる） |

---

#### iOS 固有 mapping テストについて

iOS の `denied → notDetermined` 変換は `IosNotificationPermissionServiceImpl._toStatus()` に存在する。テスト環境（Dart VM）では `Platform.isIOS = false` のため、Provider 経由だと Android impl が生成されてしまい iOS のコードパスに入れない。`ios_notification_permission_service_impl.dart` として切り出し済みのため、`IosNotificationPermissionServiceImpl` を直接インスタンス化して MethodChannel mock と組み合わせることでテスト可能。

---

#### 対応が必要なファイル

| 対応 | ファイル | 状態 |
|---|---|---|
| 新規作成 | `stub_android_notification_permission_preferences_service_impl.dart` | ✅ 完了 |
| 切り出し | `android_notification_permission_service_impl.dart` | ✅ 完了 |
| 切り出し | `ios_notification_permission_service_impl.dart` | ✅ 完了 |
| 整理 | `notification_permission_service_impl.dart`（Provider のみに削減） | ✅ 完了 |
| 改修 | `stub_notification_permission_service_impl.dart`（`statusResult` / `requestResult` をコンストラクタ引数化） | ✅ 完了 |

MethodChannel mock は `flutter_test` 標準機能で対応可能なため、追加パッケージは不要。

---

#### 次にすること（テストコード実装）

##### Step 1: `StubNotificationPermissionServiceImpl` の改修

Tier 1 テストで返り値を外から制御できるよう、コンストラクタに `statusResult` / `requestResult` を追加する。

```
対象: lib/data/services/permission/notification/stub_notification_permission_service_impl.dart
変更: StubNotificationPermissionServiceImpl({
        this.statusResult = NotificationPermissionStatus.notDetermined,
        this.requestResult = NotificationPermissionStatus.granted,
      });
```

##### Step 2: Tier 1 Integration テスト実装

UseCase → RepositoryImpl → StubService の一気通貫テスト。

```
新規作成: test/domain/use_cases/permission/notification/notification_permission_use_case_integration_test.dart
テスト対象: NotificationPermissionUseCase（ProviderContainer 経由）
スタブ: notificationPermissionServiceImplProvider を StubNotificationPermissionServiceImpl でオーバーライド
```

配置先は UseCase（entry point）にミラー。配置原則は `docs/testing/test_guideline.md`「Integration テストのファイル配置原則」参照。

「テストケース全網羅」表の Tier 1 行をすべて実装する。

##### Step 3: Tier 2 Android Service Unit テスト実装

`AndroidNotificationPermissionServiceImpl` + `StubAndroidNotificationPermissionPreferencesServiceImpl` + MethodChannel mock の組み合わせテスト。

```
新規作成: test/data/services/permission/notification/android_notification_permission_service_impl_test.dart
テスト対象: AndroidNotificationPermissionServiceImpl（直接インスタンス化）
スタブ①: StubAndroidNotificationPermissionPreferencesServiceImpl（フラグ初期値をコンストラクタで制御）
スタブ②: MethodChannel('flutter.baseflow.com/permissions/methods') を TestDefaultBinaryMessengerBinding で mock
```

「テストケース全網羅」表の Tier 2 行をすべて実装する。

##### Step 4: iOS Service Unit テスト実装

`IosNotificationPermissionServiceImpl` + MethodChannel mock の組み合わせテスト。

```
新規作成: test/data/services/permission/notification/ios_notification_permission_service_impl_test.dart
テスト対象: IosNotificationPermissionServiceImpl（直接インスタンス化）
スタブ: MethodChannel mock で PermissionStatus（granted / denied / permanentlyDenied）を制御
検証: denied → notDetermined の iOS 固有 mapping を含む全4状態
```

---

## 未完了・引き継ぎ事項

| 項目 | 引き継ぎ先 |
|---|---|
| `push_permission_status` を Braze 属性として送信する | BRAZE-015 |
| 権限変更をアプリ再開時に検知して Braze 属性を更新する | BRAZE-015 |
| `requestPermission` を呼び出すタイミング（予約確定後など）の実装 | Phase 3 |
