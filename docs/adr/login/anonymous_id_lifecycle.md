# anonymous_id / user_id ライフサイクル設計

## 1. 背景・目的

`braze_003.md` § 1.1「識別・デバイス情報」に定義された通り、Braze はユーザーを次の2種類の ID で識別する。

| 属性名         | Braze の設定方法                                                | 生成タイミング   |
|----------------|-----------------------------------------------------------------|------------------|
| `user_id`      | `changeUser(userId)`                                            | ログイン成功直後 |
| `anonymous_id` | カスタム属性 `BrazeAttribute.anonymousId`（`braze_003.md` § 4） | アプリ初回起動時 |

未ログイン状態でもアプリを利用できる設計（`braze_004.md` § 2 参照）を採用したため、anonymous_id
のライフサイクルと、ログイン後の user_id への切り替え・ローカル保存方針を明確にする必要がある。

---

## 2. 採用方針の選定

### 候補比較

| 案                                    | 概要                                             | メリット                                       | デメリット                                                                             |
|---------------------------------------|--------------------------------------------------|------------------------------------------------|----------------------------------------------------------------------------------------|
| **A: デバイス固定**                   | anonymous_id を初回起動時に1度だけ生成、永続保持 | シンプル                                       | ログアウト後に別ユーザーの匿名行動がログアウトしたユーザーの anonymous_id で記録される |
| **B: ログアウト時に新規生成**（採用） | ログアウトのたびに新しい UUID を生成             | ログアウト後のセッションがクリーンに分離される | リターンユーザーの anonymous_id 一貫性がない                                           |
| **C: Map 管理**                       | `Map<userId, anonymousId>` でユーザーごとに保持  | リターンユーザーの一貫性あり                   | ログアウト〜新規ユーザーログイン間の帰属問題は解決できない。実装が複雑                 |

### 採用：案B（ログアウト時に新規生成）

**理由:**

- 旅行アプリにおいてデバイス共有は稀であり、リターンユーザーの anonymous_id 一貫性よりも、
  **ログアウト後のクリーンな分離**を優先する
- Map 管理（案C）はログアウト〜新規ユーザーログイン間の cross-attribution を解消できず、複雑さに見合った効果が得られない
- `braze_003.md` § 3 の `changeUser(userId)` 送信責務と整合しやすい

### 既知のトレードオフ（意図的な許容）

ユーザーAがログアウト後、ユーザーBがログインするまでの匿名操作はBが誰かを判別できないため、新しい
anonymous_id（案Bで生成）で記録される。これはどの設計でも回避不可能な制約であり、本設計では許容する。

---

## 3. ストレージ設計

### 3.1 キー分離（2キー構成）

`AuthSecureStorageService` に以下の2キーを追加する。

| キー名         | 内容                               | 生成・更新タイミング      | `clearAuthData()` 対象                       |
|----------------|------------------------------------|---------------------------|----------------------------------------------|
| `anonymous_id` | 現在アクティブな匿名 ID（UUID v4） | 初回起動時 / ログアウト時 | **対象外**（ログアウト後も即時使用するため） |
| `user_id`      | API から返却される実ユーザー ID    | ログイン成功時            | **対象**（ログアウトでクリア）               |

> **注意**: `clearAuthData()` は `accessToken` / `refreshToken` / `user_id` の3キーを削除する。
> `anonymous_id` は削除しない。メソッド名との乖離を防ぐため、実装コメントで意図を明示すること。

### 3.2 追加するインターフェースメソッド（`AuthSecureStorageService`）

```dart
String getAnonymousId();

Future<void> setAnonymousId({required String id});

String getUserId();

Future<void> setUserId({required String id});
```

---

## 4. ライフサイクル

### 4.1 初回起動（`_ensureLoaded()`）

```
SecureStorage を init()
  ↓
anonymous_id が空 → UUID 生成 → setAnonymousId()
anonymous_id が非空 → スキップ（再起動・アップデート後も維持）
  ↓
TODO(BRAZE-014): Braze.changeUser(anonymousId)
TODO(BRAZE-014): Braze.logCustomAttribute('anonymous_id', anonymousId)
```

### 4.2 ログイン成功後（`_saveTokens()`）

```
accessToken / refreshToken を保存
  ↓
dto.user?.id を user_id として setUserId()
  ↓
TODO(BRAZE-014): Braze.changeUser(userId)
TODO(BRAZE-014): Braze.logCustomAttribute('anonymous_id', anonymousId)
  ↑ anonymous_id はカスタム属性として user プロファイルに紐づける
    （braze_003.md § 1.1 / BrazeAttribute.anonymousId 参照）
```

