# BRAZE-014 ユーザー識別

## 概要

ログイン・ログアウト・アプリ初回起動の各タイミングで `BrazePlugin.changeUser()` を呼び出し、
Braze 上でユーザーを正しく識別できる状態を作る。

`anonymous_id_lifecycle.md` の TODO コメント（`_ensureAnonymousId` / `_persistUserId` / `_issueNewAnonymousId`）を実装する。

---

## 前提条件（実装済み）

| 内容 | ファイル |
|---|---|
| `anonymous_id` / `user_id` のストレージ設計 | `auth_secure_storage_service_impl.dart` |
| `clearAuthData()` が `anonymous_id` を保持 | 同上 |
| `IdGenerator` コンストラクタ注入 | `auth_repository_impl.dart` |
| TODO コメント（3箇所） | `auth_repository_impl.dart` |
| `brazePluginProvider` | `braze_plugin_provider.dart` |
| `UserDto.id` は `String?` | `dto.dart` ← `int?` 変換は不要 |

---

## 設計決定

### 1. `UserIdentityService` を新設する

`AuthRepositoryImpl` が `BrazePlugin` を直接使わず、`UserIdentityService`（interface + impl + stub）を経由する。

**理由**: Service 層ルール「実I/O（外部SDK呼び出し）はインターフェースで抽象化し、テスト時にスタブ注入できる構造にする」に従う。

```
AuthRepositoryImpl → UserIdentityService ← UserIdentityServiceImpl (BrazePlugin使用)
                                         ← StubUserIdentityServiceImpl (no-op)
```

### 2. `_ensureAnonymousId()` の変更方針

**現状**: `anonymous_id` が存在する場合は早期 return → Braze 呼び出しなし。

**変更後**: UUID が存在してもしなくても Braze 呼び出しを行う。ただし**未ログイン時のみ**。

```
Before: isEmpty → 生成・保存・Braze呼び出し / isNotEmpty → return（Braze呼び出しなし）
After:  isEmpty → 生成・保存
        共通 → _isLoggedIn == false のとき changeUser(anonymousId) + setStringCustomAttribute
```

**理由**: `anonymous_id_lifecycle.md § 4.1` のフロー図は2パス収束後に `changeUser` を呼ぶ構成を示している。
Braze SDK 導入前にアプリを使っていたユーザー（アップグレードシナリオ）は
`anonymous_id` が既存でも Braze ユーザーが未設定のため、全パスで初期化が必要。

ログイン済みの場合は `changeUser(userId)` がログイン時に呼ばれており、Braze SDK がローカルに永続化しているため上書き不要。

### 3. ログアウトフロー

```
_callLogoutApi()
  ↓
clearAuthData()
  ↓
_issueNewAnonymousId()
  ├─ 新 UUID 生成 → setAnonymousId()
  ├─ userIdentityService.logoutSession()   ← Braze: push解除・データ消去
  └─ userIdentityService.changeUser(newId) ← 新匿名ユーザーとして開始
```

**`logoutSession()` を `changeUser()` の前に呼ぶ理由**: Braze の `logout()` は現ユーザーのデータをフラッシュし push トークンを解除する。その後に `changeUser` で新ユーザーを開始しないと、新匿名ユーザーに前ユーザーの push トークンが残留する。

### 4. `BrazeAttributeKey` 定数

`anonymous_id` 属性キーを文字列リテラルで直書きせず、定数クラスで管理する。

配置: `lib/data/services/braze/braze_attribute_key.dart`（BRAZE-015 以降で追加される属性キーもここに集約）

---

## 変更ファイル一覧

| 操作 | ファイル |
|---|---|
| **新規** | `lib/data/services/braze/braze_attribute_key.dart` |
| **新規** | `lib/data/services/braze/user_identity/user_identity_service.dart` |
| **新規** | `lib/data/services/braze/user_identity/user_identity_service_impl.dart` |
| **新規** | `lib/data/services/braze/user_identity/stub_user_identity_service_impl.dart` |
| **修正** | `lib/data/repositories/auth/auth_repository_impl.dart` |

---

## 実装詳細

### `braze_attribute_key.dart`

```dart
/// Braze カスタム属性キーの定数定義。
abstract class BrazeAttributeKey {
  static const String anonymousId = 'anonymous_id';
}
```

---

### `user_identity_service.dart`（interface）

