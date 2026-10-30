---
type: index
title: レイヤー仕様一覧
description: docs/architecture/layers/配下の全レイヤーファイル一覧。gen-impl-docがレイヤー判定・実装仕様生成時に参照する
tags: [index, レイヤー構成, クリーンアーキテクチャ]
related: [../index.md, ../architecture.md]
---

# レイヤー仕様一覧

各レイヤーの役割・責務・禁止事項・実装パスを記載した仕様ファイルの一覧。

## プレゼンテーション層

| レイヤー | ファイル | パス |
|---|---|---|
| View | [view.md](view.md) | `lib/presentation/{feature}/screen.dart` |
| State | [state.md](state.md) | `lib/presentation/{feature}/state.dart` |
| Notifier | [notifier.md](notifier.md) | `lib/presentation/{feature}/notifier.dart` |
| UseCase（画面） | [usecase_presentation.md](usecase_presentation.md) | `lib/presentation/{feature}/use_case.dart` |

## ドメイン層

| レイヤー | ファイル | パス |
|---|---|---|
| Interface | [interface.md](interface.md) | `lib/domain/interfaces/` |
| Entity | [entity.md](entity.md) | `lib/domain/entities/` |
| UseCase（ドメイン） | [usecase_domain.md](usecase_domain.md) | `lib/domain/use_cases/` |

## データ層

| レイヤー | ファイル | パス |
|---|---|---|
| Repository | [repository.md](repository.md) | `lib/data/repositories/` |
| Service（Web API） | [service_web_api.md](service_web_api.md) | `lib/data/services/web_api/{feature}/` |
| Service（LocalStorage） | [service_local_storage.md](service_local_storage.md) | `lib/data/services/local_storage/` |
| Service（サードパーティー） | [service_third_party.md](service_third_party.md) | `lib/data/services/{sdk_name}/` |

## Serviceレイヤーの種別判定

| 実装内容 | 種別 | 参照ファイル |
|---|---|---|
| HTTP通信 / API呼び出し | Service（Web API） | [service_web_api.md](service_web_api.md) |
| SecureStorage / SharedPreferences | Service（LocalStorage） | [service_local_storage.md](service_local_storage.md) |
| Braze / Permission / Firebase等の外部SDK | Service（サードパーティー） | [service_third_party.md](service_third_party.md) |

## 既存実装カタログ

新規feature開発時に既存実装の再利用チェックに使用する。

| ファイル | 内容 |
|---|---|
| [implementations_data.md](implementations_data.md) | データ層（Repository・Service）既存実装一覧 |
| [implementations_domain.md](implementations_domain.md) | ドメイン層（UseCase・Entity・Interface）既存実装一覧 |
| [implementations_presentation.md](implementations_presentation.md) | プレゼンテーション層（View・Notifier・UseCase）既存実装一覧 |
