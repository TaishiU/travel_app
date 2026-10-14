# BRAZE-003 データスキーマ設計

## 内容

Brazeへ送るユーザー属性、カスタムイベント、イベントプロパティを確定する

## 完了条件

属性名・型・送信タイミング・送信責務を文書化する

---

## 解決した未決定事項

### BRAZE-001 ①② user_id 取得方法

**決定**: Option A（`LoginDto` にサーバーが `user_id` を含める）を採用。

`/auth/login` のレスポンスに `data.user.id` が含まれることを API 仕様（openapi.yaml）で確認済み。

```json
{
  "data": {
    "accessToken": "string",
    "refreshToken": "string",
    "user": {
      "id": "string",
      "email": "string",
      "displayName": "string"
    }
  }
}
```

`LoginDto` への `userId` フィールド追加は**実装フェーズ（BRAZE-010〜）で行う**。Option B は API 仕様確認済みのため不採用。

| 案 | 方式 | 採用 |
|---|---|---|
| A | `LoginDto` に `userId` を追加 → `AuthSecureStorageService` に保存 | **採用** |
| B | ログイン後に `fetchMe()` で取得 → `AuthRepository.userId` フィールド追加 | 不採用（API仕様確認済みのため不要） |

**実装への影響**

| ファイル | 変更内容 | 実施フェーズ |
|---|---|---|
| `lib/data/services/web_api/auth/login/dto.dart` | `userId: String?` フィールドを追加 | BRAZE-010〜 |
| `lib/data/services/auth/auth_secure_storage_service.dart` | `userId` の読み書きメソッドを追加 | BRAZE-010〜 |
| `lib/domain/use_cases/auth/auth_use_case.dart` | `login()` 完了後に `NotificationAnalyticsRepository.changeUser(userId)` 呼び出しを追加 | BRAZE-014 |

---

### BRAZE-002 ② trip_support 緊急情報の定義範囲

**定義**: 旅行者の安全・旅程遂行に直接影響する外部起因の事象

| 対象事象 | 具体例 | 判定者 |
|---|---|---|
| フライト遅延・キャンセル | 2時間以上の遅延、欠航 | サーバー（航空会社API連携） |
| 交通機関の長時間停止 | 鉄道・バスの運行停止（復旧未定） | サーバー |
| 宿泊施設の緊急キャンセル | 事業者都合によるキャンセル | サーバー |
| 自然災害・気象警報 | 台風・地震・大雪（旅行先TZ基準） | サーバー（外部警報API連携） |
| 政府安全勧告 | 外務省スポット情報・危険情報 | サーバー |

**判定はサーバー側が行う**。Flutter側は `is_emergency: true` フラグ付きのPush通知を受信し、Androidチャンネル重要度 HIGH で表示する。ユーザー変更不可。

---

## 1. ユーザー属性スキーマ

### 1.1 識別・デバイス情報

| 属性名 | Braze属性型 | 送信タイミング | 送信責務 | 備考 |
|---|---|---|---|---|
| `user_id` | `changeUser()` で設定 | ログイン成功直後 | Flutter | Braze内部のユーザー識別子。カスタム属性ではなくAPIで設定 |
| `anonymous_id` | String | アプリ初回起動時 | Flutter | UUID生成・SecureStorageに永続化。ログイン後に `user_id` へ紐づけ |
| `locale` | String | アプリ起動時・言語変更時 | Flutter | 例: `ja-JP` |
| `timezone` | String | アプリ起動時・TZ変更時 | Flutter | 例: `Asia/Tokyo` |
| `last_active_at` | Date | アプリ起動時 | Flutter | UTC ISO8601形式 |

### 1.2 Push通知・同意状態

