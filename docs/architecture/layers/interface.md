---
type: レイヤー仕様
title: Interface（Repository抽象クラス）
description: UseCaseとデータ層の抽象境界（DIP）。UseCase→Repositoryの依存を逆転させるため常に設ける
layer: ドメイン層
path: lib/domain/interfaces/
tags: [Interface, ドメイン層, DIP, 依存性逆転, Repository]
related: [entity.md, usecase_domain.md, usecase_presentation.md, repository.md]
---

# Interface（Repository 抽象クラス）

**役割**: UseCase とデータ層の間の抽象境界（DIP）

**責務**:
- Repository 実装クラスの抽象化

**ファイル命名規則**:
- `*.dart` = interface / abstract class

**重要なポイント**:
- UseCase はデータ層の変更（Firebase → Supabase 切替等）の影響を受けない
- テスト時にスタブ実装を差し替え可能 → テスタビリティ向上
- UseCase → Repository の依存を逆転させるために**常に設ける**（パススルーでも省略しない）
