# BRAZE-005 権限・同意フロー設計

## 内容

OS権限、マーケ同意、カテゴリ別設定の関係を設計する

## 完了条件

画面フローと状態遷移図を承認する

---

## 解決した未決定事項

### BRAZE-002 ① marketing_consent 取得タイミング

**決定**: 予約完了後のOS権限取得フローに連続して取得する。

OS権限ダイアログの許可後、アプリ内モーダルで「お得情報・キャンペーンも受け取りますか？」を表示し、`marketing_consent` を取得する。取得タイミングをOS権限と統一することで、ユーザーの認知コストを抑えながら通知価値が伝わる状態で同意を取れる。

詳細は「5. marketing_consent フロー」を参照。

### BRAZE-003 ④ 権限要求タイミング・事前説明UI

**決定**: 予約確定直後（予約完了画面表示時）に権限要求する。

| 候補タイミング | 採否 | 理由 |
|---|---|---|
| アプリ初回起動直後 | 不採用 | 価値不明確・拒否率高（Apple HIG 違反） |
| 予約確定直後 | **採用** | 「予約確定通知を受け取る」という具体的な価値訴求ができる |
| ユーザー自発（設定画面から） | 補完的に採用 | 権限拒否後の再誘導画面として活用 |

事前説明UI（pre-permission rationale screen）は iOS / Android 共通で表示する。OS ネイティブダイアログの前に挟むことでユーザーの文脈を整え、Android では1回目の拒否後に再プロンプトする機会を確保する。

### BRAZE-003 ⑤ marketing_consent 取得タイミング

BRAZE-002 ① と同一。上記参照。

---

## 1. 3層の権限・同意モデル

Push通知の配信可否は独立した3層で制御される。

```
Layer 1: OS Push権限（iOS / Android ネイティブ）
         ↓ ここが OFF なら Push は届かない（Flutter からは制御不能）
Layer 2: marketing_consent（アプリ内同意）
         ↓ OS権限が ON でも marketing_consent が denied なら marketing_offer を送らない
Layer 3: notification_preferences（カテゴリ別設定）
         ↓ ユーザーがカテゴリ単位でON/OFFを切り替える
```

### 各層の責務

| 層 | 制御主体 | 設定場所 | 対象 |
|---|---|---|---|
| OS Push権限 | OS / ユーザー | iOS: システム設定 > 通知<br>Android: アプリ情報 > 通知 | 全 Push 通知の送受信 |
| marketing_consent | ユーザー | アプリ内同意ダイアログ・通知設定画面 | `marketing_offer` カテゴリのみ |
| notification_preferences | ユーザー | アプリ内通知設定画面 | `trip_preparation`, `trip_support`, `marketing_offer`（`booking_transaction` は変更不可） |

### 層間の関係

- **OS権限が OFF** → 全 Push 不可。`marketing_consent` や `notification_preferences` に関係なく Push は届かない
- **OS権限が ON・marketing_consent が denied** → `marketing_offer` のみ Push 不可。他カテゴリは正常配信
- **OS権限が ON・marketing_consent が granted・`marketing_offer` が OFF** → `marketing_offer` を配信しない
- **全 ON** → 全カテゴリを `notification_preferences` の設定に従って配信

---

## 2. OS Push権限フロー

### 2.1 iOS

#### 権限状態

| 状態 | 内容 |
|---|---|
| `not_determined` | 権限ダイアログ未表示（インストール直後のデフォルト） |
| `granted` | ユーザーが許可済み。通常のアラート通知を受信可能 |
| `denied` | ユーザーが拒否済み。OS設定からのみ変更可能 |
| `provisional` | 仮許可。通知センターのみ表示（アラートなし・バッジなし）。Braze では採用しない（下記参照） |

#### Provisional Authorization（仮許可）の不採用

**決定**: Provisional Authorization は採用しない。

| 懸念点 | 内容 |
|---|---|
| 信頼性の低下 | 取引系通知（予約確定等）が通知センターのみの表示になり、ユーザーが見落とす |
| 期待値のズレ | 「許可した覚えがないのに通知センターに溜まっている」という体験が混乱を招く |
| 関係者コスト | 「静かな通知」の仕様を PM / マーケに説明・合意形成するコストが高い |

#### iOS権限フロー