| 属性名 | Braze属性型 | 取得値 | 送信タイミング | 送信責務 |
|---|---|---|---|---|
| `push_permission_status` | String | `not_determined` / `granted` / `denied` / `provisional` | アプリ起動時・権限変更時 | Flutter |
| `marketing_consent` | String | `not_requested` / `granted` / `denied` | 同意ダイアログ結果確定時 | Flutter |
| `notification_preferences` | Object（Nested Attribute） | カテゴリ別ON/OFF | ユーザーが設定変更時 | Flutter |
| `location_permission` | String | `granted` / `denied` / `restricted` | 位置情報権限変更時 | Flutter |

**`notification_preferences` の構造**

```json
{
  "trip_preparation": true,
  "trip_support": true,
  "marketing_offer": false
}
```

`booking_transaction` はユーザー変更不可のため含めない。

### 1.3 予約・旅行状態

| 属性名 | Braze属性型 | 取得値 | 送信タイミング | 送信責務 |
|---|---|---|---|---|
| `booking_id` | String | — | 予約確定時 | Flutter |
| `booking_status` | String | `pending` / `confirmed` / `cancelled` / `completed` | 予約状態変化時 | Flutter / Server |
| `payment_status` | String | `unpaid` / `paid` / `failed` / `refunded` | 決済状態変化時 | Flutter / Server |
| `travel_start_at` | Date | — | 予約確定時 | Flutter |
| `travel_end_at` | Date | — | 予約確定時 | Flutter |
| `travel_timezone` | String | 例: `America/Los_Angeles` | 予約確定時 | Flutter |
| `days_until_departure` | Integer | — | アプリ起動時（予約あり・出発前） | Flutter |
| `calendar_registered` | Boolean | `true` / `false` | カレンダー登録完了時 | Flutter |
| `checkin_status` | String | `not_required` / `pending` / `completed` / `expired` | チェックイン状態変化時 | Flutter / Server |
| `departure_location` | String | — | 予約確定時 | Flutter |

### 1.4 行動・機能状態

| 属性名 | Braze属性型 | 送信タイミング | 送信責務 |
|---|---|---|---|
| `viewed_plan_ids` | Array（String）| プラン閲覧時（append） | Flutter |
| `last_viewed_plan_id` | String | プラン閲覧時 | Flutter |
| `offline_map_downloaded` | Boolean | ダウンロード完了時・確認時 | Flutter |
| `offline_mode_detected` | Boolean | オフライン検知・復帰時 | Flutter |
| `review_status` | String | レビュー状態変化時 | Flutter / Server |
| `trip_completed_at` | Date | 旅行完了時 | Flutter / Server |
| `web_to_app_source` | String | Web-to-App流入時 | Flutter |

---

## 2. カスタムイベントスキーマ

### 2.1 booking_transaction

#### `booking_confirmed`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `booking_id` | String | `"BK-12345"` |
| `booking_status` | String | `"confirmed"` |
| `travel_start_at` | String | UTC ISO8601 |
| `travel_end_at` | String | UTC ISO8601 |
| `travel_timezone` | String | `"Asia/Tokyo"` |
| `is_synchronous` | Boolean | 即時確定=`true`、手動承認=`false` |

| 項目 | 内容 |
|---|---|
| カテゴリ | `booking_transaction` |
| 送信者 | Flutter（同期完了時）/ Server（非同期完了時） |
| 送信目的 | 即時確定→アナリティクス、非同期→Push通知トリガー |

---

#### `payment_completed`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `booking_id` | String | — |
| `payment_status` | String | `"paid"` |
| `payment_type` | String | `"synchronous"` / `"asynchronous"` |

| 項目 | 内容 |
|---|---|
| カテゴリ | `booking_transaction` |
| 送信者 | Flutter（同期決済時）/ Server（非同期決済時） |
| 送信目的 | Push通知トリガー候補（非同期決済のみ） |

---

#### `booking_cancelled_by_user`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `booking_id` | String | — |
| `cancellation_reason` | String | ユーザー選択の理由コード（任意） |

