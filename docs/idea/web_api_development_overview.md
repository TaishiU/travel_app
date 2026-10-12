
# ユーザー要求1
旅行予約系アプリのWebAPI（Restful API）をtypescriptで開発したい。モバイルアプリ側はflutterです。
上記の方針に可能な限りAPI仕様を近づけていき、参画前に実際に旅行予約アプリを開発することでドメイン知識を深めておきたい。
すでに参画予定のサービスのアプリは手元でダウンロードしており、以下aの画面がある。bはflutter側での技術環境です。cは参画予定のチームの開発状況です。
これらをもとにAPIに必要な情報を一覧として洗い出して。
```a
・ログイン画面
　　・ログイン、新規登録
　　・googleログイン、yahoo japan idログイン、facebookログイン、lineログイン
・ホーム画面（フッター）
　　・バナー（ツアー特集、会員限定クーポン、クリエイタープログラム募集、人気ランキング商品）
　　・最近チェックしたアクティビティ一覧
　　・国内/海外で人気のアクティビティ一覧
・探す画面（フッター）
　　・検索（行き先・やりたいことから探す）
　　・あなたにおすすめのアクティビティ一覧（画像付き、料金、星5段階評価、体験談件数、料金）
　　・最新5つ星体験談一覧（画像付き）
　　・取り扱いエリア一覧（日本国内、ヨーロッパ、中東、アフリカ、アジア、ハワイ、アメリカ・カナダ）
　　・バナー（画面下部）
・アクティビティ詳細画面（探す画面から遷移）
　　・画像（4〜5枚）、料金、星5段階評価、体験談件数、概要、ハイライト
　　・プラン（3〜5つほど。例：バス観光プラン、レンタサイクルフリープラン）
　　・プラン詳細（スケジュール、参加場所Map）　
　　・体験者の投稿写真（100件以上）
　　・お支払い、キャンセル情報
　　・「今すぐ予約する」ボタン
　　・「お気に入り」ボタン
・予約画面（アクティビティ詳細画面から遷移）
　　・カレンダーでの利用日選択（残りわずか、売り切れ、催行なしの3つのstatusが日にちに表示されている）
　　・利用者数の選択、料金
・予約画面（フッター）
　　・タブ（参加予定、参加済み、キャンセル済み、その他）
　　・予約したアクティビティが表示される
・保存リスト画面（フッター）
　　・お気に入り登録したアクティビティが一覧として表示される
・メニュー画面（フッター）
　　・会員情報確認・変更、予約履歴、体験談、クレジットカード情報、パスワード再設定、ポイント履歴、クーポン、メール配信確認（変更・停止）、push通知配信確認（変更・停止）、マイエリア
　　・ログアウトボタン
```
```b
## 技術環境
Flutter / CodeMagic / Slack / ClickUp / Figma / Braze / AppsFlyer /
GA4 / Firebase / Looker / BigQuery / GTM
```
```c
〈これまで〉
webからアプリへ誘導してもcvrが下がらない改善
・ホーム画面のflutter化（他の画面はwebview表示）
・計測基盤の整備（GA4, AppsFlyer）
・web-to-app施策のリリース

〈これから〉
Flutter独自のux改善ができる機能追加&webとの連動
・push通知カテゴリ化&位置情報取得
・カレンダー登録・マイマップ機能
・webとの連動（api）
・運用の自動化・効率化（AI活用）
```

---

# API方針（ユーザー要求1への回答）
画面一覧から逆算すると、必要なAPIは単なる「アクティビティ取得API」ではありません。中心となるドメインは、**認証、アクティビティ検索、プラン、在庫・空き状況、予約、決済、レビュー、ユーザー行動、通知設定、会員情報**です。

まずは本番相当の複雑さをすべて再現するのではなく、**旅行予約の一連の流れを最後まで通せる最小構成**を作るのがおすすめです。

```text
ログイン
→ アクティビティ検索
→ 詳細・プラン確認
→ 利用日・人数選択
→ 料金確認
→ 予約作成
→ 予約確認
→ 予約履歴
→ レビュー投稿
```

以下では、FlutterクライアントとTypeScript APIを前提に、必要な情報をドメインごとに洗い出します。

***

## 1. 全体ドメイン一覧

### 優先度の考え方

| 優先度 | 意味 |
|---|---|
| P0 | 予約アプリの中核。最初に実装する |
| P1 | 実サービスに近づけるために重要 |
| P2 | 運用・マーケティング・拡張領域 |

### APIドメイン

| ドメイン | 主な役割 | 優先度 |
|---|---|---:|
| 認証・アカウント | ログイン、新規登録、ソーシャルログイン | P0 |
| ホームコンテンツ | バナー、ランキング、最近見た商品 | P1 |
| 検索 | 行き先、カテゴリ、キーワード検索 | P0 |
| エリア・カテゴリ | 地域、アクティビティ分類 | P0 |
| アクティビティ | 商品の基本情報、画像、評価 | P0 |
| プラン | 料金、内容、スケジュール、集合場所 | P0 |
| 在庫・空き状況 | 利用可能日、残席、売り切れ | P0 |
| 予約 | 予約作成、確認、変更、キャンセル | P0 |
| 決済 | 支払い方法、決済状態、金額 | P0 |
| お気に入り | 保存リスト | P1 |
| 閲覧履歴 | 最近チェックした商品 | P1 |
| レビュー | 体験談、投稿写真、評価 | P1 |
| ユーザー設定 | 会員情報、通知、メール設定 | P1 |
| クーポン・ポイント | 割引、ポイント履歴 | P2 |
| マイエリア | ユーザーの興味地域 | P2 |
| 計測イベント | GA4、AppsFlyer相当の行動記録 | P0 |
| 管理・運用 | 商品、在庫、バナー、レビュー管理 | P2 |

