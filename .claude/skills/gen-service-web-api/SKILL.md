---
name: gen-service-web-api
description: openapi.yaml から lib/data/services/web_api/ 配下のファイル（dto.dart / service.dart / stub_service_impl.dart / service_impl.dart）を自動生成する
argument-hint: "<feature-path> [--file=<yaml-path>]"
---

# gen-service-web-api

`docs/api/openapi.yaml` を読み込み、指定した feature の Service 層ファイルを生成するスキル。

生成対象: `dto.dart` → build_runner → `service.dart` → `stub_service_impl.dart` → `service_impl.dart`


---

## 重要: 既存ファイルは参照しない

`lib/data/services/web_api/` 配下の既存サービスファイル（`todos/`, `users/`, `auth/` 等）および `api_client.dart` は**読みにいかない**。
このSKILL.mdに記載されたテンプレート・シグネチャをそのまま使用する。

### ApiClient のメソッドシグネチャ（`api_client.dart` を読まずに以下を使用）

```dart
// GET
Future<Map<String, dynamic>> get({
  required String endpoint,
  Map<String, String>? headers,
  Map<String, dynamic>? queryParameters,
});

// POST
Future<Map<String, dynamic>> post({
  required String endpoint,
  required Map<String, dynamic> body,
  Map<String, String>? headers,
});

// PUT
Future<Map<String, dynamic>> put({
  required String endpoint,
  required Map<String, dynamic> body,
  Map<String, String>? headers,
});

// PATCH
Future<Map<String, dynamic>> patch({
  required String endpoint,
  required Map<String, dynamic> body,
  Map<String, String>? headers,
});

// DELETE
Future<Map<String, dynamic>> delete({
  required String endpoint,
});
```

---

## 引数パース

`$ARGUMENTS` から以下を抽出する（確認不要、そのまま解釈する）:

| 呼び出し例 | feature-path | yaml-path |
|---|---|---|
| `/gen-service-web-api todos` | `todos` | `docs/api/openapi.yaml` |
| `/gen-service-web-api auth/login` | `auth/login` | `docs/api/openapi.yaml` |
| `/gen-service-web-api --file=docs/api/openapi.yaml products` | `products` | `docs/api/openapi.yaml` |

- `--file=<path>` が含まれる場合はそのパスを使用。ない場合は `docs/api/openapi.yaml`
- 残りの文字列が feature-path

---

## Step 1: openapi.yaml 読み込み

指定パスの openapi.yaml を読み込む。

`components/schemas` 配下の `$ref` は後続ステップで参照する際にインラインで解決する。
（例: `$ref: '#/components/schemas/User'` → `components/schemas/User` の定義を参照）

---

## Step 2: 対象パスの特定

feature-path に対応する openapi.yaml の `paths` エントリをすべて収集する。

**マッチ方式:**

openapi path が `/{feature-path}` または `/{feature-path}/...` で始まるものをすべて収集する。

| feature-path | マッチする openapi paths |
|---|---|
| `products` | `/products`, `/products/{productId}` |
| `auth/login` | `/auth/login` |
| `cart` | `/cart`, `/cart/items`, `/cart/items/{itemId}` |
| `me` | `/me` |
| `me/products` | `/me/products` |
| `me/favorites` | `/me/favorites` |

### 生成モード

引数の形式によって動作が変わる。

| モード | 引数の形式 | 例 | 既存ファイルの扱い |
|---|---|---|---|
| **全体再生成** | feature の最上位セグメントのみ | `auth` | 全ファイルを上書き（確認なし） |
| **差分追加** | 具体的なパスを1つ以上指定 | `auth/login auth/register` | 既存ファイルを Read して追記・マージ |

差分追加モードでは既存ファイルを Read して現在の定義（DTO・メソッド）を把握し、不足分のみ追記する。「**重要: 既存ファイルは参照しない**」ルールは ApiClient シグネチャのテンプレート参照を禁じるものであり、差分追加時のファイル内容読み取りには適用しない。

---

## Step 3: アクション型 / リソース型 判定

収集したパス群のいずれかに**パスパラメータ（`{xxx}`）** が含まれるかどうかで判定する。

| 判定 | 条件 | 例 |
|---|---|---|
| リソース型 | パスパラメータを含むパスが1つ以上ある | `/products/{productId}` を含む |
| アクション型 | すべてのパスが固定文字列のみ | `/auth/login` のみ |

この判定は **Step 8 のエンドポイント値決定にのみ使用する**。stub_service_impl.dart の生成可否には影響しない（→ Step 7）。

**出力先ディレクトリ:**

```
lib/data/services/web_api/{feature-path}/
```

例:
- `products` → `lib/data/services/web_api/products/`
- `auth/login` → `lib/data/services/web_api/auth/login/`
- `cart` → `lib/data/services/web_api/cart/`