| 項目 | 内容 |
|---|---|
| カテゴリ | `booking_transaction` |
| 送信者 | Flutter |
| 送信目的 | 属性更新（`booking_status = cancelled` → 以降の予約関連通知停止） |

---

#### `booking_cancelled_by_operator`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `booking_id` | String | — |
| `cancellation_reason` | String | 事業者コード / 理由テキスト |

| 項目 | 内容 |
|---|---|
| カテゴリ | `booking_transaction` |
| 送信者 | Server |
| 送信目的 | Push通知トリガー |

---

### 2.2 trip_preparation

#### `calendar_register_prompt_shown`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `booking_id` | String | — |
| `days_until_departure` | Integer | `7` |

| 項目 | 内容 |
|---|---|
| カテゴリ | `trip_preparation` |
| 送信者 | Flutter |
| 送信目的 | アナリティクス（重複案内防止・表示回数管理） |

---

#### `calendar_registered`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `booking_id` | String | — |

| 項目 | 内容 |
|---|---|
| カテゴリ | `trip_preparation` |
| 送信者 | Flutter |
| 送信目的 | 属性更新（`calendar_registered = true` → カレンダー案内Push停止） |

---

#### `checkin_completed`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `booking_id` | String | — |
| `checkin_status` | String | `"completed"` |

| 項目 | 内容 |
|---|---|
| カテゴリ | `trip_preparation` |
| 送信者 | Flutter |
| 送信目的 | 属性更新（チェックイン期限Push停止） |

---

#### `trip_starting_soon`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `booking_id` | String | — |
| `departure_at` | String | UTC ISO8601 |
| `departure_location` | String | 集合場所名 |

| 項目 | 内容 |
|---|---|
| カテゴリ | `trip_preparation` |
| 送信者 | Flutter |
| 送信目的 | Push通知トリガー候補 |

---

### 2.3 trip_support

#### `trip_started`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `booking_id` | String | — |
| `travel_start_at` | String | UTC ISO8601 |

| 項目 | 内容 |
|---|---|
| カテゴリ | `trip_support` |
| 送信者 | Flutter |
| 送信目的 | 属性更新（旅マエPush停止・旅ナカセグメント切替） |

---

#### `offline_mode_entered`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `booking_id` | String | — |
| `offline_map_downloaded` | Boolean | — |
| `occurred_at` | String | UTC ISO8601（実際のオフライン発生時刻） |

| 項目 | 内容 |
|---|---|
| カテゴリ | `trip_support` |
| 送信者 | Flutter（接続復帰後に遅延送信） |
| 送信目的 | アナリティクスのみ。Push通知としては使用しない |

---

#### `trip_completed`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `booking_id` | String | — |
| `trip_completed_at` | String | UTC ISO8601 |

| 項目 | 内容 |
|---|---|
| カテゴリ | `trip_support` |
| 送信者 | Flutter / Server |
| 送信目的 | 属性更新（旅ナカPush停止・旅アトセグメント切替） |

---

### 2.4 全カテゴリ共通

#### `notification_opened`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `campaign_id` | String | Braze campaign ID |
| `notification_category` | String | `booking_transaction` 等 |
| `deep_link` | String | タップ後遷移先URL |

| 項目 | 内容 |
|---|---|
| 送信者 | Flutter（Braze SDK が自動収集） |
| 送信目的 | 開封計測・遷移先分析 |

---

#### `notification_opt_out_changed`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `category` | String | カテゴリID |
| `new_status` | Boolean | `true`=ON / `false`=OFF |
| `change_source` | String | `user_setting` / `os_permission` |

| 項目 | 内容 |
|---|---|
| 送信者 | Flutter |
| 送信目的 | 設定変更履歴・セグメント管理 |

---

### 2.5 プラン閲覧・保存（marketing_offer 関連）

#### `plan_viewed`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `plan_id` | String | — |
| `destination` | String | 目的地名 |
| `price` | Integer | 最低価格（円） |

