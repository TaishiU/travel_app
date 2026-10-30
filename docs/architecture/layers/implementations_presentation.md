---
type: 実装カタログ
title: 既存プレゼンテーション層実装一覧
description: 既存のView（Screen）・Notifier・UseCase（画面）一覧
layer: プレゼンテーション層
tags: [View, Notifier, UseCase, 実装カタログ, プレゼンテーション層]
related: [view.md, notifier.md, usecase_presentation.md]
---

# 既存プレゼンテーション層実装一覧

> プレゼンテーション層が絡むチケットで参照する。
> 既存のScreen・Notifier・UseCaseが存在する場合は再利用・拡張すること。

## View（Screen）

| feature | Screenクラス名 | ファイルパス | 画面概要 |
|---|---|---|---|
| login | LoginScreen | lib/presentation/login/screen.dart | ログイン・新規登録フォーム |
| profile | ProfileScreen | lib/presentation/profile/screen.dart | ユーザープロフィール表示・ログアウト |
| task | TaskScreen | lib/presentation/task/screen.dart | タスク一覧・追加・削除 |
| top | TopScreen | lib/presentation/top/screen.dart | トップ画面（BottomNavigationBar） |
| debug | DebugMenuScreen | lib/presentation/debug/screen.dart | デバッグメニュー（スタブ切替等） |

## Notifier

| feature | Notifierクラス名 | ファイルパス | 管理するState |
|---|---|---|---|
| login | LoginScreenNotifier | lib/presentation/login/notifier.dart | LoginScreenState |
| profile | ProfileScreenNotifier | lib/presentation/profile/notifier.dart | ProfileScreenState |
| task | TaskScreenNotifier | lib/presentation/task/notifier.dart | TaskScreenState |

## UseCase（画面）

| クラス名 | ファイルパス | 担当する画面処理 |
|---|---|---|
| ProfileScreenUseCase | lib/presentation/profile/use_case.dart | プロフィール画面のデータ取得・フォーマット |
| TaskScreenUseCase | lib/presentation/task/use_case.dart | タスク画面の操作（追加・削除・一覧取得） |
