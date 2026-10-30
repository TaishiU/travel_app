---
type: レイヤー仕様
title: State
description: UIの表示状態を保持するイミュータブルなデータクラス（Freezed使用）。Notifierとセットで管理される
layer: プレゼンテーション層
path: lib/presentation/{feature}/state.dart
tags: [State, プレゼンテーション層, Freezed, Notifier]
related: [notifier.md, view.md]
---

# State

**役割**: UI の表示状態を保持

**責務**:
- UI の描画に必要なデータの保持
- イミュータブルなデータクラス（Freezed 使用）
- SSOT から提供されるデータと UI 固有状態（検索クエリ等）を合わせて保持

**重要なポイント**:
- State は UI 固有の状態のみ持つ
- Notifier が保持・更新する（Notifier とセット）
