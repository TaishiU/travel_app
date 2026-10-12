---
name: review-service-web-api
description: gen-service-web-api で生成した lib/data/services/web_api/ 配下のファイルをレビューする
argument-hint: "<feature-path> [--file=<yaml-path>]"
---

# review-service-web-api

`gen-service-web-api` で生成したファイルを openapi.yaml と照合し、規約違反・実装漏れ・誤りを報告するスキル。

対象ファイル: `dto.dart` / `service.dart` / `stub_service_impl.dart`（リソース型のみ）/ `service_impl.dart`

---

## 引数パース

`$ARGUMENTS` から以下を抽出する:

| 呼び出し例 | feature-path | yaml-path |
|---|---|---|
| `/review-service-web-api products` | `products` | `docs/api/openapi.yaml` |
| `/review-service-web-api auth/login` | `auth/login` | `docs/api/openapi.yaml` |
| `/review-service-web-api --file=docs/api/openapi.yaml products` | `products` | `docs/api/openapi.yaml` |

- `--file=<path>` が含まれる場合はそのパスを使用。ない場合は `docs/api/openapi.yaml`
- 残りの文字列が feature-path

---

## Step 1: ファイル読み込み

以下を並列で読み込む:

1. `docs/api/openapi.yaml`（指定パス）
2. `lib/data/services/web_api/{feature-path}/dto.dart`
3. `lib/data/services/web_api/{feature-path}/service.dart`
4. `lib/data/services/web_api/{feature-path}/service_impl.dart`
5. `lib/data/services/web_api/{feature-path}/stub_service_impl.dart`（存在する場合のみ）

---

## Step 2: openapi.yaml から期待値を導出

feature-path に対応するパスエントリを収集し、以下を確定する:

- **リソース型 / アクション型**の判定（パスパラメータの有無）
- **対象 operations**（HTTP メソッド × パス）
- **レスポンス DTO**（200/201 のスキーマ）
- **requestBody フィールド**（required / optional）
- **query パラメータ**（required / optional）
- **path パラメータ**

---

## Step 3: チェックリスト実行

各ファイルを以下のチェックリストで検査する。

### 重要度の定義

- **[P1] CRITICAL** — 動作・規約に直結。必ず修正。
- **[P2] IMPORTANT** — 一貫性・保守性に影響。修正推奨。
- **[P3] SUGGESTION** — スタイル・可読性。任意対応。

---

### dto.dart チェックリスト

#### [P1] 全フィールドが nullable

openapi.yaml の `required` 属性に関わらず、DTO の全フィールドは `Type?` にする。

```dart
// ✅ Good
int? id,
String? name,

// ❌ Bad
int id,
String name,
```

#### [P1] snake_case フィールドの @JsonKey

openapi.yaml のフィールド名が snake_case の場合、`@JsonKey(name: 'original_key')` を付与し Dart 側を lowerCamelCase にする。

```dart
// ✅ Good
@JsonKey(name: 'seller_id') int? sellerId,

// ❌ Bad（@JsonKey なし）
int? seller_id,
// ❌ Bad（Dart 側が snake_case）
@JsonKey(name: 'seller_id') int? seller_id,
```

#### [P1] @freezed / fromJson の構造

```dart
// ✅ 必須構造
@freezed
abstract class XxxDto with _$XxxDto {
  const factory XxxDto({...}) = _XxxDto;
  factory XxxDto.fromJson(Map<String, dynamic> json) => _$XxxDtoFromJson(json);
}
```

チェック項目:
- `@freezed` アノテーション
- `abstract class`
- `with _$XxxDto`
- `= _XxxDto`（プライベートクラス名）
- `fromJson` ファクトリ

#### [P1] part ディレクティブ

```dart
part 'dto.freezed.dart';
part 'dto.g.dart';
```

両方が先頭に宣言されていること。

#### [P2] openapi.yaml との網羅性

200/201 レスポンスのスキーマに定義された全フィールドが DTO に含まれていること。
不要なフィールドが追加されていないこと。

#### [P2] ネスト DTO の配置

`object` 型フィールドに対応するネスト DTO が同一ファイルに定義されていること。

#### [P2] 各フィールドに日本語コメント

```dart
// ✅ Good
/// 商品ID
int? id,

// ❌ Bad（コメントなし）
int? id,
```

#### [P2] import 順序

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
// 他パッケージは不要（dto.dart は freezed_annotation のみ）
```

#### [P3] クラスコメント

`/// XxxDto（リソースの日本語説明）` 形式でクラスに日本語コメントがあること。

---

### service.dart チェックリスト

#### [P1] openapi.yaml との operation 対応

openapi.yaml に存在する operation のみメソッドを定義。余分なメソッドがないこと。

HTTP メソッド → Dart メソッド名の対応:

| HTTP | パス種別 | メソッド名 |
|---|---|---|
| GET | コレクション（パスパラメータなし） | `fetch` |
| GET | 単一リソース（パスパラメータあり） | `fetchById` |
| POST | コレクション（リソース作成） | `create` |
| POST | アクション | パス末尾キーワード（`login`, `register` 等） |
| PUT / PATCH | 単一リソース | `update` |
| DELETE | 単一リソース | `delete` |

