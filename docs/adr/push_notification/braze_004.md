# BRAZE-004 Deep Linkスキーマ設計

## 内容

通知タップ後の遷移先、パラメータ、未ログイン時の挙動を設計する

## 完了条件

`booking/:id`、`plan/:id`、`settings/notifications` などのスキーマを承認する

---

## 1. URLスキーム

### カスタムURLスキーム

| 項目 | 値 |
|---|---|
| スキーム | `travelapp://` |
| iOS登録場所 | `ios/Runner/Info.plist` の `CFBundleURLSchemes` |
| Android登録場所 | `AndroidManifest.xml` の `intent-filter`（`scheme="travelapp"`） |

**URLの構造**: `travelapp://{path}/{params}`
例: `travelapp://booking/BK-12345`、`travelapp://plan/PL-001`

### go_router パスとの対応

`travelapp://` 以降の部分が go_router のパスに対応する。

```
travelapp://booking/BK-12345
          ↕
/booking/BK-12345  ← GoRoute(path: '/booking/:bookingId')
```

Flutter側の変換処理は BRAZE-017（通知タップ遷移実装）で実装する。

---

## 2. ログイン要否方針

アプリインストール後、ログイン画面は即座に表示しない。基本的な閲覧はログイン不要（`anonymous_id`）とし、アクション（予約・お気に入り登録など）の段階でログインを促す。

保護画面は「ハードガード」と「ソフトガード」の2種類に分類する。

| 区分 | ガード種別 | 挙動 | LoginScreen への遷移 | ログイン後の戻り方 |
|---|---|---|---|---|
| **公開画面** | — | `anonymous_id` ユーザーも閲覧可 | — | — |
| **保護画面（ハードガード）** | redirect が遮断 | 未ログインで URL アクセス時に redirect が `pending_deep_link` を保存し LoginScreen へ go（スタック置き換え） | redirect が返す | `context.go(pendingPath)` |
| **保護画面（ソフトガード）** | 画面自体が処理 | 画面には遷移できる。未ログイン時は画面内に「ログインが必要です」UIを表示 | 画面のログインボタンが `context.push('/login')` | `context.pop()` で元の画面へ戻る |

**ハードガードを使う基準**: 通知タップ（冷起動含む）が起点になりうるパス。redirect が必ずかかるため `pending_deep_link` が正確に保存される。

**ソフトガードを使う基準**: アプリ内ナビゲーション（BottomNavBar等）が起点のパス。画面は表示できるが、データ取得や操作にログインが必要なケース。

> **現状のrouter.dartとの差異**
>
> 現在の `redirect` はログイン状態に関係なく未ログインユーザーを `/login` へ全リダイレクトしている。上記方針に合わせ、ハードガード対象画面のみに絞った redirect ロジックへの修正が必要。詳細は「6. router.dart修正方針」を参照。実施は**実装フェーズ（BRAZE-017）**で行う。

---

## 3. Deep Linkパス一覧

### 公開画面（ログイン不要）

| go_router パス | deep_link URL | 遷移先画面 | 通知カテゴリ |
|---|---|---|---|
| `/home` | `travelapp://home` | ホーム画面 | — |
| `/search` | `travelapp://search` | 検索画面 | `marketing_offer` |
| `/search?destination=X` | `travelapp://search?destination=X` | 検索画面（目的地プリセット） | `marketing_offer` |
| `/plan/:planId` | `travelapp://plan/PL-001` | プラン詳細画面（閲覧） | `marketing_offer` |
| `/settings/notifications` | `travelapp://settings/notifications` | 通知設定画面 | 全カテゴリ共通 |

### 保護画面（ログイン必須）

| go_router パス | deep_link URL | 遷移先画面 | ガード種別 | 通知カテゴリ |
|---|---|---|---|---|
| `/booking/:bookingId` | `travelapp://booking/BK-12345` | 予約詳細画面 | ハード | `booking_transaction` |
| `/my-trips` | `travelapp://my-trips` | 予約一覧画面 | ソフト | — |
| `/my-trips/:bookingId` | `travelapp://my-trips/BK-12345` | 旅程詳細画面（旅ナカ） | ハード | `trip_preparation` / `trip_support` |
| `/favorites` | `travelapp://favorites` | お気に入り一覧 | ソフト | — |
| `/profile` | `travelapp://profile` | プロフィール画面 | ソフト | — |

