# エラーハンドリング設計方針

## 基本方針

- `ApiClientException`（インフラ概念）を Repository 境界で `AppError`（ドメイン概念）に変換する
- View は HTTP の詳細を知らない
- `Result<T>` は Repository 層で終わらせ、ViewModel 以上には持ち込まない
- ViewModel は `AsyncNotifier<State>`（`Result<State>` の二重ラップはしない）
- View は `AsyncData` / `AsyncError` のみで分岐する

---

## 各層のエラー処理責務

| 層 | エラー型 | 役割 |
|---|---|---|
| **ApiClient** | `ApiClientException` subclass を throw | HTTP ステータスコード・ネットワーク詳細を表現 |
| **Service** | `FailureResult(ApiClientException)` を返す | 例外 → Result 変換 |
| **Repository** | `FailureResult(AppError)` を返す | インフラ型 → ドメイン型に変換（**ここが境界**） |
| **ViewModel** | `throw AppError` → `AsyncError` へ | `FailureResult` → `throw` で AsyncValue に変換 |
| **View** | `AppError` の sealed switch で分岐 | エラー種別に応じた UI 表示 |

`ApiClientException` は Repository より上の層に漏らさない。

---

## データフロー

```
ApiClient  →  throw NoInternetConnectionException（ApiClientException）
Service    →  FailureResult(ApiClientException)
Repository →  FailureResult(AppError)  ← AppError.from(error) で変換
ViewModel  →  throw AppError           ← FailureResult → throw
View       →  AsyncError(AppError)     ← sealed switch で UI 分岐
```

---

## AppError の定義

`domain/errors/app_error.dart` に sealed class として定義する。

`ApiClientException` → `AppError` の変換ロジックは `AppError.from()` factory コンストラクタに集約する。
各 Repository が個別に変換メソッドを持つ必要がなくなり、`AppError.from(error)` を呼ぶだけでよい。

```dart
sealed class AppError implements Exception {
  const AppError();

  /// ApiClientException を AppError に変換する。
  /// 全 Repository で共通して使用する。
  factory AppError.from(Exception e) => switch (e) {
    NoInternetConnectionException()        => const NetworkError(),
    UnauthorizedException()                => const UnauthorizedError(),
    InternalServerErrorException()         => ServerError(500),
    BadRequestException(:final statusCode) => ClientError(statusCode ?? 400),
    NotFoundException(:final statusCode)   => ClientError(statusCode ?? 404),
    _                                      => const UnknownError(),
  };
}

/// ネットワーク未接続
class NetworkError extends AppError {
  const NetworkError();
}

/// セッション切れ（401）
class UnauthorizedError extends AppError {
  const UnauthorizedError();
}

/// サーバーエラー（5xx）
class ServerError extends AppError {
  const ServerError(this.statusCode);
  final int statusCode;
}

/// クライアントエラー（4xx）
class ClientError extends AppError {
  const ClientError(this.statusCode);
  final int statusCode;
}

/// 上記以外
class UnknownError extends AppError {
  const UnknownError();
}
```

---

## 各層の実装例

### ApiClient

HTTP ステータスコードに応じた `ApiClientException` subclass を throw する。
`SocketException` → `NoInternetConnectionException` に変換し、dart:io の型を上位に漏らさない。

```dart
// _parseResponse 内
case 400: throw BadRequestException(...);
case 401: throw UnauthorizedException(...);
case 500: throw InternalServerErrorException(...);
// SocketException catch
lastException = NoInternetConnectionException(error.message);
```

### Service

`ApiClientException` を catch し `Result<DTO>` に変換する。
この層では `ApiClientException` → `FailureResult` の変換のみ行う（`AppError` への変換は Repository が担う）。

```dart
@override
Future<Result<UserDto>> fetch() async {
  try {
    final response = await apiClient.get(endpoint: endpoint);
    return SuccessResult(UserDto.fromJson(response));
  } on ApiClientException catch (error) {
    return FailureResult(error);
  }
}
```

### Repository

`ApiClientException` を `AppError` に変換する唯一の場所。
変換ロジックは `AppError.from()` に集約されているため、各 Repository は呼ぶだけでよい。

```dart
Future<Result<User>> fetch() async {
  try {
    final result = await userApiService.fetch();
    return switch (result) {
      SuccessResult(:final value) => _toEntity(value),
      FailureResult(:final error) => FailureResult(AppError.from(error)),
    };
  } on Exception catch (error) {
    return FailureResult(AppError.from(error));
  }
}
```

### ViewModel

`AsyncNotifier<State>` を使用する（`AsyncNotifier<Result<State>>` の二重ラップはしない）。
`FailureResult` を `throw` することで Riverpod が `AsyncError` に変換する。

```dart
// ✅ Good
@override
Future<ProfileScreenState> build() async {
  final result = await ref.read(userRepositoryProvider).fetch();
  return switch (result) {
    SuccessResult(:final value) => ProfileScreenState(user: value),
    FailureResult(:final error) => throw error,  // AppError が AsyncError になる
  };
}

// ❌ Bad: Result<State> の二重ラップ
@override
Future<Result<ProfileScreenState>> build() async {
  final result = await ref.read(userRepositoryProvider).fetch();
  return switch (result) {
    SuccessResult(:final value) => SuccessResult(ProfileScreenState(user: value)),
    FailureResult(:final error) => FailureResult(error),
  };
}
```

