---
type: レイヤー仕様
title: Repository
description: データアクセスの境界。DTO→Entity変換・ApiClientException→AppError変換・SSOT管理を担うデータ層
layer: データ層
path: lib/data/repositories/
tags: [Repository, データ層, DTO, Entity, SSOT, AppError]
related: [interface.md, entity.md, service_web_api.md, service_local_storage.md, service_third_party.md]
---

# Repository

**役割**: データアクセスの境界・DTO/Entity 変換・エラー変換

**責務**

必須:
- ドメイン層の `Interface` を実装
- DTO → Entity 変換
- `ApiClientException`（インフラ概念）→ `AppError`（ドメイン概念）への変換
- 複数 DataSource（API・LocalStorage）の調整

任意（ユースケース次第）:
- メモリキャッシュ（重複リクエスト抑制）
- Stream 通知 + SSOT 管理（複数画面でデータを同期する必要がある場合）

**禁止事項**:
- プレゼンテーション層への依存
- ビジネスロジックの保持（フィルタリング・ソート・バリデーション）

**ファイル命名規則**:
- `*_impl.dart` = concrete class（IF有無に関わらず）

**重要なポイント**:
- `ApiClientException` → `AppError` への変換はこの層が唯一の場所
- 変換ロジックは private ヘルパーで隠蔽
- パターン選択・SSOT 採用基準の詳細は `docs/rule/repository_rule.md` を参照

**Repository の分割基準（Service 層との役割分担）**:

| 層 | 分割の軸 | 理由 |
|---|---|---|
| **Repository 層** | Entity の所有権（ドメインの都合） | UseCase が扱うドメイン概念を中心に据え、URL 構造を隠蔽する |
| **Service 層** | URL 構造（API の都合） | エンドポイントと 1:1 で対応し、HTTP 通信を忠実に抽象化する |