***

# 2. 画面から必要なAPIを洗い出す

## 2.1 ログイン・新規登録

### 画面上の要件

- メールアドレス・パスワードによるログイン
- 新規登録
- Googleログイン
- Yahoo! JAPAN IDログイン
- Facebookログイン
- LINEログイン
- パスワード再設定
- ログアウト

### API一覧

| Method | Endpoint | 用途 | 認証 |
|---|---|---|---|
| POST | `/v1/auth/register` | 新規登録 | 不要 |
| POST | `/v1/auth/login` | メールログイン | 不要 |
| POST | `/v1/auth/social/{provider}` | ソーシャルログイン | 不要 |
| POST | `/v1/auth/refresh` | アクセストークン更新 | Refresh Token |
| POST | `/v1/auth/logout` | ログアウト | 必須 |
| POST | `/v1/auth/password/forgot` | 再設定メール送信 | 不要 |
| POST | `/v1/auth/password/reset` | パスワード変更 | 不要 |
| GET | `/v1/auth/me` | ログイン中ユーザー取得 | 必須 |

### ソーシャルログインの重要な設計

Flutterから受け取ったGoogleなどのトークンを、そのまま信用してはいけません。バックエンドでIDトークンを検証し、プロバイダーが返す安定したユーザー識別子を使って自サービスのユーザーに紐付けます。Googleについては、メールアドレスではなく`sub`を一意識別子として利用することが推奨されています。 [developers.google](https://developers.google.com/identity/siwg/best-practices)

```json
POST /v1/auth/social/google
{
  "idToken": "eyJhbGciOi..."
}
```

```json
201 Created
{
  "user": {
    "id": "usr_01H...",
    "displayName": "Home",
    "email": "user@example.com"
  },
  "tokens": {
    "accessToken": "...",
    "refreshToken": "...",
    "expiresIn": 900
  },
  "isNewUser": true
}
```

### ユーザー・認証テーブル

#### `users`

- `id`
- `email`
- `password_hash`
- `display_name`
- `first_name`
- `last_name`
- `first_name_kana`
- `last_name_kana`
- `phone_number`
- `birth_date`
- `gender`
- `avatar_url`
- `status`
- `created_at`
- `updated_at`
- `deleted_at`

#### `social_accounts`

- `id`
- `user_id`
- `provider`
- `provider_user_id`
- `provider_email`
- `created_at`
- `updated_at`

`provider`には以下を想定します。

```text
google
yahoo_japan
facebook
line
```

一人のユーザーが、メールログインとGoogleログインを後から紐付けられる設計にすると実践的です。

#### `refresh_tokens`

- `id`
- `user_id`
- `token_hash`
- `device_id`
- `device_name`
- `expires_at`
- `revoked_at`
- `created_at`

Flutterではアクセストークンやリフレッシュトークンを安全なストレージに保管します。Googleも、トークンを平文で送受信せず、安全に保管し、不要になったら失効・削除することを推奨しています。 [developers.google](https://developers.google.com/identity/protocols/oauth2/policies)

***

## 2.2 ホーム画面

### 画面上の要件

- バナー
- ツアー特集
- 会員限定クーポン
- クリエイタープログラム募集
- 人気ランキング
- 最近チェックしたアクティビティ
- 国内・海外の人気アクティビティ

### おすすめAPI

ホーム画面専用のBFF的なAPIを用意する方法が実装しやすいです。

```http
GET /v1/home
```

```json
{
  "banners": [],
  "sections": [
    {
      "id": "sec_001",
      "title": "国内で人気のアクティビティ",
      "type": "popular_activities",
      "items": []
    },
    {
      "id": "sec_002",
      "title": "最近チェックしたアクティビティ",
      "type": "recently_viewed",
      "items": []
    }
  ]
}
```

### バナー

#### `banners`

- `id`
- `title`
- `image_url`
- `description`
- `link_type`
- `link_target`
- `placement`
- `priority`
- `starts_at`
- `ends_at`
- `is_published`
- `display_conditions`
- `created_at`
- `updated_at`

`link_type`は以下のようにします。

```text
activity
search
coupon
external_url
campaign
creator_program
```

### ホーム画面用APIを作る理由

Flutter側から以下のAPIを個別に呼ぶ方法もあります。

```text
GET /banners
GET /activities/popular
GET /activities/recently-viewed
GET /campaigns
```

ただし、ホーム画面の初期表示でリクエスト数が増えます。

そのため、画面表示に必要なデータをまとめる次のAPIも有効です。

```http
GET /v1/home
```

ドメインAPIと画面APIを使い分ける構成です。

```text
ドメインAPI
- GET /activities
- GET /banners
- GET /reviews

画面表示用API
- GET /home
```

***

## 2.3 探す画面・検索

### 検索条件

検索では、最低限次の条件を考慮します。

- キーワード
- 行き先
- エリア
- アクティビティカテゴリ
- 利用日
- 最低料金・最高料金
- 評価
- 並び順
- ページング

### API

```http
GET /v1/activities
```

例：

```http
GET /v1/activities
  ?keyword=シュノーケリング
  &area_id=area_okinawa
  &available_date=2026-11-20
  &min_price=3000
  &max_price=20000
  &sort=popular
  &limit=20
  &cursor=...
```

### レスポンス

```json
{
  "data": [
    {
      "id": "act_001",
      "title": "沖縄の海を楽しむシュノーケリング体験",
      "thumbnailUrl": "https://cdn.example.com/activities/act_001/main.jpg",
      "startingPrice": {
        "amount": 5800,
        "currency": "JPY"
      },
      "rating": {
        "average": 4.8,
        "reviewCount": 128
      },
      "area": {
        "id": "area_okinawa",
        "name": "沖縄"
      },
      "badges": [
        "popular"
      ]
    }
  ],
  "pagination": {
    "nextCursor": "...",
    "hasNext": true
  }
}
```

### ページング

おすすめはカーソルベースです。

```http
GET /v1/activities?limit=20&cursor=eyJjcmVhdGVkQXQiOi...
```

検索結果やレビュー、投稿写真のようにデータが増え続ける一覧では、offsetよりcursorのほうが、途中の追加・削除による重複や取りこぼしを抑えやすくなります。 [djangoproject](https://djangoproject.in/blog/system-design-api-design/)

### 検索の補助API

| Method | Endpoint | 用途 |
|---|---|---|
| GET | `/v1/search/suggestions` | 検索候補 |
| GET | `/v1/areas` | エリア一覧 |
| GET | `/v1/categories` | カテゴリ一覧 |
| GET | `/v1/activities/featured` | おすすめ |
| GET | `/v1/activities/popular` | 人気 |
| GET | `/v1/reviews/latest` | 最新レビュー |

### エリア

#### `areas`

- `id`
- `parent_id`
- `name`
- `slug`
- `region_type`
- `country_code`
- `latitude`
- `longitude`
- `image_url`
- `sort_order`
- `is_active`

階層を持たせます。

```text
アジア
└── 日本
    └── 沖縄
        └── 石垣島
```

`parent_id`を持たせると、国内・海外・国・都道府県・都市を表現できます。

***

## 2.4 アクティビティ詳細画面

### 画面上の要件

- 画像4〜5枚
- 料金
- 星評価
- 体験談件数
- 概要
- ハイライト
- 複数プラン
- プラン詳細
- スケジュール
- 参加場所
- 地図
- 投稿写真
- 支払い情報
- キャンセル情報
- 今すぐ予約
- お気に入り

### API

```http
GET /v1/activities/{activityId}
```

レスポンス例：

```json
{
  "id": "act_001",
  "title": "沖縄の海を楽しむシュノーケリング体験",
  "description": "初心者でも参加できる体験です。",
  "highlights": [
    "初心者歓迎",
    "必要な器材をレンタル可能",
    "ホテル送迎あり"
  ],
  "images": [
    {
      "id": "img_001",
      "url": "https://cdn.example.com/1.jpg",
      "alt": "海での体験風景",
      "sortOrder": 1
    }
  ],
  "rating": {
    "average": 4.8,
    "reviewCount": 128
  },
  "price": {
    "startingAmount": 5800,
    "currency": "JPY"
  },
  "plans": [],
  "meetingPoints": [],
  "cancellationPolicy": {},
  "paymentInfo": {},
  "favorite": {
    "isFavorite": false
  }
}
```

### `activities`

- `id`
- `supplier_id`
- `title`
- `slug`
- `short_description`
- `description`
- `overview`
- `highlights`
- `area_id`
- `category_id`
- `status`
- `min_price`
- `max_price`
- `currency`
- `average_rating`
- `review_count`
- `booking_count`
- `published_at`
- `created_at`
- `updated_at`

### `activity_images`

- `id`
- `activity_id`
- `url`
- `image_type`
- `alt_text`
- `sort_order`

`image_type`の例：

```text
main
gallery
map
plan
review
```

### `activity_categories`

- `id`
- `name`
- `slug`
- `parent_id`
- `image_url`
- `sort_order`
- `is_active`

***

## 2.5 プラン

アクティビティとプランは分けて考える必要があります。

```text
アクティビティ
└── バス観光プラン
└── レンタサイクルフリープラン
└── 半日体験プラン
```

### API

```http
GET /v1/activities/{activityId}/plans
GET /v1/plans/{planId}
```

### `plans`

- `id`
- `activity_id`
- `name`
- `description`
- `duration_minutes`
- `min_participants`
- `max_participants`
- `price_type`
- `status`
- `booking_deadline_minutes`
- `created_at`
- `updated_at`

### 料金の考え方

単純なプラン価格だけでは不十分です。

```text
大人：8,000円
子ども：4,000円
幼児：無料
```

そのため、料金明細を別テーブルにします。

#### `plan_prices`

- `id`
- `plan_id`
- `participant_type`
- `amount`
- `currency`
- `valid_from`
- `valid_to`
- `conditions`

`participant_type`：

```text
adult
child
infant
senior
```

将来的には、曜日・繁忙期・年齢・人数による価格変動も考えられます。

***

## 2.6 プラン詳細・スケジュール・集合場所

### API

```http
GET /v1/plans/{planId}/schedule
GET /v1/plans/{planId}/meeting-points
```

### `plan_schedules`

- `id`
- `plan_id`
- `sequence`
- `start_time`
- `duration_minutes`
- `title`
- `description`
- `location_name`
- `latitude`
- `longitude`
- `map_url`
- `is_optional`

### `meeting_points`

- `id`
- `plan_id`
- `name`
- `address`
- `latitude`
- `longitude`
- `description`
- `access_information`
- `meeting_time`
- `is_default`

レスポンス例：

```json
{
  "items": [
    {
      "id": "meeting_001",
      "name": "那覇市内ホテルロビー",
      "address": "沖縄県那覇市...",
      "location": {
        "latitude": 26.2124,
        "longitude": 127.6792
      },
      "meetingTime": "08:30",
      "accessInformation": "開始10分前までにお越しください。"
    }
  ]
}
```

***

## 2.7 在庫・利用可能日

ここは旅行予約APIで最重要の領域です。

### 画面上の要件

カレンダーの日付に以下の状態を表示します。

- 残りわずか
- 売り切れ
- 催行なし

### API

```http
GET /v1/plans/{planId}/availability
```

例：

```http
GET /v1/plans/plan_001/availability
  ?from=2026-11-01
  &to=2026-12-31
  &timezone=Asia%2FTokyo
```

### レスポンス

```json
{
  "planId": "plan_001",
  "items": [
    {
      "date": "2026-11-20",
      "status": "available",
      "remainingCapacity": 12,
      "capacity": 20,
      "price": {
        "amount": 5800,
        "currency": "JPY"
      }
    },
    {
      "date": "2026-11-21",
      "status": "limited",
      "remainingCapacity": 2,
      "capacity": 20,
      "price": {
        "amount": 6800,
        "currency": "JPY"
      }
    },
    {
      "date": "2026-11-22",
      "status": "sold_out",
      "remainingCapacity": 0,
      "capacity": 20,
      "price": {
        "amount": 6800,
        "currency": "JPY"
      }
    },
    {
      "date": "2026-11-23",
      "status": "not_operating",
      "remainingCapacity": 0,
      "capacity": 0,
      "price": null
    }
  ]
}
```

### ステータス

```text
available
limited
sold_out
not_operating
closed
past
```

### `availability_slots`

- `id`
- `plan_id`
- `service_date`
- `start_time`
- `end_time`
- `capacity`
- `reserved_quantity`
- `held_quantity`
- `status`
- `price_snapshot`
- `booking_deadline_at`
- `created_at`
- `updated_at`

予約時に重要なのは、単に空き状況を取得することではありません。

```text
空き状況を表示
→ ユーザーが人数を選択
→ 予約作成
→ その間に他ユーザーが予約
```

この競合に対応する必要があります。

### 在庫確認API

```http
POST /v1/booking-quotes
```

```json
{
  "planId": "plan_001",
  "serviceDate": "2026-11-20",
  "participants": {
    "adult": 2,
    "child": 1
  },
  "meetingPointId": "meeting_001"
}
```

```json
{
  "quoteId": "quote_001",
  "expiresAt": "2026-10-07T15:10:00Z",
  "availability": "available",
  "items": [
    {
      "participantType": "adult",
      "quantity": 2,
      "unitPrice": 5800,
      "subtotal": 11600
    },
    {
      "participantType": "child",
      "quantity": 1,
      "unitPrice": 3000,
      "subtotal": 3000
    }
  ],
  "subtotal": 14600,
  "discount": 0,
  "tax": 1327,
  "total": 14600,
  "currency": "JPY"
}
```

`quote`を導入すると、料金や在庫の確認結果を短時間保持できます。

***

## 2.8 予約

### 予約画面

- 利用日選択
- プラン選択
- 利用者数
- 集合場所
- 料金
- クーポン
- 支払い方法
- 予約確定

### API

| Method | Endpoint | 用途 |
|---|---|---|
| POST | `/v1/booking-quotes` | 料金・在庫見積 |
| GET | `/v1/booking-quotes/{quoteId}` | 見積確認 |
| POST | `/v1/bookings` | 予約作成 |
| GET | `/v1/bookings` | 予約一覧 |
| GET | `/v1/bookings/{bookingId}` | 予約詳細 |
| PATCH | `/v1/bookings/{bookingId}` | 予約情報変更 |
| POST | `/v1/bookings/{bookingId}/cancel` | 予約キャンセル |
| GET | `/v1/bookings/{bookingId}/receipt` | 領収情報 |

### 予約作成

```http
POST /v1/bookings
Idempotency-Key: 2f2e0f2a-...
```

```json
{
  "quoteId": "quote_001",
  "customer": {
    "name": "山田 太郎",
    "email": "user@example.com",
    "phoneNumber": "09000000000"
  },
  "participants": [
    {
      "type": "adult",
      "quantity": 2
    },
    {
      "type": "child",
      "quantity": 1
    }
  ],
  "meetingPointId": "meeting_001",
  "paymentMethodId": "pm_001",
  "couponCode": "WELCOME10"
}
```

### 予約レスポンス

```json
{
  "id": "booking_001",
  "bookingNumber": "TRV-20261120-0001",
  "status": "confirmed",
  "activity": {
    "id": "act_001",
    "title": "沖縄の海を楽しむシュノーケリング体験"
  },
  "plan": {
    "id": "plan_001",
    "name": "半日シュノーケリングプラン"
  },
  "serviceDate": "2026-11-20",
  "total": {
    "amount": 14600,
    "currency": "JPY"
  },
  "cancelPolicy": {
    "freeCancellationUntil": "2026-11-18T23:59:59+09:00"
  },
  "createdAt": "2026-10-07T15:00:00Z"
}
```

### 予約ステータス

```text
pending
payment_required
confirmed
completed
cancel_requested
cancelled
failed
expired
```

### 予約作成で必須の設計

#### 冪等性

予約作成や決済は、通信失敗時にFlutterが再送する可能性があります。

同じリクエストで二重予約されないよう、`Idempotency-Key`を使います。冪等性キーによって、通信断後の再試行でも同じ結果を返せるようにします。 [djangoproject](https://djangoproject.in/blog/system-design-api-design/)

#### トランザクション

予約確定は以下を同一トランザクションで扱う必要があります。

```text
空き枠確認
→ 在庫減算
→ 予約作成
→ 予約参加者作成
→ 決済状態作成
```

実際の外部決済を使う場合は、データベーストランザクションと外部決済処理を分け、Webhookで最終状態を確定する設計が必要です。

***

## 2.9 予約一覧・予約履歴

### 画面上のタブ

- 参加予定
- 参加済み
- キャンセル済み
- その他

### API

```http
GET /v1/me/bookings?status=upcoming
GET /v1/me/bookings?status=completed
GET /v1/me/bookings?status=cancelled
GET /v1/me/bookings?status=other
```

または、より汎用的にします。

```http
GET /v1/bookings?status=confirmed&sort=service_date_asc
```

### レスポンス

```json
{
  "data": [
    {
      "id": "booking_001",
      "bookingNumber": "TRV-20261120-0001",
      "status": "confirmed",
      "serviceDate": "2026-11-20",
      "activity": {
        "id": "act_001",
        "title": "沖縄の海を楽しむシュノーケリング体験",
        "thumbnailUrl": "https://cdn.example.com/thumbnail.jpg"
      },
      "planName": "半日シュノーケリングプラン",
      "totalAmount": 14600
    }
  ],
  "pagination": {
    "nextCursor": null,
    "hasNext": false
  }
}
```

***

## 2.10 支払い・決済

今回の個人開発では、最初から実決済を組み込まなくても構いません。

ただし、API上は決済状態を持たせておくと、実サービスに近い設計になります。

### API

```http
GET /v1/payment-methods
POST /v1/payment-methods
DELETE /v1/payment-methods/{paymentMethodId}
POST /v1/bookings/{bookingId}/payments
GET /v1/payments/{paymentId}
```

### `payment_methods`

- `id`
- `user_id`
- `provider`
- `provider_customer_id`
- `provider_payment_method_id`
- `brand`
- `last4`
- `expiration_month`
- `expiration_year`
- `is_default`
- `created_at`

カード番号そのものは保存しません。決済サービスのトークンやPayment Method IDを保存します。

### `payments`

- `id`
- `booking_id`
- `user_id`
- `amount`
- `currency`
- `status`
- `provider`
- `provider_payment_id`
- `idempotency_key`
- `paid_at`
- `refunded_at`
- `created_at`
- `updated_at`

### 決済ステータス

```text
pending
requires_action
authorized
paid
failed
refunded
partially_refunded
```

***

## 2.11 お気に入り・保存リスト

### API

```http
GET /v1/me/favorites
POST /v1/me/favorites
DELETE /v1/me/favorites/{activityId}
```

### 登録

```json
POST /v1/me/favorites
{
  "activityId": "act_001"
}
```

### `favorites`

- `id`
- `user_id`
- `activity_id`
- `created_at`

データベースでは、次のユニーク制約を付けます。

```text
UNIQUE(user_id, activity_id)
```

これにより、同じアクティビティの二重登録を防げます。

***

## 2.12 最近チェックしたアクティビティ

ログイン前でも使える可能性があるため、設計を分けます。

### API

```http
GET /v1/me/recently-viewed
POST /v1/recently-viewed
DELETE /v1/me/recently-viewed/{activityId}
```

```json
POST /v1/recently-viewed
{
  "activityId": "act_001",
  "source": "search",
  "sessionId": "session_001"
}
```

### 設計方針

```text
ログイン前
→ device_id / anonymous_idで保持

ログイン後
→ user_idに紐付け

ログイン成功時
→ 匿名履歴をユーザー履歴へ統合
```

### `recently_viewed_activities`

- `id`
- `user_id`
- `anonymous_id`
- `activity_id`
- `viewed_at`
- `source`

同じ商品を複数回見たときにレコードを増やし続けるのか、`viewed_at`を更新するのかを決めます。最近見た一覧なら、後者のほうが扱いやすいです。

***

## 2.13 体験談・レビュー

### 画面上の要件

- 最新5つ星体験談
- アクティビティ詳細の体験談一覧
- 体験者の投稿写真
- 体験談投稿
- メニューの体験談一覧

### API

```http
GET /v1/activities/{activityId}/reviews
GET /v1/reviews/latest
GET /v1/me/reviews
POST /v1/bookings/{bookingId}/reviews
GET /v1/reviews/{reviewId}
PATCH /v1/reviews/{reviewId}
DELETE /v1/reviews/{reviewId}
```

### 投稿

```json
POST /v1/bookings/booking_001/reviews
{
  "rating": 5,
  "title": "とても楽しかったです",
  "body": "ガイドの説明がわかりやすく、初心者でも安心でした。",
  "photoIds": [
    "upload_001",
    "upload_002"
  ]
}
```

### `reviews`

- `id`
- `user_id`
- `booking_id`
- `activity_id`
- `plan_id`
- `rating`
- `title`
- `body`
- `status`
- `is_verified_purchase`
- `published_at`
- `created_at`
- `updated_at`
- `deleted_at`

### `review_photos`

- `id`
- `review_id`
- `url`
- `thumbnail_url`
- `sort_order`
- `moderation_status`
- `created_at`

`is_verified_purchase`を持たせると、実際に参加したユーザーのレビューであることを表示できます。

### レビューの状態

```text
draft
pending_moderation
published
rejected
hidden
```

投稿写真が100件以上ある画面では、必ずページングします。

```http
GET /v1/activities/act_001/review-photos?limit=30&cursor=...
```

***

## 2.14 会員情報

### API

```http
GET /v1/me
PATCH /v1/me
GET /v1/me/profile
PATCH /v1/me/profile
```

### 更新

```json
PATCH /v1/me
{
  "displayName": "山田 太郎",
  "phoneNumber": "09000000000",
  "birthDate": "1990-01-01"
}
```

### 更新時の注意

個人情報は項目ごとに更新可否を分けると安全です。

```text
表示名
電話番号
住所
生年月日
メールアドレス
```

メールアドレスや電話番号変更では、確認コードによる本人確認が必要になる場合があります。

***

## 2.15 メール・Push通知設定

### 画面上の要件

- メール配信確認・変更・停止
- Push通知配信確認・変更・停止
- Push通知カテゴリ化

### API

```http
GET /v1/me/notification-preferences
PATCH /v1/me/notification-preferences
POST /v1/me/devices
DELETE /v1/me/devices/{deviceId}
```

### レスポンス

```json
{
  "email": {
    "enabled": true,
    "categories": {
      "booking": true,
      "campaign": false,
      "review": true
    }
  },
  "push": {
    "enabled": true,
    "categories": {
      "booking": true,
      "before_trip": true,
      "during_trip": true,
      "campaign": false,
      "nearby": false
    }
  }
}
```

### `notification_preferences`

- `id`
- `user_id`
- `channel`
- `category`
- `enabled`
- `updated_at`

### `devices`

- `id`
- `user_id`
- `device_id`
- `platform`
- `push_token`
- `app_version`
- `os_version`
- `last_seen_at`
- `revoked_at`

`channel`：

```text
email
push
```

`category`：

```text
booking
payment
before_trip
during_trip
campaign
review
nearby
```

予約・決済などの重要通知は、ユーザーが停止できない必須通知として扱う場合があります。

```text
marketing通知
→ ユーザーが停止可能

予約・決済通知
→ 原則停止不可
```

***

## 2.16 マイエリア

### API

```http
GET /v1/me/areas
PUT /v1/me/areas
POST /v1/me/areas
DELETE /v1/me/areas/{areaId}
```

### `user_areas`

- `user_id`
- `area_id`
- `priority`
- `created_at`

マイエリアは、おすすめや通知のパーソナライズにも利用できます。

```text
マイエリア
→ ホームのおすすめ
→ エリア別通知
→ 人気アクティビティ
```

***

## 2.17 クーポン・ポイント

### クーポンAPI

```http
GET /v1/me/coupons
POST /v1/coupons/validate
POST /v1/me/coupons/{couponId}/claim
```

```json
POST /v1/coupons/validate
{
  "code": "WELCOME10",
  "activityId": "act_001",
  "planId": "plan_001",
  "serviceDate": "2026-11-20"
}
```

### `coupons`

- `id`
- `code`
- `name`
- `description`
- `discount_type`
- `discount_value`
- `minimum_amount`
- `maximum_discount`
- `starts_at`
- `ends_at`
- `usage_limit`
- `per_user_limit`
- `status`

### `user_coupons`

- `id`
- `user_id`
- `coupon_id`
- `claimed_at`
- `used_at`
- `booking_id`
- `status`

### ポイントAPI

```http
GET /v1/me/points
GET /v1/me/point-transactions
```

### `point_transactions`

- `id`
- `user_id`
- `type`
- `amount`
- `balance_after`
- `source_type`
- `source_id`
- `expires_at`
- `created_at`

`type`：

```text
grant
use
expire
refund
adjustment
```

ポイント残高は、履歴の合計だけで計算する方法と、残高テーブルを持つ方法があります。学習用なら履歴の整合性を重視し、本番寄りなら残高と履歴を併用します。

***

# 3. 予約ドメインの中心モデル

旅行予約APIの中心は、次の関係です。

```text
Area
  └── Activity
        └── Plan
              └── AvailabilitySlot
                    └── Booking
                          ├── BookingParticipants
                          ├── Payment
                          └── Review
```

より詳細にすると、次のようになります。

```text
User
 ├── Favorites ───────── Activity
 ├── RecentlyViewed ──── Activity
 ├── Bookings
 │     ├── BookingItems ─ Plan
 │     ├── Payment
 │     └── Review
 ├── NotificationPreferences
 ├── Devices
 ├── Coupons
 └── Points

Activity
 ├── Area
 ├── Category
 ├── Images
 ├── Plans
 ├── Reviews
 └── Favorites

Plan
 ├── Prices
 ├── Schedules
 ├── MeetingPoints
 └── AvailabilitySlots
```

***

# 4. 推奨API一覧

## P0：まず実装するAPI

```text
POST   /v1/auth/register
POST   /v1/auth/login
POST   /v1/auth/refresh
POST   /v1/auth/logout
GET    /v1/auth/me

GET    /v1/areas
GET    /v1/categories
GET    /v1/activities
GET    /v1/activities/{activityId}
GET    /v1/activities/{activityId}/plans
GET    /v1/plans/{planId}
GET    /v1/plans/{planId}/availability

POST   /v1/booking-quotes
GET    /v1/booking-quotes/{quoteId}
POST   /v1/bookings
GET    /v1/bookings
GET    /v1/bookings/{bookingId}
POST   /v1/bookings/{bookingId}/cancel
```

この範囲で、旅行予約の基本フローを完成させます。

## P1：アプリらしさを高めるAPI

```text
GET    /v1/home
GET    /v1/banners
GET    /v1/reviews/latest
GET    /v1/activities/{activityId}/reviews
GET    /v1/activities/{activityId}/review-photos

GET    /v1/me/favorites
POST   /v1/me/favorites
DELETE /v1/me/favorites/{activityId}

GET    /v1/me/recently-viewed
POST   /v1/recently-viewed

GET    /v1/me/notification-preferences
PATCH  /v1/me/notification-preferences
POST   /v1/me/devices
```

## P2：拡張機能

```text
GET    /v1/me/coupons
POST   /v1/coupons/validate
GET    /v1/me/points
GET    /v1/me/point-transactions
GET    /v1/me/areas
POST   /v1/me/reviews
GET    /v1/payment-methods
```

***

# 5. TypeScriptの型設計

Flutterとの契約を安定させるため、APIのレスポンス型を明示します。

```ts
export type ActivityStatus =
  | "draft"
  | "published"
  | "suspended"
  | "archived";

export type AvailabilityStatus =
  | "available"
  | "limited"
  | "sold_out"
  | "not_operating"
  | "closed"
  | "past";

export interface Money {
  amount: number;
  currency: string;
}

export interface RatingSummary {
  average: number;
  reviewCount: number;
}

export interface ActivitySummary {
  id: string;
  title: string;
  thumbnailUrl: string;
  startingPrice: Money;
  rating: RatingSummary;
  area: {
    id: string;
    name: string;
  };
}

export interface AvailabilitySlot {
  date: string;
  status: AvailabilityStatus;
  remainingCapacity: number;
  capacity: number;
  price: Money | null;
}
```

APIの状態値は、Flutter側とTypeScript側で同じ値を使うべきです。

```text
TypeScript: "sold_out"
Flutter:    AvailabilityStatus.soldOut
```

文字列を直接画面に表示せず、Flutter側で表示文言へ変換します。

```dart
String availabilityLabel(AvailabilityStatus status) {
  return switch (status) {
    AvailabilityStatus.available => '予約可能',
    AvailabilityStatus.limited => '残りわずか',
    AvailabilityStatus.soldOut => '売り切れ',
    AvailabilityStatus.notOperating => '催行なし',
  };
}
```

***

# 6. API共通仕様

## URL

```text
https://api.example.com/v1/activities
```

`/v1`のようなURLバージョニングにしておくと、将来の非互換変更に対応しやすくなります。 [djangoproject](https://djangoproject.in/blog/system-design-api-design/)

## 共通ヘッダー

```http
Authorization: Bearer <access-token>
Content-Type: application/json
Accept: application/json
X-Request-Id: request-uuid
```

予約や決済では追加します。

```http
Idempotency-Key: operation-uuid
```

## 共通レスポンス

```json
{
  "data": {},
  "meta": {}
}
```

一覧：

```json
{
  "data": [],
  "pagination": {
    "nextCursor": "...",
    "hasNext": true
  }
}
```

## 共通エラー

RFC 7807形式に近いエラー形式にすると、Flutter側で機械的に処理しやすくなります。

```json
{
  "type": "https://api.example.com/errors/availability-conflict",
  "title": "Availability Conflict",
  "status": 409,
  "code": "SLOT_NO_LONGER_AVAILABLE",
  "detail": "選択した利用日は予約できなくなりました。",
  "instance": "/v1/bookings",
  "errors": []
}
```

### 主なステータスコード

| Status | 用途 |
|---:|---|
| 200 | 取得・更新成功 |
| 201 | 作成成功 |
| 204 | 削除成功 |
| 400 | リクエスト形式不正 |
| 401 | 未認証・トークン不正 |
| 403 | 権限不足 |
| 404 | リソースなし |
| 409 | 在庫競合、重複 |
| 422 | 業務ルール違反 |
| 429 | レート制限 |
| 500 | サーバー内部エラー |

例えば、ログインしていない場合は401、ログイン済みだが他ユーザーの予約を見ようとした場合は403に分けます。

***

# 7. データベース設計の初期案

PostgreSQLを使う前提なら、最初のテーブルは次の構成がよいです。

## 認証・ユーザー

```text
users
social_accounts
refresh_tokens
devices
notification_preferences
```

## 商品

```text
areas
categories
activities
activity_images
plans
plan_prices
plan_schedules
meeting_points
```

## 在庫・予約

```text
availability_slots
booking_quotes
bookings
booking_participants
booking_items
payments
```

## ユーザー行動

```text
favorites
recently_viewed_activities
search_histories
```

## レビュー

```text
reviews
review_photos
```

## 販促

```text
banners
coupons
user_coupons
point_accounts
point_transactions
```

## 計測

```text
analytics_events
```

***

# 8. 計測APIも最初から設計する

今回の方針では、機能追加と計測を切り離さないことが重要です。

### API

```http
POST /v1/analytics/events
```

```json
{
  "events": [
    {
      "name": "activity_detail_viewed",
      "occurredAt": "2026-10-07T15:00:00Z",
      "anonymousId": "anon_001",
      "sessionId": "session_001",
      "properties": {
        "activityId": "act_001",
        "source": "search",
        "position": 3
      }
    }
  ]
}
```

### 主要イベント

```text
app_opened
home_viewed
search_started
search_completed
activity_card_tapped
activity_detail_viewed
plan_selected
availability_viewed
booking_quote_created
booking_started
booking_completed
booking_cancelled
favorite_added
favorite_removed
review_submitted
push_permission_granted
push_opened
coupon_applied
```

特に予約ファネルは、次のように追えるようにします。

```text
activity_detail_viewed
→ plan_selected
→ availability_viewed
→ booking_started
→ payment_started
→ booking_completed
```

これにより、どこでユーザーが離脱しているかを確認できます。

***

# 9. 個人開発での実装順序

## フェーズ1：ドメインの核

1. PostgreSQLのスキーマ作成
2. `users`
3. `areas`
4. `categories`
5. `activities`
6. `plans`
7. `availability_slots`
8. `bookings`
9. `booking_participants`
10. Flutterから検索・詳細・予約を接続

この段階で次を完成させます。

```text
ログイン
→ 検索
→ 詳細
→ 日付選択
→ 人数選択
→ 予約作成
→ 予約一覧
```

## フェーズ2：本番らしい体験

1. お気に入り
2. 最近見た商品
3. レビュー
4. 投稿写真
5. バナー
6. ホーム画面API
7. 通知設定
8. デバイス登録

## フェーズ3：難易度の高い領域

1. 在庫競合
2. 予約の冪等性
3. クーポン
4. ポイント
5. 実決済
6. 外部ログイン
7. APIイベント計測
8. 運用管理API

***

# 10. 参画前に特に深めるべきドメイン知識

今回の準備で、次の5つを重点的に理解すると、参画後に改善提案しやすくなります。

### 1. 商品とプランの違い

```text
アクティビティ = 商品全体
プラン = 予約可能な具体的なコース
```

### 2. 料金と在庫の分離

```text
料金 = いくらか
在庫 = いつ、何人予約できるか
```

料金と在庫を同じテーブルに詰め込むと、繁忙期料金や人数別料金に対応しづらくなります。

### 3. 予約と決済の分離

```text
予約状態
決済状態
在庫状態
```

これらは別々に変化するため、一つの`status`で管理しないほうが安全です。

### 4. 表示用APIとドメインAPIの分離

```text
ドメインAPI：
GET /activities
GET /plans
GET /availability

画面API：
GET /home
GET /activity-detail
```

Flutterの画面表示を高速化するためのレスポンスと、ドメインとして再利用するAPIを分ける考え方です。

### 5. 計測イベントをドメインの一部として扱う

```text
検索した
詳細を見た
プランを選んだ
予約を開始した
予約が完了した
```

これらのイベントがあると、リリース後に改善案をデータで説明できます。

***

## 最初に作るべきAPIの完成形

最初の目標は、以下のAPIをOpenAPIで定義し、Flutterから実際に呼び出すことです。

```text
POST /v1/auth/register
POST /v1/auth/login
GET  /v1/areas
GET  /v1/categories
GET  /v1/activities
GET  /v1/activities/{activityId}
GET  /v1/activities/{activityId}/plans
GET  /v1/plans/{planId}/availability
POST /v1/booking-quotes
POST /v1/bookings
GET  /v1/bookings
GET  /v1/bookings/{bookingId}
POST /v1/bookings/{bookingId}/cancel
```

この最小構成を作ったうえで、次にお気に入り、レビュー、通知、クーポンを追加してください。

最も学習効果が高いのは、画面を増やすことではなく、**検索から予約完了までの業務フローを、API・DB・Flutterの3層で最後まで実装すること**です。


---

# ユーザー要求2
以下aを理解して。aを実現するためのAPI開発（typescript）を行いたい。私はtypescriptでのAPI開発経験が浅く、過去にフリマ型マーケットプレイスのAPI開発を行った。b配下のroadmap.mdをもとにphaseごとにmarkdownファイルを作成し学習をした。
aを実現するためのAPI開発にあたり、bほど1から細かくしなくて良い（学習目的に偏りすぎなくて良い）のでが、最小限の工数でAPI開発を進めたい。a, bを理解した上で方針を立てて。bのようにroadmap.mdをもとに進めていくのが良いか、それともあらかた　学習用の説明は省きつつ、APIを開発していくスタイルにするか。私は後者の方が良いと思う。現在のtravel_appはモバイルアプリ（flutter用）の開発ディレクトリのため、API用に別のディレクトリを作成し、そこで開発していくのが良さそう（実際の開発現場でもgithubリポジトリがモバイルチームとバックエンドチームで分かれているため）
```a
/travel_app/docs/idea/web_api_development_overview.md
```
```b
/market-api/api/docs
```

---

# 方針（ユーザー要求2への回答）
スタイル：後者（ビルド優先）採用

b は「概念説明 → TODO」の学習フォーマット。今回は TODO チェックリスト中心の roadmap.md 1ファイル のみ作成し、phase詳細ファイルは原則作らない。

技術スタック
```markdown
| 項目           | 採用                           | b との差分                                                     |
|----------------|--------------------------------|----------------------------------------------------------------|
| Runtime        | Node.js + TypeScript + Express | 同じ（慣れた構成）                                             |
| DB             | PostgreSQL                     | MySQL → PostgreSQL（a の推奨・旅行予約ドメイン向け）           |
| ORM            | Prisma                         | SQL手書き → Prisma（マイグレーション・型生成が自動化 → 工数削減） |
| 認証           | JWT                            | 同じ                                                           |
| バリデーション | Zod                            | 同じ                                                           |
```

Prisma採用の理由：bはSQL学習目的で手書きだったが、今回はドメイン知識習得が目的 → スキーマ管理を自動化して実装速度優先。

ディレクトリ: /travel-api/

bと同じ親ディレクトリ配下。gitリポジトリも独立させる。

フェーズ構成（5フェーズ）

Phase 1: 環境構築 + Prismaセットアップ + コアDB
Phase 2: 認証 (register/login/refresh/me)
Phase 3: アクティビティ・エリア・カテゴリ（一覧・詳細・検索）
Phase 4: プラン・在庫・予約フロー（quotes → bookings）← ドメイン中核
Phase 5: P1機能（favorites / reviews / home API）

P2（クーポン・ポイント・ソーシャルログイン）はフェーズ外で別途。

トレードオフ：Prismaは複雑なJOINやロック（SELECT FOR UPDATE）が書きにくい場面がある。在庫競合処理（Phase 4）では $executeRaw を使うことになる。それで問題なければこの方針で roadmap.md を作成する。方向性を確認してから着手する。

---