---

## Step 4: dto.dart 生成

### 対象スキーマの収集

対象パスの **成功レスポンス**（ステータスコード 200, 201）のスキーマのみを DTO に含める。
リクエストボディのスキーマは DTO に含めない（service.dart のメソッド引数として扱う）。

### DTO クラスの命名

| ケース | 命名規則 | 例 |
|---|---|---|
| `$ref` 参照（`$ref: '#/components/schemas/XxxYyy'`） | スキーマ名を優先: `XxxYyyDto` | `TokenResponseDto`, `UserDto` |
| リソース名から派生（inline object） | `{PascalCase}Dto` | `ProductSummaryDto`, `ProductDetailDto` |
| アクション名から派生（inline object） | `{PascalCase}Dto` | `RefreshTokenDto` |
| ネストされたオブジェクト | 親クラスの意味を継承した PascalCase | `ProductImageDto` |

複数エンドポイントが同じ `$ref` を参照する場合（例: `/auth/register` と `/auth/login` がともに `TokenResponse` を返す）、DTO クラスは1つだけ定義する（重複定義しない）。

レスポンスが複数スキーマに分かれる場合（一覧用と詳細用など）、同一 `dto.dart` に全クラスを定義する。

### 型マッピング（OpenAPI → Dart）

| OpenAPI `type` | `format` | Dart 型 |
|---|---|---|
| `integer` | — | `int?` |
| `number` | `float` / `double` | `double?` |
| `string` | — | `String?` |
| `string` | `date-time` / `email` / `uri` | `String?` |
| `boolean` | — | `bool?` |
| `object` | — | 新規 DTO クラス（同一ファイルに定義） |
| `array` | items: object | `List<XxxDto>?` |
| `array` | items: primitive | `List<型>?` |

**全フィールドを nullable にする**（`required` フィールドも nullable にする）。

### snake_case → lowerCamelCase 変換

openapi.yaml のフィールド名が `snake_case` の場合は `lowerCamelCase` に変換し、
元のキー名が異なる場合は `@JsonKey(name: 'original_key')` を付与する。

```yaml
# openapi.yaml
seller_id:
  type: integer
```

```dart
// dto.dart
/// 出品者ID
@JsonKey(name: 'seller_id') int? sellerId,
```

### ファイルテンプレート

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dto.freezed.dart';
part 'dto.g.dart';

/// XxxDto（クラスが表すリソースの日本語説明）
@freezed
abstract class XxxDto with _$XxxDto {
  /// コンストラクタ
  const factory XxxDto({
    /// ID
    int? id,

    /// （各フィールドに対応する日本語コメント）
    String? fieldName,
  }) = _XxxDto;

  /// JSONから生成
  factory XxxDto.fromJson(Map<String, dynamic> json) =>
      _$XxxDtoFromJson(json);
}

/// ネストDTOがある場合は同一ファイルに定義
/// XxxNestedDto
@freezed
abstract class XxxNestedDto with _$XxxNestedDto {
  /// コンストラクタ
  const factory XxxNestedDto({
    /// ID
    int? id,
  }) = _XxxNestedDto;

  /// JSONから生成
  factory XxxNestedDto.fromJson(Map<String, dynamic> json) =>
      _$XxxNestedDtoFromJson(json);
}
```

---

## Step 5: build_runner 実行

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

dto.dart 生成後に必ず実行する。エラーが出た場合は dto.dart を修正して再実行する。

---

## Step 6: service.dart 生成

### メソッド名の決定

| HTTP メソッド | パスの種類 | メソッド名 |
|---|---|---|
| `GET` | コレクション（パスパラメータなし） | `fetch()` |
| `GET` | 単一リソース（パスパラメータあり） | `fetchById({required int id})` |
| `POST` | コレクション（リソース作成） | `create({...})` |
| `POST` | アクション（固定パス） | パス末尾のキーワード（`login`, `register` 等） |
| `PUT` | 単一リソース（完全置換） | `update({...})` |
| `PATCH` | 単一リソース（部分更新） | `update({...})` |
| `DELETE` | 単一リソース | `delete({required int id})` |

### 戻り値の型

| レスポンスのステータスコード | Dart 戻り値型 |
|---|---|
| 200, 201（レスポンスボディあり） | `Future<Result<XxxDto>>` |
| 204（No Content） | `Future<Result<void>>` |

### メソッド引数の決定

| openapi の場所 | Dart の扱い |
|---|---|
| path パラメータ（`in: path`） | `required` 名前付き引数 |
| query パラメータ（`in: query`） | nullable 名前付き引数（省略可） |
| requestBody の `required` フィールド | `required` 名前付き引数 |
| requestBody の optional フィールド | nullable 名前付き引数（省略可） |

**名前付き引数を必ず使用する**（1引数でも例外なし）。

### ファイルテンプレート

```dart
import 'package:travel_app/data/services/web_api/{feature}/dto.dart';
import 'package:travel_app/utils/result.dart';