```dart
abstract class UserIdentityService {
  /// Brazeのアクティブユーザーを切り替える。
  /// ログイン時は userId、未ログイン時は anonymousId を渡す。
  void changeUser({required String userId});

  /// String型カスタム属性を設定する。
  void setStringCustomAttribute({required String key, required String value});

  /// Brazeユーザーセッションを終了する。
  /// push解除・ローカルデータ消去を行う。changeUser() の前に呼ぶこと。
  Future<void> logoutSession();
}
```

---

### `user_identity_service_impl.dart`（impl）

- `BrazePlugin` をコンストラクタ注入
- `changeUser` → `_brazePlugin.changeUser(userId)`
- `setStringCustomAttribute` → `_brazePlugin.setStringCustomUserAttribute(key, value)`
- `logoutSession` → `await _brazePlugin.logout()`

Provider:
```dart
final userIdentityServiceImplProvider = Provider<UserIdentityService>(
  (ref) => UserIdentityServiceImpl(
    brazePlugin: ref.read(brazePluginProvider),
  ),
);
```

---

### `stub_user_identity_service_impl.dart`（stub）

全メソッド no-op。

---

### `auth_repository_impl.dart` 変更点

#### Provider

```dart
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    authApiService: ref.read(authApiServiceImplProvider),
    authSecureStorageService: ref.read(authSecureStorageServiceImplProvider),
    idGenerator: () => const Uuid().v4(),
    userIdentityService: ref.read(userIdentityServiceImplProvider), // 追加
  ),
);
```

#### コンストラクタ

```dart
AuthRepositoryImpl({
  required this.authApiService,
  required this.authSecureStorageService,
  required this.idGenerator,
  required this.userIdentityService, // 追加
});

final UserIdentityService userIdentityService; // 追加
```

#### `_ensureAnonymousId()` 変更

```dart
Future<void> _ensureAnonymousId() async {
  var anonymousId = authSecureStorageService.getAnonymousId();
  if (anonymousId.isEmpty) {
    anonymousId = idGenerator();
    await authSecureStorageService.setAnonymousId(id: anonymousId);
  }
  // 未ログイン時のみ Braze 匿名セッションを確立
  // （ログイン済みは _persistUserId() で changeUser(userId) 済みのため上書きしない）
  if (!(_isLoggedIn ?? false)) {
    userIdentityService
      ..changeUser(userId: anonymousId)
      ..setStringCustomAttribute(
        key: BrazeAttributeKey.anonymousId,
        value: anonymousId,
      );
  }
}
```

#### `_persistUserId()` 変更

```dart
Future<void> _persistUserId({required String userId}) async {
  if (userId.isEmpty) return;
  await authSecureStorageService.setUserId(id: userId);
  userIdentityService.changeUser(userId: userId);
  userIdentityService.setStringCustomAttribute(
    key: BrazeAttributeKey.anonymousId,
    value: authSecureStorageService.getAnonymousId(),
  );
}
```

#### `_issueNewAnonymousId()` 変更

```dart
Future<void> _issueNewAnonymousId() async {
  final id = idGenerator();
  await authSecureStorageService.setAnonymousId(id: id);
  await userIdentityService.logoutSession(); // Braze: push解除・データ消去
  userIdentityService.changeUser(userId: id); // 新匿名ユーザーとして開始
}
```

---

## テスト方針

| テストケース | 確認内容 |
|---|---|
| 初回起動（未ログイン） | `changeUser(anonymousId)` + `setStringCustomAttribute('anonymous_id', anonymousId)` が呼ばれる |
| 再起動（未ログイン・anonymous_id 既存） | `changeUser(anonymousId)` + `setStringCustomAttribute` が呼ばれる |
| 再起動（ログイン済み） | `changeUser` が呼ばれない |
| ログイン成功 | `changeUser(userId)` + `setStringCustomAttribute('anonymous_id', anonymousId)` が呼ばれる |
| ログアウト | `logoutSession()` → `changeUser(newAnonymousId)` の順で呼ばれる |

スタブ: `StubUserIdentityServiceImpl` を注入し、メソッド呼び出しを `verify`。

---

## スコープ外

| 内容 | チケット |
|---|---|
| ログイン・ログアウトカスタムイベント送信 | BRAZE-016 |
| `NotificationAnalyticsRepository` との連携 | BRAZE-015/016 |
