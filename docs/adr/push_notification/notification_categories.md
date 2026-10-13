# Push通知カテゴリ定義

## 基本原則：イベント送信と通知手段の分離

このドキュメントで定義するカテゴリ・イベントは「**Brazeへ送るデータ・イベントのグルーピング**」であり、「全イベントがPush通知につながる」わけではない。

```
Flutter → Braze へイベント・属性を送信（トラッキング層）
              ↓
         Braze がキャンペーン設定に基づいて判断
              ↓
    Push通知 / In-App Message / アナリティクスのみ（何も送らない）
```

Brazeへ送信する目的は以下3つに分類される。Push通知はその一手段に過ぎない。

| 送信目的 | 内容 | 例 |
|---|---|---|
| **Push通知トリガー** | ユーザーがアプリ外にいる可能性が高い非同期・サーバー起因イベント | `booking_cancelled_by_operator`・`payment_completed`（非同期決済） |
| **属性更新** | Brazeのユーザープロフィールを更新し、以降の配信判断に使う | `calendar_registered`・`checkin_completed`（完了によりリマインドを停止） |
| **アナリティクス** | セグメント分析・効果測定・重複排除のための状態記録 | `booking_confirmed`（即時確定）・`offline_mode_entered`（復帰後遅延送信） |

Push通知かIn-App Messageかアナリティクスのみかは、Brazeのキャンペーン設計で決定する。Flutter側はイベント・属性を正確に送ることに責任を持つ。

---

## 採用フェーズ

初期リリースは **Phase 1 の4カテゴリ** に絞る。`local_info`・`engagement` は依存機能（位置情報・レビュー）が揃った段階で追加する。

| カテゴリID | カテゴリ名 | 採用フェーズ |
|---|---|---|
| `booking_transaction` | 予約・決済 | Phase 1 |
| `trip_preparation` | 出発準備 | Phase 1 |
| `trip_support` | 旅行中サポート | Phase 1 |
| `marketing_offer` | お得情報・キャンペーン | Phase 1 |
| `local_info` | 周辺・現地情報 | Phase 2（位置情報機能追加後） |
| `engagement` | レビュー・履歴・次回提案 | Phase 2（レビュー機能追加後） |

---

## カテゴリ比較一覧

| カテゴリID | 目的 | 初期値 | ユーザー変更 | 頻度上限 | 重複排除キー | タイムゾーン |
|---|---|---|---|---|---|---|
| `booking_transaction` | 予約確定・決済・変更・キャンセルなど取引上必須の通知 | ON | 不可（OS権限のみ） | イベント駆動・上限なし | `booking_id + event_type` | 予約者の設定TZ |
| `trip_preparation` | カレンダー登録・チェックイン・持ち物・出発前リマインド | ON | 可 | 旅行あたり3〜5件 | `booking_id + reminder_type + scheduled_at` | ユーザーTZ |
| `trip_support` | 出発・到着・日程・オフライン表示・緊急情報 | ON | 一部可（緊急は不可） | 1日2〜3件（緊急除く） | `booking_id + event_key + day` | 現地TZ（`travel_timezone`） |
| `marketing_offer` | 割引・次回予約促進・限定プラン | OFF | 可 | 週2件 | `campaign_id + user_id` | ユーザーTZ |
| `local_info` | 現在地近くの観光・飲食・天候・交通情報 | OFF | 可 | 1日1件 | `place_id + user_id + date` | 現地TZ |
| `engagement` | レビュー依頼・利用履歴・リピート提案 | ON | 可 | 旅行後30日で1〜2件 | `booking_id + action_type` | ユーザーTZ |

---

## Phase 1 カテゴリ詳細

### `booking_transaction`（予約・決済）

| 項目 | 値 |
|---|---|
| **目的** | 予約確定・決済完了・変更・キャンセルなど、取引上必須の通知 |
| **初期値** | ON |
| **ユーザー変更** | 不可（OS通知権限のみ） |
| **頻度上限** | イベント駆動・上限なし |
| **重複排除キー** | `booking_id + event_type` |
| **Androidチャンネル重要度** | HIGH |

**抑制条件**

| 条件 | 内容 |
|---|---|
| 通知権限OFF | OS権限がない場合は送信不可（制御不能） |
| キャンセル完了後 | キャンセル完了通知のみ送信し、以降の予約系通知を停止 |

**送信イベント**

