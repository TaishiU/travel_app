# 設計方針議論メモ

## 問題の発端

auth テストを実装する中で、`AuthSecureStorageService` インターフェース（以下 IF）の存在意義を問い直す必要が生じた。

---

## 元々の設計方針

**「インターフェースを設ける理由はスタブ注入のため」**

```
実I/O（flutter_secure_storage, http など）を末端に集約し、
インターフェースを境界にしてスタブと差し替えることで
Notifier → UseCase → Repository → Service（実物）まで
1プロセスで一気通貫のテストを可能にする。
```

この方針に基づき、現プロジェクトのスタブ境界は以下の2か所：

| インターフェース | スタブ | 担う I/O |
|---|---|---|
| `AuthApiService` | `StubAuthApiServiceImpl` | HTTP 通信 |
| `SecureStorageService` | `StubSecureStorageServiceImpl` | flutter_secure_storage |

---

## 問題視していること

### `AuthSecureStorageService` IF の必要性

```
lib/data/services/local_storage/secure_storage/auth/auth_secure_storage_service.dart
```

- `AuthSecureStorageServiceImpl` は存在する（実装クラス）
- `StubAuthSecureStorageServiceImpl` は存在しない（スタブ不在）
- テストは `StubSecureStorageServiceImpl` を下位に注入することで、`AuthSecureStorageServiceImpl` を実物のまま動かせる

→ 「スタブを入れる必要がない = IF を設ける理由がない」という主張

---

## IF を削除した場合の影響範囲

### 変更が必要なファイル

| ファイル | 変更内容 |
|---|---|
| `lib/data/services/local_storage/secure_storage/auth/auth_secure_storage_service.dart` | 削除 |
| `lib/data/repositories/auth/auth_repository_impl.dart` | コンストラクタの型を `AuthSecureStorageServiceImpl` に変更 |
| `lib/data/services/web_api/api_client.dart` | フィールドの型を `AuthSecureStorageServiceImpl` に変更 |
| `lib/data/services/local_storage/secure_storage/auth/auth_secure_storage_service_impl.dart` | provider の返り型を `AuthSecureStorageServiceImpl` に変更 |
| `test/data/repositories/auth/auth_repository_test.dart` | `MockAuthSecureStorageService` → mock不要 or 具象クラスをmock |
| `test/data/services/web_api/api_client_test.dart` | `MockAuthSecureStorageService` → `StubSecureStorageServiceImpl` ベースに書き直し |

---

## 核心の論点：IF の用途は2種類ある

現状、`AuthSecureStorageService` IF は**2つの異なる目的**で使われている。

### 用途①：I/O スタブ（元々の設計方針）

```
テスト対象 → Interface ← StubImpl（インメモリ）
```

`SecureStorageService` がこれに該当。`flutter_secure_storage` という実I/Oを排除するためのIF。

### 用途②：依存制御（api_client_test での実態）

```dart
// getAccessToken() が返す値をピンポイントで指定
when(mockAuthService.getAccessToken()).thenReturn('valid_token');
```

`api_client_test.dart` における `MockAuthSecureStorageService` がこれに該当。
I/O の排除ではなく「テスト対象（`ApiClient`）が隣の依存から受け取る値を制御する」ための使い方。

---

## メリット・デメリット

### IF を削除する（方針に一貫する）

| | 内容 |
|---|---|
| **メリット** | 「IFはスタブのため」という方針に完全一致。不要な抽象層がなくなる |
| **デメリット** | `api_client_test.dart` の書き直しが必要。`StubSecureStorageServiceImpl` + `AuthSecureStorageServiceImpl` + `init()` の組み合わせが冗長になる |

### IF を残す（現状維持）

| | 内容 |
|---|---|
| **メリット** | `api_client_test.dart` の依存制御テストが簡潔に書ける |
| **デメリット** | 「IFはスタブのため」という方針と矛盾する。IFの存在理由が暗黙的になる |

---

## 結論

**`AuthSecureStorageService` IF を削除する。**

### 根拠

- IFの目的は「実I/Oをスタブに差し替えるため」のみ（`architecture_responsibilities.md` に明文化済み）
- `AuthSecureStorageServiceImpl` は実I/Oを持たず、`SecureStorageService`（IF あり）に委譲しているだけ → IF不要の基準に該当
- `api_client_test.dart` で `MockAuthSecureStorageService` を使っていた理由（依存制御）は、IFを設ける根拠として認めない

### 対応内容

| ファイル | 変更内容 |
|---|---|
| `lib/data/services/local_storage/secure_storage/auth/auth_secure_storage_service.dart` | 削除 |
| `lib/data/repositories/auth/auth_repository_impl.dart` | 型を `AuthSecureStorageServiceImpl` に変更 |
| `lib/data/services/web_api/api_client.dart` | 型を `AuthSecureStorageServiceImpl` に変更 |
| `lib/data/services/local_storage/secure_storage/auth/auth_secure_storage_service_impl.dart` | provider の返り型を `AuthSecureStorageServiceImpl` に変更 |
| `test/data/services/web_api/api_client_test.dart` | `MockAuthSecureStorageService` → `StubSecureStorageServiceImpl` + `AuthSecureStorageServiceImpl` に書き直し |
