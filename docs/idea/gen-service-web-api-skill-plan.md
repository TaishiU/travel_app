# gen-service-web-api Skill 実装計画

作成日: 2026-10-06

---

## 目的

Service層（`lib/data/services/web_api/` 配下）の実装を自動化する Claude Code Skill を作成する。

> スキル名を `gen-service-web-api` とする理由:
> Service層には `local_storage/` と `web_api/` の2種類が存在する。
> 今回の対象は `web_api/` のみのため、将来的な `gen-service-local-storage` との区別のために明示的に命名する。

---

## Skill 基本情報

| 項目 | 内容 |
|---|---|
| スキル名 | `gen-service-web-api` |
| 格納パス | `.claude/skills/gen-service-web-api/SKILL.md` |
| 対象 | `lib/data/services/web_api/{feature}/` |
| インプット | `docs/api/openapi.yaml`（デフォルト）または `--file` 指定 |

### 呼び出し例

```
/gen-service-web-api todos
/gen-service-web-api auth/login
/gen-service-web-api --file=docs/api/openapi.yaml todos
```

---

## 必要なドキュメント

- `openapi.yaml`（RESTful API の I/O 定義）
  - デフォルト配置パス: `docs/api/openapi.yaml`
  - `--file=<path>` で上書き可能

---

## 実行フロー

```
1. openapi.yaml 読み込み
      ↓
2. 対象エンドポイント特定（$ARGUMENTS から feature 名を抽出）
      ↓
3. アクション型 / リソース型 判定
   ├─ パス末尾がパスパラメータ（{id} 等）→ リソース型（例: todos, users）
   └─ パスがすべて固定文字列          → アクション型（例: auth/login）
      ↓
4. 出力先ディレクトリ決定
   ├─ リソース型:  lib/data/services/web_api/{resource}/
   └─ アクション型: lib/data/services/web_api/{action}/{sub-action}/
      ↓
5. dto.dart 生成（全フィールド nullable + ネスト DTO も同一ファイルに）
      ↓
6. build_runner 実行
      flutter pub run build_runner build --delete-conflicting-outputs
      ↓
7. service.dart 生成（Abstract interface）
      ↓
8. stub_service_impl.dart 生成（リソース型のみ）
      ↓
9. service_impl.dart 生成
```

---

## アクション型 / リソース型 判定基準

`docs/rule/coding_rule.md` の「Service 実装規約」に準拠。

| 種別 | 定義 | ディレクトリ粒度 | 例 |
|---|---|---|---|
| **アクション型** | パスがすべて固定文字列 | 1操作 = 1ディレクトリ | `auth/login` → `web_api/auth/login/` |
| **リソース型** | パスパラメータを含む | 1リソース = 1ディレクトリ | `todos/{id}` → `web_api/todos/` |

> 判断基準: パスの末尾が `{id}` 等のパスパラメータ → リソース型。パスの末尾が固定文字列 → アクション型。

---

## 型マッピング（OpenAPI → Dart）

| OpenAPI `type` | `format` | Dart 型 |
|---|---|---|
| `integer` | — | `int?` |
| `number` | `float` / `double` | `double?` |
| `string` | — | `String?` |
| `boolean` | — | `bool?` |
| `object` | — | 新規 DTO クラス（同一ファイルに定義） |
| `array` | items: object | `List<XxxDto>?` |
| `array` | items: primitive | `List<型>?` |

全フィールドを nullable にする理由: API レスポンスの欠損・将来の変更に対して DTO を堅牢にする腐敗防止層としての役割を果たすため。

---

## 各生成ファイルの仕様

### dto.dart

- `@freezed` アノテーション
- `part 'dto.freezed.dart';` と `part 'dto.g.dart';` を宣言
- 全フィールド nullable
- ネストされたオブジェクトは同一ファイル内に別 DTO クラスとして定義
- `fromJson` ファクトリを持つ
- フィールドに日本語コメントを付与（フィールド名から推測）

```dart
// 例: todos/dto.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dto.freezed.dart';
part 'dto.g.dart';

/// TodosDto
@freezed
abstract class TodosDto with _$TodosDto {
  /// コンストラクタ
  const factory TodosDto({
    /// TODO一覧
    List<TodoDto>? todos,
  }) = _TodosDto;

  /// JSONから生成
  factory TodosDto.fromJson(Map<String, dynamic> json) =>
      _$TodosDtoFromJson(json);
}

/// TodoDto
@freezed
abstract class TodoDto with _$TodoDto {
  /// コンストラクタ
  const factory TodoDto({
    /// ID
    int? id,

    /// ユーザーID
    int? userId,

    /// タイトル
    @JsonKey(name: 'todo') String? todo,

    /// 完了したかどうか
    bool? completed,
  }) = _TodoDto;

  /// JSONから生成
  factory TodoDto.fromJson(Map<String, dynamic> json) =>
      _$TodoDtoFromJson(json);
}
```

### service.dart

- `abstract class` で Interface を定義
- メソッドは openapi.yaml の operations（GET/POST/PUT/DELETE）に対応
- 戻り値は `Future<Result<XxxDto>>`
- メソッド引数はパスパラメータ・クエリパラメータ・リクエストボディに対応
- **名前付き引数必須**（coding_rule.md 準拠）

```dart
// 例: todos/service.dart
import 'package:travel_app/data/services/web_api/todos/dto.dart';
import 'package:travel_app/utils/result.dart';

/// インターフェース
abstract class TodosApiService {
  /// [TodosDto] を取得
  Future<Result<TodosDto>> fetch();
}
```

