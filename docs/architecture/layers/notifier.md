---
type: レイヤー仕様
title: Notifier
description: StateとUseCaseの橋渡し役。AsyncNotifier<State>でState保持・更新とUseCase呼び出しを担う
layer: プレゼンテーション層
path: lib/presentation/{feature}/notifier.dart
tags: [Notifier, プレゼンテーション層, AsyncNotifier, Riverpod, State]
related: [state.md, usecase_presentation.md, view.md]
---

# Notifier

**役割**: State の保持・更新と UseCase 呼び出しを担う（State とセット）

**責務**:
- UseCase 呼び出し
- state 更新

**禁止**:
- 業務ロジックの保持
- データ層（Repository・Service）への直接アクセス

**重要なポイント**:
- `AsyncNotifier<State>` を使用する（`Result<State>` の二重ラップはしない）
- `build()` 内で throw が発生した場合、Riverpod が自動で `AsyncError` に変換する
- `build()` 内で Stream を `watch` → Repository がデータを更新すると自動で再構築
- public メソッド名は View からのアクション名（`toggleTodo`, `refresh`, `logout`）
- データ取得・更新は UseCase 経由（`ref.read(useCaseProvider).method()`）
- `ref.listen` で他 Notifier の変更を監視し SSOT を維持
- エラーハンドリングの詳細は [error_handling.md](../error_handling.md) を参照
