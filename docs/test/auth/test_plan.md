# auth テスト方針

参照: [test_guideline.md](../test_guideline.md)

---

## スタブ境界

末端I/O（プロセス外と通信する箇所）のみスタブに置き換え、それ以外は実物を使う。
参照: [test_guideline.md レイヤー別テスト設計](../test_guideline.md#レイヤー別テスト設計)

```
Notifier → UseCase → Repository → [AuthSecureStorageServiceImpl] → [StubSecureStorageServiceImpl]
                         ↓                                                        ↑
                  [StubAuthApiServiceImpl]                                  ここでスタブ注入 → 1プロセスで完結（Small）
```

`AuthSecureStorageServiceImpl` はメモリバッファ（`_accessToken` 等）を持つ実装であり、
`SecureStorageService`（`flutter_secure_storage` ラッパー）が真のI/O境界。

---

## 新規作成ファイル

| ファイル | 用途 |
|---|---|
| `lib/data/services/local_storage/secure_storage/stub_secure_storage_service.dart` | `SecureStorageService` のインメモリスタブ（全テスト共通） |
| `lib/data/services/web_api/auth/stub_service_impl.dart`（修正） | `shouldFail` フラグ追加（異常系テスト用） |

---

## テストファイル構成

エントリーポイントにミラーする配置原則に従う。
参照: [test_guideline.md Integration テストのファイル配置原則](../test_guideline.md#integration-テストのファイル配置原則)

| ファイル | エントリーポイント | 種別 |
|---|---|---|
| `test/presentation/login/login_screen_notifier_integration_test.dart` | `LoginScreenNotifier` | Integration × Small |
| `test/domain/use_cases/auth/auth_use_case_integration_test.dart` | `AuthUseCase` | Integration × Small |
| `test/data/repositories/auth/auth_repository_impl_test.dart` | `AuthRepositoryImpl` | Unit × Small |
| `test/data/services/local_storage/secure_storage/auth/auth_secure_storage_service_impl_test.dart` | `AuthSecureStorageServiceImpl` | Unit × Small |

---

## ProviderContainer 構成

`secureStorageServiceImplProvider` を上書きすることで、
`authSecureStorageServiceImplProvider` が内部で参照する `SecureStorageService` がスタブに差し替わる。

```dart
ProviderContainer buildContainer({bool shouldFail = false}) {
  return ProviderContainer(
    overrides: [
      authApiServiceImplProvider.overrideWithValue(
        StubAuthApiServiceImpl(shouldFail: shouldFail),
      ),
      secureStorageServiceImplProvider.overrideWithValue(
        StubSecureStorageServiceImpl(),
      ),
    ],
  );
}
```

---

## 3条件・テストケース設計

参照: [test_guideline.md テスト仕様の設計原則](../test_guideline.md#テスト仕様の設計原則契約による設計)

### `LoginScreenNotifier` Integration テスト

#### `login`

| ケース | 事前条件 | 事後条件 |
|---|---|---|
| 正常系: ログイン成功 | StubApi が `SuccessResult(TokenResponseDto)` を返す | `state == AsyncData(LoginScreenState(isLoading: false))` |
| 正常系: 二重呼び出し防止 | `isLoading: true` の state | 2回目の `login()` が即リターン・state 変化なし |
| 異常系: ログイン失敗 | StubApi が `FailureResult` を返す | `state` が `AsyncError` に遷移 |

#### `register`

| ケース | 事前条件 | 事後条件 |
|---|---|---|
| 正常系: 登録成功 | StubApi が `SuccessResult(TokenResponseDto)` を返す | `state == AsyncData(LoginScreenState(isLoading: false))` |
| 異常系: 登録失敗 | StubApi が `FailureResult` を返す | `state` が `AsyncError` に遷移 |

---

### `AuthUseCase` Integration テスト

#### `login`

| ケース | 事前条件 | 事後条件 |
|---|---|---|
| 正常系: pendingDeepLink なし | StubApi 成功 / `pendingDeepLink == null` | `SuccessResult(null)` |
| 正常系: pendingDeepLink あり | StubApi 成功 / `repo.pendingDeepLink = '/foo'` 設定済み | `SuccessResult('/foo')` かつ取得後クリア |
| 異常系: API エラー | StubApi が `FailureResult` を返す | `FailureResult` |

#### `register`

| ケース | 事前条件 | 事後条件 |
|---|---|---|
| 正常系 | StubApi 成功 | `SuccessResult(null)` |
| 異常系 | StubApi が `FailureResult` を返す | `FailureResult` |

#### `checkIsLoggedIn`

| ケース | 事前条件 | 事後条件 |
|---|---|---|
| 正常系: 未ログイン | StubSecureStorage に accessToken なし | `false` |
| 正常系: ログイン済み | `login()` 成功後 | `true` |

---

### `AuthRepositoryImpl` Unit テスト

#### `login`

| ケース | 事前条件 | 事後条件 |
|---|---|---|
| 正常系: トークン保存 | StubApi が `TokenResponseDto(accessToken, refreshToken, user)` を返す | `SuccessResult<void>` / SecureStorage にトークン保存 / `isLoggedIn == true` |
| 異常系: エラー変換 | StubApi が `FailureResult(ApiClientException)` を返す | `FailureResult(AppError)` に変換 |

#### `logout`

| ケース | 事前条件 | 事後条件 |
|---|---|---|
| 正常系 | ログイン済み状態 | `isLoggedIn == false` / accessToken・refreshToken が空文字 / anonymousId は保持 |

#### `isLoggedIn`

| ケース | 事前条件 | 事後条件 |
|---|---|---|
| 正常系: 初回ロード（トークンなし） | StubSecureStorage に何もない | `false` |
| 正常系: 初回ロード（トークンあり） | StubSecureStorage に accessToken がある | `true` |
| 正常系: ログイン後（キャッシュ） | `login()` 完了済み | `_ensureLoaded` を経由せず `true` |

---

### `AuthSecureStorageServiceImpl` Unit テスト

#### `init`

| ケース | 事前条件 | 事後条件 |
|---|---|---|
| 正常系: ストレージから読み込み | StubSecureStorage に各キーの値が保存済み | `getAccessToken()` 等で値を取得できる |
| 正常系: ストレージが空 | StubSecureStorage に何もない | 全ゲッターが空文字を返す |

#### `setAccessToken` / `getAccessToken`

| ケース | 事前条件 | 事後条件 |
|---|---|---|
| 正常系 | 初期状態 | `setAccessToken` 後に `getAccessToken` で同値を返す |

#### `clearAuthData`

| ケース | 事前条件 | 事後条件 |
|---|---|---|
| 正常系 | accessToken・refreshToken・userId が保存済み | 3つが空文字 / anonymousId は保持 |
