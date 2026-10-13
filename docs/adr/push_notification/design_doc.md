今回のデザインドックは「**Brazeへ送るユーザー属性・カスタムイベントを、どの画面・どのタイミングで送るか**」を中心に定義するのが適切です。Brazeは通知の送信・セグメント判定を担い、Flutterは権限取得、ユーザー識別、属性・イベント送信、通知タップ後の画面遷移を担います。

## デザインドック案

### 1. タスクの目的

**目的**: 旅行予約アプリにおいて、Push通知を「旅マエ・旅ナカ・旅アト」のユーザー状態に応じて適切なカテゴリで配信できる基盤を、BrazeとFlutterの連携により整備する。

**スコープ**:

- Braze Flutter SDKの導入と初期化
- Push通知権限の取得とトークン登録
- 通知カテゴリごとのユーザー設定の管理
- 画面・アクションに応じたBraze属性・カスタムイベントの送信
- 通知タップ時のディープリンク遷移
- 通知カテゴリ別の重複排除・抑制に必要な状態送信

**スコープ外**:

- Brazeダッシュボードでのキャンペーン作成・配信運用
- 通知文面・配信時間・セグメントの最終決定
- サーバー側の予約データ設計、API実装
- 位置情報の常時トラッキング

Brazeの統合では、ユーザー識別、属性、カスタムイベント、データ送信の設計を事前に揃えることが推奨されています。

### 2. 設計・実装方針

#### 基本方針

- **Brazeへ送るデータは「通知判断に必要な最小限」にする**
- **取引系とマーケ系の同意・設定を分離する**
- **ユーザー状態はイベント駆動で送信し、画面表示ごとの過剰送信を避ける**
- **通知タップ後の遷移先は`deep_link`で統一する**
- **カテゴリは最初は4つに絞る**: `booking_transaction`、`trip_preparation`、`trip_support`、`marketing_offer`

#### BrazeとFlutterの責務分離

| 担当 | 責務 |
| --- | --- |
| Flutter | SDK初期化、Push権限要求、ユーザーID設定、属性・イベント送信、通知受信、タップ後遷移、通知設定UI |
| Braze | ユーザープロフィール管理、セグメント作成、キャンペーン配信、配信履歴、A/Bテスト |
| バックエンド | 予約状態・決済状態・旅行日程などの正となるデータ管理、必要に応じたサーバー起因イベント |
| マーケ・運用 | カテゴリ別キャンペーン設計、配信タイミング、文面、効果測定 |

Brazeでは、Push権限の明示的な取得が必要であり、iOSではユーザーが許可するまで通常のPushは有効になりません。Android 13以降もPush権限の要求・許可が必要です。

### 3. 画面・タイミング別の取得・送信設計