```
予約完了画面
  ↓
push_permission_status を確認
  ├─ not_determined → 事前説明UI を表示（後述）
  ├─ denied        → 設定誘導バナーを表示
  └─ granted       → スキップ（次ステップ: marketing_consent 確認）
```

**事前説明UI → OS ダイアログ**

```
[事前説明UI]
「予約確定・旅行中のお知らせをお届けします」
「許可すると次の通知が届きます:」
  ・ 予約確定・キャンセル（取引通知）
  ・ 出発前のリマインダー
  ・ 旅行中のサポート情報
[通知を許可する] ← タップで OS ダイアログを呼び出す
[あとで設定する] ← スキップ（granted なしで次へ）

  ↓ [通知を許可する] タップ

[iOS ネイティブダイアログ]
"「TravelApp」が通知を送信しようとしています"
[許可]  [許可しない]

  ├─ 許可  → push_permission_status = granted
  │         → Braze に push_permission_status を送信
  │         → marketing_consent フローへ（後述）
  └─ 許可しない → push_permission_status = denied
                 → Braze に push_permission_status を送信
                 → 設定誘導バナーを表示（非ブロッキング）
```

**注意**: iOS のネイティブ権限ダイアログは**原則1回限り**。拒否後は OS 設定からしか変更できない。

#### 権限拒否後の誘導（iOS）

```
[設定誘導バナー（非ブロッキング・ホーム等に表示）]
「予約通知を受け取るには通知を許可してください」
[設定を開く] ← URLScheme "app-settings:" で設定画面を開く
[×] ← 非表示にする（再表示はアプリ再起動後）
```

---

### 2.2 Android 13+

#### 権限状態（内部管理）

Android のネイティブ API は iOS のような named status を持たないため、Flutter 側で以下の状態を管理する。

| 内部状態 | 対応する Android 状態 | 内容 |
|---|---|---|
| `not_determined` | `POST_NOTIFICATIONS` 未要求 | 新規インストール時のデフォルト（Android 13+ は通知 OFF） |
| `granted` | 権限付与済み | 通知受信可能 |
| `1st_denied` | 1回目拒否後 | `shouldShowRequestPermissionRationale()` = `true`。再プロンプト可能 |
| `permanently_denied` | 2回目拒否後 | `shouldShowRequestPermissionRationale()` = `false`。OS設定からのみ変更可能 |

Braze へ送る `push_permission_status` 属性は iOS と共通の値域（`not_determined` / `granted` / `denied`）に正規化する。`1st_denied` → `denied`、`permanently_denied` → `denied` として送信する。

#### Android権限フロー

```
予約完了画面
  ↓
push_permission_status を確認
  ├─ not_determined → 事前説明UI（1回目）を表示
  ├─ 1st_denied     → rationale UI（2回目説明）を表示 → 再プロンプト
  ├─ permanently_denied → 設定誘導バナーを表示
  └─ granted        → スキップ（次ステップ: marketing_consent 確認）
```

**1回目: 事前説明UI → OS ダイアログ（not_determined）**

```
[事前説明UI]
「予約確定・旅行中のお知らせをお届けします」
（iOS と同内容）
[通知を許可する]
[あとで設定する]

  ↓ [通知を許可する] タップ

[Android OS ダイアログ]
「TravelApp に通知の送信を許可しますか？」
[許可]  [許可しない]

  ├─ 許可         → granted
  └─ 許可しない   → 1st_denied（shouldShowRationale = true）
                   → rationale フラグを保存
```

**2回目: rationale UI → 再プロンプト（1st_denied）**

Android では「1回目拒否後に理由を説明してから再プロンプト」できる機会が**1度だけ**ある。

```
[rationale UI（モーダル or インライン）]
「通知はなぜ必要ですか？」
  ・ 予約キャンセルなどの重要なお知らせを即座に受け取れます
  ・ 出発前日に旅行の準備を確認できます
  ・ 旅行中に緊急情報を受け取れます
「これらを受け取るには通知を許可してください」
[通知を許可する]  [許可しない]

  ↓ [通知を許可する] タップ

[Android OS ダイアログ（2回目）]
  ├─ 許可       → granted
  └─ 許可しない → permanently_denied
                 → 設定誘導バナーを表示
```

**設定誘導バナー（permanently_denied）**