| イベント | 起因 | タイミング | 送信目的 |
|---|---|---|---|
| `booking_confirmed` | ユーザー / サーバー | 予約確定直後 | 即時確定→アナリティクス、手動承認→Push通知トリガー候補 |
| `payment_completed` | サーバー | 決済成功後 | Push通知トリガー候補（非同期決済の場合） |
| `booking_cancelled_by_user` | ユーザー | ユーザー自身がキャンセル操作を完了した直後 | 属性更新（アプリ内UIで完結・Push不要） |
| `booking_cancelled_by_operator` | サーバー | 事業者・システム都合によるキャンセル発生時 | Push通知トリガー |

`booking_cancelled` をユーザー都合・事業者都合で分離している理由は、起因によって送信目的と通知手段が異なるため（下記参照）。

**通知手段の使い分け**

`booking_transaction` のイベントは、発火タイミングが同期か非同期かによって適切な通知手段が変わる。Push通知が必要なのは非同期・サーバー起因のイベントに限られる。

| パターン | 具体例 | 通知手段 |
|---|---|---|
| ユーザー操作の直後に同期完了 | 即時決済成功・即時予約確定・`booking_cancelled_by_user` | アプリ内UI（完了画面・バナー） |
| 非同期完了・サーバー起因 | 手動承認型の予約確定・非同期決済・`booking_cancelled_by_operator`・返金処理 | Push通知 |

`booking_cancelled_by_user` はユーザー自身がアプリ内で操作した結果のため、完了画面でのアプリ内UIで十分。Push通知は不要（自分で操作したことを改めて通知する意味がない）。`booking_cancelled_by_operator` はユーザーが関知しない外部起因のため、Push通知が必要。

「ユーザー変更不可」の制約はPush通知にのみ適用される。アプリ内UIにはOS権限・ユーザー設定の概念がないため、同期完了イベントをアプリ内UIで完結させる場合はこの制約は不要になる。

各イベントが同期・非同期のどちらに該当するかはサーバー側の仕様次第であり、BRAZE-020（予約・決済イベント実装）の前に確認が必要。

---

### `trip_preparation`（出発準備）

| 項目 | 値 |
|---|---|
| **目的** | カレンダー登録案内・チェックイン・持ち物・出発前リマインド |
| **初期値** | ON |
| **ユーザー変更** | 可 |
| **頻度上限** | 旅行あたり3〜5件 |
| **重複排除キー** | `booking_id + reminder_type + scheduled_at` |
| **Androidチャンネル重要度** | DEFAULT |

**抑制条件**

| 条件 | 内容 |
|---|---|
| カレンダー登録済み | カレンダー登録案内を停止 |
| 出発済み | 出発日以降すべて停止 |
| キャンセル済み | 全予約関連ジョブを停止 |
| 深夜帯（22:00〜7:00） | ユーザーTZで判定し送信しない |

**送信イベント**

| イベント | タイミング | 送信目的 |
|---|---|---|
| `calendar_register_prompt_shown` | 出発7日前・カレンダー未登録時 | アナリティクス（重複案内防止・表示回数管理） |
| `calendar_registered` | カレンダー登録完了後 | 属性更新（以降のカレンダー案内Pushを停止させる） |
| `checkin_completed` | チェックイン完了後 | 属性更新（以降のチェックイン期限Push停止） |
| `trip_starting_soon` | 出発前日 | Push通知トリガー候補 |

---

### `trip_support`（旅行中サポート）

| 項目 | 値 |
|---|---|
| **目的** | 出発・到着・日程・オフライン表示・緊急情報 |
| **初期値** | ON |
| **ユーザー変更** | 一部可（緊急情報は変更不可） |
| **頻度上限** | 1日2〜3件（緊急除く） |
| **重複排除キー** | `booking_id + event_key + day` |
| **Androidチャンネル重要度** | DEFAULT（緊急はHIGH） |

**抑制条件**

| 条件 | 内容 |
|---|---|
| 旅行期間外 | `travel_start_at` 前・`travel_end_at` から24時間後に自動停止 |
| キャンセル済み | 旅行中サポートを停止 |

**送信イベント**

| イベント | タイミング | 送信目的 |
|---|---|---|
| `trip_started` | 出発日または初回チェックイン後 | 属性更新（旅マエPushを停止・旅ナカセグメントへ切替） |
| `offline_mode_entered` | 接続復帰後に遅延送信（※下記補足参照） | アナリティクス（Push不可・アプリ内UIで完結） |
| `trip_completed` | `travel_end_at` 経過後または完了操作時 | 属性更新（旅ナカPushを停止・旅アトセグメントへ切替） |