| 画面 / 状態 | タイミング | 取得するデータ | Brazeへ送るデータ | 目的 |
| --- | --- | --- | --- | --- |
| アプリ起動 | アプリ起動時、またはログイン復帰時 | `push_permission_status`、`locale`、`timezone`、`anonymous_id` | `push_permission_status`、`locale`、`timezone` | Push可否と言語・時刻の判定 |
| ログイン成功 | 認証成功直後 | `user_id`、未ログイン時の`anonymous_id` | `changeUser(user_id)`、`anonymous_id`の紐づけ | ゲスト期間の行動をユーザーに統合 |
| Web-to-App遷移 | アプリ初回起動、ディープリンク解析後 | `web_to_app_source`、`last_viewed_plan_id`、`campaign_id` | `web_to_app_source`、`last_viewed_plan_id` | Web経由の流入計測と「続きから」表示 |
| プラン詳細 | プラン閲覧時 | `plan_id`、`destination`、`price`、閲覧日時 | `plan_viewed`イベント、`last_viewed_plan_id` | 閲覧履歴・リターゲティングの基礎データ |
| プラン保存 | 「あとで見る」押下時 | `plan_id`、保存状態 | `plan_saved`イベント、`saved_plan_ids` | 比較・再訪・値下げ通知の対象管理 |
| 予約確定 | 予約完了画面表示時 | `booking_id`、`booking_status`、`travel_start_at`、`travel_end_at`、`travel_timezone` | `booking_confirmed`イベント、予約属性 | 予約確定通知、出発前リマインドの起点 |
| 決済完了 | 決済成功コールバック後 | `booking_id`、`payment_status` | `payment_completed`イベント、`payment_status` | 決済完了通知、支払い状態の管理 |
| 予約キャンセル | キャンセル完了時 | `booking_id`、`cancellation_reason` | `booking_cancelled`イベント、`booking_status` | キャンセル通知と、以降の予約関連通知停止 |
| ホーム / 予約詳細 | 予約後、出発日までの日数判定時 | `days_until_departure`、`calendar_registered`、`checkin_status` | `days_until_departure`、`calendar_registered`、`checkin_status` | 出発前リマインドの配信対象判定 |
| カレンダー登録案内 | 出発7日前、未登録の場合 | `booking_id`、`calendar_registered` | `calendar_register_prompt_shown`イベント | 同一案内の重複防止と効果測定 |
| カレンダー登録完了 | OSカレンダー登録成功後 | `booking_id` | `calendar_registered`イベント、`calendar_registered=true` | 以降のカレンダー案内を停止 |
| チェックイン完了 | チェックイン成功後 | `booking_id`、`checkin_status` | `checkin_completed`イベント、`checkin_status` | チェックイン期限通知の停止 |
| 出発前日 | 出発前日になった時点 | `booking_id`、`departure_location`、`departure_at` | `trip_starting_soon`イベント | 予約内容確認・持ち物・集合案内の配信対象化 |
| 旅行開始 | 出発日または初回チェックイン後 | `booking_id`、`trip_status` | `trip_started`イベント | 旅マエ通知を停止し、旅ナカ通知へ切替 |
| 旅ナカホーム | 旅行期間中のアプリ起動時 | `booking_id`、当日の旅程、`offline_map_downloaded` | `trip_day`、`offline_map_downloaded` | 当日のチケット・マップ・案内の表示最適化 |
| オフライン検知 | ネットワーク状態がオフラインになった時 | `booking_id`、`offline_mode_detected` | `offline_mode_entered`イベント | オフライン表示・保存済みマップ案内 |
| 現地情報画面 | 位置情報権限がある場合の画面表示時 | `location_permission`、`current_location`、`place_id` | `location_permission`、必要時のみ現在地関連イベント | 周辺情報・現地案内の配信可否判定 |
| 旅行終了 | `travel_end_at`経過後、または完了操作時 | `booking_id`、`trip_completed_at` | `trip_completed`イベント | レビュー依頼・旅のまとめ・次回提案の開始 |
| レビュー依頼 | 旅行終了直後、未レビューの場合 | `booking_id`、`review_status` | `review_requested`イベント | レビュー依頼の重複排除と計測 |
| レビュー送信 | レビュー投稿完了後 | `booking_id`、`review_status` | `review_submitted`イベント、`review_status` | 以降のレビュー依頼停止、次回提案の精度向上 |
| 通知設定画面 | ユーザーがカテゴリ設定を変更した時 | `notification_preferences`、`marketing_consent` | `notification_preferences`、`marketing_consent` | カテゴリ別配信の即時反映 |
| 通知タップ | Push通知タップ時 | `deep_link`、`campaign_id`、`notification_category` | `notification_opened`イベント | 開封計測と適切な画面遷移 |

Brazeでは、`changeUser`によるユーザー識別、属性設定、`requestImmediateDataFlush`による送信制御が基本操作として案内されています。

## タスク・チケット分解

### Phase 1: 調査・設計