```
[設定誘導バナー]
「予約通知を受け取るには設定から通知を有効にしてください」
[設定を開く]  ← Intent で通知設定画面を開く
```

---

### 2.3 共通設計方針

#### 事前説明UIの要件

| 要件 | 内容 |
|---|---|
| 表示内容 | 通知を許可することで得られる具体的な価値（取引通知・出発準備・旅行サポート）を列挙 |
| 表示タイミング | OS ダイアログの直前（ユーザーが「なぜ許可するか」を理解した状態でダイアログを見る） |
| 「あとで」の扱い | スキップ可能・非ブロッキング。次回の予約完了時に再表示（ただし OS ダイアログ未表示かつ `not_determined` の間のみ） |
| 「あとで」の再表示上限 | 最大2回（3回目以降は表示しない。OS ダイアログ呼び出し機会が無駄に減ることを防ぐ） |

#### 権限要求の実施タイミングまとめ

| シーン | 対象 | 理由 |
|---|---|---|
| 予約完了画面 | 全ユーザー（not_determined / 1st_denied） | 価値訴求が最も明確なタイミング |
| ホーム画面バナー | granted 未取得ユーザーへの継続的な誘導 | 非ブロッキングで再リマインド |
| 通知設定画面 | ユーザー自発 | 設定画面から権限状態を確認・OS設定へ誘導 |

---

### 2.4 OS権限APIの異常系設計方針

#### 権限処理に異常系は存在するか

`permission_handler` は MethodChannel 経由でOS APIを呼び出す。そのため、技術的には以下の例外が throw される可能性がある。

| 例外 | 発生条件 |
|---|---|
| `PlatformException` | ネイティブ側（iOS/Android）の処理失敗 |
| `MissingPluginException` | プラグイン未登録（ビルド設定ミス） |
| SharedPreferences 書き込み失敗 | ストレージ極端な不足（実質稀） |

ただし、これらは「ユーザーが操作することで解決できる状態」ではない。ビルド設定ミスや端末レベルの異常であり、正しくビルドされたアプリの実行時には実質発生しない。

> **注意**: iOS で `PERMISSION_NOTIFICATIONS=1` マクロが抜けた場合は例外を throw せず、常に `denied` を返すという動作になる（BRAZE-012 参照）。設定ミスはクラッシュではなく値の劣化として現れる。

---

#### 通信系エラーとの本質的な違い

権限APIの例外を通信系エラーと同じ観点で扱ってはならない。

| 軸 | 通信系エラー | 権限API例外 |
|---|---|---|
| 原因 | ネットワーク未接続・サーバー障害 | ビルド設定ミス・OSバグ |
| ユーザーに対処手段はあるか | **あり**（WiFi ON / 再試行） | **なし** |
| 実行時に頻繁に発生するか | 発生しうる | 正しいビルドでは実質発生しない |
| UIで伝える価値 | 高い（ユーザーが解決できる） | ない（伝えても解決できない） |

通信系エラーはスナックバーや「再試行」ボタンで意味のある対処ができるが、権限API例外でユーザーができることは何もない。スナックバーやダイアログを表示しても混乱させるだけである。

---

#### 設計方針の結論

**権限処理において、ユーザーが操作できる異常系は存在しない。**

- `denied` / `permanentlyDenied` はエラーではなくドメインの正常状態として既に `NotificationPermissionStatus` enum でモデル化済み
- 技術的例外（`PlatformException`）はビルド設定エラーを意味するため、フォールバック値を返すより例外を伝播させてサーフェスさせる方が正しい
- `error_handling.md` の `AppError` は HTTP API 向けの設計であり、権限APIには持ち込まない
- スナックバー・ダイアログ等のUIは**追加しない**

---

#### 現状のコードで例外が起きたときの伝播

`AndroidNotificationPermissionServiceImpl.checkStatus()` でOS APIを呼ぶ箇所：

```dart
// android_notification_permission_service_impl.dart
final status = await Permission.notification.status; // ← PlatformException が throw される可能性
```

現状、どのレイヤーも try/catch を持っていないため、例外はそのまま伝播する。

```
AndroidNotificationPermissionServiceImpl.checkStatus()
  └─ PlatformException throw
       ↑ キャッチなし
  NotificationPermissionRepositoryImpl.checkStatus()
       ↑ キャッチなし
  NotificationPermissionUseCase.checkStatus()
       ↑ キャッチなし
  Notifier.build() または Notifier.someMethod()
```