---

## 4. 通知カテゴリ別の遷移先一覧

| 通知カテゴリ | 通知イベント | deep_link URL | ログイン要否 | 備考 |
|---|---|---|---|---|
| `booking_transaction` | `booking_confirmed` | `travelapp://booking/{bookingId}` | 必須 | 予約確定通知から予約詳細へ |
| `booking_transaction` | `payment_completed` | `travelapp://booking/{bookingId}` | 必須 | 決済完了通知から予約詳細へ |
| `booking_transaction` | `booking_cancelled_by_operator` | `travelapp://booking/{bookingId}` | 必須 | キャンセル通知から予約詳細へ |
| `trip_preparation` | `trip_starting_soon` | `travelapp://my-trips/{bookingId}` | 必須 | 出発前日通知から旅程詳細へ |
| `trip_support` | （緊急・サポート系） | `travelapp://my-trips/{bookingId}` | 必須 | 旅ナカ通知から旅程詳細へ |
| `marketing_offer` | （キャンペーン・割引） | `travelapp://plan/{planId}` | 不要 | プラン詳細閲覧はログイン不要 |
| `marketing_offer` | （次回旅行提案） | `travelapp://search` | 不要 | 検索画面へ誘導 |
| 全カテゴリ共通 | `notification_opt_out_changed` | `travelapp://settings/notifications` | 不要 | 通知設定画面へ |

---

## 5. 未ログイン時の保留遷移設計

保護画面へのdeep linkを未ログイン状態で受け取った場合の挙動。

### フロー

```
通知タップ（未ログイン）
  ↓
go_router が保護画面へのアクセスを検知
  ↓
遷移先パスを SharedPreferences へ保存
  pending_deep_link = "/booking/BK-12345"
  ↓
ログインプロンプトを表示
  ↓
ログイン完了（user_id 取得）
  ↓
SharedPreferences から pending_deep_link を読み出し
  ↓
router.go('/booking/BK-12345') → 予約詳細画面へ遷移
SharedPreferences の pending_deep_link をクリア
```

### 冷起動（アプリ未起動時に通知タップ）との差異

| 状態 | 保留遷移先の保存場所 | 理由 |
|---|---|---|
| フォアグラウンド / バックグラウンド | メモリ（Riverpod StateProvider） | アプリが生きているため永続化不要 |
| 冷起動（アプリ未起動） | SharedPreferences | プロセス終了後も遷移先を保持するため |

実装上は **SharedPreferences を一次保存場所として統一**し、ログイン後に読み出してクリアする。`main.dart` で既に `SharedPreferencesWithCache` を初期化済みのため、追加の初期化は不要。

### 保留遷移の対象外

以下のケースは保留遷移を行わず、ホーム画面へフォールバックする。

| ケース | 理由 |
|---|---|
| ログイン後に `bookingId` が自分の予約に存在しない | 別ユーザーの予約URL等 |
| go_router のルート定義にマッチしないパス | 誤ったURLスキーム → `errorBuilder` が発火 |

**API レベルの 404（リソース不存在）は対象外ではない**。`/booking/BK-99999` がルートパターン `/booking/:bookingId` にマッチする限り、go_router は BookingDetailScreen へ遷移する。その画面内で API が 404 を返した場合は「予約が見つかりません」などのエラー状態を表示する。遷移自体を止める必要はない。

---

## 6. router.dart 修正方針（実装フェーズへの申し送り）

**実施チケット**: BRAZE-017

### 現状の問題

```dart
// 現在: 未ログインユーザーはすべて /login へリダイレクト
redirect: (context, state) async {
  final loggedIn = await ref.read(authUseCaseProvider).checkIsLoggedIn();
  if (!loggedIn) {
    return LoginScreen.path; // ← 公開画面にもアクセスできない
  }
  ...
}
```

### 各コンポーネントの責務分担