### View

`AsyncData` / `AsyncError` のみで分岐する。
`AsyncError.error` を `AppError` の型パターンでエラー種別ごとに UI を出し分ける。

`UnauthorizedError` は後述の `ProviderObserver` が共通処理するため、View の switch には書かない。

```dart
// ✅ Good
body: switch (viewModel) {
  AsyncLoading() => const CircularProgressIndicator(),
  AsyncData(:final value) => _Body(state: value),
  AsyncError(:final error) => switch (error) {
    NetworkError() => _NoInternetView(onRetry: ...),
    ServerError()  => _ServerErrorView(onRetry: ...),
    AppError()     => CoreError(error: error, onPressed: ...),
    _              => CoreError(error: Exception(error), onPressed: ...),
  },
},

// ❌ Bad: AsyncData の中に Result の switch が混在
body: switch (viewModel) {
  AsyncLoading() => const CircularProgressIndicator(),
  AsyncData(value: final result) => switch (result) {
    SuccessResult(value: final state) => _Body(state: state),
    FailureResult(:final error) => CoreError(error: error, ...),
  },
  AsyncError(:final error) => CoreError(error: error as Exception, ...),
},
```

#### sealed class なのに UnauthorizedError を省略できる理由

`AppError` は sealed class だが、View の switch で exhaustiveness（網羅性）チェックが働かない理由がある。

`AsyncError.error` の静的型は `Object` であり、`AppError` ではない。
Dart の sealed class exhaustiveness チェックは、**switch の対象が sealed 型として静的に型付けされている場合のみ**適用される。

```dart
// sealed exhaustiveness が適用される（error が AppError 型）
final AppError appError = error as AppError;
switch (appError) {
  case NetworkError(): ...
  // UnauthorizedError, ServerError, ClientError, UnknownError が未記載 → コンパイルエラー
}

// sealed exhaustiveness が適用されない（error が Object 型）
switch (error) {          // error は Object
  NetworkError() => ...,
  ServerError()  => ...,
  AppError()     => ...,  // 残りの AppError subclass（UnauthorizedError 含む）はここに落ちる
  _              => ...,  // Object 全体をカバーするワイルドカード
}
```

`_` ワイルドカードが `Object` 全体を網羅するため、`UnauthorizedError` を省略してもコンパイルエラーにならない。
`UnauthorizedError` が発生した場合は `AppError()` パターンに落ちるが、`ProviderObserver` が即座に logout を呼ぶため、このブランチが描画されることはほぼない。

---

## UnauthorizedError の共通処理（ProviderObserver）

`UnauthorizedError`（セッション切れ）は全画面で同一の挙動（強制ログアウト → LoginScreen へ全スタッククリアで遷移）が必要なため、各 View に書くのではなく `ProviderObserver` で一元処理する。

### 仕組み

```
AsyncError(UnauthorizedError) 発生
  ↓ ProviderObserver.didUpdateProvider が検知
authRepository.logout() 呼び出し
  ↓ _isLoggedIn = false → notifyListeners()
GoRouter の refreshListenable が発火
  ↓ redirect 再評価 → loggedIn == false
LoginScreen.path へ go（全スタッククリア）
```

GoRouter の `refreshListenable` に `AuthRepository`（`ChangeNotifier`）を渡している設計を活用する。
View から直接遷移するのではなく、**認証状態を変えるだけで GoRouter が自動でリダイレクト**する。

### 実装

```dart
// lib/utils/unauthorized_error_observer.dart
class UnauthorizedErrorObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (newValue is AsyncError && newValue.error is UnauthorizedError) {
      container.read(authRepositoryProvider).logout();
    }
  }
}
```

```dart
// main.dart
ProviderScope(
  observers: [UnauthorizedErrorObserver()],
  child: const MyApp(),
)
```

---

## アクション系のエラーハンドリング

画面の初期ロード（`build()`）と異なり、ユーザー操作（いいね送信等）はエラー種別ごとに異なる UI を出す必要がある。
この場合は `AsyncError` に変換せず、**コールバック方式**を使う。

アクション系でも `UnauthorizedError` の場合は `logout()` を呼ぶだけでよい。
GoRouter が自動でリダイレクトするため、View 側にコールバックを用意する必要はない。

```dart
// ViewModel
Future<void> submitAction({
  required int targetId,
  required VoidCallback onSuccess,
  required VoidCallback onNetworkError,
  required VoidCallback onFailure,
}) async {
  final result = await ref.read(someRepositoryProvider).submit(targetId);
  switch (result) {
    case SuccessResult():
      onSuccess();
    case FailureResult(:final error):
      switch (error) {
        case UnauthorizedError():
          // logout() → notifyListeners() → GoRouter が LoginScreen へリダイレクト
          await ref.read(authRepositoryProvider).logout();
        case NetworkError(): onNetworkError();
        default:             onFailure();
      }
  }
}

// View（onUnauthorized コールバック不要）
onPressed: () => ref.read(provider.notifier).submitAction(
  targetId: id,
  onSuccess: () { ... },
  onNetworkError: () => showNetworkErrorDialog(context),
  onFailure: () => showGenericErrorDialog(context),
),
```

`build()` の結果（画面全体のエラー）と、アクションの結果（部分的なエラー）を分けて扱うことで、それぞれの UI 表現に適した設計になる。