**各レイヤーに try/catch は追加しない**。これは意図した設計である。

---

#### Notifier を書いたときの挙動

`build()` とアクションメソッドで挙動が異なる。

---

**`build()` の場合（自動キャッチ）**

`build()` は Riverpod が戻り値の `Future` を `AsyncValue` でラップする仕組みになっている。そのため、`build()` 内で throw された例外は Riverpod が自動でキャッチし `state = AsyncError` に変換する。try/catch は不要。

```dart
@override
Future<SomeState> build() async {
  final status = await ref.read(notificationPermissionUseCaseProvider).checkStatus();
  // ↑ PlatformException が伝播してきた場合、Riverpod が自動でキャッチ → AsyncError
  return SomeState(permissionStatus: status);
}
```

```
Service → (PlatformException 伝播) → Repository → UseCase → Notifier.build()
                                                               ↓
                                               Riverpod が自動キャッチ
                                                               ↓
                                                         AsyncError
```

---

**アクションメソッドの場合（自動キャッチなし）**

`build()` 以外の通常メソッドでは Riverpod は例外を自動キャッチしない。throw された例外は呼び出し元（View の `onPressed` 等）まで伝播する。`state` も更新されない。

```dart
Future<void> requestPermission() async {
  final status = await ref.read(notificationPermissionUseCaseProvider).requestPermission();
  // ↑ PlatformException が伝播してきた場合、Riverpod はキャッチしない
  //   例外は View の onPressed まで伝播する
  state = AsyncData(state.requireValue.copyWith(permissionStatus: status));
}
```

アクションメソッドでエラーを捕捉して特定の処理をしたい場合は、`error_handling.md` が定義するコールバック方式を使う：

```dart
Future<void> requestPermission({
  required VoidCallback onGranted,
  required VoidCallback onDenied,
  required VoidCallback onFailure,
}) async {
  try {
    final status = await ref.read(notificationPermissionUseCaseProvider).requestPermission();
    switch (status) {
      case NotificationPermissionStatus.granted: onGranted();
      default: onDenied();
    }
  } on Exception catch (_) {
    onFailure();
  }
}
```

または `state` を `AsyncError` にしたい場合は `AsyncValue.guard` を使う：

```dart
Future<void> refresh() async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    final status = await ref.read(notificationPermissionUseCaseProvider).checkStatus();
    return SomeState(permissionStatus: status);
  });
  // throw された場合 state = AsyncError になる
}
```

---

**本権限実装においての結論**

`checkStatus()` / `requestPermission()` をどちらで呼ぶかは Notifier 実装時に決定する。いずれの呼び出し方であっても、PlatformException は正しいビルドでは実質発生しないため、追加の try/catch は現時点では不要と判断している。将来エラー時に特定のUI制御が必要になった場合は、`build()` 経由であれば AsyncError として自動伝播し、アクションメソッド経由であればコールバック方式で対応する。

---

#### View での受け取り

`PlatformException` は `AppError` ではないため、`error_handling.md` の View パターンにおける `_` ワイルドカードが受け取る。

```dart
// View
switch (viewModel) {
  AsyncLoading() => ...,
  AsyncData(:final value) => _Body(state: value),
  AsyncError(:final error) => switch (error) {
    NetworkError() => ...,
    ServerError()  => ...,
    AppError()     => CoreError(error: error, onPressed: ...),
    _ => CoreError(error: Exception(error), onPressed: ...), // ← PlatformException はここ
  },
}
```

本番環境では Crashlytics 等のクラッシュレポートに自動記録されるため、例外のサイレント握り潰しよりも開発・運用上のメリットがある。

---

## 3. marketing_consent フロー

### marketing_consent とは

Apple HIG・Brazeガイドラインが「プロモーション通知には OS 権限とは別に明示同意を取れ」と要求するために設けた**アプリ独自の同意フラグ**。OS のネイティブ権限（Push を物理的に届けられるか）とは独立して管理する。

#### なぜ marketing_consent が必要か

ポイントは `not_requested` 状態の存在。トグル（ON / OFF）だけでは「まだ聞いていない」と「聞いたが断られた」を区別できない。