| コンポーネント | 責務 | context.go() / pop() |
|---|---|---|
| `router.dart`（redirect） | **ハードガード**のみ遮断 + `pending_deep_link` の**保存** | 呼ばない（return で遷移先を指示） |
| `AuthUseCase.login()` | ログイン処理 + `pending_deep_link` の取得・削除 → **戻り値で返す** | 呼ばない |
| `LoginNotifier.login()` | UseCase を呼び、戻り値を**そのまま呼び出し元へ返す** | 呼ばない |
| `LoginScreen`（screen.dart） | Notifier を呼び、戻り値と `canPop()` を見て **`context.go()` または `context.pop()` を呼ぶ** | ✅ ここだけ |

`pending_deep_link` は UseCase 内で取得・削除を原子的に行う。Notifier の state には保存しない（SharedPreferences と state の二重管理・クリア忘れによる値の混濁を避けるため）。

---

### 修正後の設計

#### router.dart（redirect）

redirect の責務は「保護判定 + pending_deep_link の保存」のみ。ログイン後の遷移先決定には関与しない。

```dart
redirect: (context, state) async {
  final loggedIn = await ref.read(authUseCaseProvider).checkIsLoggedIn();
  final path = state.matchedLocation;

  // 保護画面へのアクセスかつ未ログインの場合のみ介入
  if (!loggedIn && _isProtectedPath(path)) {
    // pending_deep_link の保存は UseCase 経由で行う（Service 層直呼び禁止）
    await ref.read(authUseCaseProvider).savePendingDeepLink(path);
    return LoginScreen.path;
  }

  // ログイン済みでログイン画面にいる場合はホームへ（ログイン画面の直接アクセス防止）
  if (loggedIn && path == LoginScreen.path) {
    return HomeScreen.path;
  }

  return null;
},

// ハードガード対象のみ。ソフトガード（/my-trips 等）は含めない
bool _isProtectedPath(String path) {
  const protectedPrefixes = [
    '/booking',        // ハードガード: 通知タップ・冷起動の起点になりうる
    '/my-trips/',      // ハードガード: 旅程詳細（/my-trips/:bookingId）のみ。末尾スラッシュで一覧を除外
  ];
  return protectedPrefixes.any((prefix) => path.startsWith(prefix));
}

// ソフトガード対象（redirect は関与しない。画面自体がログインUIを表示する）
// /my-trips    → MyTripsScreen がログイン促進UIを表示
// /favorites   → TBD
// /profile     → TBD
```

#### AuthUseCase

ログイン処理と `pending_deep_link` の取得・削除を一連で行い、パスを戻り値として返す。`context.go()` は呼ばない。

```dart
// pending_deep_link の保存（redirect から呼ばれる）
Future<void> savePendingDeepLink(String path) {
  return _authRepository.savePendingDeepLink(path);
}

// ログイン処理（LoginNotifier から呼ばれる）
// 戻り値: ログイン後の遷移先パス（pending がなければ null）
Future<String?> login({
  required String email,
  required String password,
}) async {
  // /auth/login を実行し accessToken / refreshToken / userId を保存
  await _authRepository.login(email: email, password: password);

  // pending_deep_link を取得・削除して返す（Notifier state には保存しない）
  return _authRepository.getAndClearPendingDeepLink();
}
```

#### LoginNotifier

UseCase の戻り値を state に保存せず、呼び出し元（LoginScreen）へそのまま返す。

```dart
// 戻り値: ログイン後の遷移先パス（pending がなければ null）
Future<String?> login({
  required String email,
  required String password,
}) async {
  state = const AsyncLoading();
  return await AsyncValue.guard(() async {
    return ref.read(authUseCaseProvider).login(
      email: email,
      password: password,
    );
  }).then((result) {
    state = result.whenData((_) => const LoginState());
    return result.value; // pendingPath を返す
  });
}
```

#### LoginScreen（screen.dart）

Notifier の戻り値（`pendingPath`）と `context.canPop()` を組み合わせて遷移先を決定する。`context.go()` / `context.pop()` はここだけ。

```dart
Future<void> _onLoginTap() async {
  final pendingPath = await ref.read(loginNotifierProvider.notifier).login(
    email: _emailController.text,
    password: _passwordController.text,
  );
  if (!mounted) return;

  if (context.canPop() && (pendingPath == null || pendingPath.isEmpty)) {
    // ソフトガード: push で開かれた。元の画面へ pop して戻る
    // → 元の画面が auth 変化を検知して再描画し、データを表示する
    context.pop();
  } else if (pendingPath != null && pendingPath.isNotEmpty) {
    // ハードガード / 冷起動: redirect が pendingPath を保存済み → go で遷移
    context.go(pendingPath);
  } else {
    // フォールバック（pendingPath なし・canPop 不可）
    context.go(HomeScreen.path);
  }
}
```