/// インターフェース
abstract class XxxApiService {
  /// [XxxDto] 一覧を取得
  Future<Result<XxxDto>> fetch();

  /// [XxxDto] を取得
  Future<Result<XxxDto>> fetchById({
    required int id,
  });

  /// [XxxDto] を作成
  Future<Result<XxxDto>> create({
    required String name,
    String? description,
  });

  /// [XxxDto] を更新
  Future<Result<XxxDto>> update({
    required int id,
    String? name,
  });

  /// [XxxDto] を削除
  Future<Result<void>> delete({
    required int id,
  });
}
```

実際に対象パスに存在する operations のみ定義する（不要なメソッドは含めない）。

---

## Step 7: stub_service_impl.dart 生成

ダミーデータはフィールド名・型から推測して生成する。
openapi.yaml に `example` 値があればそれを使用する。

### ダミーデータの指針

| Dart 型 | ダミー値の例 |
|---|---|
| `int?` | `1` |
| `String?` | フィールド名を利用（例: `name` → `'test name'`, `email` → `'test@example.com'`）|
| `String?`（`url` / `image` 系フィールド） | `'https://placehold.jp/400x400.png?text={リソース名}-{index}'`（例: `'https://placehold.jp/400x400.png?text=product-1'`）|
| `bool?` | `false` |
| `double?` | `0.0` |
| `List<XxxDto>?` | `List.generate` で 2〜3件生成 |
| `Future<Result<void>>` | `SuccessResult(null)` を返す（ダミーデータ不要） |

> `https://example.com/image.jpg` は実際にアクセスするとエラーになるため使用しない。
> `https://placehold.jp/400x400.png?text=xxx` はプレースホルダ画像として実際に表示される。`text` にリソース名＋インデックスを入れることで一意に区別できる。

### ダミー値の共通化

同じダミー値が複数のメソッドに登場する場合は、クラス内の `static const` フィールドに抽出して使い回す。

**抽出基準**: 同一の文字列・数値リテラルが2箇所以上に現れる場合は必ず抽出する。

**命名規則**: `_` prefix の lowerCamelCase（例: `_accessToken`, `_userId`, `_displayName`）。

```dart
class StubXxxApiServiceImpl implements XxxApiService {
  StubXxxApiServiceImpl();

  // 複数メソッドで共通するダミー値を static const に集約
  static const _userId = '1';
  static const _displayName = 'test user';
  static const _accessToken = 'test-access-token';
  static const _refreshToken = 'test-refresh-token';

  @override
  Future<Result<TokenResponseDto>> login({...}) async {
    return SuccessResult(
      TokenResponseDto(
        accessToken: _accessToken,   // ← ハードコーディング禁止
        refreshToken: _refreshToken,
        user: UserDto(id: _userId, displayName: _displayName),
      ),
    );
  }
}
```

`static const` フィールドはコンパイル時定数のため、全フィールドがそれで構成される DTO は `const` コンストラクタ呼び出しが可能（`const SuccessResult(XxxDto(...))`）。ランタイム値（メソッド引数など）が混在する場合は `const` 不可。

### ファイルテンプレート

```dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/web_api/{feature}/dto.dart';
import 'package:travel_app/data/services/web_api/{feature}/service.dart';
import 'package:travel_app/utils/result.dart';

/// プロバイダ
final stubXxxApiServiceImplProvider = Provider<StubXxxApiServiceImpl>(
  (ref) => StubXxxApiServiceImpl(),
);

/// スタブ実装クラス
class StubXxxApiServiceImpl implements XxxApiService {
  /// コンストラクタ
  StubXxxApiServiceImpl();

  // 複数メソッドで使い回すダミー値を static const に集約
  static const _userId = 1;
  static const _name = 'test name';

  @override
  Future<Result<XxxDto>> fetch() async {
    final items = List.generate(2, (index) {
      return XxxDto(
        id: index + 1,
        name: '$_name ${index + 1}',
      );
    });
    return SuccessResult(XxxDto(data: items));
  }
}
```

---

## Step 8: service_impl.dart 生成

### endpoint の値

| 型 | `static const` の定義方法 | 例 |
|---|---|---|
| リソース型 | 1つ: `static const endpoint = 'products'` | `endpoint`, `'$endpoint/$id'` |
| アクション型（メソッド1つ） | 1つ: `static const endpoint = 'auth/login'` | `endpoint` |
| アクション型（メソッド複数） | メソッドごとに private 定数を定義 | `static const _loginEndpoint = 'auth/login'` |

アクション型（複数）の命名規則: `_${メソッド名}Endpoint`（例: `_loginEndpoint`, `_registerEndpoint`）。

