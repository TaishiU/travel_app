---
name: fix-named-args
description: lib/ 配下の .dart ファイルを対象に位置引数違反を検知し、名前付き引数へ修正する
argument-hint: "[changed|staged|branch|all] [--base=<branch>]"
---

# fix-named-args

`lib/` 配下の `.dart` ファイルを対象に位置引数違反を検知し、名前付き引数へ修正するスキル。
違反の検知ツールとして `scripts/check_named_args.dart` を実行する（修正対象はツール自体ではなく `lib/` 配下のアプリケーションコード）。

## 実行手順

### Step 1: 違反一覧を取得

`$ARGUMENTS` の有無でコマンドを決定する（確認不要）:

| 呼び出し例 | `$ARGUMENTS` | 実行コマンド |
|---|---|---|
| `/fix-named-args` | （空） | `dart scripts/check_named_args.dart` |
| `/fix-named-args staged` | `staged` | `dart scripts/check_named_args.dart --scope=staged` |
| `/fix-named-args branch` | `branch` | `dart scripts/check_named_args.dart --scope=branch` |
| `/fix-named-args all` | `all` | `dart scripts/check_named_args.dart --scope=all` |
| `/fix-named-args branch --base=develop` | `branch --base=develop` | `dart scripts/check_named_args.dart --scope=branch --base=develop` |

- `$ARGUMENTS` が空 → 引数なしで実行（スクリプトのデフォルト `changed` が適用される）
- `$ARGUMENTS` あり → `--scope=$ARGUMENTS` を付けて実行

違反がなければ終了。

---

### Step 2: 処理方式の判断

スクリプト出力の末尾に **ファイル数** が表示される:
```
❌ 名前付き引数違反 51件を検出（12ファイル）
```

この **ファイル数** で処理方式を決める（違反件数ではなくファイル数で判断する）。

> **なぜファイル数か**: コスト源は各ファイルの Read + Edit。1ファイルに違反が20件あっても
> トークンコストは1ファイル分だが、20ファイルに1件ずつあればコンテキストが20ファイル分膨らむ。

| 違反ファイル数 | 処理方式 |
|---|---|
| **< 5** | **直列**（メインスレッドで Step 3a へ） |
| **≥ 5** | **並列**（サブエージェントに委譲して Step 3b へ） |

バッチサイズ: **5ファイル / サブエージェント**
（例: 25ファイル → 5エージェント並列起動）

---

## 直列パス（ファイル数 < 5）

### Step 3a: 宣言側を修正

各違反ファイルを開き、位置引数を `{...}` で囲んで名前付き引数に変換する。

**`required` の付け方は引数の性質で判断する:**

| 引数の性質 | 修正後 |
|---|---|
| 非 null 型（`String`, `int`, `bool` 等） | `required String name` |
| null 許容・必須（null を明示的に渡させる意図） | `required String? name` |
| null 許容・省略可（省略 = null と同義、省略されることが多い） | `String? name` |

**判断の目安:**
- 引数名が `option`, `filter`, `query`, `callback` 等、オプション的な意味を持つ → `required` なし
- 引数が省略されると動作が変わる（全件取得 vs フィルタあり等）→ `required` なし
- 上記に当てはまらない nullable → `required String?` をデフォルトとする

```dart
// 修正前
Future<void> setAppTheme(String theme) async { ... }
Future<List<Todo>> fetchTodos(String? statusFilter, String? query) async { ... }

// 修正後
Future<void> setAppTheme({required String theme}) async { ... }
Future<List<Todo>> fetchTodos({String? statusFilter, String? query}) async { ... }
//                              ↑ 省略可なので required なし
```

### Step 4a: 呼び出し側修正

宣言を修正すると呼び出し側はコンパイルエラーになる。
`dart analyze` でエラー箇所を特定し、位置引数を名前付きに変換する。

```bash
dart analyze 2>&1 | grep "error"
```

```dart
// 修正前（コンパイルエラー）
setAppTheme('dark');
fetchTodos('completed', null);

// 修正後
setAppTheme(theme: 'dark');
fetchTodos(statusFilter: 'completed');
```

### Step 5a: 検証

```bash
# 名前付き引数チェック（Step 1 と同じスコープで再実行）
dart scripts/check_named_args.dart --scope=<changed|staged|branch|all>

# 静的解析
flutter analyze
```

両方がクリアになったら完了。

---

## 並列パス（ファイル数 ≥ 5）

### Step 3b-Phase1: 宣言修正をサブエージェントに並列委譲

**バッチ分割:**
違反ファイルリストを5ファイル単位に分割し、1バッチにつき1サブエージェントを起動する。

```
例: 23ファイル → Batch A(5), Batch B(5), Batch C(5), Batch D(5), Batch E(3)
→ 5エージェントを同一メッセージで並列起動
```

**サブエージェントへの委譲内容:**
- **宣言側の修正のみ**（呼び出し側は触らない）
  - 複数エージェントが同一ファイルを同時編集する衝突を防ぐため
- `@freezed` コンストラクタを修正した場合は `build_runner` を実行
- 終了後に担当ファイルと修正内容をサマリとして返す

**サブエージェント起動の呼び出し方（Agent ツール）:**

サブエージェントは毎回コールドスタートのため、プロンプトに必要情報をすべて含める。
以下をテンプレートとして、バッチ内の違反詳細を埋め込む:

```
あなたは Flutter/Dart プロジェクトの位置引数を名前付き引数に修正する作業を担当します。

プロジェクトパス: <working_directory>

## 担当ファイルと違反内容
<check_named_args の出力から該当バッチ分をそのまま貼り付ける>

## 修正ルール（宣言側のみ修正すること。呼び出し側は修正しない）

1. 各ファイルを開き、違反のある関数・メソッド・コンストラクタの引数を `{...}` で囲む
2. required の付け方:
   - 非 null 型 → required T name
   - null 許容・必須 → required T? name
   - null 許容・省略可（option/filter/query/callback 等） → T? name（required なし）
3. @freezed コンストラクタを修正した場合は以下を実行:
   dart run build_runner build --delete-conflicting-outputs
4. @override メソッドは修正不要（ただし interface / abstract 側の宣言は修正対象）

完了後、修正したファイル一覧と各ファイルの変更概要を返してください。
```

**並列起動の例（1メッセージで全バッチを同時送信）:**

```
Agent(Batch A: path/to/files...) + Agent(Batch B: ...) + Agent(Batch C: ...) を
1つのメッセージに含めて並列実行する
```

### Step 3b-Phase2: 呼び出し側修正

全サブエージェントの完了後、メインスレッドで呼び出し側エラーを修正する。

```bash
flutter analyze 2>&1 | grep "error"
```

呼び出し側修正でも **エラーが存在するファイル数 ≥ 5** の場合は、
同じバッチ分割・サブエージェント並列起動のパターンを適用する。
（各サブエージェントへのプロンプトには `flutter analyze` のエラー出力から該当ファイル分を渡す）

### Step 3b-Phase3: 検証

```bash
# 名前付き引数チェック（Step 1 と同じスコープで再実行）
dart scripts/check_named_args.dart --scope=<changed|staged|branch|all>

# 静的解析
flutter analyze
```

両方がクリアになったら完了。

---

## 注意事項

- `@override` メソッドは検知対象外。ただし interface / abstract 側の宣言は検知対象。
  interface を修正すると実装側もコンパイルエラーになるため、合わせて修正する。
- `@freezed` クラスのコンストラクタを修正した場合は `build_runner` を再実行する:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- 一度に大量修正すると PR が肥大化する。ファイル単位 or 機能単位で分割して修正・コミットする。
