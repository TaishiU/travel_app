# Repository 規約

## Interface と依存性の逆転

### ファイル構成

Repository は Interface と実装クラス（Impl）に分離する。Service レイヤーと同じ構造。

```
lib/domain/interfaces/{feature}/〇〇_repository.dart   ← Interface（抽象クラス）
lib/data/repositories/{feature}/〇〇_repository_impl.dart ← Impl（実装クラス）
lib/domain/entities/{feature}/〇〇.dart                ← Entity
```

これにより UseCase はデータ層の実装を知らず、Interface にのみ依存する（依存性の逆転）。

```
UseCase → Interface ← RepositoryImpl
```

### 命名規則

| | ファイル名 | クラス名 |
|---|---|---|
| Interface | `〇〇_repository.dart` | `〇〇Repository` |
| Impl | `〇〇_repository_impl.dart` | `〇〇RepositoryImpl` |

### Provider の定義

Provider は Impl ファイルに定義し、**型は Interface** で提供する。UseCase / Notifier は Interface 型として受け取るため、Impl の詳細を知らない。

```dart
// lib/data/repositories/user/user_repository_impl.dart
final userRepositoryProvider = Provider<UserRepository>( // ← Interface 型
  (ref) => UserRepositoryImpl(
    usersApiService: ref.read(usersApiServiceImplProvider),
  ),
);
```

### Auth の特殊ケース（ChangeNotifier）

GoRouter の `refreshListenable` に`ChangeNotifier`を渡す必要があるが、**Interface（Domain層）はFlutter非依存に保つ**。`ChangeNotifier` の継承は Impl 側のみ。

```dart
// lib/domain/interfaces/auth/auth_repository.dart
// Flutter 依存なし
abstract class AuthRepository {
  Future<bool> get isLoggedIn;
  Future<Result<void>> login({required String username, required String password});
  Future<void> logout();
}
```

```dart
// lib/data/repositories/auth/auth_repository_impl.dart

// 通常（Interface 型）
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ref.read(authRepositoryImplProvider),
);

// GoRouter 用（Impl 型で ChangeNotifier として渡す）
final authRepositoryImplProvider = Provider<AuthRepositoryImpl>(
  (ref) => AuthRepositoryImpl(...),
);

class AuthRepositoryImpl extends ChangeNotifier implements AuthRepository {
  @override
  Future<Result<void>> login({...}) async {
    // ...
    notifyListeners(); // GoRouter の redirect をトリガー
  }
}
```

```dart
// GoRouter
refreshListenable: ref.read(authRepositoryImplProvider)
```

Provider が2本になるが、UseCase / Notifier は Interface 型のみを知り、GoRouter だけが Impl を直接参照する構成になる。

---

## パターン一覧

Repository は以下4パターンに分類される。新規作成時はどのパターンに該当するかを判断して実装する。

| パターン | 典型例 | 使用条件 |
|---|---|---|
| A: シンプル fetch | `UserRepository` | 単一画面・キャッシュ不要 |
| B: メモリキャッシュ + StreamController | `TodoRepository` | 複数画面でデータ同期が必要 |
| C: LocalDB Stream パススルー | `TaskRepository` | DB がリアクティブな場合 |
| D: ChangeNotifier | `AuthRepository` | GoRouter リダイレクト専用 |

---

## Pattern A: シンプル fetch

**使用条件**: 単一画面のみで利用・画面間同期不要・キャッシュ不要

**実装例**: `lib/data/repositories/user/user_repository.dart`

- Service を呼び出し DTO → Entity 変換して返すだけ
- `StreamController` やキャッシュフィールドは持たない

```dart
Future<Result<User>> fetch() async {
  try {
    final result = await usersApiService.fetchById();
    switch (result) {
      case SuccessResult<UserDto>():
        final user = _toEntity(dto: result.value);
        if (user == null) return const FailureResult(UnknownError());
        return SuccessResult(user);
      case FailureResult<UserDto>():
        return FailureResult(AppError.from(result.error));
    }
  } on Exception catch (error) {
    return FailureResult(AppError.from(error));
  }
}
```

---

## Pattern B: メモリキャッシュ + StreamController

**使用条件**: 複数の独立した画面が同一データを同時に表示・更新する場合

**実装例**: `lib/data/repositories/todo/todo_repository.dart`

- `StreamController.broadcast()` で SSOT キャッシュの変更を通知
- `List.unmodifiable()` で流すことで UI 側の直接操作を防ぎ、「更新は必ず Repository 経由」を強制する

```dart
final _todosStreamController = StreamController<List<Todo>>.broadcast();
Stream<List<Todo>> get todosStream => _todosStreamController.stream;
List<Todo> _todos = [];

// 更新時
_todos[index] = updated;
_todosStreamController.add(List.unmodifiable(_todos));
```

**注意**: `StreamController.broadcast()` は新規購読者に直前の値を流さない。
Notifier の `build()` で `ref.watch(streamProvider)` する場合、`fetch()` を先行して呼ぶか、初期データを Provider 側で保証する設計にする。

---

## Pattern C: LocalDB Stream パススルー

**使用条件**: LocalDB（Drift 等）のリアクティブな watch を利用する場合

**実装例**: `lib/data/repositories/task/task_repository.dart`

- DB の `watchAll()` を Stream として公開し、DB への書き込みが発生した時点で自動反映
- Repository 自身は `StreamController` を持たない

