---
name: gen-repository
description: Service層のservice.dart / dto.dartを読み込み、lib/domain/entities/ / lib/domain/interfaces/ / lib/data/repositories/ 配下のファイルを自動生成し、registry.mdを更新する
argument-hint: "<domain-name> [--pattern=A|B|C|D]"
---

# gen-repository

Service層（`lib/data/services/web_api/`）の既存ファイルを読み込み、指定ドメインの Repository 層ファイルを生成するスキル。

**前提**: `gen-service-web-api` 実行済みで対象 domain の `service.dart` / `dto.dart` が存在すること。

生成対象:
1. `lib/domain/entities/{domain}/{entity_snake}.dart`（Freezed Entity）
2. `lib/domain/interfaces/{domain}/{name}_repository.dart`（Interface）
3. `lib/data/repositories/{domain}/{name}_repository_impl.dart`（Impl + Provider）

終端で `lib/data/repositories/registry.md` を更新する。

---

## 重要: 読み込みルール

既存の `lib/data/repositories/` 配下の実装ファイルは**参照しない**。
このSKILL.mdのテンプレートをそのまま使用する。

**必ず読み込むファイル:**
- `lib/data/services/web_api/{domain}/` 配下の `service.dart` と `dto.dart`（複数ある場合はすべて）
- `lib/data/repositories/registry.md`（存在する場合のみ）

---

## 引数パース

`$ARGUMENTS` から以下を抽出する（確認不要、そのまま解釈する）:

| 呼び出し例 | domain | pattern |
|---|---|---|
| `/gen-repository area` | `area` | A |
| `/gen-repository auth --pattern=D` | `auth` | D |
| `/gen-repository plan --pattern=A` | `plan` | A |

- パターン一覧: `/docs/rule/repository_rule.md`の「パターン一覧」セクションを参照。
- `--pattern=<X>` が含まれる場合はそのパターンを使用。ない場合は A
- 残りの文字列が domain-name

---

## Step 1: Service スキャン + ユーザー確認

### 1-1. サービスファイル探索

`lib/data/services/web_api/{domain}/` を調べ、`service.dart` をすべて収集する。

| ディレクトリ構造 | 収集ルール |
|---|---|
| フラット（`{domain}/service.dart`） | 1件収集 |
| サブディレクトリ型（`{domain}/{sub}/service.dart`） | 全サブディレクトリの `service.dart` を収集 |

```
# フラット例（areas/）
lib/data/services/web_api/areas/service.dart  → 1件

# サブディレクトリ例（auth/）
lib/data/services/web_api/auth/register/service.dart
lib/data/services/web_api/auth/login/service.dart
lib/data/services/web_api/auth/refresh/service.dart
lib/data/services/web_api/auth/logout/service.dart
lib/data/services/web_api/auth/me/service.dart  → 5件
```

### 1-2. registry.md クロスドメインチェック

`lib/data/repositories/registry.md` が存在する場合、**domain が異なる** Repository エントリのうち、Return Entity 列に今回の domain 名（単数形）を含む行を探す。

発見した場合: 「以下のメソッドは既に別 Repository に登録されています: {行の内容}」と通知する。

### 1-3. ユーザー確認

収集結果を提示し、追加・除外を確認する。

```
以下の Service を {Domain}Repository に含めます:

  [1] lib/data/services/web_api/{domain}/service.dart
      → {XxxApiService}（fetch, fetchById, ...）
  [2] lib/data/services/web_api/{domain}/{sub}/service.dart
      → {YyyApiService}（login, ...）

追加・除外がある場合は指示してください（例: activities/service.dart の fetchPlansByActivityId を追加）。
ない場合はそのまま続行します。
```

ユーザーが追加を指示した場合、その `service.dart` も読み込み対象に加える。

---

## Step 2: dto.dart 読み込み

収集した `service.dart` と同一ディレクトリの `dto.dart` をすべて読み込み、DTO クラス名・フィールド一覧を把握する。

---

## Step 3: クラス名・ファイルパスの導出

### domain → 単数形ドメイン名（Repository名の基）

| 変換パターン | 例 |
|---|---|
| 末尾 `ies` → `y` | `activities → Activity`、`categories → Category` |
| 末尾 `s` を除去 | `areas → Area`、`plans → Plan`、`todos → Todo` |
| 変化なし | `auth → Auth` |