**`offline_mode_entered` の設計補足**

デバイスがオフラインになると Braze へのイベント送信も Push通知の受信も両方できない。「オフラインになった瞬間に Push で案内する」は技術的に不可能なため、以下3つの役割に分けて扱う。

| 役割 | 実現方法 |
|---|---|
| オフライン中のUI案内 | Push通知ではなく**アプリ内UI**（バナー・ダイアログ）で完結 |
| オフライン体験のアナリティクス | 接続**復帰後**にローカルキューからBrazeへ遅延送信 |
| 予防的なオフライン対策の案内 | オンライン時に**事前Push**（出発前日・旅行開始直後に `offline_map_downloaded = false` のユーザーへ） |

```
接続断を検知
  → アプリ内UI: 「オフライン中です。保存済みマップが使えます」
  → キャッシュデータ・オフラインマップへ自動切り替え
  → Brazeイベントはローカルキューに保存（送信保留）
接続復帰
  → ローカルキューのイベントをBrazeへ遅延送信（アナリティクス目的のみ）
```

---

### `marketing_offer`（お得情報・キャンペーン）

| 項目 | 値 |
|---|---|
| **目的** | 割引・次回予約促進・限定プラン |
| **初期値** | OFF |
| **ユーザー変更** | 可 |
| **頻度上限** | 週2件 |
| **重複排除キー** | `campaign_id + user_id` |
| **Androidチャンネル重要度** | LOW |

**抑制条件**

| 条件 | 内容 |
|---|---|
| マーケ同意未取得 | `marketing_consent = false` の場合は送信しない（OS権限とは独立して管理） |
| クールダウン中 | 直近7日以内に同カテゴリ送信済みの場合は抑制 |
| 直近予約者 | 予約確定〜出発前のユーザーへの重複施策を抑制 |

**同意フロー上の注意点**

- OS Push権限とは別に、アプリ内でマーケティング通知への明示同意（`marketing_consent`）を取得する
- Apple HIG・Brazeガイドラインに従い、オプトアウト手段を常に提供する
- iOSのネイティブ権限ダイアログは初回1回限りのため、価値が伝わるタイミング（予約後など）で要求する

---

## Phase 2 カテゴリ詳細（追加予定）

### `local_info`（周辺・現地情報）

位置情報権限の取得と現地データの供給元が整ってから追加する。位置情報権限がない場合は一般現地情報へフォールバックする設計とする。

| 項目 | 値 |
|---|---|
| **初期値** | OFF |
| **抑制条件** | 位置情報権限OFF・旅行期間外・夜間 |
| **頻度上限** | 1日1件 |

### `engagement`（レビュー・履歴・次回提案）

レビュー機能・レコメンドデータが揃ってから追加する。1予約あたりレビュー依頼1回を上限とする重複排除が前提。

| 項目 | 値 |
|---|---|
| **初期値** | ON |
| **抑制条件** | レビュー済み・旅行終了前・直近送信済み |
| **頻度上限** | 旅行後30日で1〜2件 |

---

## Brazeへ送るデータスキーマ

Flutter側の役割は「状態・イベント・属性を送り、通知タップ後の遷移を実装する」こと。配信対象やタイミングの判断はBraze側のキャンペーン設計で行う。

### ユーザー属性

| 値 | 内容 | 主な使われ方 |
|---|---|---|
| `user_id` | ログイン済みユーザーを一意に識別するID | ユーザー設定・予約履歴・通知履歴などを紐づける。Brazeでのユーザー識別に使う |
| `anonymous_id` | 未ログイン状態でも端末単位で一意にするID | Web-to-App流入直後やゲスト利用時の行動保持。ログイン後に `user_id` へ紐づける |
| `push_permission_status` | OSレベルのPush通知権限状態。`not_determined` / `granted` / `denied` / `provisional` | Push配信可否の判定。`denied` ならアプリ内メッセージや設定案内へ切り替え |
| `marketing_consent` | マーケティング通知の同意状態。`granted` / `denied` / `not_requested` | `marketing_offer` カテゴリの配信可否を判定する。取引系通知とは分離して管理 |
| `notification_preferences` | カテゴリ別の通知ON/OFF設定 | ユーザーがアプリ内で選択したカテゴリ別設定を反映し、不要な通知を抑制 |
| `timezone` | ユーザーのタイムゾーン。例: `Asia/Tokyo` | 出発前リマインド・レビュー依頼・キャンペーン配信時間をユーザーの現地時間に合わせる |
| `locale` / `language` | 端末またはユーザー設定の言語・地域。例: `ja-JP` | 通知文・アプリ内文言・日付表記の切り替え |
| `location_permission` | 位置情報権限の状態。`granted` / `denied` / `restricted` | 周辺情報・現在地ベースの案内を出すかを判定。未許可なら一般現地情報へフォールバック |
| `last_active_at` | 最後にアプリを利用した日時 | 休眠ユーザーの検知・再エンゲージメント施策・通知頻度の調整 |