### service_impl.dart

- `implements XxxApiService`
- `static const endpoint = '<リソース名 or フルパス>';`
  - リソース型: `'todos'`
  - アクション型: `'auth/login'`
- `Provider<XxxApiServiceImpl>` を定義
- `apiClient.get/post/put/delete` を使用
- エラーハンドリング:
  - `on ApiClientException catch (error)` → `logger.e` + `FailureResult`
  - `on Exception catch (error)` → `logger.e` + `FailureResult`
- ログラベル: `'[XxxApiServiceImpl]'`

```dart
// 例: todos/service_impl.dart
import 'package:travel_app/data/services/web_api/api_client.dart';
import 'package:travel_app/data/services/web_api/api_exception.dart';
import 'package:travel_app/data/services/web_api/todos/dto.dart';
import 'package:travel_app/data/services/web_api/todos/service.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// プロバイダ
final todosApiServiceImplProvider = Provider<TodosApiServiceImpl>(
  (ref) => TodosApiServiceImpl(apiClient: ref.read(apiClientProvider)),
);

/// APIサービス実装クラス
class TodosApiServiceImpl implements TodosApiService {
  /// コンストラクタ
  TodosApiServiceImpl({required this.apiClient});

  /// ApiClient
  final ApiClient apiClient;

  /// エンドポイント
  static const endpoint = 'todos';

  @override
  Future<Result<TodosDto>> fetch() async {
    try {
      final response = await apiClient.get(endpoint: endpoint);
      final todosDto = TodosDto.fromJson(response);
      return SuccessResult(todosDto);
    } on ApiClientException catch (error) {
      logger.e('[TodosApiServiceImpl] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e('[TodosApiServiceImpl] Unexpected Error: $error');
      return FailureResult(error);
    }
  }
}
```

### stub_service_impl.dart（リソース型のみ）

- アクション型（auth/login 等）には生成しない
- `implements XxxApiService`
- `Provider<StubXxxApiServiceImpl>` を定義
- レスポンスはハードコードのダミーデータ（openapi.yaml の example があれば使用、なければ型に合わせて生成）

---

## 規模に応じた処理方式

fix-named-args スキルと同じ方針。

| 対象エンドポイント数 | 処理方式 |
|---|---|
| **< 5** | 直列（メインスレッドで逐次生成） |
| **≥ 5** | 並列（サブエージェント 5エンドポイント/バッチで並列起動） |

初期実装は直列のみ。エンドポイントが増えた時点で並列化を追加する。

---

## openapi.yaml 管理の課題と解決案

### 現状の問題

- openapi.yaml はバックエンドチームが管理
- フロントチームは Slack 経由での共有がなければ更新を検知できない
- 手動での追従は漏れ・遅延が発生しやすい

### 提示されたアプローチ案

1. バックエンドの GitHub リポジトリで `openapi.yaml` を含む PR がマージされたら GitHub Actions を起動
2. GitHub Actions がフロントチームの Slack チャンネルに自動通知
3. フロントチームのメンバーが検知 → GitHub issue を手動作成（openapi.yaml 取得 + Service 層更新）
4. `/gen-service-web-api` スキルで Service 層を生成

### 代替案: クロスリポジトリ自動 PR（推奨）

Slack 通知 + 手動 issue 作成のステップを省略し、より自動化を進める案。

```
バックエンドリポジトリ
  main マージ時 GH Actions 起動
  → フロントリポジトリへ repository_dispatch イベント送信
        ↓
フロントリポジトリ
  dispatch 受信 → openapi.yaml を docs/api/ へ更新
  → 自動で PR 作成（ブランチ名例: chore/update-openapi-{date}）
        ↓
フロントチームがPRをレビュー・マージ（破壊的変更の確認を人間が担保）
        ↓
/gen-service-web-api <feature> を実行
```

**提示案との比較:**

| 観点 | Slack + 手動 issue 案 | クロスリポジトリ自動 PR 案 |
|---|---|---|
| 自動化度 | 通知まで自動、以降は手動 | PR 作成まで自動 |
| 設定複雑度 | Slack Webhook + GH Actions | GH Actions + PAT（クロスリポジトリ権限） |
| 人間の判断 | issue 作成・対応タイミング | PRレビュー・マージのみ |
| 履歴管理 | issue 履歴 | PR 履歴（差分が明確） |
| バックエンドチームへの依存 | repository_dispatch 設定が必要 | 同左 |

**前提条件（クロスリポジトリ自動 PR 案）:**
- バックエンドリポジトリへの `repository_dispatch` 送信権限（PAT または GitHub App）
- バックエンドチームとの GH Actions 設定の合意

---

## 実装優先順位

| 優先度 | タスク | 備考 |
|---|---|---|
| ~~1~~ | ~~`docs/api/` ディレクトリ作成 + サンプル `openapi.yaml` 配置~~ | ✅ 完了 |
| 2 | `.claude/skills/gen-service-web-api/SKILL.md` 作成 | Skill 本体 |
| 3 | クロスリポジトリ同期の GH Actions | バックエンドチームとの調整後 |

---

## 参考ファイル

| ファイル | 役割 |
|---|---|
| `lib/data/services/web_api/todos/` | リソース型の実装例 |
| `lib/data/services/web_api/users/` | リソース型の実装例（ネスト DTO あり） |
| `lib/data/services/web_api/auth/login/` | アクション型の実装例 |
| `.claude/skills/fix-named-args/SKILL.md` | 既存 Skill のフォーマット参考 |
| `docs/rule/coding_rule.md` | Service 実装規約 |