| チケット | 内容 | 完了条件 |
| --- | --- | --- |
| `BRAZE-001` Braze連携の現状調査 | 既存のBraze SDK有無、Firebase Messaging設定、通知権限実装、Deep Link実装、認証基盤を調査する | 影響ファイル一覧と現状メモを作成する |
| `BRAZE-002` 通知カテゴリの確定 | `booking_transaction`、`trip_preparation`、`trip_support`、`marketing_offer`の定義、初期値、変更可否、抑制条件を確定する | カテゴリ定義表を関係者で承認する |
| `BRAZE-003` データスキーマ設計 | Brazeへ送るユーザー属性、カスタムイベント、イベントプロパティを確定する | 属性名・型・送信タイミング・送信責務を文書化する |
| `BRAZE-004` Deep Linkスキーマ設計 | 通知タップ後の遷移先、パラメータ、未ログイン時の挙動を設計する | `booking/:id`、`plan/:id`、`settings/notifications`などのスキーマを承認する |
| `BRAZE-005` 権限・同意フロー設計 | OS権限、マーケ同意、カテゴリ別設定の関係を設計する | 画面フローと状態遷移図を承認する |

### Phase 2: 基盤実装

| チケット | 内容 | 完了条件 |
| --- | --- | --- |
| `BRAZE-010` Braze SDK導入 | Flutter向けBraze SDKを追加し、iOS / Androidの初期設定を行う | debug / releaseビルドでSDK初期化が成功する |
| `BRAZE-011` 環境別設定 | API key、endpoint、環境フラグをdev / staging / prodで分離する | 各環境で正しいBrazeワークスペースに接続できる |
| `BRAZE-012` Push権限管理 | `push_permission_status`の取得、権限要求、権限変更検知を実装する | iOS / Android 13+で権限状態が正しく取得できる |
| `BRAZE-013` Pushトークン登録 | BrazeのPush登録処理を実装する | Brazeダッシュボードでテスト端末がPush対象として確認できる |
| `BRAZE-014` ユーザー識別 | ログイン時の`changeUser`、ログアウト時の処理、`anonymous_id`の引き継ぎを実装する | ゲスト→ログイン後も行動データが正しく紐づく |
| `BRAZE-015` 属性送信Repository | Braze属性送信を`NotificationAnalyticsRepository`等に集約する | UIから直接Braze SDKを呼ばない構成になる |
| `BRAZE-016` カスタムイベント送信 | `booking_confirmed`などのイベント送信APIを実装する | イベント名・プロパティが仕様どおり送信される |
| `BRAZE-017` 通知タップ遷移 | Pushの`deep_link`を解析し、Router / Navigatorへ反映する | 冷起動・フォアグラウンド・バックグラウンドの3パターンで遷移する |

### Phase 3: カテゴリ別実装

| チケット | 内容 | 完了条件 |
| --- | --- | --- |
| `BRAZE-020` 予約・決済イベント | `booking_confirmed`、`payment_completed`、`booking_cancelled`を送信する | 予約〜キャンセルまでの状態変化がBrazeへ反映される |
| `BRAZE-021` 出発準備データ | `days_until_departure`、`calendar_registered`、`checkin_status`を送信する | 出発前リマインドの判定に必要な属性が揃う |
| `BRAZE-022` カレンダー連携 | カレンダー登録案内、登録完了イベント、登録済み判定を実装する | 未登録時のみ案内が出る |
| `BRAZE-023` 旅ナカ状態 | `trip_started`、`trip_completed`、オフライン状態を送信する | 旅マエ→旅ナカ→旅アトの状態遷移がBrazeで判別できる |
| `BRAZE-024` 位置情報・現地情報 | `location_permission`と、位置情報を使う画面での最小限のイベントを送信する | 権限なしでもアプリが壊れず、一般情報へフォールバックする |
| `BRAZE-025` レビュー・旅アト | `trip_completed`、`review_requested`、`review_submitted`を送信する | レビュー依頼が1予約あたり1回に制御できる |
| `BRAZE-026` マーケ同意・設定UI | 通知設定画面でカテゴリ別ON/OFFとマーケ同意を管理する | 設定変更がBraze属性へ反映される |