### 予約・旅行状態

| 値 | 内容 | 主な使われ方 |
|---|---|---|
| `booking_id` | 1件の予約を一意に識別するID | 予約確定・変更・キャンセル・出発前リマインド・レビュー依頼を予約単位で管理 |
| `booking_status` | 予約状態。`pending` / `confirmed` / `cancelled` / `completed` | 予約確定通知・キャンセル時の通知停止・旅行終了後のレビュー依頼開始などを制御 |
| `payment_status` | 決済状態。`unpaid` / `paid` / `failed` / `refunded` | 決済完了・支払い期限・返金完了などの通知を出す |
| `travel_start_at` | 旅行開始日時 | 出発前リマインド・カレンダー登録・チェックリストの表示タイミングを計算 |
| `travel_end_at` | 旅行終了日時 | 旅ナカ機能の終了・レビュー依頼の開始・周辺情報通知の停止を判定 |
| `travel_timezone` | 旅行先のタイムゾーン。例: `America/Los_Angeles` | 現地時刻での集合時刻・現地情報通知を正しく表示 |
| `days_until_departure` | 出発日までの日数 | 「7日前ならカレンダー登録」「3日前ならチェックイン」など状態別の準備案内を出し分け |
| `calendar_registered` | 旅行予定を端末カレンダーへ登録済みか | 未登録のときだけカレンダー登録案内を送る |
| `checkin_status` | チェックイン状態。`not_required` / `pending` / `completed` / `expired` | 期限前にチェックイン案内を送り、完了後は通知を止める |
| `departure_location` | 出発地（空港・駅・集合場所などの名称や座標） | 出発前日の集合案内・経路案内・地図表示 |

### 行動・機能状態

| 値 | 内容 | 主な使われ方 |
|---|---|---|
| `viewed_plan_ids` | ユーザーが閲覧したプランのID一覧 | 値下げ・残席通知の対象判定 |
| `last_viewed_plan_id` | 最後に閲覧したプランのID | Web-to-App流入時の「続きから見られます」表示 |
| `offline_map_downloaded` | 対象地域のオフラインマップをダウンロード済みか | 出発前・旅行開始直後にダウンロード案内を出す（済みなら案内を止める） |
| `offline_mode_detected` | 端末がオフライン状態と判定されたか | アプリ内オフラインUI切り替え。接続復帰後にBrazeへ遅延送信 |
| `review_status` | レビュー状態。`not_requested` / `requested` / `submitted` / `skipped` | 旅行終了後のレビュー依頼を送るか・再依頼するか・依頼を止めるかを判定 |
| `trip_completed_at` | 旅行完了日時 | レビュー依頼・次回提案などの開始条件 |
| `marketing_consent` | マーケティング通知への同意状態 | `marketing_offer` の配信可否判定（OS権限とは独立） |
| `web_to_app_source` | Webからアプリへの流入元。例: `web_plan_detail` / `qr` / `email` | Web-to-App導線の計測・流入元に応じた初回表示の制御 |

### 通知イベント

| イベント | 内容 | カテゴリ |
|---|---|---|
| `booking_confirmed` | 予約が確定したことを示すイベント | `booking_transaction` |
| `payment_completed` | 決済が完了したことを示すイベント | `booking_transaction` |
| `booking_cancelled` | 予約がキャンセルされたことを示すイベント | `booking_transaction` |
| `calendar_register_prompt_shown` | カレンダー登録案内を表示したことを示すイベント | `trip_preparation` |
| `calendar_registered` | カレンダー登録が完了したことを示すイベント | `trip_preparation` |
| `checkin_completed` | チェックインが完了したことを示すイベント | `trip_preparation` |
| `trip_starting_soon` | 出発前日になったことを示すイベント | `trip_preparation` |
| `trip_started` | 旅行が開始したことを示すイベント | `trip_support` |
| `offline_mode_entered` | オフライン状態に入ったことを示すイベント（接続復帰後に遅延送信） | `trip_support` |
| `trip_completed` | 旅行が完了したことを示すイベント | `trip_support` |
| `notification_opened` | 通知がタップされアプリが開かれたことを示すイベント | 全カテゴリ |
| `notification_opt_out_changed` | ユーザーが通知設定または権限を変更したことを示すイベント | 全カテゴリ |

