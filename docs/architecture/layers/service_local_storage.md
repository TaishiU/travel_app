---
type: レイヤー仕様
title: Service（LocalStorage）
description: SecureStorage / SharedPreferencesの抽象化を担うService層。認証トークン等の機密データはflutter_secure_storageを使用する
layer: データ層
path: lib/data/services/local_storage/
tags: [Service, データ層, LocalStorage, SecureStorage, SharedPreferences]
related: [repository.md, service_web_api.md, service_third_party.md]
---

# Service（LocalStorage）

**役割**: SecureStorage / SharedPreferences の抽象化

**責務**:
- ローカルストレージ操作の抽象化
- 認証トークン等の機密データの保管（`flutter_secure_storage` 使用）
- 設定値等の永続化（`shared_preferences` 使用）

**禁止事項**:
- ビジネスロジックの保持
- `AppError` への変換（変換は Repository が担う）

**ファイル命名規則**:
- `*.dart` = interface / abstract class
- `*_impl.dart` = concrete class

**重要なポイント**:
- 認証トークン等の機密データは必ず `flutter_secure_storage` を使用する（`SharedPreferences` は暗号化されないため使用禁止）
- 実I/O（ストレージ操作）をクラス内で直接実行している → IF を設ける