### Phase 4: 検証・リリース

| チケット | 内容 | 完了条件 |
| --- | --- | --- |
| `BRAZE-030` QAシナリオ作成 | 権限、ログイン、予約、キャンセル、オフライン、通知タップのテストケースを作成する | QA観点リストが完成する |
| `BRAZE-031` Brazeテスト配信 | テストユーザー・テスト端末でカテゴリ別キャンペーンを検証する | カテゴリ・状態・Deep Linkが正しく動く |
| `BRAZE-032` 重複排除テスト | 同一イベントの再送、アプリ再起動、オフライン復帰時の挙動を検証する | 同一通知が重複しない |
| `BRAZE-033` プライバシー確認 | 位置情報、予約情報、決済情報の扱いと通知文面を確認する | 機微情報が通知文面に含まれない |
| `BRAZE-034` ストア申請前確認 | iOS / Androidの権限文言、プライバシー、通知挙動を確認する | ストア審査観点をクリアする |

## 既存コードへの影響調査

| 調査対象 | 確認内容 | 影響 |
| --- | --- | --- |
| `main.dart` | アプリ初期化順序、DI構成、Router初期化 | Braze初期化をどこに置くか |
| 認証Repository / AuthProvider | ログイン・ログアウト処理、ユーザーIDの有無 | `changeUser`、`anonymous_id`引き継ぎの追加 |
| Router / Deep Link処理 | 既存のURLスキーム、Universal Links、App Links | 通知用Deep Linkの追加・競合確認 |
| 予約API / Booking Repository | `booking_id`、`booking_status`、日程の取得可否 | Brazeへ送る予約属性の供給元を確認 |
| 決済フロー | 決済成功・失敗・返金のコールバック有無 | `payment_completed`イベントの発火位置 |
| カレンダー機能 | 既存カレンダー登録機能、権限処理の有無 | `calendar_registered`の判定方法 |
| 位置情報機能 | `geolocator`等の権限処理、利用画面 | 位置情報イベントの取得範囲と権限フロー |
| Firebase Messaging | FCM設定、トークン管理、通知ハンドラ | BrazeとFCMの役割分担・重複設定の排除 |
| Analytics実装 | GA4 / AppsFlyer / GTMのイベント送信箇所 | イベント名・プロパティの重複や不整合を防ぐ |
| 通知設定UI | 既存設定画面の有無 | カテゴリ別トグルとマーケ同意UIの追加 |

## 代替案と採用理由

| 案 | 内容 | 採用 / 不採用 | 理由 |
| --- | --- | --- | --- |
| A. Braze属性＋カスタムイベントで状態管理 | Flutterが状態・イベントをBrazeへ送り、Braze側でセグメント・配信を制御する | **採用** | マーケ運用がBrazeだけでセグメントや配信条件を変更でき、Flutter側の再リリースを減らせる |
| B. Flutter側で通知スケジュールを完全管理 | アプリ内で予約状態・日時を監視し、ローカル通知を予約する | 部分採用 | 予約確定や変更をアプリ起動なしで反映しにくく、アンインストールや複数端末で不整合が起きる |
| C. サーバー主導で通知を送る | バックエンドが予約状態を検知し、Braze API経由で配信する | 部分採用 | 予約確定・キャンセルなど信頼性重視の取引系に有効。ただし初期実装コストが高い |
| D. Firebase Messagingのみで実装 | FCMで通知を送り、Brazeは使わない | 不採用 | セグメント、キャンペーン管理、効果測定、マーケ運用の独立性が弱い |
| E. 全データをBrazeへ常時送信 | 位置情報や閲覧履歴を高頻度で送る | 不採用 | プライバシーリスク、通信量、データ品質、ストア審査上の懸念が大きい |

