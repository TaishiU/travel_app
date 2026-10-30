---
type: レイヤー仕様
title: Service（Web API）
description: HTTP通信の抽象化とDTOの返却を担うService層。ApiClientを通じてHTTP通信を行い、DTOを返す
layer: データ層
path: lib/data/services/web_api/{feature}/
tags: [Service, データ層, WebAPI, HTTP, DTO, ApiClient]
related: [repository.md, service_local_storage.md, service_third_party.md]
---

# Service（Web API）

**役割**: HTTP 通信の抽象化・DTO の返却

**責務**:
- HTTP 通信の抽象化
- DTO（Data Transfer Object）の返却
- API レスポンスの型定義・JSON 変換

**禁止事項**:
- ビジネスロジックの保持
- `AppError` への変換（変換は Repository が担う）

**ファイル命名規則**:
- `*.dart` = interface / abstract class
- `*_impl.dart` = concrete class
- `dto.dart` = DTO 定義

**重要なポイント**:
- DTO はこの層が所有（`lib/data/services/web_api/{feature}/dto.dart`）
- DTO の全フィールドは nullable（サーバー仕様の変動に対応）
- `ApiClient` は認証トークン付与・リトライ・401 リフレッシュを自動処理

**IF を設ける基準**:
- 実I/O（ネットワーク通信）をクラス内で直接実行している → IF を設ける
- 別の Service に委譲しているだけ → IF 不要（下位 Service の IF で十分）
