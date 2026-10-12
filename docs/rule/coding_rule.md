# コーディング規約

## アーキテクチャ責務

このプロジェクトは **Feature-First Clean Architecture** を採用している。
各レイヤーの詳細な責務・実装例は [architecture_responsibilities.md](../architecture/architecture_responsibilities.md) を参照。

---

## 重要な原則

### 1. 依存関係の方向

```
View → Notifier → UseCase（画面 / ドメイン）→ Interface ← Repository → Service
Entity ← Repository（DTO → Entity 変換）
```

- Notifier は UseCase を通じてのみ Interface にアクセスする
- UseCase は Interface（抽象クラス）のみを知り、Repository 実装に依存しない
- Entity はどの層にも依存しない

### 2. 責務の分離

| コンポーネント | パス | 責務 | 禁止事項                                   |
|---|---|---|----------------------------------------|
| **View** | `presentation/*/screen.dart` | 状態の描画・ユーザーアクションの委譲 | ビジネスロジック・直接の UseCase / Repository 呼び出し |
| **Notifier** | `presentation/*/notifier.dart` | UseCase 呼び出し・state 更新 | 業務ロジック保持・データ層への直接アクセス                  |
| **UseCase（画面）** | `presentation/*/use_case.dart` | 画面固有の業務ロジック | state 更新・Repository 実装への直接依存           |
| **UseCase（ドメイン）** | `domain/use_cases/` | ドメイン概念の業務ロジック | state 更新・プレゼンテーション層 / データ層への依存         |
| **Repository** | `data/repositories/` | SSOT 管理・DTO→Entity 変換・Stream 通知 | プレゼンテーション層への依存                         |
| **Service** | `data/services/` | HTTP 通信・LocalStorage 操作・DTO 返却 | ビジネスロジック                               |
| **Entity** | `domain/entities/` | ビジネスモデルの表現 | プレゼンテーション層 / データ層への依存                                   |

### 3. `on Exception catch` の徹底

```dart
// ✅ Good
try {
  final result = await apiService.fetch();
  // ...
} on Exception catch (error) {
  return FailureResult(error);
}

// ❌ Bad: 型なし catch（avoid_catches_without_on_clauses 違反）
try {
  final result = await apiService.fetch();
} catch (e) {
  return FailureResult(Exception(e.toString()));
}
```

### 4. Null Safety

- `!`（強制アンラップ）は**絶対に使用しない**
- `??`、`?.`、`final` への代入で対応する

```dart
// ✅ Good
final value = nullableValue ?? defaultValue;
final name = dto.name ?? '';

// ❌ Bad
final value = nullableValue!;
```

---

## 命名規則

### 基本ルール

- **Bool 値プロパティ**: `is`, `has`, `can`, `should` をprefix
  ```dart
  bool isCompleted;
  bool hasError;
  bool canSubmit;
  bool isFetched;
  ```

- **private メソッド/プロパティ**: `_` をprefix
  ```dart
  List<Todo> _todos;
  Todo? _toEntity(TodoDto dto) {}
  ```

- **生成ファイル**: `.freezed.dart`, `.g.dart`

### View 命名規則

- **`_screen`**: AppBar / BottomNavigationBar 等を持つ画面
  ```dart
  class TodoListScreen extends HookConsumerWidget {}
  ```

- **`_page`**: ページ単位で切り替わる UI
  ```dart
  class TodoDetailPage extends HookConsumerWidget {}
  ```

- **`_widget`**: View 跨ぎで再利用可能なコンポーネント
  ```dart
  class CoreAppBar extends StatelessWidget {}
  ```

- **`_item`**: リスト / グリッドの個々要素（View 跨がない）
  ```dart
  class TodoListItem extends StatelessWidget {}
  ```

### クラス・ファイル命名

- **ファイル名**: snake_case
  ```
  todo_list_screen_notifier.dart
  todos_dto.dart
  auth_use_case.dart
  ```

- **クラス名**: PascalCase
  ```dart
  class TodoListScreenNotifier {}
  class TodosDto {}
  class AuthUseCase {}
  ```

- **変数・メソッド名**: lowerCamelCase
  ```dart
  final filterdTodos = [];
  Future<void> toggleTodo(int id) async {}
  ```

- **定数**: lowerCamelCase
  ```dart
  static const endpoint = 'todos';
  ```

---

## Flutter/Dart コーディング規約

### 1. Widget 構成

#### Widget の選択

