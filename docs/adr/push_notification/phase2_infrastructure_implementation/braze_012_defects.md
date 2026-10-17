# BRAZE-012: 実装欠陥レポート

対象コミット: `b7bdd80`
対象 ADR: `braze_012.md`

---

## 欠陥一覧

### 1. Android Auto Backup による SharedPreferences 権限フラグの不正復元【Critical】

**箇所**: `android/app/src/main/AndroidManifest.xml`（7〜11行目）

`<application>` タグに `android:allowBackup="false"` も `android:dataExtractionRules` も指定なし。Android 6.0+ のデフォルト動作は Auto Backup 有効（SharedPreferences 含む全データをバックアップ）。

**攻撃シナリオ:**

1. ユーザーが通知権限を恒久拒否 → `notification_permission_requested=true` / `notification_permission_permanently_denied=true` が Google Drive にバックアップ
2. アプリをアンインストール → OS 側の通知権限はリセット（未要求状態に戻る）
3. アプリを再インストール → SharedPreferences がバックアップから復元
4. `checkStatus()`: OS は `denied`（未要求）を返すが `_requestedKey=true`, `_permanentlyDeniedKey=true` → `permanentlyDenied` を返す
5. アプリが「OS設定から許可してください」UI を表示 → ユーザーはダイアログで許可できるのに誘導先が設定画面

**影響**: 再インストールユーザーへの通知権限取得が恒久的に不可能になる。通知取得率の意図しない低下。

---

### 2. `requestPermission()` で `restricted` 時に `_permanentlyDeniedKey` が立たない【Moderate】

**箇所**: `lib/data/services/permission/notification/android_notification_permission_service_impl.dart`（34〜43行目）

```dart
if (status == PermissionStatus.permanentlyDenied) {   // restricted はここに入らない
  await preferencesService.setPermanentlyDenied(value: true);
  return NotificationPermissionStatus.permanentlyDenied;
}
return _toStatus(status: status);  // restricted → permanentlyDenied を返すがフラグ未設定
```

`_toStatus()` は `restricted → permanentlyDenied` に変換するが、`_permanentlyDeniedKey` はセットされない。

**影響シーケンス:**

1. `requestPermission()` → OS が `restricted` → 呼び出し元には `permanentlyDenied` が返る（正）
2. `_permanentlyDeniedKey` は `false` のまま
3. 次の `checkStatus()` で OS が `denied` を返すと `_handleDenied()` → `_requestedKey=true`, `_permanentlyDeniedKey=false` → `denied`（1回目拒否扱い）を返す（誤）
4. アプリが rationale UI + 再プロンプトを試みる → OS は即座に `permanentlyDenied` を返す無限ループに陥る

---

### 3. iOS でも `AndroidNotificationPermissionPreferencesService` を無条件初期化【Low】

**箇所**: `lib/data/services/permission/notification/notification_permission_service_impl.dart`（13〜20行目）

```dart
final notificationPermissionServiceImplProvider =
    Provider<NotificationPermissionService>(
      (ref) => buildNotificationPermissionService(
        preferencesService: ref.read(
          androidNotificationPermissionPreferencesServiceImplProvider,  // iOS でも呼ばれる
        ),
        isIos: Platform.isIOS,
      ),
    );
```

`isIos=true` のとき `preferencesService` は `IosNotificationPermissionServiceImpl` に渡されず完全に未使用だが、`androidNotificationPermissionPreferencesServiceImplProvider`（→ `sharedPreferencesServiceImplProvider`）の `ref.read()` が必ず実行される。

**影響**: `sharedPreferencesServiceImplProvider` が iOS 環境で未初期化または例外をスローするケースで、iOS ビルドが通知権限サービス構築時に不必要なクラッシュを起こす。Android 専用の依存が iOS のプロバイダーグラフに混入するため、依存逆転の設計意図と矛盾する。

---

### 4. `NotificationPermissionStatus.denied` コメントの iOS 記述が誤り【Doc / Low】

**箇所**: `lib/domain/entities/permission/notification/notification_permission_status.dart`（14〜18行目）

```dart
/// 一度拒否済み・再要求可能（iOS: denied / Android: 1st_denied）
///
/// iOS では OS設定への誘導が必要。Android では rationale UI + 再プロンプト可能。
denied,
```

iOS では `PermissionStatus.denied` = `UNAuthorizationStatus.notDetermined`（未要求）であり、`IosNotificationPermissionServiceImpl._toStatus()` で `denied → notDetermined` に変換される。つまり iOS の通常パスで `NotificationPermissionStatus.denied` が返ることはない（`_` catch-all の provisional 等のみ）。