> `design_doc.md` § 4 パターンD シーケンス図と対応。

### 4.3 ログアウト（`logout()`）

```
refreshToken を使って /auth/logout API 呼び出し（失敗しても続行）
  ↓
clearAuthData()（accessToken / refreshToken / user_id を削除）
  ↓
新しい UUID を生成 → setAnonymousId()  ← ここが案Bの核心
  ↓
TODO(BRAZE-014): Braze.changeUser(newAnonymousId)
```

---

## 5. Braze との連携（実装チケット: BRAZE-014）

本ドキュメントはローカルストレージの設計のみを扱う。Braze SDK の呼び出しは BRAZE-014 で実装する。

| タイミング   | Braze 操作                                                                    | 参照                                                                                      |
|--------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|
| 初回起動     | `changeUser(anonymousId)` + `logCustomAttribute('anonymous_id', anonymousId)` | `braze_003.md` § 1.1                                                                      |
| ログイン成功 | `changeUser(userId)` + `logCustomAttribute('anonymous_id', anonymousId)`      | `braze_003.md` § 3（送信責務: `AuthUseCase.login()` → `NotificationAnalyticsRepository`） |
| ログアウト   | `changeUser(newAnonymousId)`                                                  | —                                                                                         |

---

## 6. 実装方針

### 6.1 テスト容易性: `IdGenerator` 注入

UUID を内部でインスタンス化するとテスト時にモック化できない。`typedef` で抽象化し、コンストラクタ経由で注入する。

```dart
// auth_repository_impl.dart
typedef IdGenerator = String Function();

// Provider（本番: uuid パッケージを注入）
AuthRepositoryImpl
(
authApiService: ...,
authSecureStorageService: ...,
idGenerator: () => const Uuid().v4(), // 外部依存はここだけ
)

// テスト（固定値を注入）
AuthRepositoryImpl(
authApiService: mockAuthApiService,
authSecureStorageService: mockSecureStorage,
idGenerator: () => 'test-anonymous-id',
)
```

### 6.2 単一責任: メソッド分割

親メソッドは子メソッドの呼び出し・制御のみ。1つの処理を1つの子メソッドに分離することで、各処理を独立してテストできる。

| 親メソッド        | 子メソッド               | 責務                              |
|-------------------|--------------------------|-----------------------------------|
| `_ensureLoaded()` | `_loadLoginState()`      | accessToken → `_isLoggedIn` 設定  |
| `_ensureLoaded()` | `_ensureAnonymousId()`   | anonymous_id の初回発行・保存     |
| `_saveTokens()`   | `_persistTokenPair()`    | accessToken / refreshToken の保存 |
| `_saveTokens()`   | `_persistUserId()`       | user_id の保存（空なら no-op）    |
| `logout()`        | `_callLogoutApi()`       | API 呼び出し（失敗しても続行）    |
| `logout()`        | `_issueNewAnonymousId()` | 新 UUID 生成 → setAnonymousId()   |

---

## 7. 変更ファイルまとめ

| ファイル                                                                                    | 変更内容                                                                                                       |
|---------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| `lib/domain/interfaces/auth/auth_repository.dart`                                           | 変更なし（userId/anonymousId 管理は Service 層のみ）                                                           |
| `lib/data/services/local_storage/secure_storage/auth/auth_secure_storage_service.dart`      | `getAnonymousId()` / `setAnonymousId()` / `getUserId()` / `setUserId()` 追加                                   |
| `lib/data/services/local_storage/secure_storage/auth/auth_secure_storage_service_impl.dart` | 同上の実装。`init()` でロード。`clearAuthData()` は `anonymous_id` を対象外に                                  |
| `lib/data/repositories/auth/auth_repository_impl.dart`                                      | コンストラクタに `IdGenerator` 追加。`_ensureLoaded()` / `_saveTokens()` / `logout()` を親子メソッド構造に変更 |
| `pubspec.yaml`                                                                              | `uuid` パッケージ追加（未導入の場合）                                                                          |

---

## 8. スコープ外（別チケット）

| 内容                                                             | チケット                             |
|------------------------------------------------------------------|--------------------------------------|
| Braze SDK の `changeUser()` / `logCustomAttribute()` 実装        | BRAZE-014                            |
| `AuthUseCase.login()` → `NotificationAnalyticsRepository` の連携 | BRAZE-014（`braze_003.md` § 3 参照） |