#### [P1] 名前付き引数（1引数でも例外なし）

```dart
// ✅ Good
Future<Result<XxxDto>> fetchById({required int id});

// ❌ Bad（位置引数）
Future<Result<XxxDto>> fetchById(int id);
```

#### [P1] required 引数が optional より前

```dart
// ✅ Good
Future<Result<XxxDto>> create({
  required int categoryId,
  required String name,
  String? description,
});

// ❌ Bad
Future<Result<XxxDto>> create({
  String? description,
  required int categoryId,
});
```

#### [P1] 戻り値の型

| レスポンス | 戻り値型 |
|---|---|
| 200 / 201（ボディあり） | `Future<Result<XxxDto>>` |
| 204（No Content） | `Future<Result<void>>` |

#### [P2] 引数と openapi.yaml の対応

| openapi | Dart |
|---|---|
| path パラメータ | `required` 名前付き引数 |
| query パラメータ（required） | `required` 名前付き引数 |
| query パラメータ（optional） | nullable 名前付き引数 |
| requestBody required フィールド | `required` 名前付き引数 |
| requestBody optional フィールド | nullable 名前付き引数 |

#### [P2] import 順序

```dart
import 'package:travel_app/data/services/web_api/{feature}/dto.dart';
import 'package:travel_app/utils/result.dart';
```

`result.dart` のみ追加インポートが必要。

#### [P3] メソッドに日本語コメント

```dart
/// 商品一覧を取得
Future<Result<ProductsDto>> fetch({...});
```

---

### service_impl.dart チェックリスト

#### [P1] double catch（ApiClientException → Exception）

**最重要。** 全メソッドで必ずこの順番で2段階catch。

```dart
// ✅ Good
} on ApiClientException catch (error) {
  logger.e('[XxxApiServiceImpl] ApiClientException: $error');
  return FailureResult(error);
} on Exception catch (error) {
  logger.e('[XxxApiServiceImpl] Unexpected Error: $error');
  return FailureResult(error);
}

// ❌ Bad: 型なし catch（avoid_catches_without_on_clauses 違反）
} catch (e) {
  return FailureResult(Exception(e.toString()));
}

// ❌ Bad: ApiClientException を省略
} on Exception catch (error) {
  return FailureResult(error);
}
```

#### [P1] null-aware element 構文（use_null_aware_elements 準拠）

optional な値を Map に追加する場合は `'key': ?value` 構文を使用。
`if (x != null) 'key': x` は **lint 違反**。

```dart
// ✅ Good
final queryParameters = <String, dynamic>{
  'q': ?q,
  'category_id': ?categoryId,
};

final body = <String, dynamic>{
  'name': name,           // required: ?不要
  'description': ?description,  // optional: ?を付ける
};

// ❌ Bad
if (categoryId != null) queryParameters['category_id'] = categoryId;
if (description != null) body['description'] = description;
// ❌ Bad
final queryParameters = <String, dynamic>{
  if (q != null) 'q': q,
};
```

#### [P1] endpoint の値

| 型 | endpoint 値 | 例 |
|---|---|---|
| リソース型 | リソース名（feature-path 先頭セグメント） | `'products'`, `'cart'` |
| アクション型 | フルパス（先頭 `/` を除く） | `'auth/login'` |

```dart
static const endpoint = 'products'; // リソース型
static const endpoint = 'auth/login'; // アクション型
```

#### [P1] ApiClient メソッドと HTTP メソッドの対応

openapi.yaml の HTTP メソッドに対応する `apiClient` メソッドを使用していること。

| OpenAPI | ApiClient |
|---|---|
| GET | `apiClient.get` |
| POST | `apiClient.post` |
| PUT | `apiClient.put` |
| PATCH | `apiClient.patch` |
| DELETE | `apiClient.delete` |

#### [P1] パスパラメータの埋め込み

```dart
// ✅ Good
await apiClient.get(endpoint: '$endpoint/$id');
await apiClient.delete(endpoint: '$endpoint/$id');

// ❌ Bad
await apiClient.get(endpoint: 'products/$id');  // endpoint 定数を使わない
```

#### [P1] 強制アンラップ禁止

```dart
// ❌ Bad
final id = response['id']!;
```

`!` は絶対使用禁止。`??` や `?.` で対応。

#### [P1] Provider の定義

```dart
// ✅ Good
final xxxApiServiceImplProvider = Provider<XxxApiServiceImpl>(
  (ref) => XxxApiServiceImpl(apiClient: ref.read(apiClientProvider)),
);
```

- Provider の型パラメータが実装クラス（`XxxApiServiceImpl`）になっていること
- コンストラクタ引数に `apiClient: ref.read(apiClientProvider)` を渡していること

#### [P2] logger.e のフォーマット