| 対象 | 規則 | 例 |
|---|---|---|
| Repository名（Interface） | `{単数}Repository` | `AreaRepository` |
| RepositoryImpl名 | `{単数}RepositoryImpl` | `AreaRepositoryImpl` |
| Provider名 | `{lowerCamel(単数)}RepositoryProvider` | `areaRepositoryProvider` |
| Interface ファイル名 | `{snake(単数)}_repository.dart` | `area_repository.dart` |
| Impl ファイル名 | `{snake(単数)}_repository_impl.dart` | `area_repository_impl.dart` |

### Entity 名の導出

DTO クラス名から `Dto` サフィックスを除去する。

| DTO クラス名 | Entity 名 |
|---|---|
| `AreaDto` | `Area` |
| `ActivitySummaryDto` | `ActivitySummary` |
| `PlanWithMeetingPointsDto` | `PlanWithMeetingPoints` |

Service の各メソッドの戻り値 `Future<Result<XxxDto>>` → `Future<Result<Xxx>>` に対応づける。

---

## Step 4: Entity 生成

既存ファイルがある場合は**上書き前にユーザーに確認する**。

### DTO → Entity フィールド変換ルール

DTO の全フィールドは nullable（`T?`）→ Entity は原則 non-nullable（`required T`）に変換する。

| DTO 型 | Entity 型 | `_toEntity` での処理 |
|---|---|---|
| `String?` | `required String` | `dto.field ?? ''` |
| `int?` | `required int` | `dto.field ?? 0` |
| `double?` | `required double` | `dto.field ?? 0.0` |
| `bool?` | `required bool` | `dto.field ?? false` |
| `List<XxxDto>?` | `required List<Xxx>` | `(dto.field ?? []).map((item) => _toXxxEntity(item: item)).toList()` |
| ネスト `XxxDto?` | `required Xxx` | `_toXxxEntity(xxxDto: dto.xxx)` |

**必須フィールド（識別子）の扱い:**
`id` または `{name}Id` 形式のフィールドが null の場合、`_toEntity` は `null` を返す。呼び出し元（fetch メソッド）で `FailureResult(UnknownError())` に変換する。

### Entity ファイル配置ルール

- ファイルパス: `lib/domain/entities/{domain}/{snake(primaryEntity)}.dart`
- 同一ドメインの Sub-entity（`AreaChild`、`PlanSchedule` 等）は親と**同一ファイルに定義**する
- ドメインをまたぐ Entity 参照（例: `ActivityDetail` が `Plan` を内包）は cross-domain import を許容する

### Entity ファイルテンプレート

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '{entity_snake}.freezed.dart';
part '{entity_snake}.g.dart';

/// {Entity の日本語説明}
@freezed
abstract class {Entity} with _${Entity} {
  /// コンストラクタ
  const factory {Entity}({
    /// ID
    required String id,

    /// （各フィールドに対応する日本語コメント）
    required String fieldName,
  }) = _{Entity};

  /// JSONから生成
  factory {Entity}.fromJson(Map<String, Object?> json) =>
      _${Entity}FromJson(json);
}

/// Sub-entity がある場合は同一ファイルに続けて定義
@freezed
abstract class {SubEntity} with _${SubEntity} {
  /// コンストラクタ
  const factory {SubEntity}({
    required String id,
  }) = _{SubEntity};

  /// JSONから生成
  factory {SubEntity}.fromJson(Map<String, Object?> json) =>
      _${SubEntity}FromJson(json);
}
```

---

## Step 5: build_runner 実行

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Entity 生成後に必ず実行する。エラーがある場合は Entity を修正して再実行する。

---

## Step 6: Interface 生成

Flutter・Data層への依存を一切持たない。import は `domain/entities/` と `utils/result.dart` のみ。

### Interface ファイルテンプレート

```dart
import 'package:travel_app/domain/entities/{domain}/{entity_snake}.dart';
import 'package:travel_app/utils/result.dart';

/// インターフェース
abstract class {Domain}Repository {
  /// [{Entity}] 一覧を取得
  Future<Result<{Entity}>> fetch();

