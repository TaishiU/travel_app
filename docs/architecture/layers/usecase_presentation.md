---
type: レイヤー仕様
title: UseCase（画面）
description: 特定画面の関心事に属すロジックを集約する画面ユースケース。フォームバリデーション・複数ステップ処理等を担う
layer: プレゼンテーション層
path: lib/presentation/{feature}/use_case.dart
tags: [UseCase, プレゼンテーション層, 画面ユースケース]
related: [notifier.md, interface.md, usecase_domain.md]
---

# UseCase（画面ユースケース）

**役割**: 特定の画面の関心事に属すロジックの集約

**責務**:
- 画面固有の業務ロジックの実行（フォームバリデーション・複数ステップ処理等）
- Notifier に書くには複雑すぎる処理の集約
- Repository Interface 経由でのデータ取得・加工
- 複数 Repository の協調操作

**禁止事項**:
- state 更新
- Repository 実装クラスへの直接依存

**重要なポイント**:
- 画面固有の複雑なロジックが生じた場合にのみ作成する（YAGNI 適用）
- 単純な委譲のみであれば不要
- Repository から受け取った `FailureResult` は `throw error` で呼び出し元に伝播させる

詳細設計（メソッド命名規則・Provider宣言・テスト設計等）は [use_case.md](../use_case.md) を参照。