```dart
// ✅ Good
logger.e('[ProductsApiServiceImpl] ApiClientException: $error');
logger.e('[ProductsApiServiceImpl] Unexpected Error: $error');

// ❌ Bad（クラス名が間違い）
logger.e('[ProductApiServiceImpl] ...');  // 's' 抜け等
```

クラス名がログのプレフィックスと一致していること。

#### [P2] delete の戻り値

```dart
// ✅ Good
return const SuccessResult(null);

// ❌ Bad（const 漏れ）
return SuccessResult(null);
```

#### [P2] implements の対象

```dart
class XxxApiServiceImpl implements XxxApiService { ... }
```

対応する Interface を implements していること。

#### [P2] import 順序

```dart
// 外部パッケージ
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 内部パッケージ（アルファベット順）
import 'package:travel_app/data/services/web_api/api_client.dart';
import 'package:travel_app/data/services/web_api/api_exception.dart';
import 'package:travel_app/data/services/web_api/{feature}/dto.dart';
import 'package:travel_app/data/services/web_api/{feature}/service.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';
```

#### [P3] コンストラクタに `required`

```dart
// ✅ Good
XxxApiServiceImpl({required this.apiClient});

// ❌ Bad
XxxApiServiceImpl(this.apiClient);
```

---

### stub_service_impl.dart チェックリスト

#### [P1] アクション型に stub_service_impl.dart が存在しないこと

アクション型（パスパラメータなし）のディレクトリに `stub_service_impl.dart` があれば指摘。

#### [P1] Interface のメソッドを全て @override

service.dart に定義された全メソッドが `@override` 付きで実装されていること。
漏れているメソッドがあれば指摘。

#### [P1] スタブも async メソッド

```dart
// ✅ Good
Future<Result<ProductsDto>> fetch({...}) async { ... }

// ❌ Bad
Future<Result<ProductsDto>> fetch({...}) { ... }
```

#### [P2] ダミーデータの品質

画像 URL に `https://example.com/...` を使っていないこと。使っている場合は `https://placehold.jp/400x400.png?text=xxx` に変更を推奨。

```dart
// ✅ Good
url: 'https://placehold.jp/400x400.png?text=product-$id',

// ❌ Bad
url: 'https://example.com/image.jpg',
```

#### [P2] Provider の定義（引数なし）

```dart
// ✅ Good
final stubXxxApiServiceImplProvider = Provider<StubXxxApiServiceImpl>(
  (ref) => StubXxxApiServiceImpl(),
);

// ❌ Bad（apiClient を渡している）
final stubXxxApiServiceImplProvider = Provider<StubXxxApiServiceImpl>(
  (ref) => StubXxxApiServiceImpl(apiClient: ref.read(apiClientProvider)),
);
```

#### [P2] SuccessResult の返し方

DTO の `id` に使える引数が**メソッドシグネチャに存在する**場合は、その引数を使う。
存在しない場合は固定値（`1` 等）で問題ない。

判定基準:
- `fetchById({required int id})` → `id` 引数が使えるので `ProductDetailDto(id: id, ...)` が必須
- `create({required String name, ...})` → `id` に直接マップできる引数がないので `id: 1` で可

```dart
// ✅ Good: id 引数あり → 引数を使う
Future<Result<ProductDetailDto>> fetchById({required int id}) async {
  return SuccessResult(ProductDetailDto(id: id, ...));
}

// ✅ Good: id に使える引数なし → 固定値で可
Future<Result<ProductDetailDto>> create({
  required String name,
  required int price,
  ...
}) async {
  return SuccessResult(ProductDetailDto(id: 1, ...));
}

// ❌ Bad: id 引数があるのに固定値
Future<Result<ProductDetailDto>> fetchById({required int id}) async {
  return SuccessResult(ProductDetailDto(id: 1, ...));  // id を使っていない
}
```

#### [P3] import 順序（stub_service_impl.dart）

```dart
// 外部パッケージ
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 内部パッケージ
import 'package:travel_app/data/services/web_api/{feature}/dto.dart';
import 'package:travel_app/data/services/web_api/{feature}/service.dart';
import 'package:travel_app/utils/result.dart';
```

---

## Step 4: レポート出力

### 出力形式

```
## review-service-web-api: {feature-path}

Review result: Approve  ← P1=0 かつ P2=0 の場合
Review result: Reject   ← P1≥1 または P2≥1 の場合

### [P1] CRITICAL
- {ファイル名}:{行番号} — {問題の説明}
  修正例: {修正後のコード（短く）}

### [P2] IMPORTANT
- {ファイル名}:{行番号} — {問題の説明}

### [P3] SUGGESTION
- {ファイル名}:{行番号} — {問題の説明}

### 総評
{P1件数} 件の CRITICAL、{P2件数} 件の IMPORTANT、{P3件数} 件の SUGGESTION
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

- 生成コード（`dto.freezed.dart`, `dto.g.dart`）はレビュー対象外
- openapi.yaml と実装の**差分**に集中する（openapi.yaml 自体の問題は指摘しない）
- `flutter analyze` の出力がある場合（`step analyze` 等）はその結果も参照してよい
