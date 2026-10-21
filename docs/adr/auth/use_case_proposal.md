# ログイン機能 ユースケース提案

## 背景・目的

現状は `router.dart` の `redirect` でアクセストークンの有無を毎回チェックし、
未ログインであれば一律 LoginScreen へ強制遷移させている。

```dart
// 現状（router.dart）
redirect: (context, state) async {
  final loggedIn = await ref.read(authUseCaseProvider).checkIsLoggedIn();
  if (!loggedIn) return LoginScreen.path;   // 未ログインは全画面でブロック
  if (loggingIn) return TodoListScreen.path;
  return null;
},
```

この制約を取り除き、**未ログインでもアプリを利用できる**ように変更する。

---

## ユースケース

### パターンA: 未ログイン状態でのアプリ利用（匿名ユーザー）

**誰が・どういう時に・何をする**
未登録ユーザーが初回起動時にそのままアプリを使い始める。

**振る舞い**
- ログイン画面を経由せず TodoListScreen を表示する
- `anonymous_id`（UUID）を SecureStorage に生成・保存し、以降の操作に紐付ける
- Braze のカテゴリ配信など Push 通知のターゲティングに anonymous_id を使用する

**今回対応する:** ✅  
**対応箇所:** `router.dart` の redirect 除去、`AuthRepository` への anonymous_id 管理追加

---

### パターンB: 任意画面のログインボタン押下

**誰が・どういう時に・何をする**
未ログインユーザーが画面内の「ログインボタン」を押下する。

**振る舞い**
1. LoginScreen に遷移（GoRouter で push）
2. LoginScreen はタブ構成（ログイン / 新規登録）
   - **ログインタブ**: email / password 入力 → `/auth/login` を呼ぶ
   - **新規登録タブ**: email / password / displayName 入力 → `/auth/register` を呼ぶ
3. 処理中はオーバーレイローディング表示（背景黒・中央スピナー）
4. 完了後 → TodoListScreen に遷移（`go`）
   - 将来的に「遷移元 URL を extra で渡して戻る」に拡張予定（issue 起票）
5. 処理失敗はエラーメッセージ表示 → パターンE 参照

**今回対応する:** ✅  
**対応箇所:** `LoginScreen`（タブ UI・ローディング UI）、`LoginScreenNotifier`（連打防止・isLoading state）

---

### パターンC: ログイン必須画面への遷移（予約詳細など）

> **詳細設計**: `docs/adr/push_notification/phase1_research_and_design/braze_004.md`
> - ハードガード / ソフトガードの分類基準
> - `pending_deep_link` の保留遷移フロー（冷起動含む）
> - `router.dart` / `AuthUseCase` / `LoginNotifier` / `LoginScreen` の責務分担

**誰が・どういう時に・何をする**
未ログインユーザーがログイン必須の画面（予約詳細など）に遷移しようとする。

**振る舞い**
1. GoRouter の redirect でログイン必須フラグを検知
2. LoginScreen へ強制遷移（`extra` に `redirectPath` を持たせる）
3. ログイン完了後 → 元の画面へ自動リダイレクト

**今回対応する:** ❌（パターンB の後に対応。issue 起票）  
**理由:** 対象画面（予約詳細）が未実装のため

---

### パターンD: ログイン後の userId × anonymous_id 紐付け

**誰が・どういう時に・何をする**
anonymous_id 状態でアプリを使っていたユーザーがログインする。

**振る舞い**
- ログイン成功後、`/auth/login` レスポンスの `user.id` を SecureStorage に保存
- Braze の `changeUser(userId)` で anonymous_id → userId に切り替える
- anonymous_id 期間のイベントが Braze 側でマージされる

**今回対応する:** ✅（Braze 連携部分は BRAZE-013 の既存フローに乗る）  
**対応箇所:** `AuthRepository.login()`

---

### パターンE: ログイン / 新規登録の失敗（異常系）

**誰が・どういう時に・何をする**
ユーザーがログインまたは新規登録を実行したが、処理が失敗する。

**失敗ケースと UI 表示**

| ケース | HTTPステータス | エラーメッセージ |
|---|---|---|
| メールアドレス / パスワード不一致 | 401 | 「メールアドレスまたはパスワードが正しくありません」 |
| メールアドレス重複（登録時） | 409 | 「このメールアドレスはすでに登録されています」 |
| バリデーションエラー | 422 | 「入力内容を確認してください」 |
| ネットワーク接続エラー | — | 「通信エラーが発生しました。再度お試しください」 |
| その他サーバーエラー | 5xx | 「しばらく時間をおいてから再度お試しください」 |

**振る舞い**
1. 処理失敗 → `LoginScreenNotifier` が `AppError` を `throw`（`AsyncError` に変換）
2. オーバーレイローディングを非表示（`isLoading = false`）
3. ログインボタンが再度タップ可能な状態に戻る
4. エラーメッセージをフォーム上部に表示（`AsyncError` を `ref.watch` で検知）
5. ユーザーが入力を修正 → 再度ボタン押下で再試行可能

**状態遷移イメージ**

