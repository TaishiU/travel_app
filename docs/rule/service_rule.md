# Service 実装規約

## ディレクトリ構造

```
lib/data/services/
├── local_storage/   # SecureStorage / SharedPreferences / DB
└── web_api/         # HTTP REST API
    ├── api_client.dart
    ├── api_exception.dart
    └── {endpoint_path}/
        ├── service.dart           # Interface
        ├── service_impl.dart      # 実装
        ├── stub_service_impl.dart # スタブ実装（任意）
        ├── dto.dart               # DTO 定義
        ├── dto.freezed.dart       # 生成コード
        └── dto.g.dart             # 生成コード
```

## エンドポイント種別に応じたグルーピング

API エンドポイントは **アクション型** と **リソース型** の2種類に分類し、ディレクトリ粒度を使い分ける。

| 種別 | 定義 | ディレクトリ粒度 |
|---|---|---|
| **アクション型** | パスがすべて固定文字列（例: `auth/login`） | **1操作 = 1ディレクトリ** |
| **リソース型** | パスパラメータを含む（例: `todos/{id}`） | **1リソース = 1ディレクトリ** |

### アクション型の例

エンドポイント `POST /auth/login` → `web_api/auth/login/`

```
web_api/auth/login/
├── service.dart
├── service_impl.dart
└── dto.dart
```

```dart
static const endpoint = 'auth/login';  // フルパスを定義
```

将来 `POST /auth/refresh` が追加された場合は `web_api/auth/refresh/` として独立させる。

### リソース型の例

エンドポイント `GET /todos`、`GET /todos/{id}` → どちらも `web_api/todos/` に集約

```
web_api/todos/
├── service.dart           # fetchList(), fetchById(id) を持つ
├── service_impl.dart
├── stub_service_impl.dart
└── dto.dart
```

```dart
static const endpoint = 'todos';  // リソース名を定義
```

`todos/{id}/comments` のようなサブリソースが生えた場合は `web_api/todos/comments/` として切り出す。

### 判断基準

> パスの末尾が **パスパラメータ（`{id}`）** なら リソース型 → リソース単位でまとめる
> パスの末尾が **固定文字列** なら アクション型 → 1操作で1ディレクトリ

## ファイル命名

| ファイル | 役割 |
|---|---|
| `service.dart` | Interface（abstract class） |
| `service_impl.dart` | 実装クラス・Provider 定義 |
| `stub_service_impl.dart` | スタブ実装（バックエンド未完成時） |
| `dto.dart` | DTO 定義（`@freezed`） |

## リソース型ディレクトリ名は plural

REST リソース名（エンドポイント文字列）に合わせ複数形を使用する。

```
✅ web_api/users/   （endpoint = 'users'）
❌ web_api/user/
```

## Map リテラルの null-aware element（Dart 3.8+）

クエリパラメータ・リクエストボディなど、nullable な値を条件付きで Map に追加する場合は `'key': ?value` 構文（null-aware element）を使用する。
`use_null_aware_elements` lint（project-wide）により `if (x != null) 'key': x` は違反となる。

```dart
// ✅ Good: null-aware element（use_null_aware_elements 準拠）
final queryParameters = <String, dynamic>{
  'q': ?q,
  'category_id': ?categoryId,
};

final body = <String, dynamic>{
  'name': name,           // required: ?不要
  'description': ?description,  // optional: ?を付ける
};

// ❌ Bad: if-null ガード（use_null_aware_elements 違反）
final queryParameters = <String, dynamic>{
  if (q != null) 'q': q,
  if (categoryId != null) 'category_id': categoryId,
};
```

## Firebase サービスの追加

FCM・Firebase Analytics など Firebase SDK 経由のサービスは `firebase/` ディレクトリに追加する。

### ディレクトリ構造

```
lib/data/services/
├── local_storage/
├── web_api/
└── firebase/
    ├── fcm/
    │   ├── service.dart           # Interface
    │   ├── service_impl.dart      # FCM SDK 実装
    │   └── stub_service_impl.dart # スタブ実装
    └── analytics/
        ├── service.dart           # Interface
        └── service_impl.dart      # Firebase Analytics SDK 実装
```

### `firebase/` にまとめる理由

**1. `local_storage/` と対称**

`local_storage/` が `secure_storage/`・`preferences/`・`database/` を1カテゴリにまとめるのと同じ発想。Firebase も複数サービスを1カテゴリに収める。

**2. Firebase 依存を明示**

FCM も Analytics も `google-services.json`・Firebase 初期化を共有する。実装上の結合が強いため1ディレクトリにまとめるのが自然。

**3. 将来拡張に対応**

Crashlytics・Remote Config が追加されても `firebase/` 配下に追加するだけ。ディレクトリ設計を変える必要がない。

**4. Interface + Impl で実装を隠蔽**

`firebase/fcm/service.dart`（Interface）を設けることで、テスト時はスタブ実装に差し替え可能。FCM SDK の詳細が上位層に漏れない。

### 各サービスの注意点

**FCM**

- トークン取得・更新・フォアグラウンド通知処理をすべて `fcm/` に集約
- スタブが重要：バックエンド未完成でも通知フローのテストが可能

**Analytics**

- fire-and-forget（レスポンスなし）のため DTO 不要
- スタブは no-op 実装で十分（テスト時にイベントが飛ばないようにする目的）

```dart
// firebase/analytics/service.dart
abstract class AnalyticsService {
  Future<void> logEvent({required String name, Map<String, Object>? parameters});
  Future<void> setUserId(String userId);
}
```

### カテゴリ命名の対比

| ディレクトリ | 命名の軸 | 例 |
|---|---|---|
| `local_storage/` | 通信先（端末ストレージ） | SharedPreferences, SecureStorage |
| `web_api/` | 通信先（HTTP REST サーバー） | DummyJSON API |
| `firebase/` | 通信先（Firebase SDK・インフラ） | FCM, Analytics, Crashlytics |

`web_api/` が「通信プロトコル（HTTP）」で名前をつけているのと同様、`firebase/` は「SDK/インフラ名」でつける一貫した命名。