---

## ユーザー状態 × 通知対応表

| 旅行ライフサイクル | ユーザー状態 | カテゴリ | 通知例 | アプリ側が取得・送信する値 |
|---|---|---|---|---|
| 予約前 | 閲覧履歴あり・未予約 | `marketing_offer` | 閲覧プランの値下げ・残席通知 | `viewed_plan_ids`、`last_viewed_at`、`price`、`availability` |
| 予約前 | Push権限未許可 | 全カテゴリ | アプリ内で権限案内 | `push_permission_status`、権限案内表示回数 |
| 予約後 | 予約確定直後 | `booking_transaction` | 予約確定・決済完了 | `booking_id`、`booking_status`、`payment_status`、`travel_start_at`、`travel_end_at` |
| 予約後 | 出発7日前・カレンダー未登録 | `trip_preparation` | カレンダー登録案内 | `booking_id`、`calendar_registered`、`days_until_departure` |
| 予約後 | 出発3日前・チェックイン未完了 | `trip_preparation` | チェックイン・必要情報入力案内 | `checkin_status`、`required_fields_missing`、`deadline_at` |
| 予約後 | 出発前日 | `trip_preparation` | 出発時刻・持ち物・予約内容確認 | `departure_at`、`departure_location`、`booking_summary`、`timezone` |
| 旅行中 | 出発当日・移動中 | `trip_support` | 出発リマインド・遅延・変更 | `flight_or_transport_status`、`delay_minutes`、`current_itinerary` |
| 旅行中 | オフライン検知 | `trip_support` | **アプリ内UI**でオフラインマップ案内（Push不可） | `network_status`、`offline_map_available`、`my_map_last_synced_at` |
| 旅行後 | 旅行終了直後・未レビュー | `engagement` | レビュー依頼 | `trip_completed_at`、`review_status`、`booking_id` |
| 旅行後 | 一定日数経過・次回候補あり | `marketing_offer` | 次回旅行提案 | `past_destinations`、`preferred_tags`、`recommendation_ids`、`marketing_consent` |

---

## タイムゾーン方針

| カテゴリ | 基準TZ | 理由 |
|---|---|---|
| `booking_transaction` | 予約者の設定TZ | 決済・確定通知はユーザーの現地時刻が基準 |
| `trip_preparation` | ユーザーTZ | 出発前の行動はユーザーの生活時間に合わせる |
| `trip_support` | 現地TZ（`travel_timezone`） | 旅行中は現地時刻での案内が正確 |
| `marketing_offer` | ユーザーTZ | マーケ配信はユーザーの生活時間に合わせる |
| `local_info` | 現地TZ | 周辺情報・営業時間は現地基準 |
| `engagement` | ユーザーTZ | レビュー依頼・次回提案はユーザーの生活時間に合わせる |

---

## 実装上の重要ルール

- **取引系はユーザー設定でOFFにしない**: 予約確定・キャンセル・決済は信頼性のため変更不可とする。Androidでも取引系とプロモーション系の分離が推奨される
- **マーケ系は二重同意**: OSのPush許可に加えて、アプリ内のマーケ通知同意（`marketing_consent`）を持たせる。Appleもプロモーションには明示同意を求めている
- **重複排除キーを必ず持つ**: 同じ予約・同じ種別・同時刻の通知を二重送信しない仕組みをBraze側で持つ
- **タイムゾーンは目的別に分ける**: 出発前はユーザーTZ、現地情報は現地TZ、レビュー依頼はユーザーTZ
- **通知本文に機微情報を入れない**: 予約番号全文・決済金額・住所などをロック画面に表示しない。Appleも通知に機微情報を含めないよう推奨している
- **キャンセル時は状態を即時無効化**: `booking_status = cancelled` を送信し、出発準備・旅行中サポートのスケジュール配信をすべて停止する
- **旅行終了後はカテゴリを切り替える**: `trip_support` と `local_info` を停止し、`engagement` または `marketing_offer` へ引き継ぐ