**条件分岐の設計意図**

| canPop() | pendingPath | 判定 | 理由 |
|---|---|---|---|
| true | null / 空 | `pop()` | ソフトガードから push で開かれた正常ケース |
| false | あり | `go(pendingPath)` | ハードガード / 冷起動。redirect がスタックを置き換えているため pop 不可 |
| true | あり | `go(pendingPath)` | redirect が canPop=true になる実装依存ケース。pendingPath を優先 |
| false | null / 空 | `go(HomeScreen)` | フォールバック。通常フローでは発生しない |

**stale pendingPath に関する既知のエッジケース**

以下のシナリオでは `canPop()=true` かつ `pendingPath` が古い値（別フローで保存されたもの）になる可能性がある。

```
① redirect が '/booking/BK-123' を保存 → LoginScreen へ go
② ユーザーがログインせずに戻る（アプリ内遷移等で LoginScreen を脱出）
   → SharedPreferences に '/booking/BK-123' が残ったまま
③ MyTripsScreen のログインボタンから push('/login')（canPop=true）
④ login() 内の getAndClearPendingDeepLink() が '/booking/BK-123' を返す
⑤ canPop=true かつ pendingPath='/booking/BK-123' → go('/booking/BK-123') ← 意図しない遷移
```

**根本的な解決策（BRAZE-017 で採用を検討）**: `extra` で遷移元を明示渡しすることで `canPop()` の実装依存を排除する。

```dart
// ソフトガードの画面から push する際に source を渡す
context.push('/login', extra: {'source': 'soft_guard'});

// LoginScreen 側
final extra = GoRouterState.of(context).extra as Map?;
final isSoftGuard = extra?['source'] == 'soft_guard';

if (isSoftGuard) {
  context.pop();
} else if (pendingPath != null && pendingPath.isNotEmpty) {
  context.go(pendingPath);
} else {
  context.go(HomeScreen.path);
}
```

---

### 具体例：パターンA（アプリ起動中に保護画面へアクセス）

**シーン**: 未ログインユーザーが HomeScreen（公開）から「マイ旅程」をタップして `/my-trips`（保護）へ遷移しようとした

```
HomeScreen
  ↓ BottomNavBar「マイ旅程」タップ
  context.go('/my-trips')

[redirect 発火]
  checkIsLoggedIn() → false
  _isProtectedPath('/my-trips') → true
  authUseCaseProvider.savePendingDeepLink('/my-trips')
    → AuthRepository → SharedPreferences に保存
  return LoginScreen.path  ← スタックが /login に置き換わる

LoginScreen
  ↓ メールアドレス・パスワード入力 → 「ログイン」タップ
  _onLoginTap() が発火

  LoginNotifier.login()
    → AuthUseCase.login()
        → /auth/login 実行・トークン保存
        → AuthRepository.getAndClearPendingDeepLink()
            SharedPreferences から '/my-trips' を取得・削除
        → return '/my-trips'
    → return '/my-trips' （state には保存しない）

  pendingPath = '/my-trips'
  context.go('/my-trips')  ← LoginScreen が呼ぶ

MyTripsScreen へ遷移
```

**なぜ `context.pop()` ではないか**
redirect は go（スタック置き換え）で LoginScreen へ飛ばしているため、LoginScreen の背後に `/my-trips` は存在しない。`pop()` すると HomeScreen へ戻るだけで、マイ旅程には到達しない。

---

### 具体例：パターンA'（ソフトガード・画面内ログインボタン経由）

**シーン**: 未ログインユーザーが BottomNavBar から「マイ旅程」をタップ。MyTripsScreen にはログイン促進UIが表示され、ログインボタンを押した

