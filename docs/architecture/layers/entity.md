---
type: レイヤー仕様
title: Entity
description: ビジネスドメインの純粋なモデル。Freezedで不変性を保証し、data/・presentation/に依存しない
layer: ドメイン層
path: lib/domain/entities/
tags: [Entity, ドメイン層, Freezed, ビジネスモデル]
related: [interface.md, repository.md]
---

# Entity

**役割**: ビジネスドメインの純粋なモデル

**責務**:
- ビジネス概念の表現
- 不変オブジェクト（Freezed 使用）

**重要なポイント**:
- `data/` や `presentation/` に依存しない（最上位層）
- Freezed で不変性・`copyWith` を保証
- API レスポンスは Service 層の DTO として受け取り、Entity への変換は Repository が担当