「iOS では OS設定への誘導が必要」は `permanentlyDenied` の説明であり `denied` に対しては誤り。BRAZE-015 で `push_permission_status` 属性送信の分岐ロジックを実装する際、このコメントを信頼すると iOS ユーザーへの誤った UI 分岐（設定誘導すべきでない状態で設定誘導）を実装するリスクがある。

---

## 動作確認手順

### 欠陥 1 — Android Auto Backup による権限フラグ不正復元

**確認方法**: Android エミュレータ（ADB）
**理由**: OS レベルのバックアップ/リストア動作はユニットテストで再現不可。

**前提**: `adb root` が使えるエミュレータイメージ（Google APIs 版など）、API 33+

```bash
# 1. アプリをビルド・インストール
flutter run

# 2. エミュレータ上で通知権限を恒久拒否にする
#    Android 13+: 初回ダイアログで「許可しない」→ 設定 > アプリ > 権限 > 通知 > 「許可しない」に設定

# 3. SharedPreferences にフラグが書き込まれたことを確認
adb shell run-as com.example.travel_app \
  cat /data/data/com.example.travel_app/shared_prefs/FlutterSharedPreferences.xml
# → notification_permission_requested=true、
#    notification_permission_permanently_denied=true を含むことを確認

# 4. SharedPreferences を外部ストレージに退避（バックアップ復元のシミュレーション）
adb shell run-as com.example.travel_app \
  cp /data/data/com.example.travel_app/shared_prefs/FlutterSharedPreferences.xml \
  /sdcard/FlutterSharedPreferences_backup.xml

# 5. アプリをアンインストール（OS 側の通知権限がリセットされる）
adb uninstall com.example.travel_app

# 6. アプリを再インストール・一度起動して shared_prefs ディレクトリを作成
flutter run
# 起動を確認したらアプリを強制終了

# 7. バックアップを書き戻す（Google Drive 復元のシミュレーション）
adb root
adb shell cp /sdcard/FlutterSharedPreferences_backup.xml \
  /data/data/com.example.travel_app/shared_prefs/FlutterSharedPreferences.xml

# 8. アプリを再起動
flutter run
```

**観察ポイント**: OS は通知権限を「未要求」として返すにもかかわらず、アプリが「設定画面で通知を許可してください」UI を表示する。`checkStatus()` にブレークポイントを置くと `_requestedKey=true` / `_permanentlyDeniedKey=true` の状態で `permanentlyDenied` を返すことを確認できる。

---

### 欠陥 2 — `requestPermission()` で `restricted` 時に `_permanentlyDeniedKey` が立たない

**判定: 非妥当 — 動作確認手順なし**

`PermissionStatus.restricted` は permission_handler プラットフォームインターフェース上で `*Only supported on iOS.*` と明記されており、Android の `requestPermission()` から返ることはない。Android 向け実装クラス（`AndroidNotificationPermissionServiceImpl`）では発生しないコードパスであるため、欠陥として対処不要。

---

### 欠陥 3 — iOS でも `AndroidNotificationPermissionPreferencesService` を無条件初期化

**確認方法**: ユニットテスト（既存テストファイルへの追加）
**理由**: 実機/シミュレータでは SharedPreferences が iOS でも動作するため現行コードではクラッシュしない。欠陥は「Dart の eager evaluation により `isIos` チェック前に `ref.read()` が実行される」構造的問題であり、テストコードで直接示せる。

**追加先**: `test/data/services/permission/notification/notification_permission_service_impl_test.dart`

```dart
// buildNotificationPermissionService グループに追加
group('欠陥再現', () {
  test(
    'isIos=true でも preferencesService の引数式が評価される（Dart eager evaluation）',
    () {
      // Dart は関数呼び出し前に全引数を評価する。
      // 実際の Provider では:
      //   buildNotificationPermissionService(
      //     preferencesService: ref.read(androidNotificationPermissionPreferencesServiceImplProvider),
      //     isIos: Platform.isIOS,
      //   )
      // の形になっており、isIos チェックより前に ref.read() が実行される。

      var wasEvaluated = false;

      StubAndroidNotificationPermissionPreferencesServiceImpl getService() {
        wasEvaluated = true;
        return StubAndroidNotificationPermissionPreferencesServiceImpl();
      }

      buildNotificationPermissionService(
        preferencesService: getService(),
        isIos: true,
      );

      // isIos=true でも Android 専用サービスの生成式が実行されている（欠陥）
      expect(wasEvaluated, isTrue);
    },
  );
});
```

