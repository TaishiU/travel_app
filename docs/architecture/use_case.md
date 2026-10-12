# UseCase 設計

## 1. 種別

UseCase は配置層によって2種類に分類される。

| 種別 | 配置 | 役割 |
|---|---|---|
| **画面ユースケース** | `lib/presentation/{feature}/use_case.dart` | 特定の画面の関心事に属すロジックの集約 |
| **ドメインユースケース** | `lib/domain/use_cases/` | 特定の画面に属さないドメイン概念の集約 |

本ドキュメントは**画面ユースケース**を対象とする。ドメインユースケースは `architecture_responsibilities.md` を参照。

---

## 2. 責務

- 画面固有の業務ロジックの実行（フォームバリデーション・複数ステップ処理等）
- Repository Interface 経由でのデータ取得・加工
- Notifier の `build()` から呼ばれる初期状態の構築（`initState()`）

---

## 3. 禁止事項

- state の更新（state の変更は Notifier が担う）
- Repository 実装クラス（`*_repository_impl.dart`）への直接依存
- プレゼンテーション層・データ層への依存

---

## 4. YAGNI 適用

画面固有の複雑なロジックが生じた場合にのみ作成する。

Notifier の `build()` が Repository 呼び出し1件と単純な変換のみであっても、**Notifier から Repository への直接アクセスは禁止**のため `use_case.dart` は必要。

> Notifier の禁止事項: データ層（Repository 実装・Service）への直接アクセス

---

## 5. メソッド命名規則

### 初期化メソッド

画面の初期状態を構築するメソッドは `initState()` とする。

```dart
Future<XxxScreenState> initState() async { ... }
```

### データ取得メソッド（initState の子関数）

`initState()` から呼ばれるデータ取得メソッドは public とし、`fetch` プレフィックスを付ける。

```dart
Future<User> fetchUser() async { ... }
Future<List<Post>> fetchPosts() async { ... }
```

**public にする理由:** 独立した振る舞いであり、単体テスト可能にすることで `initState()` のテストボリュームを抑えられる。各メソッドは自身の失敗ケースを単体でテストし、`initState()` は組み立て（全成功時の State 検証）のみテストする。

*public / private の判断基準は「10. テスト設計」セクションの「public にすべき判断基準」を参照。

### 操作メソッド

画面からのユーザー操作に応じたメソッドは、操作内容を表す動詞で命名する。

```dart
Future<void> submit() async { ... }
Future<Result<void>> toggleItem(int id) async { ... }
```

### State 構築メソッド（`_buildState`）

`XxxScreenState` のプロパティが多い場合、State 構築処理を `_buildState()` に切り出す。

**切り出す目安: プロパティが 10 個を超えた場合**

`initState()` にはfetch呼び出しが3〜5行ある。プロパティが10個を超えると合計 ~15行となり、一画面でオーケストレーション構造（何を取得しているか）を把握しにくくなる。プロパティの列挙が `initState()` の主役になった時点で切り出す。厳密な絶対値ではなく、「fetch行 + State構築行の合計が ~15行を超えたら」を実用的な判断基準とする。

```dart
// ❌ プロパティ 15 個: State 構築が initState() を支配する
Future<XxxScreenState> initState() async {
  final user = await fetchUser();
  final profile = await fetchProfile();
  return XxxScreenState(
    displayName: '${user.firstName} ${user.lastName}',
    age: user.age,
    // ... 13 行続く
  );
}

// ✅ _buildState() に切り出す: initState() がオーケストレーションに専念できる
Future<XxxScreenState> initState() async {
  final user = await fetchUser();
  final profile = await fetchProfile();
  return _buildState(user: user, profile: profile);
}

XxxScreenState _buildState({
  required User user,
  required Profile profile,
}) {
  return XxxScreenState(
    displayName: '${user.firstName} ${user.lastName}',
    age: user.age,
    // ... 残りのプロパティ
  );
}
```

**`_buildState()` が private な理由:**

- 純粋変換（I/O なし・失敗なし）→ 単独で呼ぶ意味がない
- `initState()` の文脈でしか意味を持たない実装詳細
- 単独でテストしても「自作自演」になる（プロパティの mapping をコードと同じくトレースするだけ）
- `initState()` のテスト（最終 State 検証）で暗黙的にカバーされる

*詳細は「10. テスト設計」セクションの「public にすべき判断基準」を参照。

---

## 6. Provider 宣言

### `Provider<T>`（非 autoDispose）を使用する

```dart
final xxxScreenUseCaseProvider = Provider<XxxScreenUseCase>(
  (ref) => XxxScreenUseCase(ref: ref),
);
```

**`autoDispose` を付けない理由:**

1. **`ref.read` との相性**
   Notifier の `build()` は `ref.read(useCaseProvider)` で UseCase を取得する。`ref.read` はリスナーを追加しないため、`autoDispose` の UseCase は取得直後に破棄対象となる可能性がある。
   非同期処理（`await`）中に UseCase の `ref` が dispose されると、内部の `ref.read(repositoryProvider)` が例外を投げる恐れがある。

2. **UseCase に状態なし**
   UseCase は `Ref` を保持するだけでステートレス。破棄によるメモリ解放のメリットがない。

3. **コードベースとの一貫性**
   `authUseCaseProvider` など既存のすべての UseCase Provider が `Provider<T>`（非 autoDispose）を採用している。

---

## 7. 実装形式

UseCase はクラスとして定義し、`Ref` をコンストラクタで受け取る。