| 状態 | トグルの見え方 | 必要なアプリの挙動 |
|---|---|---|
| `not_requested` | OFF | 次の適切なタイミングでモーダルを**自動表示する** |
| `denied` | OFF | ユーザーが一度断った。モーダルを**自動表示しない** |

トグルが OFF という事実だけでは、どちらの状態かわからない。`marketing_consent` を持つことで「まだ聞いていないから予約後に聞く」vs「聞いたが断られたから聞かない」を判定できる。

**初回以降は一緒に動く**

初回の同意モーダルが終わった後は、設定画面でのトグル操作が `marketing_consent` と `notification_preferences.marketing_offer` を同時に更新する。実質的に冗長になるが、`not_requested` の判定ロジックを成立させるために両者を持ち続ける。

#### ストア審査・リジェクトリスクとの関係

**Apple HIG と App Store Review Guidelines は別物**であり、リジェクトに直結するのは後者のみ。

| ドキュメント | 性質 | 違反時のリスク |
|---|---|---|
| Apple HIG | デザイン推奨・ベストプラクティス | 直接のリジェクト要因にはならない |
| App Store Review Guidelines | 審査基準・ルール | 違反でリジェクトあり |

**App Reviewガイドライン4.5.4の実際の要件**

> アプリが機能するためにプッシュ通知を必須とすることはできません。また、プッシュ通知を個人情報や秘密情報を送信するために使用することは許可されません。プッシュ通知をキャンペーンやダイレクトマーケティングのために使用することはできません。ただし、そのプッシュ通知を、ユーザーがアプリのUIに表示される同意メッセージを通じて明示的にオプトインすることができ、同時にオプトアウトする手段をアプリに設ける場合を除きます。サービスを不正に使用すると、デベロッパとしての権限を失う可能性があります。

