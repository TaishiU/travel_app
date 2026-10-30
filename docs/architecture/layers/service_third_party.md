---
type: レイヤー仕様
title: Service（サードパーティー）
description: 外部SDK（Braze・Permission・Firebase等）をコンストラクタ注入で抽象化するService層
layer: データ層
path: lib/data/services/{sdk_name}/
tags: [Service, データ層, Braze, Firebase, Permission, サードパーティー, SDK]
related: [repository.md, service_web_api.md, service_local_storage.md]
---

# Service（サードパーティー）

**役割**: 外部SDK（Braze・Permission・Firebase 等）のラップ・抽象化

**対象SDK**: Braze / Permission / Firebase 等
- `lib/data/services/braze/`
- `lib/data/services/permission/`
- `lib/data/services/firebase/`

**責務**:
- 外部SDK操作の抽象化
- SDKインスタンスのコンストラクタ注入による差し替え可能な設計

**禁止事項**:
- ビジネスロジックの保持
- `AppError` への変換（変換は Repository が担う）

**重要なポイント**:
- 外部SDKインスタンスはコンストラクタ注入し、Provider 単位で差し替え可能にする → 追加の IF は不要
- 実I/O（デバイスAPI・外部SDK呼び出し）をクラス内で直接実行している場合は IF を設ける

```dart
// ✅ Good: 外部SDKのインスタンスをコンストラクタ注入 → テスト時にProviderごと差し替え可能
final pushTokenServiceImplProvider = Provider<PushTokenService>(
  (ref) => PushTokenServiceImpl(
    brazePlugin: ref.read(brazePluginProvider),
    firebaseMessaging: ref.read(firebaseMessagingProvider),
    isAndroid: Platform.isAndroid,
  ),
);
```