```dart
final profileScreenUseCaseProvider = Provider<ProfileScreenUseCase>(
  (ref) => ProfileScreenUseCase(ref: ref),
);

class ProfileScreenUseCase {
  ProfileScreenUseCase({required this.ref});

  final Ref ref;

  /// 画面の初期状態を構築する。子関数の返り値を組み立てるだけ。
  Future<ProfileScreenState> initState() async {
    final user = await fetchUser();
    return ProfileScreenState(
      user: user,
    );
  }

  /// ユーザー情報を取得する。失敗時は throw。
  Future<User> fetchUser() async {
    final result = await ref.read(userRepositoryProvider).fetch();
    return switch (result) {
      SuccessResult(:final value) => value,
      FailureResult(:final error) => () {
        logger.e('[ProfileScreenUseCase] fetchUser error: $error');
        throw error;
      }(),
    };
  }
}
```

---

## 8. Notifier との連携

Notifier の `build()` は UseCase の `initState()` を呼び出すのみとする。

```dart
// ✅ Good: Notifier は UseCase に委譲するだけ
@override
Future<ProfileScreenState> build() async {
  return ref.read(profileScreenUseCaseProvider).initState();
}

// ❌ Bad: Notifier がデータ層に直接アクセス
@override
Future<ProfileScreenState> build() async {
  final result = await ref.read(userRepositoryProvider).fetch();
  return switch (result) { ... };
}
```

---

## 9. エラーハンドリング

UseCase は例外を throw する。Notifier はそれを catch せず Riverpod の `AsyncError` に変換する。

```
UseCase:   例外 throw（業務エラーを型付き例外で表現）
Notifier:  例外を catch しない → build() の Future が失敗 → AsyncError に変換
View:      AsyncError をハンドリングして CoreError Widget を表示
```

詳細は `error_handling.md` を参照。

---

## 10. テスト設計

### テストの責務分担

| メソッド | テストの責務 |
|---|---|
| `fetchUser()` などの子関数 | 正常系（Entity を返す）・異常系（throw する）を単体テスト |
| `initState()` | 全子関数成功時に正しい State が組み立てられることを確認 |

`initState()` は「組み立て」のテストに絞る。各子関数の失敗ケースは子関数のテストが担う。

### public にすべき判断基準

判断の問い：**「この関数は単体で呼ばれることに意味があるか？」**

| | `fetchUser()` | `_toDisplayName()` / `_buildState()` |
|---|---|---|
| 外部 I/O | あり（Repository 経由） | なし（純粋変換） |
| 失敗可能性 | あり（throw） | なし |
| 単体で呼ぶ意味 | ある | ない（親の文脈でのみ意味を持つ） |
| 単体テストの価値 | 高い（失敗ケースを独立検証） | 低い（親テストで十分・自作自演になりやすい） |
| 性質 | **独立した契約** | **親の実装詳細** |

`_toDisplayName` や `_buildState` を単独でテストしようとすると「自作自演」になりやすい。

```dart
// 自作自演の例: テストがコードをそのままトレースするだけ
expect(_toDisplayName('太郎', '山田'), equals('太郎 山田')); // 検証になっていない
```

`initState()` のテスト（最終 State の検証）を通じて暗黙的にカバーされるため、個別テストは不要。

```dart
// ✅ public: 外部 I/O を含む独立した振る舞い
Future<User> fetchUser() async { ... }
Future<List<Post>> fetchPosts() async { ... }

// ✅ private: 外部に依存しない純粋な加工処理（親の実装詳細）
String _toDisplayName(String first, String last) => '$first $last';
XxxScreenState _buildState({required User user, ...}) { ... }
```

> **`@visibleForTesting` について**
> `package:meta` の `@visibleForTesting` は「設計として private が正しいが、テスト都合で仕方なく public にする場合」に使うアノテーション。
> `package:meta` は Flutter SDK に同梱されており、pubspec.yaml に追加しなくても使える。
> 上記の判断基準で public が正当と判断できる場合は、設計意図の誤表現になるため付けない。

### private にした場合のテストコスト

子関数が private の場合、`initState()` 経由でしかテストできない。子関数が10個あると：

```
// private の場合
initState テスト:
  - 正常系（全成功）× 1
  - fetchUser 失敗 × 1  ← 残り9つのfakeセットアップも必要
  - fetchPosts 失敗 × 1  ← 同上
  ...
  合計 11 テスト、各テストで全依存のセットアップが必要

// public の場合
initState テスト:
  - 正常系（組み立て検証）× 1  のみ

fetchUser テスト:
  - 正常系 × 1
  - 異常系 × 1

fetchPosts テスト:
  - 正常系 × 1
  - 異常系 × 1
  ...
  各テストのセットアップは最小限（1依存のみ）
```

private にした場合のテストは「どの子関数の何が壊れたか」の局所性が失われる。テストスイートが肥大するにつれ、変更への心理的コストが上がる。

### `initState()` テストの書き方

```dart
group('initState', () {
  group('正常系', () {
    test('全データ取得成功時にProfileScreenStateを返す', () async {
      // Given: 全スタブが正常値を返すよう設定
      // When: useCase.initState()
      // Then: 返り値の State が期待通りのフィールドを持つ
    });
  });
});

group('fetchUser', () {
  group('正常系', () {
    test('Userを返す', () async {
      // Given: StubRepository が User を返す
      // When: useCase.fetchUser()
      // Then: 期待した User が返る
    });
  });
  group('異常系', () {
    test('FailureResult のとき例外を throw する', () async {
      // Given: StubRepository が FailureResult を返す
      // When / Then: fetchUser() が例外を throw する
    });
  });
});
```

---

## 11. ファイル構成

```
presentation/{feature}/
├── screen.dart
├── notifier.dart
├── use_case.dart   ← 本ドキュメントの対象
└── state.dart
```
