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