```dart
Stream<List<Task>> get tasksStream => taskLocalService.watchAll().map(
  (items) => items.map((item) => _toEntity(item: item)).toList(),
);
```

---

## Pattern D: ChangeNotifier（GoRouter リダイレクト専用）

**使用条件**: GoRouter の `redirect` でログイン状態を判定する場合のみ

**実装例**: `lib/data/repositories/auth/auth_repository.dart`

- `ChangeNotifier` を継承し `notifyListeners()` で GoRouter に変更を通知
- GoRouter の `refreshListenable` に渡すことで、ログイン・ログアウト時に自動でリダイレクト判定が走る
- 認証トークンは SecureStorage に永続化し、メモリキャッシュ（`_isLoggedIn`）と併用

```dart
class AuthRepository extends ChangeNotifier {
  bool? _isLoggedIn;

  Future<Result<void>> login({...}) async {
    // ...
    _isLoggedIn = true;
    notifyListeners(); // GoRouter の redirect をトリガー
    return const SuccessResult(null);
  }
}
```

**注意**: `ChangeNotifier` は GoRouter のリダイレクト制御が目的のパターン。認証以外の用途では使用しない。

---

## SSOT 採用基準

以下に該当する場合に Pattern B または C を選択する。

| 条件 | SSOT 必要 |
|---|---|
| 複数の独立した画面が同一データを同時に表示する | ✅ |
| 一方の更新を他方に即座に反映させる必要がある | ✅ |
| 単一画面でのみ利用する | ❌ |
| 画面遷移後は古いデータを捨てて再取得する設計 | ❌ |

---

## `_toEntity`（腐敗防止層）

### 役割

Web API から渡ってくるデータは常に不安定（値の欠損・null・予期しない型）である。
`_toEntity` はその不安定さを吸収し、ドメイン層に **null を持ち込まない** ための腐敗防止層（Anti-Corruption Layer）として機能する。

```
DTO（nullable）→ _toEntity → Entity（non-nullable）→ UseCase / Notifier / View
```

この変換を Repository に集約することで、UseCase 以降の層は null を意識しない実装になる。

### 規則

**Entity のフィールドは原則 non-nullable にする。**
`_toEntity` 内で DTO の nullable フィールドに対して `??` で初期値を与え、null を Entity に持ち込まない。

| 型 | デフォルト初期値 | 備考 |
|---|---|---|
| `String` | `''` | |
| `int` | `0` | |
| `double` | `0.0` | |
| `bool` | `false` | 要件によって `true` になる場合もある（例: デフォルトで公開状態など） |
| `List<T>` | `[]` | |
| ネストした DTO | 再帰的に `_toEntity` 系メソッドで変換 | |

**必須フィールドが欠損している場合は null を返す（変換失敗扱い）。**
Entity として成立しない（ID など識別子が null）場合は `null` を返し、呼び出し元（fetch メソッド）で null チェックして `FailureResult` を返す。

```dart
// _toEntity が null を返した場合は FailureResult として扱う
Future<Result<User>> fetch() async {
  // ...
  case SuccessResult<UserDto>():
    final user = _toEntity(dto: result.value);
    if (user == null) return const FailureResult(UnknownError());
    return SuccessResult(user);
}
```

参照: `lib/data/repositories/user/user_repository.dart`

```dart
// ✅ 必須フィールド欠損 → null を返す
Todo? _toEntity({required TodoDto dto}) {
  if (dto.id == null || dto.userId == null) return null;

  return Todo(
    id: dto.id!,           // null チェック済みなので ! を使用
    userId: dto.userId!,   // 同上
    todo: dto.todo ?? '',
    completed: dto.completed ?? false,
  );
}

// ✅ ネストした DTO → 専用の private メソッドに委譲
User? _toEntity({required UserDto dto}) {
  if (dto.id == null) return null;

  return User(
    id: dto.id!,
    hair: _toHairEntity(hairDto: dto.hair),
    address: _toAddressEntity(addressDto: dto.address),
    // ...
  );
}

Hair _toHairEntity({required HairDto? hairDto}) => Hair(
  color: hairDto?.color ?? '',
  type: hairDto?.type ?? '',
);
```

### やってはいけないこと

```dart
// ❌ Entity に nullable フィールドを持ち込む
class Todo {
  final String? todo; // → View で null チェックが発生し続ける
}

// ❌ _toEntity の外で ?? を使って初期値を補完する
// Repository の外に null 処理が漏れ出す
final title = todo.title ?? ''; // UseCase や View でやらない
```

---

## SSOT 採用基準

以下に該当する場合に Pattern B または C を選択する。

| 条件 | SSOT 必要 |
|---|---|
| 複数の独立した画面が同一データを同時に表示する | ✅ |
| 一方の更新を他方に即座に反映させる必要がある | ✅ |
| 単一画面でのみ利用する | ❌ |
| 画面遷移後は古いデータを捨てて再取得する設計 | ❌ |

---

## 共通規約

- `ApiClientException` → `AppError` の変換は Repository が唯一の場所（Service で変換しない）
- DTO → Entity の変換ロジックは private メソッドに隠蔽する（`_toEntity`）
- ビジネスロジック（フィルタリング・ソート・バリデーション）は UseCase / Entity へ委譲する
- プレゼンテーション層の関心事（表示順・UI 固有フィルタ）を持たない
