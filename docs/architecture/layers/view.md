---
type: レイヤー仕様
title: View
description: UIコンポーネント・画面表示を担うプレゼンテーション層。状態表示とユーザーアクションのNotifierへの委譲のみ行う
layer: プレゼンテーション層
path: lib/presentation/{feature}/screen.dart
tags: [View, プレゼンテーション層, Widget, Screen]
related: [state.md, notifier.md, usecase_presentation.md]
---

# View

**役割**: UI コンポーネント・画面表示

**責務**:
- 状態を表示するのみ
- ユーザーアクションを Notifier に伝える

**禁止**:
- ビジネスロジックの保持
- UseCase / データ層 の直接呼び出し

**重要なポイント**:
- `AsyncData` / `AsyncError` のみで分岐する（`AsyncData` の中に Result の二重 switch をしない）
- ビジネスロジックは Notifier / UseCase に移動する
- エラーハンドリングの詳細は [error_handling.md](../error_handling.md) を参照

詳細設計（CustomScrollView・Section・Component構成等）は [view.md](../view.md) を参照。
