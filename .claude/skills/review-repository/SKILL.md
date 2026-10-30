---
name: review-repository
description: gen-repository で生成した lib/domain/entities/ / lib/domain/interfaces/ / lib/data/repositories/ 配下のファイルをレビューする
argument-hint: "<domain> [--pattern=A|B|C|D]"
---

# review-repository

`gen-repository` で生成したファイルをテンプレートと規約のみと照合し、規約違反・実装漏れ・誤りを報告するスキル。

対象ファイル: `entity.dart` / `*_repository.dart`（Interface） / `*_repository_impl.dart`（Impl） / `registry.md`

---

## 引数パース

`$ARGUMENTS` から以下を抽出する:

| 呼び出し例 | domain | pattern |
|---|---|---|
| `/review-repository area` | `area` | A |
| `/review-repository auth --pattern=D` | `auth` | D |

- `--pattern=<X>` が含まれる場合はそのパターンを使用。ない場合は A
- 残りの文字列が domain

---

## 重要: 読み込みルール

既存の実装ファイルの「意図・経緯」を参照しない。
このSKILL.mdに定義したテンプレートと規約のみを根拠に採点する。

---

## Step 1: ファイル読み込み

以下を並列で読み込む:

1. `lib/data/services/web_api/{domain}/service.dart`（複数ある場合は全件）
2. `lib/domain/entities/{domain}/` 配下の `.dart`（生成ファイル除く）
3. `lib/domain/interfaces/{domain}/{name}_repository.dart`
4. `lib/data/repositories/{domain}/{name}_repository_impl.dart`
5. `lib/data/repositories/registry.md`

---

## Step 2: チェックリスト実行

各ファイルを以下のチェックリストで検査する。

### 重要度の定義

- **[P1] CRITICAL** — 動作・規約に直結。必ず修正。
- **[P2] IMPORTANT** — 一貫性・保守性に影響。修正推奨。
- **[P3] SUGGESTION** — スタイル・可読性。任意対応。

---

### entity.dart チェックリスト

#### [P1] Freezed 構造

```dart
// ✅ 必須構造
@freezed
abstract class Xxx with _$Xxx {
  const factory Xxx({...}) = _Xxx;
  factory Xxx.fromJson(Map<String, Object?> json) => _$XxxFromJson(json);
}
```

チェック項目:
- `@freezed` アノテーション
- `abstract class`
- `with _$Xxx`
- `= _Xxx`（プライベートクラス名）
- `fromJson` ファクトリ（`Map<String, Object?>` 型）

#### [P1] part ディレクティブ

```dart
part 'xxx.freezed.dart';
part 'xxx.g.dart';
```

両方が先頭に宣言されていること。

#### [P1] DTO → Entity の nullable → non-nullable 変換

DTO の nullable フィールド（`T?`）が Entity では `required T` になっていること。
Entity に nullable フィールド（`String?` 等）が残っている場合は P1。

```dart
// ❌ Bad
String? name,

// ✅ Good
required String name,
```

#### [P1] 必須フィールド（id 等）の null チェック

`_toEntity` 内で `id == null` チェックが行われ、null の場合は `null` を返していること。
呼び出し元で `FailureResult(UnknownError())` に変換していること。

#### [P2] ネスト Sub-entity は同一ファイルに定義

DTO にネストした `object` 型がある場合、その Sub-entity が同一ファイル内に定義されていること。

#### [P2] 各フィールドに日本語コメント

```dart
// ✅ Good
/// ユーザーID
required String id,
```

#### [P3] クラスに日本語コメント

---

### Interface（`*_repository.dart`）チェックリスト

#### [P1] Flutter / data 層への import がない

import は `domain/entities/` と `utils/result.dart` のみ許容。

```dart
// ❌ Bad
import 'package:flutter/foundation.dart';
import 'package:travel_app/data/repositories/...';
```

※ Pattern D の Interface は `ChangeNotifier` を import しない（Impl 側のみ）。

#### [P1] service.dart のメソッドのみ定義（余分なメソッドなし）

`service.dart` に存在しない operation に対応するメソッドが定義されていれば P1。

#### [P1] 戻り値型

| service.dart の戻り値 | Interface の戻り値 |
|---|---|
| `Future<Result<XxxDto>>` | `Future<Result<Xxx>>` |
| `Future<Result<void>>` | `Future<Result<void>>` |

Pattern B の場合は以下が含まれていること:

```dart
Stream<List<Xxx>> get xxxStream;
List<Xxx> get latestXxx;
Future<Result<void>> fetch({bool force = false});
```

#### [P1] 名前付き引数（1引数でも例外なし）

```dart
// ✅ Good
Future<Result<Xxx>> fetchById({required String id});

// ❌ Bad（位置引数）
Future<Result<Xxx>> fetchById(String id);
```

