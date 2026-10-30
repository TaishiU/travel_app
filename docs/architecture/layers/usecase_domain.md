---
type: レイヤー仕様
title: UseCase（ドメイン）
description: 特定の画面に属さないドメイン概念の集約。呼び出し元が1画面でもドメイン概念ならdomain層に配置する
layer: ドメイン層
path: lib/domain/use_cases/
tags: [UseCase, ドメイン層, ドメインユースケース, ビジネスロジック]
related: [interface.md, entity.md, usecase_presentation.md]
---

# UseCase（ドメインユースケース）

**役割**: 特定の画面に属さないドメイン概念の集約

**責務**:
- 業務ロジックの実行
- Repository Interface 経由でのデータ取得・加工
- 複数 Repository の協調操作

**禁止事項**:
- state 更新
- Repository 実装クラスへの直接依存

**重要なポイント**:
- 呼び出し元が1画面であっても「特定の画面に属さないドメイン概念」であれば domain 層に配置する
- `FailureResult` は `throw error` で呼び出し元に伝播させる