今回の前提では、**Aを基本にし、予約確定・キャンセルなどの重要イベントだけCを併用**する構成が現実的です。Flutterは状態とイベントの送信、Brazeはセグメントと配信、サーバーは正となる予約状態の管理という役割分担にします。

## リスクと注意点

### セキュリティ・プライバシー

- `current_location`、住所、予約番号、決済金額、クレジットカード情報を通知文面やイベントプロパティへ安易に送らない
- 位置情報は「周辺情報を使う画面を開いた瞬間」など、目的が明確なタイミングでのみ取得する
- ログアウト時は`anonymous_id`への切替、またはBrazeのログアウト・データ消去方針を決める
- `marketing_consent`がないユーザーへマーケ系イベントを送っても、マーケ配信対象に含まれないようBraze側と整合させる

### 通知・ストア審査

- Push通知をアプリ利用の必須条件にしない
- マーケティングPushは、アプリ内UIで目的を示した上で明示同意を取り、いつでもOFFにできるようにする。Appleのガイドラインも、プロモーション目的のPushには明示同意とオプトアウト手段を求めています。[developer.apple]
- 権限ダイアログの仕様と要求タイミング
    - iOSのネイティブ権限ダイアログは基本的に一度しか出せないため、初回起動直後の無差別要求は避け、予約後や旅程作成後など価値が伝わるタイミングで要求する
    - Android 13以降はPush権限が必要であり、2回拒否されるとアプリからの再プロンプトはできず、OS設定からの有効化が必要になります。[braze]
    - 詳細は`braze_002.md`の「6. iOS / Android の権限ダイアログ仕様と要求タイミング」セクションにて整理
- Androidでは取引系・出発準備・マーケ系を通知チャンネルとして分け、ユーザーが種類ごとに制御できるようにする
- iOSのprovisional authorizationは「静かな通知」であり、通常のアラート通知と同じには扱えません。用途と期待値を関係者で揃える必要があります。[braze][braze]

### 実装リスク

- **イベント名の不統一**: `booking_confirmed`と`reservation_confirmed`などが混在すると、Brazeセグメントが壊れる。定数クラスで一元管理する
- **二重送信**: 画面再描画、リトライ、オフライン復帰で同じイベントが複数回送られる可能性がある。イベントIDまたは`booking_id + event_type + occurred_at`で重複排除する
- **タイムゾーン不整合**: ユーザーTZと旅行地TZを混同すると、出発前通知や現地情報がずれる
- **冷起動時のDeep Link**: 通知タップでアプリが未起動のまま起動するケースを最初からテストする
- **BrazeとFCMの二重管理**: トークン登録、通知ハンドラ、権限処理が重複しないよう責務を明確にする

## ドキュメントの目次案

```
# Push通知カテゴリ化・Braze連携デザインドック

## 1. 背景と目的
## 2. スコープ
## 3. 用語定義
## 4. 通知カテゴリ定義
## 5. ユーザー状態 × カテゴリ対応表
## 6. BrazeとFlutterの責務分離
## 7. 画面・タイミング別データ送信設計
## 8. データスキーマ
### 8.1 ユーザー属性
### 8.2 予約・旅行状態
### 8.3 行動・機能状態
### 8.4 カスタムイベント
## 9. Deep Link設計
## 10. 権限・同意フロー
## 11. 重複排除・通知抑制
## 12. タイムゾーン設計
## 13. 既存コードへの影響
## 14. 代替案と意思決定
## 15. リスクと対策
## 16. QA観点
## 17. リリース計画
```

最初のチケットとしては、`BRAZE-001 現状調査`、`BRAZE-002 カテゴリ確定`、`BRAZE-003 データスキーマ設計`、`BRAZE-004 Deep Link設計`、`BRAZE-005 権限・同意フロー設計`の5件を先行で起票するのがよいです。これらが固まらないままSDK導入を始めると、イベント名・属性・遷移先の修正コストが大きくなります。