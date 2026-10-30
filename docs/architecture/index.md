---
type: index
title: アーキテクチャドキュメント一覧
description: docs/architecture/配下の全ドキュメント一覧。アーキテクチャ・レイヤー構成・エラーハンドリング・ライブラリ等を網羅する
tags: [index, アーキテクチャ, クリーンアーキテクチャ]
related: [architecture.md, layers/index.md]
---

# アーキテクチャドキュメント一覧

`docs/architecture/` 配下の全ドキュメントの受付ファイル。

## 概要・全体設計

| ドキュメント | 内容 |
|---|---|
| [architecture.md](architecture.md) | 3層クリーンアーキテクチャ全体構成・依存関係・レイヤー構成テーブル |
| [structure.md](structure.md) | `lib/` 配下のディレクトリ構成 |
| [libraries.md](libraries.md) | 使用ライブラリ一覧（状態管理・ナビゲーション・HTTP等） |

## 型・エラー

| ドキュメント | 内容 |
|---|---|
| [result.md](result.md) | `Result<T>` 型の定義・使い方 |
| [error_handling.md](error_handling.md) | `ApiClientException` → `AppError` 変換・`AsyncNotifier` パターン |

## レイヤー詳細（既存）

| ドキュメント | 内容 |
|---|---|
| [view.md](view.md) | `CustomScrollView` ・Screen/_Content・Section・Component 構成設計 |
| [use_case.md](use_case.md) | UseCase（画面）の設計・メソッド命名規則・テスト設計 |

## レイヤー仕様（OKF荷札付き）

各レイヤーの役割・責務・禁止事項・実装パスを記載した仕様ファイル群。
`layers/index.md` を起点に参照する。

| ドキュメント | 内容 |
|---|---|
| [layers/index.md](layers/index.md) | レイヤー仕様ファイル一覧（Serviceサブタイプ判定表含む） |
| [layers/view.md](layers/view.md) | View レイヤー仕様 |
| [layers/state.md](layers/state.md) | State レイヤー仕様 |
| [layers/notifier.md](layers/notifier.md) | Notifier レイヤー仕様 |
| [layers/usecase_presentation.md](layers/usecase_presentation.md) | UseCase（画面）レイヤー仕様 |
| [layers/interface.md](layers/interface.md) | Interface レイヤー仕様 |
| [layers/entity.md](layers/entity.md) | Entity レイヤー仕様 |
| [layers/usecase_domain.md](layers/usecase_domain.md) | UseCase（ドメイン）レイヤー仕様 |
| [layers/repository.md](layers/repository.md) | Repository レイヤー仕様 |
| [layers/service_web_api.md](layers/service_web_api.md) | Service（Web API）レイヤー仕様 |
| [layers/service_local_storage.md](layers/service_local_storage.md) | Service（LocalStorage）レイヤー仕様 |
| [layers/service_third_party.md](layers/service_third_party.md) | Service（サードパーティー）レイヤー仕様 |

## 既存実装カタログ

新規feature開発時に再利用可能な既存実装の一覧。Repository / Service が絡む場合は必ず参照する。

| ドキュメント | 内容 |
|---|---|
| [layers/implementations_data.md](layers/implementations_data.md) | データ層（Repository・Service）既存実装一覧 |
| [layers/implementations_domain.md](layers/implementations_domain.md) | ドメイン層（UseCase・Entity・Interface）既存実装一覧 |
| [layers/implementations_presentation.md](layers/implementations_presentation.md) | プレゼンテーション層（View・Notifier・UseCase）既存実装一覧 |
