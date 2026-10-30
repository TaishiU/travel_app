---
type: 実装カタログ
title: 既存ドメイン層実装一覧
description: 既存のUseCase（ドメイン）・Entity・Interface一覧
layer: ドメイン層
tags: [UseCase, Entity, Interface, 実装カタログ, ドメイン層]
related: [usecase_domain.md, entity.md, interface.md]
---

# 既存ドメイン層実装一覧

> ドメイン層が絡むチケットで参照する。
> 既存のUseCase・Entity・Interfaceが存在する場合は再利用すること。

## UseCase（ドメイン）

| クラス名 | ファイルパス | 担当するドメイン処理 |
|---|---|---|
| AuthUseCase | lib/domain/use_cases/auth/auth_use_case.dart | 認証（ログイン・ログアウト・ユーザー情報取得） |
| RegisterPushTokenUseCase | lib/domain/use_cases/push_token/register_push_token_use_case.dart | プッシュトークン登録（FCM取得→Braze登録） |
| TaskUseCase | lib/domain/use_cases/task/task_use_case.dart | タスク管理（一覧取得・追加・削除） |
| NotificationPermissionUseCase | lib/domain/use_cases/permission/notification/notification_permission_use_case.dart | 通知権限状態取得・リクエスト |

## Entity

| クラス名 | ファイルパス | 表現するドメイン概念 |
|---|---|---|
| User | lib/domain/entities/user/user.dart | ユーザー情報 |
| Task | lib/domain/entities/task/task.dart | タスク |
| NotificationPermissionStatus | lib/domain/entities/permission/notification/notification_permission_status.dart | 通知権限ステータス（granted / denied / notDetermined） |

## Interface（Repository抽象クラス）

| クラス名 | ファイルパス | 抽象化対象 |
|---|---|---|
| AuthRepository | lib/domain/interfaces/auth/auth_repository.dart | 認証・ユーザー情報Repository |
| NotificationAnalyticsRepository | lib/domain/interfaces/notification/notification_analytics_repository.dart | 通知分析Repository |
| NotificationPermissionRepository | lib/domain/interfaces/permission/notification/notification_permission_repository.dart | 通知権限Repository |
| PushTokenRepository | lib/domain/interfaces/push_token/push_token_repository.dart | プッシュトークンRepository |
| TaskRepository | lib/domain/interfaces/task/task_repository.dart | タスクRepository |