- **状態を持たない**: `StatelessWidget`
- **ローカル状態 + Hooks**: `HookConsumerWidget`（Riverpod + flutter_hooks 利用時）
- **Riverpod のみ**: `ConsumerWidget`

```dart
class TodoListScreen extends HookConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(todoListScreenProvider);
    return Scaffold(/* ... */);
  }
}
```

#### Widget の分割

- 1つの Widget は 100 行以内を目安に分割
- 再利用可能な部分は別 Widget に抽出
- `build` メソッド内に複雑なロジックを書かない

### 2. const の使用

可能な限り `const` を使用して Widget 再構築を最適化する。

```dart
// ✅ Good
const Text('Hello')
const SizedBox(height: 16)
const EdgeInsets.all(8)
const CircularProgressIndicator()

// ❌ Bad
Text('Hello')
SizedBox(height: 16)
```

### 3. Key の使用

リストアイテムには必ず `Key` を指定する。

```dart
ListView.builder(
  itemBuilder: (context, index) {
    final todo = todos[index];
    return TodoListItem(
      key: ValueKey(todo.id),
      todo: todo,
    );
  },
)
```

### 4. 名前付き引数

**引数の個数に関わらず、メソッド・関数・コンストラクタの引数には必ず名前付き引数（`{...}`）を使用する。**

```dart
// ✅ Good: 何を渡しているか呼び出し元で明確
Future<Result<void>> login({
  required String username,
  required String password,
}) { ... }

login(username: username, password: password);

// ❌ Bad: 同じ型が並ぶと順序ミスがコンパイルエラーにならない
Future<Result<void>> login(String username, String password) { ... }

login(password, username); // 順序ミス: String 同士なのでコンパイルエラーにならない
```

**理由:**
- 同じ型の引数が複数ある場合、位置引数では引数の順序ミスがコンパイルエラーにならない
- 名前付き引数により呼び出し元で「何に何を渡しているか」が自明になる
- チーム内での一貫性を保つ（メンバーによって名前付き有無がバラバラになることを防ぐ）

**「1引数なら位置引数でも良い」としない理由:**
- `fetchById(user.id)` と書くべきところを `fetchById(item.id)` と書いてもコンパイルが通る。「1引数だから自明」は成立しない
- 引数が増えた時点でルールが変わる → 「今は1つだから位置引数」→「増えたから名前付きに直す」という余計な修正が発生する
- 「常に名前付き」にすることで判断コストがゼロになり、コードベース全体の一貫性が保たれる

**`required` の付け方（nullable との共存）:**

`required` の意味は「省略不可」であり「非 null」ではない。null 許容型でも `required` を付けられる。
付けるかどうかは「呼び出し側が省略できるか」で判断する。

| 引数の性質 | 書き方 | 呼び出し側 |
|---|---|---|
| 非 null・必須 | `required String name` | `foo(name: 'Alice')` |
| null 許容・必須（明示的に null を渡させる） | `required String? name` | `foo(name: null)` |
| null 許容・省略可（省略 = null と同義） | `String? name` | `foo()` または `foo(name: 'Alice')` |

```dart
// ✅ required String? — null を渡すことを呼び出し側に明示させる
Future<void> updateProfile({
  required String? displayName,  // null = 「名前を削除する」という意図
  required String? avatarUrl,
}) { ... }

updateProfile(displayName: null, avatarUrl: 'https://...');

// ✅ String?（required なし）— 省略可能なオプション
Future<List<Todo>> fetchTodos({
  String? statusFilter,   // 省略時は全件取得
  String? searchQuery,    // 省略時はフィルタなし
}) { ... }

fetchTodos();                          // 省略可
fetchTodos(statusFilter: 'completed'); // 一部だけ渡せる
```

**補足・例外:**
- Flutter フレームワークのオーバーライドメソッド（`build(BuildContext context, WidgetRef ref)` 等）は対象外
- このルールは Dart 標準 lint で自動強制できないため、`scripts/check_named_args.dart` で pre-commit 時に検知する

#### `required` を optional より前に宣言する

名前付き引数リスト内では、**`required` 引数を optional 引数より前に宣言する**。

```dart
// ✅ Good: required → optional の順
Future<List<Product>> fetchProducts({
  required String categoryId,
  String? query,
  int? limit,
}) { ... }

// ❌ Bad: optional が required より前
Future<List<Product>> fetchProducts({
  String? query,
  required String categoryId,
  int? limit,
}) { ... }
```