**実行コマンド**:
```bash
flutter test test/data/services/permission/notification/notification_permission_service_impl_test.dart
```

---

### 欠陥 4 — `NotificationPermissionStatus.denied` コメントの iOS 記述が誤り

**確認方法**: 既存テストで確認済み
**理由**: `ios_notification_permission_service_impl_test.dart` の既存テストが iOS の `denied` → `notDetermined` 変換を検証しており、エンティティのコメント記述（「iOS: denied」「iOS では OS設定への誘導が必要」）と実装の乖離が確認できる。

**確認対象テスト**: `test/data/services/permission/notification/ios_notification_permission_service_impl_test.dart`

```
'OS=denied → notDetermined（iOS固有: denied は未要求を意味する）'
```

このテストが pass する = 実装は `denied → notDetermined` に変換している = エンティティの `denied` コメントにある「iOS: denied」「iOS では OS設定への誘導が必要」は誤り、という欠陥が確認できる。

**実行コマンド**:
```bash
flutter test test/data/services/permission/notification/ios_notification_permission_service_impl_test.dart
```

---

## 修正案

### 妥当性判定サマリ

| # | 指摘 | 妥当性 | 根拠 |
|---|---|---|---|
| 1 | Auto Backup による権限フラグ不正復元 | **妥当** | `AndroidManifest.xml` に `allowBackup` 未指定・デフォルト `true` を確認 |
| 2 | `restricted` 時に `_permanentlyDeniedKey` が未設定 | **非妥当** | `PermissionStatus.restricted` は permission_handler の仕様上 iOS 専用（`*Only supported on iOS.*`）。Android の `requestPermission()` では発生しない |
| 3 | iOS でも Android Preferences Provider を無条件 `ref.read` | **妥当** | `notification_permission_service_impl.dart` の Provider 実装を確認 |
| 4 | `denied` コメントの iOS 記述が誤り | **妥当** | `ios_notification_permission_service_impl.dart` で `denied → notDetermined` 変換を確認 |

---

### 修正 1 — `AndroidManifest.xml` に `android:allowBackup="false"` を追加

**対象**: `android/app/src/main/AndroidManifest.xml`

```xml
<!-- Before -->
<application
    android:label="travel_app"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">

<!-- After -->
<application
    android:label="travel_app"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:allowBackup="false">
```

> **補足**: バックアップ対象データが他にも存在する場合は `android:allowBackup="false"` の代わりに `android:dataExtractionRules` + `android:fullBackupContent` で SharedPreferences キーのみを除外する方針も選択可。現時点でバックアップすべきユーザーデータはないため `false` で十分。

---

### 修正 2 — 非妥当のため対応なし

`PermissionStatus.restricted` は Android で発生しないため修正不要。

---

### 修正 3 — Provider を iOS/Android で条件分岐し Android 依存を分離

**対象**: `lib/data/services/permission/notification/notification_permission_service_impl.dart`

```dart
// Before
final notificationPermissionServiceImplProvider =
    Provider<NotificationPermissionService>(
      (ref) => buildNotificationPermissionService(
        preferencesService: ref.read(
          androidNotificationPermissionPreferencesServiceImplProvider,
        ),
        isIos: Platform.isIOS,
      ),
    );

// After
final notificationPermissionServiceImplProvider =
    Provider<NotificationPermissionService>((ref) {
  if (Platform.isIOS) {
    return IosNotificationPermissionServiceImpl();
  }
  return AndroidNotificationPermissionServiceImpl(
    preferencesService: ref.read(
      androidNotificationPermissionPreferencesServiceImplProvider,
    ),
  );
});
```

> `buildNotificationPermissionService` はテスト時の `isIos` 注入に使用しているため、関数自体は残す。ただし Provider からは呼ばず、テスト専用のファクトリとして位置づけ直す。

---

### 修正 4 — `denied` の docコメントを実態に合わせて修正

**対象**: `lib/domain/entities/permission/notification/notification_permission_status.dart`

```dart
// Before
/// 一度拒否済み・再要求可能（iOS: denied / Android: 1st_denied）
///
/// iOS では OS設定への誘導が必要。Android では rationale UI + 再プロンプト可能。
denied,

// After
/// 一度拒否済み・再要求可能（Android: 1st_denied）
///
/// Android では rationale UI + 再プロンプト可能。
/// iOS では通常パスでこの状態は返らない（PermissionStatus.denied → notDetermined に変換）。
denied,
```