#### `plan_saved`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `plan_id` | String | — |

---

### 2.6 engagement（Phase 2・参考定義）

#### `review_requested`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `booking_id` | String | — |

#### `review_submitted`

| プロパティ | 型 | 値 / 例 |
|---|---|---|
| `booking_id` | String | — |
| `rating` | Integer | 1〜5（任意） |

---

## 3. 画面・タイミング別送信責務一覧

| 送信内容 | 送信者 | Flutter内の責務者 |
|---|---|---|
| `changeUser(userId)` | Flutter | `AuthUseCase.login()` → `NotificationAnalyticsRepository` |
| `push_permission_status` | Flutter | `NotificationPermissionUseCase` → `NotificationAnalyticsRepository` |
| `marketing_consent` | Flutter | 通知設定画面 Notifier → `NotificationAnalyticsRepository` |
| `booking_confirmed`（同期） | Flutter | 予約確定 UseCase → `NotificationAnalyticsRepository` |
| `booking_confirmed`（非同期） | Server | Braze REST API |
| `booking_cancelled_by_operator` | Server | Braze REST API |
| `payment_completed`（同期） | Flutter | 決済完了 UseCase → `NotificationAnalyticsRepository` |
| `payment_completed`（非同期） | Server | Braze REST API |
| `calendar_registered` | Flutter | カレンダー登録完了後 UseCase |
| `trip_started` | Flutter | 旅行開始検知 UseCase |
| `offline_mode_entered` | Flutter（遅延） | ネットワーク復帰時 Repository（ローカルキューから送信） |
| `trip_completed` | Flutter / Server | 旅行完了 UseCase / Braze REST API |

---

## 4. 実装上の注意点

### イベント名・属性名の一元管理

イベント名・属性名は定数クラスで管理し、文字列のハードコードを防ぐ。

```dart
// lib/data/services/braze/braze_event_constants.dart
abstract class BrazeEvent {
  static const bookingConfirmed = 'booking_confirmed';
  static const paymentCompleted = 'payment_completed';
  static const bookingCancelledByUser = 'booking_cancelled_by_user';
  static const bookingCancelledByOperator = 'booking_cancelled_by_operator';
  static const calendarRegisterPromptShown = 'calendar_register_prompt_shown';
  static const calendarRegistered = 'calendar_registered';
  static const checkinCompleted = 'checkin_completed';
  static const tripStartingSoon = 'trip_starting_soon';
  static const tripStarted = 'trip_started';
  static const offlineModeEntered = 'offline_mode_entered';
  static const tripCompleted = 'trip_completed';
  static const notificationOpened = 'notification_opened';
  static const notificationOptOutChanged = 'notification_opt_out_changed';
  static const planViewed = 'plan_viewed';
  static const planSaved = 'plan_saved';
}

abstract class BrazeAttribute {
  static const userId = 'user_id';
  static const anonymousId = 'anonymous_id';
  static const pushPermissionStatus = 'push_permission_status';
  static const marketingConsent = 'marketing_consent';
  static const notificationPreferences = 'notification_preferences';
  static const bookingId = 'booking_id';
  static const bookingStatus = 'booking_status';
  static const paymentStatus = 'payment_status';
  static const travelStartAt = 'travel_start_at';
  static const travelEndAt = 'travel_end_at';
  static const travelTimezone = 'travel_timezone';
  static const daysUntilDeparture = 'days_until_departure';
  static const calendarRegistered = 'calendar_registered';
  static const checkinStatus = 'checkin_status';
  static const offlineMapDownloaded = 'offline_map_downloaded';
}
```

### 二重送信防止

同一イベントの重複送信を防ぐため、`NotificationAnalyticsRepository` 内でイベントIDによる排他制御を行う。