```
HomeScreen
  ↓ BottomNavBar「マイ旅程」タップ
  context.go('/my-trips')

[redirect は発火しない]
  /my-trips はソフトガード → _isProtectedPath() 対象外

MyTripsScreen（遷移できる）
  未ログイン → Notifier が anonymous_id を検知
  → 「マイ旅程を見るにはログインが必要です」＋ログインボタンを表示
  ↓ ログインボタンタップ
  context.push('/login')
  ← スタック: [HomeScreen / MyTripsScreen / LoginScreen]

LoginScreen
  ↓ ログイン成功
  _onLoginTap() が発火

  LoginNotifier.login()
    → AuthUseCase.login()
        → /auth/login 実行・トークン保存
        → getAndClearPendingDeepLink() → null（redirect が保存していない）
        → return null
    → return null

  pendingPath = null
  context.canPop() → true（MyTripsScreen がスタックにある）
  条件: canPop()=true && pendingPath==null → context.pop()
  ← スタック: [HomeScreen / MyTripsScreen]

MyTripsScreen（再表示）
  auth 状態変化を検知 → Notifier がデータを再取得
  マイ旅程の一覧を表示
```

**パターンAとの比較**

| | パターンA（ハードガード・redirect） | パターンA'（ソフトガード・push） |
|---|---|---|
| LoginScreen への到達 | redirect が go（スタック置き換え） | 画面が push（スタックに積む） |
| canPop() | false | true |
| pendingPath | あり（redirect が保存） | null（redirect が介入しない） |
| ログイン後の操作 | `context.go(pendingPath)` | `context.pop()` |
| ログイン後の画面 | pendingPath の画面へ新規遷移 | MyTripsScreen へ戻り再描画 |

---

### 具体例：パターンB（アプリ未起動時に通知をタップ・冷起動）

**シーン**: Braze から「予約BK-12345が確定しました」という Push 通知が届き、アプリが閉じた状態でタップ

```
[OS がアプリを起動]
  Braze SDK コールバック発火
  deep_link = 'travelapp://booking/BK-12345'
  → router.go('/booking/BK-12345')

[redirect 発火（スタックはまだない）]
  checkIsLoggedIn() → false
  _isProtectedPath('/booking/BK-12345') → true
  authUseCaseProvider.savePendingDeepLink('/booking/BK-12345')
    → SharedPreferences に保存
  return LoginScreen.path  ← アプリの最初の画面として表示

LoginScreen
  ↓ ログイン操作
  _onLoginTap() が発火

  LoginNotifier.login()
    → AuthUseCase.login()
        → /auth/login 実行・トークン保存
        → getAndClearPendingDeepLink() → '/booking/BK-12345'
        → return '/booking/BK-12345'

  pendingPath = '/booking/BK-12345'
  context.go('/booking/BK-12345')

BookingDetailScreen へ遷移
```

パターンAとの違いは「スタック自体が存在しない」点のみ。ログイン後の処理フローは同一。

---

## 7. パラメータ設計

### パスパラメータ

| パラメータ名 | 型 | 例 | 用途 |
|---|---|---|---|
| `bookingId` | String | `BK-12345` | 予約・旅程の識別 |
| `planId` | String | `PL-001` | プランの識別 |

### クエリパラメータ（公開画面のみ）

| パラメータ名 | 型 | 例 | 用途 |
|---|---|---|---|
| `destination` | String | `Tokyo` | 検索画面の目的地プリセット |
| `date` | String | `2027-03-01` | 検索画面の日程プリセット |
| `campaign_id` | String | `CAMP-001` | マーケ施策の流入元計測 |

保護画面ではクエリパラメータを使わない。予約IDはパスパラメータで渡す。

---

## 未決定事項

| # | 未決定事項 | 内容 | 決定チケット |
|---|---|---|---|
| 1 | URLスキーム名の最終確定 | `travelapp` を本番スキームとして採用するか（バンドルIDと合わせる場合あり） | BRAZE-010 |
| 2 | Universal Links / App Links の採用可否 | Web-to-App流入と通知deep linkを統一するか（Webサーバー側の設定が必要） | 別途ロードマップ |
| 3 | LoginScreen の source 明示渡し採用可否 | `canPop()` 依存のリスク（stale pendingPath・go_router 実装依存）を排除するため `extra` で遷移元を渡すか | BRAZE-017 |
| 4 | `pending_deep_link` の有効期限 | 保存した保留遷移先をどれくらい保持するか（例: 24時間・セッション中のみ） | BRAZE-017 |