**理由:**
- 呼び出し側が「何を必ず渡さなければならないか」をシグネチャの先頭で把握できる
- IDE の補完候補にも `required` 引数が先に表示されるため入力ミスを減らせる

### 5. BuildContext の扱い

非同期処理後に `BuildContext` を使用する場合は `mounted` チェックを行う。

```dart
// ✅ Good
Future<void> _handleSubmit(BuildContext context) async {
  await repository.submit();
  if (!context.mounted) return;
  Navigator.of(context).pop();
}
```

### 5. 非同期処理

`async/await` を使用する。`then/catchError` は使用しない。

```dart
// ✅ Good
Future<Result<void>> login({
  required String username,
  required String password,
}) async {
  try {
    final result = await authApiService.login(
      username: username,
      password: password,
    );
    // ...
  } on Exception catch (error) {
    return FailureResult(error);
  }
}

// ❌ Bad
Future<Result<void>> login({...}) {
  return authApiService.login(...).then((result) {
    // ...
  }).catchError((e) {
    return FailureResult(Exception(e.toString()));
  });
}
```

### 6. セキュアなデータ保存

認証トークン等の機密データは `AuthSecureStorageService` を使用して保存する。

```dart
// ✅ Good
await authSecureStorageService.setAccessToken(token);

// ❌ Bad
final prefs = await SharedPreferences.getInstance();
await prefs.setString('access_token', token);  // 暗号化されない
```

### 7. Import 順序

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. 外部パッケージ
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 4. 内部パッケージ（同プロジェクト）
import 'package:travel_app/data/repositories/todo/todo_repository.dart';
import 'package:travel_app/domain/entities/todos/todos.dart';
import 'package:travel_app/utils/result.dart';
```

### 8. コメント

変数名・メソッド名・処理の内容を読むだけで理解できるようにする。
それでもわからない非自明な処理のみにコメントを付与する。

```dart
// TODO コメント
// TODO(username): 環境変数から読み込む
final apiConfig = ApiConfig.development();
```

### 9. Linter 設定

- `analysis_options.yaml` で設定
- 静的解析: `flutter analyze`

**必須対応ルール**:

**エラーハンドリング**:
- `avoid_catches_without_on_clauses`: catch 句で具体的な例外型を指定

**パフォーマンス最適化**:
- `prefer_const_constructors`: 可能な限り const を使用
- `unawaited_futures`: Future は必ず await する

**Null Safety**:
- `use_null_aware_elements`: Map リテラルで nullable 値を条件付き追加する場合は `'key': ?value` 構文を使用（`if (x != null) 'key': x` は違反）→ 実装パターンは `docs/rule/service_rule.md`の「Map リテラルの null-aware element（Dart 3.8+）」セクションを参照。

**Widget 最適化**:
- `use_colored_box`: `Container(color:)` を `ColoredBox` に置換
- `sized_box_for_whitespace`: 空白用には `SizedBox` を使用

**デバッグコード削除**:
- `avoid_print`: 本番コードで `print` 使用禁止 → `debugPrint` または `logger` を使用

---

## その他のルール

### カラー定義

- `ui/core/styles/app_color.dart` で定義し、`AppColor` クラス経由で使用する
- ハードコードされたカラー値は使用しない

```dart
// ✅ Good
import 'package:travel_app/ui/core/styles/app_color.dart';
Container(color: AppColor.primary)

// ❌ Bad
Container(color: Color(0xFF2196F3))
Container(color: Colors.blue)
```

### PR サイズ

- **PR は 400 行未満**
- 大きな変更は複数の PR に分割する
- **ビルドの通る状態**にする

### テスト

- 修正時には必ずユニットテストを追加
- スタブ実装（Service のスタブ）を使用して差し替え
- スタブは `data/services/web_api/{endpoint_path}/stub_service_impl.dart` に配置

#### テストのグルーピング

```dart
group('クラス名またはメソッド名', () {
  group('正常系', () {
    test('具体的なテストケース', () {
      // Arrange / Act / Assert
    });
  });

  group('異常系', () {
    test('具体的なテストケース', () {
      // Arrange / Act / Assert
    });
  });
});
```

**グルーピングのルール**:
- **第1階層**: クラス名またはテスト対象のメソッド名
- **第2階層**: `正常系` と `異常系` でグルーピング
- **test**: 具体的なテストケースを日本語で記述

### コード生成

以下の変更後は必ず生成コマンドを実行する:
- `@freezed` アノテーション付きクラス
- `@JsonSerializable` アノテーション付きクラス

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
