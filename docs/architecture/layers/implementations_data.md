---
type: 実装カタログ
title: 既存データ層実装一覧
description: 新規feature開発時に再利用可能な既存のRepository・Service実装の一覧
layer: データ層
tags: [Repository, Service, 実装カタログ, データ層]
related: [repository.md, service_web_api.md, service_local_storage.md, service_third_party.md]
---

# 既存データ層実装一覧

> Repository / Service が絡むチケットで必ず参照する。
> 既存実装が存在する場合は0から実装せず再利用すること。

## Repository

| クラス名 | インターフェース | ファイルパス | 扱うドメイン |
|---|---|---|---|
| AuthRepositoryImpl | AuthRepository | lib/data/repositories/auth/auth_repository_impl.dart | 認証・ユーザー情報 |
| NotificationAnalyticsRepositoryImpl | NotificationAnalyticsRepository | lib/data/repositories/notification/notification_analytics_repository_impl.dart | 通知分析イベント送信 |
| NotificationPermissionRepositoryImpl | NotificationPermissionRepository | lib/data/repositories/permission/notification/notification_permission_repository_impl.dart | 通知権限ステータス管理 |
| PushTokenRepositoryImpl | PushTokenRepository | lib/data/repositories/push_token/push_token_repository_impl.dart | プッシュトークン管理 |
| TaskRepositoryImpl | TaskRepository | lib/data/repositories/task/task_repository_impl.dart | タスク管理（CRUD） |
| UserRepository | なし（IF未設置） | lib/data/repositories/user/user_repository.dart | ユーザー情報取得 |

## Service（Web API）

| クラス名 | インターフェース | ファイルパス | エンドポイント群 |
|---|---|---|---|
| AuthApiServiceImpl | AuthApiService | lib/data/services/web_api/auth/service_impl.dart | 認証（ログイン・トークンリフレッシュ） |
| ProductsApiServiceImpl | ProductsApiService | lib/data/services/web_api/products/service_impl.dart | 商品一覧・詳細 |
| UsersApiServiceImpl | UsersApiService | lib/data/services/web_api/users/service_impl.dart | ユーザー一覧・詳細 |

## Service（LocalStorage）

| クラス名 | インターフェース | ファイルパス | 用途 |
|---|---|---|---|
| SecureStorageServiceImpl | SecureStorageService | lib/data/services/local_storage/secure_storage/secure_storage_service_impl.dart | SecureStorage基盤（flutter_secure_storage） |
| AuthSecureStorageServiceImpl | なし（SecureStorageServiceを内部利用） | lib/data/services/local_storage/secure_storage/auth/auth_secure_storage_service_impl.dart | 認証トークン保管（SecureStorage使用） |
| SharedPreferencesServiceImpl | SharedPreferencesService | lib/data/services/local_storage/preferences/shared_preferences_service_impl.dart | SharedPreferences基盤 |
| AuthPreferencesServiceImpl | AuthPreferencesService | lib/data/services/local_storage/preferences/auth/auth_preferences_service_impl.dart | 認証関連設定保管 |
| SettingsPreferencesServiceImpl | SettingsPreferencesService | lib/data/services/local_storage/preferences/settings/settings_preferences_service_impl.dart | アプリ設定保管 |
| AndroidNotificationPermissionPreferencesServiceImpl | AndroidNotificationPermissionPreferencesService | lib/data/services/local_storage/preferences/permission/notification/android_notification_permission_preferences_service_impl.dart | Android通知権限フラグ保管 |
| TaskLocalServiceImpl | TaskLocalService | lib/data/services/local_storage/database/task/task_local_service_impl.dart | タスクDB（Drift） |

## Service（サードパーティー）

| クラス名 | SDK | ファイルパス | 用途 |
|---|---|---|---|
| BrazeAnalyticsServiceImpl | BrazeAnalyticsService | lib/data/services/braze/analytics/braze_analytics_service_impl.dart | Brazeカスタムイベント・属性送信 |
| PushTokenServiceImpl | PushTokenService | lib/data/services/braze/push_token/push_token_service_impl.dart | Brazeプッシュトークン登録 |
| UserIdentityServiceImpl | UserIdentityService | lib/data/services/braze/user_identity/user_identity_service_impl.dart | Brazeユーザー識別（changeUser） |
| NotificationPermissionServiceImpl | NotificationPermissionService | lib/data/services/permission/notification/notification_permission_service_impl.dart | iOS/Android通知権限リクエスト・状態確認 |