  /// [{Entity}] をIDで取得
  Future<Result<{Entity}>> fetchById({
    required String id,
  });
}
```

実際に Service に存在する operations のみ定義する（不要なメソッドは含めない）。

---

## Step 7: Impl 生成

### Impl ファイルテンプレート（単一 Service の場合）

```dart
import 'package:travel_app/data/repositories/{domain}/{name}_repository.dart';
import 'package:travel_app/data/services/web_api/{domain}/dto.dart';
import 'package:travel_app/data/services/web_api/{domain}/service.dart';
import 'package:travel_app/data/services/web_api/{domain}/service_impl.dart';
import 'package:travel_app/domain/entities/{domain}/{entity_snake}.dart';
import 'package:travel_app/domain/errors/app_error.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// プロバイダ
final {lowerCamel}RepositoryProvider = Provider<{Domain}Repository>(
  (ref) => {Domain}RepositoryImpl(
    {lowerCamel}ApiService: ref.read({lowerCamel}ApiServiceImplProvider),
  ),
);

/// リポジトリ実装クラス
class {Domain}RepositoryImpl implements {Domain}Repository {
  /// コンストラクタ
  {Domain}RepositoryImpl({required this.{lowerCamel}ApiService});

  /// {Domain}ApiService
  final {Domain}ApiService {lowerCamel}ApiService;

  @override
  Future<Result<{Entity}>> fetch() async {
    try {
      final result = await {lowerCamel}ApiService.fetch();
      switch (result) {
        case SuccessResult<{Entity}Dto>():
          final entity = _toEntity(dto: result.value);
          if (entity == null) return const FailureResult(UnknownError());
          return SuccessResult(entity);
        case FailureResult<{Entity}Dto>():
          logger.e('[{Domain}RepositoryImpl] \${result.error}');
          return FailureResult(AppError.from(result.error));
      }
    } on Exception catch (error) {
      return FailureResult(AppError.from(error));
    }
  }

  /// [{Entity}Dto] を [{Entity}] に変換
  {Entity}? _toEntity({required {Entity}Dto dto}) {
    if (dto.id == null) return null;

    return {Entity}(
      id: dto.id!,
      fieldName: dto.fieldName ?? '',
    );
  }
}
```

### 多対1構造（複数 Service をまとめる場合）

```dart
/// プロバイダ
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    authLoginApiService: ref.read(authLoginApiServiceImplProvider),
    authRegisterApiService: ref.read(authRegisterApiServiceImplProvider),
    authRefreshApiService: ref.read(authRefreshApiServiceImplProvider),
    authLogoutApiService: ref.read(authLogoutApiServiceImplProvider),
    authMeApiService: ref.read(authMeApiServiceImplProvider),
  ),
);

/// リポジトリ実装クラス
class AuthRepositoryImpl implements AuthRepository {
  /// コンストラクタ
  AuthRepositoryImpl({
    required this.authLoginApiService,
    required this.authRegisterApiService,
    required this.authRefreshApiService,
    required this.authLogoutApiService,
    required this.authMeApiService,
  });

  final AuthLoginApiService authLoginApiService;
  final AuthRegisterApiService authRegisterApiService;
  final AuthRefreshApiService authRefreshApiService;
  final AuthLogoutApiService authLogoutApiService;
  final AuthMeApiService authMeApiService;

  // 各メソッドは対応する Service を呼び出す
}
```

### `_toEntity` での `!` 使用について

`_toEntity` 内で null チェック済みの必須フィールド（`id` 等）に限り `!` を使用する。
null チェック後の強制アンラップは安全なため、このケースのみ例外的に許容する。
それ以外の場所での `!` 使用は禁止。

---

## Step 8: registry.md 更新

`lib/data/repositories/registry.md` を新規作成または更新する。

- ファイルが存在しない場合はヘッダーから作成する
- 今回生成した Repository のエントリを追記・上書きする（重複行は作らない）
- 既存の他 Repository のエントリは変更しない

### registry.md フォーマット

```markdown
# Repository Registry

> このファイルは `gen-repository` Skill が自動生成・更新する。手動編集不可。
> PR レビュー時に openapi.yaml・Service 層との整合チェックに使用する。