```
初期状態（isLoading: false, error: null）
  ↓ ログインボタン押下
isLoading: true（オーバーレイ表示）
  ↓ API 失敗
AsyncError（isLoading: false）
  ↓ View が AsyncError を検知
エラーメッセージ表示 + ボタン再活性
```

**今回対応する:** ✅  
**対応箇所:** `LoginScreenNotifier`（throw による AsyncError 変換）、`LoginScreen`（AsyncError 時のエラーメッセージ Widget）

---

## 今回対応しないもの（issue 起票）

| パターン | 内容 | 理由 |
|---|---|---|
| パターンC | ログイン必須画面への自動リダイレクト | 対象画面未実装 |
| パターンB 拡張 | ログイン後に遷移元画面へ戻る | パターンB 完成後に対応 |

---

## 既存コードの修正点

### 1. APIリクエストの `username` → `email` 修正

`openapi.yaml` の `/auth/login` は `email` フィールドを要求しているが、
既存実装は `username` を使用している。

```yaml
# openapi.yaml（正）
/auth/login:
  requestBody:
    properties:
      email:    # ← email
        type: string
      password:
        type: string
```

```dart
// 既存コード（誤）
Future<Result<void>> login({
  required String username,   // ← username になっている
  required String password,
})
```

**修正対象ファイル:**
- `lib/domain/use_cases/auth/auth_use_case.dart`
- `lib/data/repositories/auth/auth_repository.dart`
- `lib/data/services/web_api/auth/login/service.dart` （および impl）
- `lib/presentation/login/notifier.dart`
- `lib/presentation/login/screen.dart`（TextFieldのラベル・hintText）

### 2. `LoginDto` → `TokenResponseDto` への置き換え

`openapi.yaml` の `TokenResponse` スキーマは `/auth/login` と `/auth/register` の両エンドポイントで共通して使用される。既存の `LoginDto` は `user` フィールドを持たず、登録エンドポイントと共有もできていないため、`TokenResponseDto` として再定義する。

```yaml
# openapi.yaml（TokenResponse）
TokenResponse:
  properties:
    accessToken: string
    refreshToken: string
    user:
      $ref: '#/components/schemas/User'   # ← 既存 LoginDto に存在しない

User:
  properties:
    id: string (uuid)
    email: string
    displayName: string (nullable)
```

**方針:**
- `lib/data/services/web_api/auth/login/dto.dart` の `LoginDto` を廃止
- `lib/data/services/web_api/auth/dto.dart` に `TokenResponseDto` / `UserDto` を新規作成（login・register 共用）
- `AuthRepository.login()` と `AuthRepository.register()` の両方から参照する

**修正対象ファイル:**
- `lib/data/services/web_api/auth/dto.dart`（新規作成: `TokenResponseDto` / `UserDto`）
- `lib/data/services/web_api/auth/login/dto.dart`（削除）
- `lib/data/repositories/auth/auth_repository.dart`（`LoginDto` → `TokenResponseDto` 参照に変更）

### 3. `router.dart` の redirect 変更

> **詳細設計（責務分担・具体例・エッジケース）**: `docs/adr/push_notification/phase1_research_and_design/braze_004.md` — セクション 6「router.dart 修正方針」

未ログインでもメイン画面を表示できるよう、全画面ブロックを撤廃する。
ログイン必須画面のみ個別に guard をかける構成に変更。

```dart
// 変更後イメージ
redirect: (context, state) async {
  // ログイン必須パスのリストに含まれていれば LoginScreen へ
  const requiresAuth = ['/booking/detail']; // 将来拡張
  if (requiresAuth.any((p) => state.matchedLocation.startsWith(p))) {
    final loggedIn = await ref.read(authUseCaseProvider).checkIsLoggedIn();
    if (!loggedIn) return LoginScreen.path;
  }
  return null;
},
```

---

## ログイン画面の UI 仕様

### ローディング表示

```
ログインボタン押下
  ↓
state.isLoading = true
  ↓
Stack(
  children: [
    _LoginForm(),           // 通常のフォーム（操作不可）
    if (isLoading)
      ColoredBox(           // 背景黒・半透明オーバーレイ
        color: Colors.black54,
        child: Center(child: CircularProgressIndicator()),
      ),
  ],
)
```

### 連打防止

`LoginScreenState` に `isLoading` フラグを持たせ、
`true` の間はログインメソッドを早期 return する。

```dart
Future<void> login({required String email, required String password}) async {
  if (state.value?.isLoading ?? false) return;  // 連打防止
  state = AsyncData(state.value!.copyWith(isLoading: true));
  // ...
}
```

---

## 設計にした理由

- **未ログイン状態を first-class に扱う**: 強制ログインはコンバージョン障壁になる。
  anonymous_id を持たせることで Push 通知の配信対象にも含められる。
- **パターンC（リダイレクト）を後回し**: 対象画面が存在しない状態で実装しても
  動作確認できないため YAGNI で省く。先に B を完成させてから拡張する。
- **ローディングはオーバーレイ方式**: ボタンの disabled 切替だけだとタップ中の
  視覚フィードバックが薄い。背景暗転で「処理中」を明示する。