### パスパラメータの埋め込み

```dart
// GET /products/{productId}
final response = await apiClient.get(endpoint: '$endpoint/$productId');

// DELETE /products/{productId}
await apiClient.delete(endpoint: '$endpoint/$productId');
```

### null-aware element 構文（`use_null_aware_elements` 準拠）

Dart 3.8 以降、Map リテラルで nullable な値を条件付きで追加する場合は `'key': ?value` 構文を使用する。

```dart
// ✅ Good: null-aware element（use_null_aware_elements 準拠）
final queryParameters = <String, dynamic>{
  'q': ?q,
  'category_id': ?categoryId,
  'min_price': ?minPrice,
};

// ❌ Bad: if-null ガード（use_null_aware_elements 違反）
final queryParameters = <String, dynamic>{
  if (q != null) 'q': q,
  if (categoryId != null) 'category_id': categoryId,
  if (minPrice != null) 'min_price': minPrice,
};
```

`'key': ?value` は value が null のとき自動的にエントリを生成しないため、
`queryParameters` と POST/PUT の `body` 両方に適用する。

required フィールドは常に存在するため `?` 不要:

```dart
final body = <String, dynamic>{
  'name': name,           // required: ?不要
  'price': price,         // required: ?不要
  'description': ?description,  // optional: ?を付ける
  'status': ?status,            // optional: ?を付ける
};
```

### ファイルテンプレート

```dart
import 'package:travel_app/data/services/web_api/api_client.dart';
import 'package:travel_app/data/services/web_api/api_exception.dart';
import 'package:travel_app/data/services/web_api/{feature}/dto.dart';
import 'package:travel_app/data/services/web_api/{feature}/service.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// プロバイダ
final xxxApiServiceImplProvider = Provider<XxxApiServiceImpl>(
  (ref) => XxxApiServiceImpl(apiClient: ref.read(apiClientProvider)),
);

/// APIサービス実装クラス
class XxxApiServiceImpl implements XxxApiService {
  /// コンストラクタ
  XxxApiServiceImpl({required this.apiClient});

  /// ApiClient
  final ApiClient apiClient;

  /// エンドポイント
  static const endpoint = 'xxx';

  @override
  Future<Result<XxxDto>> fetch({
    String? optionalParam,
  }) async {
    try {
      // query パラメータがある場合は null-aware element 構文で構築
      final queryParameters = <String, dynamic>{
        'optional_param': ?optionalParam,
      };
      final response = await apiClient.get(
        endpoint: endpoint,
        queryParameters: queryParameters,
      );
      final dto = XxxDto.fromJson(response);
      return SuccessResult(dto);
    } on ApiClientException catch (error) {
      logger.e('[XxxApiServiceImpl] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e('[XxxApiServiceImpl] Unexpected Error: $error');
      return FailureResult(error);
    }
  }

  @override
  Future<Result<XxxDto>> fetchById({required int id}) async {
    try {
      final response = await apiClient.get(endpoint: '$endpoint/$id');
      final dto = XxxDto.fromJson(response);
      return SuccessResult(dto);
    } on ApiClientException catch (error) {
      logger.e('[XxxApiServiceImpl] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e('[XxxApiServiceImpl] Unexpected Error: $error');
      return FailureResult(error);
    }
  }

  @override
  Future<Result<void>> delete({required int id}) async {
    try {
      await apiClient.delete(endpoint: '$endpoint/$id');
      return const SuccessResult(null);
    } on ApiClientException catch (error) {
      logger.e('[XxxApiServiceImpl] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e('[XxxApiServiceImpl] Unexpected Error: $error');
      return FailureResult(error);
    }
  }
}
```

---

## Step 9: 静的解析

```bash
flutter analyze
```

エラーがある場合は修正してから完了とする。

---

## 注意事項

### 既存ファイルの扱い

**全体再生成モード**（引数が最上位セグメントのみ）: 既存ファイルは確認なしで上書きする。

**差分追加モード**（具体的なパスを指定）: 既存ファイルを Read して現在の定義を把握し、不足する DTO・メソッドのみ追記する。既存の定義は変更しない。

### import 順序（docs/rule/coding_rule.md 準拠）

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. 外部パッケージ
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 4. 内部パッケージ（package:travel_app/...）
import 'package:travel_app/data/services/web_api/...';
import 'package:travel_app/utils/result.dart';
```

### 名前付き引数（docs/rule/coding_rule.md 準拠）

全メソッドの引数は名前付き引数を使用する（1引数でも例外なし）。

### enum フィールドの扱い

openapi.yaml の `enum` 値は `String?` として扱う（Dart enum は定義しない）。

```yaml
status:
  type: string
  enum: [draft, published, archived]
```

```dart
/// ステータス
String? status,
```
