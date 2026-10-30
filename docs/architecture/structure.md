---
type: ディレクトリ構造
title: Directory Structure
description: lib/配下のディレクトリ構成（data/domain/presentation/utils等）
tags: [ディレクトリ構造, プロジェクト構成]
related: [architecture.md]
---

# Directory Structure

```
lib/
├── main.dart
├── router.dart
├── config/            # 環境設定
├── data/
│   ├── repositories/  # Repository実装
│   └── services/
│       ├── local/     # SharedPreferences, SecureStorage
│       └── remote/    # APIクライアント, DTO
├── design_system/
│   ├── components/    # 共通コンポーネント
│   └── styles/        # スタイル
├── domain/
│   ├── entities/      # Freezedエンティティ
│   ├── use_cases/     # ビジネスロジック
│   └── errors/        # ドメインエラー
├── presentation/
│   └── {feature}/     # View, ViewModel...etc
└── utils/             # Result型, Logger等
```