#### [P2] メソッドに日本語コメント

---

### `*_repository_impl.dart` チェックリスト

#### [P1] `on Exception catch`（型なし catch 禁止）

```dart
// ✅ Good
on Exception catch (error) {
  return FailureResult(AppError.from(error));
}

// ❌ Bad
catch (e) { ... }
```

#### [P1] `AppError.from` によるエラー変換

`FailureResult` を返す際は `AppError.from(result.error)` を経由していること。
生の例外をそのまま `FailureResult` に渡していれば P1。

#### [P1] `!` の使用箇所制限

`_toEntity` 内で null チェック済みの必須フィールド（`if (dto.id == null) return null;` の後の `dto.id!` 等）のみ許容。
それ以外の場所で `!` を使用していれば P1。

#### [P1] Provider の型が Interface

```dart
// ✅ Good
final xxxRepositoryProvider = Provider<XxxRepository>(...)

// ❌ Bad
final xxxRepositoryProvider = Provider<XxxRepositoryImpl>(...)
```

※ Pattern D のみ Provider 2本構成（Interface 用 + GoRouter 用 Impl 用）が正解。

#### [P1] Pattern B: `StreamController` + `List.unmodifiable`

Pattern B が指定された場合:
- `StreamController<List<Xxx>>.broadcast()` を使用していること
- Stream への `add` 時に `List.unmodifiable(...)` で流していること
- `fetch` の戻り値が `Future<Result<void>>` であること

#### [P1] Pattern D: Interface に `ChangeNotifier` がない

Pattern D が指定された場合、Interface ファイルに `ChangeNotifier` 継承がないこと。
`ChangeNotifier` 継承は Impl 側のみ。

#### [P1] 名前付き引数（1引数でも例外なし）

#### [P2] `logger.e` のフォーマット

```dart
// ✅ Good
logger.e('[XxxRepositoryImpl] $error');

// ❌ Bad（クラス名の表記ミス）
logger.e('[XxxReposirotyImpl] $error');
```

#### [P2] `required` 引数が optional より前

#### [P2] import 順序（`coding_rule.md` 準拠）

```dart
// 外部パッケージ
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 内部パッケージ（アルファベット順）
import 'package:travel_app/data/repositories/{domain}/{name}_repository.dart';
import 'package:travel_app/data/services/web_api/{domain}/...';
import 'package:travel_app/domain/entities/{domain}/...';
import 'package:travel_app/domain/errors/app_error.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';
```

#### [P3] コンストラクタ引数に `required`

```dart
// ✅ Good
XxxRepositoryImpl({required this.xxxApiService});
```

---

### `registry.md` チェックリスト

#### [P1] 今回生成した全メソッドが登録されている

`service.dart` のメソッド数と `registry.md` の対応行数が一致していること。
漏れているメソッドがあれば行単位で指摘。

#### [P1] 重複行がない

同一 Repository + Method の組み合わせが 2 行以上存在すれば P1。

#### [P2] Source Service・Source Endpoint が正しく記録されている

`service.dart` の実装と照合して不一致があれば P2。

---

## Step 3: レポート出力

### 出力形式

```
## review-repository: {domain}（pattern {X}）

Review result: Approve  ← P1=0 かつ P2=0 の場合
Review result: Reject   ← P1≥1 または P2≥1 の場合

### [P1] CRITICAL
- {ファイル名}:{行番号} — {問題の説明}
  修正例: {修正後のコード（1行）}

### [P2] IMPORTANT
- {ファイル名}:{行番号} — {問題の説明}

### [P3] SUGGESTION
- {ファイル名}:{行番号} — {問題の説明}

### 総評
P1 X 件 CRITICAL、P2 Y 件 IMPORTANT、P3 Z 件 SUGGESTION
```

### Approve / Reject 判定基準

| 結果 | 条件 |
|---|---|
| **Approve** | P1=0 かつ P2=0（P3 のみ、または全 PASS） |
| **Reject** | P1≥1 または P2≥1 |

P3 SUGGESTION は Approve / Reject に影響しない。

### レポートのルール

- 問題がないチェック項目は出力しない（合格項目は省略）
- 行番号は読み込んだファイルの実際の行番号を使用
- 修正例はコードブロックでなく1行インラインで示す
- 指摘事項が何もない場合は `Review result: Approve` と `指摘事項なし。LGTM` のみ出力

---

## 注意事項

- 生成ファイル（`.freezed.dart`、`.g.dart`）はレビュー対象外
- Pattern が引数で指定されていない場合は A を仮定する
- Pattern B/C/D 固有のチェック項目は、該当パターンが指定された場合のみ適用する