| Repository | Method | Return Entity | Source Service | Source Endpoint |
|---|---|---|---|---|
| AuthRepository | login | AuthToken | AuthLoginApiService | POST /auth/login |
| AuthRepository | register | AuthToken | AuthRegisterApiService | POST /auth/register |
| AuthRepository | refreshToken | AuthToken | AuthRefreshApiService | POST /auth/refresh |
| AuthRepository | logout | void | AuthLogoutApiService | POST /auth/logout |
| AuthRepository | me | User | AuthMeApiService | GET /auth/me |
| AreaRepository | fetch | Area | AreasApiService | GET /areas |
| CategoryRepository | fetch | Category | CategoriesApiService | GET /categories |
| ActivityRepository | fetch | ActivitySummary | ActivitiesApiService | GET /activities |
| ActivityRepository | fetchById | ActivityDetail | ActivitiesApiService | GET /activities/{activityId} |
| PlanRepository | fetchByActivityId | PlanWithMeetingPoints | ActivitiesApiService | GET /activities/{activityId}/plans |
| PlanRepository | fetchById | PlanDetail | PlansApiService | GET /plans/{planId} |
```

---

## Step 9: 静的解析

```bash
flutter analyze
```

エラーがある場合は修正してから完了とする。

---

## Pattern B: メモリキャッシュ + StreamController（差分）

Pattern A との差分のみ。

### Interface への追加

```dart
abstract class {Domain}Repository {
  Stream<List<{Entity}>> get {entities}Stream;
  List<{Entity}> get latest{Entities};
  Future<Result<void>> fetch({bool force = false});
}
```

### Impl への追加フィールド

```dart
List<{Entity}> _{entities} = [];
bool _isFetched = false;
final _{entities}StreamController = StreamController<List<{Entity}>>.broadcast();

Stream<List<{Entity}>> get {entities}Stream => _{entities}StreamController.stream;
List<{Entity}> get latest{Entities} => List.unmodifiable(_{entities});
```

fetch の戻り値は `Future<Result<void>>`。取得後に `_todosStreamController.add(List.unmodifiable(_{entities}))` で通知する。

### Provider への追加

```dart
final {entities}StreamProvider = StreamProvider<List<{Entity}>>((ref) {
  return ref.watch({domain}RepositoryProvider).{entities}Stream;
});
```

---

## Pattern D: ChangeNotifier（差分）

Pattern A との差分のみ。Auth 専用。

### Interface（Flutter 非依存を厳守）

```dart
// lib/domain/interfaces/auth/auth_repository.dart
// flutter/foundation.dart は import しない
import 'package:travel_app/domain/entities/auth/auth_token.dart';
import 'package:travel_app/domain/entities/auth/user.dart';
import 'package:travel_app/utils/result.dart';

abstract class AuthRepository {
  Future<bool> get isLoggedIn;
  Future<Result<AuthToken>> login({
    required String email,
    required String password,
  });
  Future<Result<AuthToken>> register({
    required String email,
    required String password,
    String? displayName,
  });
  Future<Result<AuthToken>> refreshToken({required String refreshToken});
  Future<void> logout({required String refreshToken});
  Future<Result<User>> me();
}
```

### Impl（ChangeNotifier 継承）

```dart
import 'package:flutter/foundation.dart';

class AuthRepositoryImpl extends ChangeNotifier implements AuthRepository {
  @override
  Future<Result<AuthToken>> login({...}) async {
    // ...
    _isLoggedIn = true;
    notifyListeners(); // GoRouter の redirect をトリガー
    return SuccessResult(authToken);
  }
}
```

### Provider 2本構成

```dart
// UseCase / Notifier 用（Interface 型）
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ref.read(authRepositoryImplProvider),
);

// GoRouter 用（Impl 型で ChangeNotifier として渡す）
final authRepositoryImplProvider = Provider<AuthRepositoryImpl>(
  (ref) => AuthRepositoryImpl(
    authLoginApiService: ref.read(authLoginApiServiceImplProvider),
    authRegisterApiService: ref.read(authRegisterApiServiceImplProvider),
    authRefreshApiService: ref.read(authRefreshApiServiceImplProvider),
    authLogoutApiService: ref.read(authLogoutApiServiceImplProvider),
    authMeApiService: ref.read(authMeApiServiceImplProvider),
    authSecureStorageService: ref.read(authSecureStorageServiceImplProvider),
  ),
);
```

GoRouter での使用:
```dart
refreshListenable: ref.read(authRepositoryImplProvider)
```

---

## 注意事項

### import 順序（docs/rule/coding_rule.md 準拠）

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter SDK
import 'package:flutter/foundation.dart';

// 3. 外部パッケージ
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 4. 内部パッケージ（package:travel_app/...）
import 'package:travel_app/data/repositories/...';
import 'package:travel_app/data/services/web_api/...';
import 'package:travel_app/domain/entities/...';
import 'package:travel_app/domain/errors/app_error.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';
```

### 名前付き引数（docs/rule/coding_rule.md 準拠）

全メソッドの引数は名前付き引数を使用する（1引数でも例外なし）。