参照: [App Reviewガイドライン4.5.4
](https://developer.apple.com/jp/app-store/review/guidelines/#apple-sites-and-services)

要件は「アプリ内UIで明示的にオプトイン・オプトアウトする手段を設けていること」。
**モーダルである必要はない。**

`notification_preferences.marketing_offer` トグルが初期値 OFF でユーザーが能動的に ON にする設計であれば、それ自体が「アプリ内のオプトインフロー」として要件を満たす。`marketing_consent` モーダルがなくてもリジェクトにはならない。

**リジェクトリスク一覧**

| ケース | リジェクトリスク |
|---|---|
| マーケ通知をアプリ内オプトイン・オプトアウトなしに送る | 高（4.5.4 違反） |
| マーケ通知トグルの初期値が ON | 高（明示的なオプトインとみなされない） |
| トグルが初期値 OFF・ユーザーが能動的に ON にする | **低（要件を満たす）** |
| `marketing_consent` モーダルあり | 低（より明確な同意フロー） |

**ステークホルダーへの正確な伝え方**

「`marketing_consent` モーダルがないとリジェクト確定」は不正確。正確には：

- マーケ通知の**アプリ内オプトイン・オプトアウトの手段が何かしら必要**（モーダルかトグルかは問わない）
- トグルが初期値 OFF でユーザーが能動的に ON にする設計であれば App Store 要件は満たせる

モーダルを入れる理由は「リジェクト回避」よりも「`not_requested` / `denied` の判別によるモーダル出し分けロジックの確立・将来の法令対応（GDPR 等）の余地確保」。

議論がモーダル不要の方向に進む場合は「トグルのみでも App Store 要件は満たせる。ただし `not_requested` / `denied` の判別ができなくなる。まだ聞いていないユーザー（`not_requested`）と一度断ったユーザー（`denied`）を区別できないため、前者への初回取得機会を逃すか、後者に繰り返し同意を求めるかの二択しか取れなくなる。
そのため、`marketing_consent` を持つことで、まだ聞いていないユーザーにのみ適切なタイミングでモーダルを表示し、断ったユーザーへの不要な再表示を防げる」という観点で議論するのが正確。

#### marketing_offer カテゴリとの関係

`marketing_consent` は `marketing_offer` カテゴリの**上位ゲート（親）**。`notification_preferences` の `marketing_offer` トグルは**下位設定（子）**。

```
marketing_consent（親: マーケ通知を受け取ることに同意するか）
    └─ notification_preferences.marketing_offer（子: このカテゴリを ON にするか）
```

`marketing_offer` Push を届けるには3条件すべてが必要。

```
OS権限 = granted
  AND marketing_consent = granted                      ← 親ゲート
  AND notification_preferences.marketing_offer = true  ← 子トグル
```

`booking_transaction` / `trip_preparation` / `trip_support` は予約・取引・旅行サービスに関する通知であり、Apple HIG が明示同意を要求する「プロモーション通知」には該当しない。OS権限のみで制御する。`marketing_offer` はプロモーション（割引・キャンペーン）通知に該当するため、Apple HIG 準拠で `marketing_consent` という上位ゲートを設けている。

---

### 状態

| 状態 | 内容 |
|---|---|
| `not_requested` | 同意ダイアログ未表示（初期値） |
| `granted` | ユーザーが同意済み |
| `denied` | ユーザーが明示的に拒否済み |

#### 3状態と設定画面の関係

`not_requested` はユーザー向けの表示状態ではなく、**「モーダルをまだ出していない」というアプリ内部のフラグ**（詳細は「なぜ marketing_consent が必要か」を参照）。設定画面のトグルは実質2値（ON / OFF）で管理する。

| 内部状態 | 設定画面の表示 | アプリの挙動 |
|---|---|---|
| `not_requested` | OFF（`denied` と同じ表示） | 次の適切なタイミング（予約後など）でモーダルを**自動表示する** |
| `denied` | OFF | ユーザーが一度「受け取らない」を選択済み。モーダルを**自動表示しない** |
| `granted` | ON | 正常配信 |

`not_requested` と `denied` の区別は「モーダルを再表示するか」の判定にのみ使う。設定画面からのトグル操作はどちらの状態からでも同じ。

| 操作 | 遷移 |
|---|---|
| OFF（`not_requested` or `denied`） → ON | `marketing_consent = granted` |
| ON（`granted`） → OFF | `marketing_consent = denied` |

`denied` から `granted` への変更は通知設定画面（`/settings/notifications`）でユーザーが行える（再オプトイン可能）。

### 取得フロー

OS Push権限の許可後に連続して表示する。OS権限が denied の場合は取得しない（Push が届かない状態でマーケ同意を求めても意味がない）。

```
OS権限ダイアログ → 許可
  ↓
marketing_consent の確認
  ├─ granted / denied → スキップ（既取得）
  └─ not_requested  → marketing_consent モーダルを表示

[marketing_consent モーダル]
「お得情報・キャンペーンのお知らせも受け取りますか？」
  ・ 旅行先の限定プラン・割引情報
  ・ 旅行プランの値下げ通知
  ・ 次回旅行のおすすめ情報
「いつでも通知設定からオフにできます」
[受け取る]   → marketing_consent = granted → Braze 送信
[受け取らない] → marketing_consent = denied  → Braze 送信

※ 週2件まで・いつでもOFFにできる旨を明示する（Apple HIG 準拠）
```

**OS権限が denied の場合の扱い**

OS権限が denied の状態では Push が届かないため、`marketing_consent` の取得を行わない。`marketing_consent = not_requested` のまま維持し、OS権限取得後（設定画面からの有効化）に改めて通知設定画面で同意を促す。

### 再オプトインフロー（通知設定画面）

```
通知設定画面（/settings/notifications）
  ↓
「お得情報・キャンペーン通知」トグル
  ├─ OFF → ON にタップ
  │     ├─ marketing_consent = not_requested or denied
  │     │   → marketing_consent = granted → Braze 送信
  │     └─ OS権限 = denied
  │         → 「設定から通知を有効にしてください」ダイアログ → 設定画面へ誘導
  └─ ON → OFF にタップ
        → marketing_consent = denied → Braze 送信
```

---

## 4. カテゴリ別設定フロー

### 変更可否

| カテゴリ | ユーザー変更 | 初期値 | 変更画面 |
|---|---|---|---|
| `booking_transaction` | **不可** | ON | トグルなし（常時ON表示・理由を説明） |
| `trip_preparation` | 可 | ON | 通知設定画面のトグル |
| `trip_support` | 一部可（緊急は不可） | ON | 通知設定画面のトグル（緊急は灰色・説明付き） |
| `marketing_offer` | 可 | OFF | marketing_consent + 通知設定画面のトグル |

### 設定変更フロー

```
通知設定画面（/settings/notifications）
  ↓
カテゴリ別トグル変更
  ↓
Notifier が notification_preferences を更新
  ↓
NotificationAnalyticsRepository 経由で Braze へ送信
  ・ 属性: notification_preferences（Object）を更新
  ・ イベント: notification_opt_out_changed（category, new_status, change_source="user_setting"）
```

### notification_preferences の構造（再掲）

```json
{
  "trip_preparation": true,
  "trip_support": true,
  "marketing_offer": false
}
```

`booking_transaction` はユーザー変更不可のため含めない。

---

## 5. 画面一覧

| 画面 | パス | 役割 |
|---|---|---|
| 事前説明UI | モーダル（予約完了画面上） | OS権限ダイアログ前に通知の価値を説明 |
| rationale UI | モーダル（Android 1回目拒否後） | 再プロンプト前の理由説明 |
| marketing_consent モーダル | モーダル（OS権限許可直後） | マーケ通知への同意取得 |
| 通知設定画面 | `/settings/notifications` | カテゴリ別 ON/OFF・marketing_consent の変更 |
| 設定誘導バナー | ホーム画面等（非ブロッキング） | OS権限 denied 後のOS設定への誘導 |

### 通知設定画面のUI構成

```
通知設定
────────────────────────────
OS通知権限
  ステータス: [許可済み / 未許可]
  [設定を開く]（未許可時のみ表示）

────────────────────────────
取引・予約通知           [常時ON・ロック]
  予約確定・変更・キャンセルなどの重要なお知らせ    ← booking_transaction（変更不可）
  ※ この通知はオフにできません

出発準備通知             [ON/OFF]
  カレンダー登録・チェックイン・出発前のリマインド  ← notification_preferences.trip_preparation

旅行中サポート通知        [ON/OFF]
  旅行中のサポート情報                             ← notification_preferences.trip_support
  緊急情報は常時受け取ります

お得情報・キャンペーン    [ON/OFF]
  割引・次回予約のおすすめ・限定プラン              ← marketing_consent
  週2件まで配信されます                               & notification_preferences.marketing_offer

────────────────────────────
```

全カテゴリのトグルは同じ画面に並ぶ。詳細画面への分割は不要。「お得情報・キャンペーン」のトグル操作のみ `marketing_consent` と `notification_preferences.marketing_offer` を同時に更新する（他カテゴリは `notification_preferences` のみ）。

---

## 6. 権限・同意状態の組み合わせマトリックス

| OS権限 | marketing_consent | trip_preparation | trip_support | marketing_offer | booking_transaction | アプリ内挙動 |
|---|---|---|---|---|---|---|
| granted | granted | ON | ON | ON | ON | 全カテゴリ Push 配信可 |
| granted | granted | ON | ON | OFF | ON | marketing_offer 以外配信可 |
| granted | denied | ON | ON | OFF | ON | marketing_offer 配信不可。通知設定トグルは OFF（タップで granted に変更可） |
| granted | not_requested | ON | ON | OFF | ON | marketing_offer 配信不可。予約後に marketing_consent モーダルを表示 |
| denied | any | 灰色・操作不可 | 灰色・操作不可 | 灰色・操作不可 | 灰色・操作不可 | Push 不可。アプリ内メッセージのみ。設定誘導バナーを表示 |
| not_determined | any | 灰色・操作不可 | 灰色・操作不可 | 灰色・操作不可 | 灰色・操作不可 | Push 未設定。予約完了時に権限要求フローを開始 |

**表の読み方**

- `ON` / `OFF` → トグルが表示・操作可能
- `灰色・操作不可` → OS権限がないため Push が届かない状態。全カテゴリのトグルを灰色表示・操作不可にし、通知設定画面の最上部の「設定を開く」ボタンでOS設定への誘導を優先する
- `marketing_offer` 列の OFF → ON 操作のみ `marketing_consent` と `notification_preferences.marketing_offer` を同時に更新する（他カテゴリは `notification_preferences` のみ）

`marketing_consent = denied` は「初回の同意モーダルでユーザーが『受け取らない』を選んだ状態」。設定トグルは OFF で画面に表示されており、いつでも ON に変更できる（灰色・非表示ではない）。

---

## 7. 状態遷移図

### OS Push権限（iOS）

```
not_determined
    │
    │ 事前説明UI → [通知を許可する]
    │ → OS ダイアログ表示
    │
    ├─[許可]────────────────→ granted
    │                              │
    │                              │ (ユーザーが OS 設定でOFF)
    │                              ↓
    └─[許可しない]──────────→ denied ──→ (OS 設定でのみ変更可能)
                                         ↑
                                         └─(ユーザーが OS 設定でON)
```

### OS Push権限（Android 13+）

```
not_determined
    │
    │ 事前説明UI → [通知を許可する]
    │ → OS ダイアログ表示（1回目）
    │
    ├─[許可]─────────────────────────────────→ granted
    │                                                │
    │                                                │ (OS 設定でOFF)
    └─[許可しない]                                   ↓
          │                                    permanently_denied
          │ shouldShowRationale=true             （OS 設定でのみ変更可能）
          ↓
      1st_denied
          │
          │ rationale UI → [通知を許可する]
          │ → OS ダイアログ表示（2回目）
          │
          ├─[許可]───────────────────────────→ granted
          │
          └─[許可しない]
                │
                │ shouldShowRationale=false
                ↓
          permanently_denied
           （OS 設定でのみ変更可能）
```

### marketing_consent

```
not_requested
    │
    │ OS権限 granted 後に marketing_consent モーダル表示
    │
    ├─[受け取る]──────→ granted ←──────────────────────┐
    │                      │                             │
    │                      │ 通知設定画面でトグル OFF    │ 通知設定画面でトグル ON
    │                      ↓                             │
    └─[受け取らない]──→ denied ──────────────────────────┘
```

### push_permission_status の Braze 送信値

| Flutter 内部状態 | Braze 送信値 |
|---|---|
| not_determined | `not_determined` |
| granted | `granted` |
| denied（iOS） | `denied` |
| 1st_denied（Android） | `denied` |
| permanently_denied（Android） | `denied` |

---

## 8. Braze属性の送信設計（権限・同意関連）

| 属性 / イベント | 送信タイミング | 送信値 | 責務 |
|---|---|---|---|
| `push_permission_status` | アプリ起動時 / OS権限変更時 | `not_determined` / `granted` / `denied` | `NotificationPermissionUseCase` |
| `marketing_consent` | 同意モーダル結果確定時 / 通知設定変更時 | `not_requested` / `granted` / `denied` | 通知設定画面 Notifier → `NotificationAnalyticsRepository` |
| `notification_preferences` | ユーザーが設定変更時 | `{trip_preparation, trip_support, marketing_offer}` の Object | 通知設定画面 Notifier → `NotificationAnalyticsRepository` |
| `notification_opt_out_changed`（イベント） | カテゴリON/OFF変更時 / OS権限変更時 | `{category, new_status, change_source}` | `NotificationPermissionUseCase` / 通知設定画面 Notifier |

### 送信フロー（Flutter 内）

```
OS権限変更（PermissionHandler コールバック）
  ↓
NotificationPermissionUseCase.onPermissionChanged()
  ↓
NotificationAnalyticsRepository.updatePushPermissionStatus()
  ↓
BrazeAnalyticsService.setUserAttribute('push_permission_status', ...)
  + BrazeAnalyticsService.logCustomEvent('notification_opt_out_changed', ...)
```

---

## 9. 未決定事項

| # | 未決定事項 | 内容 | 決定チケット |
|---|---|---|---|
| 1 | 事前説明UI の表示回数上限の最終確定 | 「あとで」選択後の再表示を最大2回と定義したが、PM と UX の観点で最終確定が必要 | `BRAZE-026` |
| 2 | marketing_consent モーダルの文言 | 「受け取る」「受け取らない」の表現・説明文はコピーライティング担当と確認 | `BRAZE-026` |
| 3 | 設定誘導バナーの表示頻度 | denied 後のバナーをセッションごとに表示するか、ユーザーが×で消したら以降非表示にするか | `BRAZE-026` |
| 4 | `trip_support` 緊急情報カテゴリのUI表現 | 通知設定画面で緊急情報トグルを灰色（変更不可）表示する際の説明文 | `BRAZE-026` |
| 5 | marketing_consent の有効期限 | `denied` から一定期間後に `not_requested` へリセットし再同意を促す設計にするか | 別途ロードマップで決定 |