| 排他キー | 対象イベント |
|---|---|
| `booking_id + event_type` | `booking_confirmed`, `payment_completed`, `booking_cancelled_*` |
| `booking_id + reminder_type + scheduled_at` | `calendar_register_prompt_shown`, `trip_starting_soon` |
| `booking_id + event_key + day` | `trip_started`, `trip_completed` |

### Deep Linkの仕組み

`notification_opened` の `deep_link` プロパティに格納するURLの形式と、go_router との接続方法を示す。

#### URLの正体

`deep_link` はブラウザで開くWebのURLではなく、**アプリ固有のカスタムURLスキーム**。

```
travelapp://booking/BK-12345
travelapp://settings/notifications
```

`travelapp://` をiOS `Info.plist` / `AndroidManifest.xml` にスキームとして登録すると、このURLをタップしたときにOSがブラウザではなくアプリを起動する。

#### 通知タップから画面表示までのフロー

```
Brazeダッシュボード（キャンペーン設定）
  push通知ペイロードに deep_link を埋め込む
  { "deep_link": "travelapp://booking/BK-12345" }
    ↓
ユーザーが通知をタップ
    ↓
OSがスキームを見てアプリを起動 or フォアグラウンドへ
    ↓
Braze SDK → Flutter のコールバックへ URL を渡す
    ↓
Flutter 側でURLをパース → go_router パスに変換
  router.go('/booking/BK-12345')
    ↓
go_routerのroute定義に照合
  GoRoute(path: '/booking/:bookingId', ...)
    ↓
BookingDetailScreen(bookingId: 'BK-12345') が表示される
```

#### go_router パスと deep_link URL の対応

`deep_link` の値は `travelapp://` 以降の部分が go_router のパスに対応する。

| go_router パス | deep_link URL | 遷移先画面 |
|---|---|---|
| `/booking/BK-12345` | `travelapp://booking/BK-12345` | 予約詳細画面 |
| `/plan/PL-001` | `travelapp://plan/PL-001` | プラン詳細画面 |
| `/settings/notifications` | `travelapp://settings/notifications` | 通知設定画面 |

スキーマの全体設計（パス一覧・パラメータ・未ログイン時の保留遷移）は `BRAZE-004` で確定する。

#### Flutter側の実装イメージ（BRAZE-017）

```dart
// Braze SDK のコールバックでURLを受け取り go_router へ渡す
BrazePlugin.setBrazeDeepLinkCallback((url) {
  final uri = Uri.parse(url); // travelapp://booking/BK-12345
  final path = '/${uri.host}${uri.path}'; // /booking/BK-12345
  router.go(path);
});
```

未ログイン時は go_router の `redirect` が `/login` へ飛ばすため、ログイン完了後に元のパスへ戻す保留遷移先の管理が別途必要（BRAZE-004 のスコープ）。

---

### 日時フォーマット

Brazeへ送るすべての日時はUTC ISO8601形式（例: `2026-10-13T09:00:00Z`）。タイムゾーン変換はFlutter側で行い、`travel_timezone` 等のTZ属性とは分離して管理する。

---

## 未決定事項

| # | 未決定事項 | 内容 | 決定チケット |
|---|---|---|---|
| 1 | サーバーの同期・非同期イベント仕様 | 各予約・決済イベントが同期・非同期のどちらに該当するか（Server送信範囲の確定に必要） | `BRAZE-020` |
| 2 | `notification_preferences` のBraze属性形式 | BrazeのNested Attributeとして送るか、`trip_preparation_enabled` 等にフラット展開するか | `BRAZE-015` |
| 3 | Deep Linkスキーマ | 通知タップ後の遷移先パス・パラメータ・未ログイン時挙動 | `BRAZE-004` |
| 4 | 権限要求タイミング・事前説明UI | OS権限要求のタイミングとUI設計 | `BRAZE-005` |
| 5 | `marketing_consent` 取得タイミング | 予約完了後・初回起動後など、どのタイミングで同意ダイアログを表示するか | `BRAZE-005` |
