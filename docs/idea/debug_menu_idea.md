## 参考記事

ZOZO TECH BLOG デバッグメニューでFlutterのアプリ開発をスムーズに！
参考記事URL: https://techblog.zozo.com/entry/flutter-debug-menu

### 目次

- はじめに
- 背景・課題
- 解決策：デバッグメニューの導入
- デバッグメニューの呼び出し方法
- 実装した機能と具体的な活用場面
    1. ログ表示機能
    2. 画面遷移デバッグ
    3. SharedPreferencesデバッグ
    4. API通信モック機能の切り替え
    5. 時刻デバッグ機能
- まとめ

### はじめに

「ZOZOマッチ」は、ZOZOとして初めてFlutterを採用したモバイルアプリです。
ZOZOマッチの開発では、様々な状態を再現する作業に多くの時間を費やしており、効率化が課題となっていました。
本記事では、この課題を解決するデバッグメニューの作り方と効果的な機能を紹介します。

### 背景・課題

ZOZOマッチの開発業務の中で、コードレビューやバグ修正時に特定の状態を再現する作業が頻繁に発生しています。マッチングアプリという性質上、審査ステータス・写真の登録状態・時刻に依存するイベント・チュートリアルの表示状態など、非常に多くの状態が複雑に絡み合っています。これらの状態を手動で再現する作業は毎回10分以上かかり、エンジニアの集中力を削ぐだけでなく、状態の再現ミスによるバグの見逃しリスクも高まっていました。

アプリの画面数が100を超える規模となっており、特定の画面にたどり着くまでに複数の画面を経由します。さらに、期間限定キャンペーンや特定時刻の機能など、時間に依存したイベントのテストでは、その時刻になるまで待機するかシステム時刻を変更していました。

これらの非効率な作業により、本来の開発業務に集中できる時間が削られ、チーム全体の生産性低下を招いていました。

### 解決策：デバッグメニューの導入

これらの課題を解決するため、アプリ内にデバッグメニューを実装しました。

デバッグメニューは、開発・テスト時のみ使用できる特別な画面です。本番環境では動作しないため、セキュリティリスクを排除しています。この画面から、通常のユーザー操作では再現困難な様々な状態をUIから手軽に設定・再現できます。今回はそのデバッグメニューの中から効果的であった機能を紹介します。

デバッグメニューの呼び出し方法
デバッグメニューへのアクセス方法として、以下の2つの方法を実装しています。「端末を振る」については、shake_gestureパッケージを使用し、実現しました。

```dart
// 1. 端末を振る（ShakeGesture）
ShakeGesture.registerCallback
(
onShake: () {
// 遷移する動作
},
);

// 2. 同じタブを複数回連続タップ（5回の例）
if (tapCount.value == 5) {
// 遷移する動作
}
```

### 実装した機能と具体的な活用場面

#### 1. ログ表示機能

アプリ内のイベントやエラーを時系列で確認できる機能です。開発中の問題を素早く特定するために、[Talker](https://pub.dev/packages/talker)
を採用しました。

Talkerを選んだ理由は次のとおりです。

- 専用のログ画面があり、アプリ内で確認できる
- ログレベル（debug、info、warning、error）を色分け表示でき、視認性が高い
- 例外を自動で捕捉して記録できる
- Dio、Riverpod、BLoCなどの主要パッケージと統合できる
- フィルタリングで目的のログをすぐに絞り込める

Talker専用画面については、パッケージのREADMEに掲載されている[Web Demo](https://frezyx.github.io/talker/#/talker)
をご覧ください。

デバッグメニューでは、次のログを表示します。

- アプリケーション動作
    - 各画面のbuild実行とレンダリング状況
    - 画面遷移時のルート変更とスタックの変化
- 外部サービス連携
    - Google Analyticsのユーザー行動イベント（表示・いいね・画面表示）
    - 送信の成功/失敗と送信内容の事前検証
    - FirebaseのInstallation ID設定・更新
    - 各エンドポイントの接続状態と設定値
    - 認証/トークン処理の進行状況
- HTTP 通信
    - リクエスト（ボディ・ヘッダー・パラメータ）
    - レスポンス（ボディ・ステータスコード・処理時間）
- 設定・環境情報
    - アプリ名、バージョン、ビルド番号、パッケージ情報
    - 環境（開発/本番）の切り替え状況
    - デバッグリポジトリの使用状況

ログ画面はリアルタイムで更新され、新しいログが上部に追加されます。ログレベルやキーワードで絞り込みでき、必要な情報にすばやく到達できます。テキストとして共有する機能もあり、チーム内の情報共有が容易です。非エンジニアでも簡単にログを共有できる点は大きなメリットとなりました。

Talkerは特に他チームとの連携に役立ちました。具体的には、QAチームやデザイナーチームから不具合報告を受けた際、再現時のログをチケットに添付してもらう運用にしました。これにより、ログを確認するだけで「バックエンドのレスポンスが誤っているのか」「アプリ実装が間違っているのか」を即座に判別でき、調査の初動時間を大幅に短縮できました。こうした迅速な対応を実現できたのは、非エンジニアでも簡単にログを共有できる仕組みがTalkerに備わっていたからです。

アプリチーム単体でも多くの利点がありました。Crashlyticsとの連携設定が容易で、Google
Analytics導入時にはイベント送信の正しさを即座に確認でき、デバッグメニューでは難しい検証を補完できました。さらに、常に画面のルーティング情報が出力されるため、階層の深い画面にいても自分の位置を即座に把握できる点も便利でした。

この機能により、デバッグ時間の短縮、予期しないエラーの早期発見、API通信の可視化、状態管理の理解促進、分析イベントの検証を実現し、開発効率が大きく向上しました。

#### 2. 画面遷移デバッグ

アプリ内の任意の画面へワンタップで直接遷移できる機能です。検索と履歴を備え、開発中の移動コストを下げます。ZOZOマッチの画面数は100を超えるため、通常操作では深い階層（例：オンボーディング途中の全身写真を登録する画面）への到達が手間でした。

この機能はZOZOマッチの遷移で採用しているgo_routerの仕組みを応用することで実現しています。この記事では詳細を割愛しますが、RouteConfigurationから定義済みのパス情報を抽出する仕組みにすることで、新規画面の追加時も追加実装が不要な作りにしています。

画面遷移デバッグでは様々な機能が搭載されています。実際の画面をもとに、機能詳細を解説していきます。

1. 画面IDをテキスト入力して遷移したい画面を検索できる機能。ZOZOマッチには100種類以上の画面があるため、この検索機能で目的の画面へすぐアクセスが可能。
2. 直近でデバッグメニューから遷移した画面の履歴を表示する機能。特定の画面へ繰り返し遷移する際に履歴から開けるので、毎回検索する手間を省ける。
3. 全てのルートをリスト形式で表示する。この一覧をタップすると該当の画面へ1ステップで移動ができる。

このツールにより、深い階層の画面へ数秒で移動でき、開発時間を短縮できました。全画面を容易に確認できるため、リグレッションの早期発見にも有効です。

現在の課題は、ユーザー固有の画面（例：相手のプロフィール）へ遷移する際に、ユーザーIDなどのパラメータを指定できず、動的ルートに対応できていない点です。今後は、パラメータ入力に対応した遷移デバッグの実装を検討しています。

#### 3. SharedPreferencesデバッグ

SharedPreferencesに保存されているデータの確認・編集機能です。アプリ内の各種フラグや設定値を管理するSharedPreferencesの値を、開発中に簡単に確認・変更できるデバッグ画面として実装しています。

ZOZOマッチでは、チュートリアル表示フラグやIn-App
Reviewのリクエスト制御など、通常は特定の条件でしか変更されない値が多数存在します。これらの値を手動で操作できることで、開発・テスト効率が向上しました。

例えば、チュートリアルの再確認では、一度表示した後は通常再表示されないためデザイン変更や修正後の確認が難しい状況でしたが、フラグを任意のタイミングでリセットすることにより再表示が可能になりました。また、In-App
Reviewのテストでは、同一ユーザーには一定期間レビューを表示しないフラグを制御できるため、表示履歴を削除し、開発中に何度でも表示をテストできるようになりました。

この機能により、検証のリードタイムを短縮し、開発サイクルを高速化できます。

#### 4. API通信モック機能の切り替え

バックエンド開発と並行してフロントエンドを進める際、未実装APIや再現しづらいレスポンスが課題でした。本番用Repositoryとダミーデータを返すDebugRepositoryを切り替え、API通信をモック化できるようにしました。切り替えはデバッグメニューから行えます。

API通信モック機能の切り替画面

実装アプローチは以下のとおりです。

DebugRepositoryは本番Repositoryを継承し、必要なメソッドのみをオーバーライドしています。

```dart
// 本番用Repository
class UserRepository {
  Future<User> getUserById(String id) async {
    final response = await apiClient.get('/users/$id');
    return User.fromJson(response.data);
  }
}

// Debug用Repository
class DebugUserRepository extends UserRepository {
  @override
  Future<User> getUserById(String id) async {
    // ダミーデータを返す
    return User(
      id: id,
      name: 'テストユーザー',
      age: 25,
    );
  }
}
```

Riverpodによる動的切り替えでは、デバッグフラグに応じてRepositoryを実行時に切り替えます。

```dart
// Providerでの使用例
@riverpod
UserRepository userRepository(Ref ref) =>
    selectRepositoryByBuildMode(
      // 本番用のRepository
          () =>
          UserRepository(
            apiClient: ref.watch(apiClientProvider),
          ),
      // デバッグ用の設定
      debugConfig: (
      factory: () => DebugUserRepository(),
      enabled: ref.watch(isDebugModeProvider),
      ),
    );
```

全てのRepositoryで統一的に切り替えられるよう、selectRepositoryByBuildMode という共通ヘルパーを用意しています。

```dart
T selectRepositoryByBuildMode<T>(T Function() releaseOrProfile, {
  ({T Function() factory, bool enabled})? debugConfig,
}) {
  // リリースビルドでは常に実APIを使用
  if (!kDebugMode) {
    return releaseOrProfile();
  }

  // デバッグビルドでフラグがONの場合はDebugRepositoryを使用
  if (debugConfig != null && debugConfig.enabled) {
    final debugInstance = debugConfig.factory();
    return debugInstance;
  }

  // それ以外は実APIを使用
  return releaseOrProfile();
}
```

この仕組みにより、次が可能になります。

- ビルドモード連動 - kDebugModeでリリースビルドを判定し、本番では常に実APIを使用
- 動的切り替え - デバッグビルドでは画面上のトグルで即座に切り替え
- 可視化 - 現在使用中のRepositoryをコンソールで確認

また、デバッグメニューに統合したことで、画面上のトグルで手早くモック機能を切り替え、本番APIとモックデータを用途に応じて使い分けられます。

API通信モックを導入したことで、APIの実装完了を待たずにUIを実装・確認でき、バックエンドとフロントエンドの並行開発が可能になりました。また、空リスト・大量データ・特殊文字列などのデータパターンを簡単に再現でき、動作確認が容易になりました。

バグ修正時は、DebugRepositoryでレスポンスを任意に制御し、エラー状態を即時に再現・検証できます。

#### 5. 時刻デバッグ機能

ZOZOマッチでは特定時刻の機能が多く実装されており、その動作確認が開発の大きな課題となっていました。チャンスタイム1やレコメンド更新2など、特定の時刻でのみ動作する機能をテストするために、従来は端末の時刻設定を変更する必要がありました。しかし、これによりバックエンドから取得できるデータとの整合性に問題が発生しました。

この問題を解決するため、サーバー時刻ヘッダー機能を導入しました。すべてのAPIレスポンスに含まれるdateヘッダーからサーバー時刻を取得し、端末時刻との差分（オフセット）を計算します。これにより、端末の時刻設定に依存しない正確な時刻を取得できるようになりました。

```dart
// 従来の実装（端末時刻に依存）
final now = DateTime.now(); // 端末の時刻設定に影響される

// 新しい実装（サーバー時刻を使用）
final now = serverTimeClock.now(ref); // サーバー時刻を基準とした正確な時刻
```

デバッグビルドでは、特別なヘッダーx-znm-debug-timerに任意の時刻を指定できます。サーバー側はそれを受け取り、dateヘッダーとは別でx-znm-debug-timer-responseに特殊な時刻を設定してくれる仕組みになっています。この仕組みを利用し、アプリ内だけで有効な仮想時刻を使い、特定時刻の機能を検証します。任意の時刻はデバッグメニューから容易に切り替えでき、テスト効率が向上します。

例えば、「20:
20」など特定の時刻にのみ動作する機能のテストに活用することにより、任意のタイミングで動作確認が可能になりました。これにより、端末時刻の変更に伴う副作用を排除し、特定時刻の機能を安全かつ効率的に検証できるようになりました。

### まとめ

本記事では、Flutterのデバッグメニュー構築を紹介しました。デバッグメニューは、単なる効率化を超えて、チームの働き方と開発体験を変える基盤になり得ます。今後も実運用のフィードバックを取り込み、より多くの検証・開発フローで最適化を進めていきます。

## 実装方針

### フェーズ1：デバッグメニュー画面 + Talkerログ表示

#### パッケージ

| パッケージ | バージョン | 用途 |
|---|---|---|
| `talker_flutter` | 5.1.20 | Talker コア + アプリ内ログ画面（`TalkerScreen`） |
| `talker_riverpod_logger` | 5.1.20 | Riverpod の state 変化を Talker に流す observer |

`logger` パッケージは削除。

#### Talker インスタンス

`lib/utils/talker.dart` でグローバルインスタンスを定義。

```dart
// lib/utils/talker.dart
final Talker talker = TalkerFlutter.init();
```

#### 既存 logger との互換

`lib/utils/logger.dart` を Talker ラッパーに置き換え。
`TalkerShortcuts` extension で `d/i/w/e()` ショートカットを定義し、既存の `logger.d()` / `logger.e()` 呼び出し箇所は無変更のまま維持。

```dart
// lib/utils/logger.dart
extension TalkerShortcuts on Talker {
  void d(dynamic message) => debug(message?.toString());
  void i(dynamic message) => info(message?.toString());
  void w(dynamic message) => warning(message?.toString());
  void e(dynamic message) => error(message?.toString());
}

final Talker logger = talker;
```

#### Riverpod observer 統合

`main.dart` の `ProviderScope` に `TalkerRiverpodObserver` を追加。
Riverpod の provider 追加・更新・破棄・エラーが自動でログに流れる。

```dart
ProviderScope(
  observers: [
    UnauthorizedErrorObserver(),
    TalkerRiverpodObserver(talker: talker),
  ],
  ...
)
```

#### デバッグメニュー画面

`lib/presentation/debug/screen.dart` を新規作成。
現時点のメニュー項目は「ログ表示」のみ。タップで `TalkerScreen(talker: talker)` へ遷移。

```
lib/presentation/debug/
  screen.dart   ← デバッグメニュー一覧
```

#### ルーティング

`lib/router/router.dart` に `/debug` ルートを追加。
`kDebugMode` で条件分岐し、リリースビルドではルート自体が存在しない。

```dart
if (kDebugMode)
  GoRoute(
    path: DebugMenuScreen.path,
    builder: (context, state) => const DebugMenuScreen(),
  ),
```

#### 呼び出し入口

`TodoListScreen` の `CoreAppBar` actions に `kDebugMode` 限定のバグアイコンを追加。
タップで `context.toDebugMenuScreen()` を呼び出す（go_router の NavigationExtension 経由）。

```dart
if (kDebugMode)
  IconButton(
    onPressed: () => context.toDebugMenuScreen(),
    icon: const Icon(Icons.bug_report_outlined),
  ),
```

#### 変更ファイル一覧

| ファイル | 変更種別 |
|---|---|
| `pubspec.yaml` | `logger` 削除、`talker_flutter` / `talker_riverpod_logger` 追加 |
| `lib/utils/talker.dart` | 新規：グローバル Talker インスタンス |
| `lib/utils/logger.dart` | 置き換え：Talker ラッパー + `d/i/w/e` extension |
| `lib/main.dart` | `TalkerRiverpodObserver` を observers に追加 |
| `lib/presentation/debug/screen.dart` | 新規：デバッグメニュー画面 |
| `lib/router/router.dart` | `/debug` ルート追加（`kDebugMode` 限定） |
| `lib/presentation/home/todo_list/screen.dart` | AppBar にデバッグアイコン追加（`kDebugMode` 限定） |


#### Android Studio でデバッグ起動手順

前提

- Android Studio インストール済み
- Flutter / Dart プラグイン導入済み
- Android エミュレータ作成済み

手順

1. エミュレータ起動

Device Manager（右サイドバー or メニュー: View > Tool Windows > Device Manager）を開き、対象の AVD の ▶ をクリック。

2. プロジェクトを開く

File > Open で travel_app/ を選択。

3. 実行構成を確認

ツールバーの実行構成ドロップダウンが main.dart になっていることを確認。

4. デバッグ実行

ツールバーの虫アイコン（🐛 Debug）をクリック、またはショートカット ^D（Mac）/ Shift+F9（Win/Linux）。

→ これが kDebugMode = true でのビルド・起動。

確認ポイント

起動後、TodoList 画面の AppBar 右上にバグアイコン（🐛）が表示されていれば kDebugMode = true で動作している。

---
補足：実行モードの違い

| 実行方法 | kDebugMode | kProfileMode | kReleaseMode |
|---|---|---|---|
| Debug（虫アイコン / ^D） | true | false | false |
| Run（▶ / ^R） | true | false | false |
| Profile | false | true | false |
| Release | false | false | true |

▶ Run も kDebugMode = true なので、デバッグアイコンは表示される。厳密にブレークポイントを使いたい場合のみ Debug を使う必要がある。

---

#### Talkerログの活用・整理メモ

##### Claude Codeへのバグ調査依頼への活用

ログをそのまま貼り付けることで、Claude Codeが「問題がどの層で起きたか」を即座に特定できる。

**バグ報告の粒度が変わる例**
- Before: 「Todo画面が表示されない」
- After: ログ + 「`riverpod-update` で `AsyncLoading` → `AsyncData` の遷移が起きていない」

| シーン | 使えるログ |
|---|---|
| API疎通確認 | `[debug] APIリクエスト` + `[info] レスポンスボディ` |
| Providerの依存関係確認 | `[riverpod-add]` の初期化順序 |
| データがUIに届かない | `riverpod-update` の PREVIOUS→NEW 遷移 |
| 認証エラー | `[debug] リクエストヘッダー` のトークン確認 |

##### 各ログの評価

| ログ種別 | 評価 | 理由 |
|---|---|---|
| `[riverpod-add]` Provider初期化 | **必要** | 依存関係の確認・初期化失敗の特定に必須 |
| `[debug] APIリクエスト` | **必要** | URL・ヘッダー・リトライ回数の確認 |
| `[info] レスポンスボディ` | **必要** | APIレスポンスが正しいかの一次確認 |
| `[riverpod-update]` 型変化部分 | **必要** | AsyncLoading/AsyncData/AsyncError遷移の確認 |
| `PREVIOUS/NEW state` のデータ全量 | **冗長（正常時）** | 30件リスト等が毎回展開されノイズになる |
| `Instance of 'XXX'` の初期化state | **冗長** | ほぼ定型で情報量が低い |

##### `riverpod-update` フルstate出力の問題点

現状のログで最も冗長。1エントリに30件のTodoリストが2回（PREVIOUS / NEW）展開される。

```
[riverpod-update] TodoListScreenNotifier updated
PREVIOUS state: AsyncData(value: TodoListScreenState(todos: [30件フルテキスト...]))
NEW state:      AsyncLoading(value: TodoListScreenState(todos: [同じ30件...]))
```

- **ノイズ** — stateが大きいほど1エントリが巨大になり、Talker画面でスクロールが大変
- **差分が見えない** — 変化点（`AsyncData → AsyncLoading`）が大量のtodos展開に埋もれる

**対処案**: `TalkerRiverpodObserver`内の`TalkerRiverpodLoggerSettings`をカスタマイズすることでログ表示/非表示の設定が可能

```dart
ProviderScope(
  observers: [
    UnauthorizedErrorObserver(),
    TalkerRiverpodObserver(
        talker: talker,
        settings: const TalkerRiverpodLoggerSettings(
            printProviderAdded: false,
            printProviderUpdated: false,
        ),
    ),
  ],
  ...
)
```

---

### フェーズ2：API通信モック切り替え

#### 参考記事との差分

参考記事は **Repository 層**で切り替え（`DebugUserRepository extends UserRepository`）。
このプロジェクトは Service 層に既に Interface（`TodosApiService` 等）が存在するため、**Service 層**で切り替える方が自然かつ影響範囲が小さい。

#### 設計

```
isStubApiEnabledProvider（NotifierProvider<bool>）
        ↓ watch
todosApiServiceProvider（Provider<TodosApiService>）← スタブ or 実API を返す統合Provider
        ↓ watch
todoRepositoryProvider  ← Repository 側の変更なし（引数の型は元から Interface のまま）
```

**フラグが変わったときの連鎖**:
1. `isStubApiEnabledProvider` 更新
2. 統合 Provider（`todosApiServiceProvider` 等）が再評価
3. Repository Provider が再生成 → SSOT キャッシュ（`_isFetched` / `_todos`）もリセット
4. `todosStreamProvider` が再構築 → UI 自動更新

#### 実装ファイル一覧

| ファイル | 内容 |
|---|---|
| `lib/data/services/web_api/stub_api_enabled_provider.dart` | 新規：`isStubApiEnabledProvider`（`NotifierProvider<bool>`） |
| `lib/data/services/web_api/todos/service_impl.dart` | `todosApiServiceProvider`（統合 Provider）追加 |
| `lib/data/services/web_api/users/service_impl.dart` | `usersApiServiceProvider` 追加 |
| `lib/data/services/web_api/products/service_impl.dart` | `productsApiServiceProvider` 追加 |
| `lib/data/repositories/todo/todo_repository.dart` | `ref.read` → `ref.watch(todosApiServiceProvider)` に変更 |
| `lib/data/repositories/user/user_repository.dart` | `ref.read` → `ref.watch(usersApiServiceProvider)` に変更 |
| `lib/presentation/debug/screen.dart` | `SwitchListTile` 追加（`StatelessWidget` → `ConsumerWidget` に変更） |

#### 主要実装コード

**`stub_api_enabled_provider.dart`**

```dart
final NotifierProvider<StubApiEnabledNotifier, bool> isStubApiEnabledProvider =
    NotifierProvider<StubApiEnabledNotifier, bool>(StubApiEnabledNotifier.new);

class StubApiEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  bool get enabled => state;
  set enabled(bool value) => state = value;
}
```

**統合 Provider（各 `service_impl.dart` に追加）**

```dart
// todos の例。users / products も同様
final todosApiServiceProvider = Provider<TodosApiService>((ref) {
  // リリースビルドでは常に実 API
  if (!kDebugMode) {
    return TodosApiServiceImpl(apiClient: ref.read(apiClientProvider));
  }
  final isStub = ref.watch<bool>(isStubApiEnabledProvider);
  return isStub
      ? StubTodoApiServiceImpl()
      : TodosApiServiceImpl(apiClient: ref.read(apiClientProvider));
});
```

**Repository Provider の変更**

```dart
// ref.read → ref.watch に変更し、統合 Provider を参照する
final todoRepositoryProvider = Provider<TodoRepository>(
  (ref) => TodoRepository(
    todoApiService: ref.watch(todosApiServiceProvider),
  ),
);
```

**デバッグメニューへのトグル追加**

```dart
SwitchListTile(
  secondary: const Icon(Icons.cloud_off_outlined),
  title: const Text('APIモック'),
  subtitle: Text(isStub ? 'スタブ' : '実API'),
  value: isStub,
  onChanged: kDebugMode
      ? (value) => ref.read(isStubApiEnabledProvider.notifier).enabled = value
      : null,
),
```

#### 備考

- `auth/login/` は `stub_service_impl.dart` が未実装のため対象外
- `products` の Repository は未作成のため Repository 側の変更はなし（統合 Provider のみ追加済み）
- `StateProvider` は Riverpod 3.x で廃止済み → `NotifierProvider` を使用

---

#### テスト方針

新しい Service 層を追加するときは、以下の 3 ファイルを必ずテストする。

| テスト対象 | テストファイル配置 |
|---|---|
| `*ApiServiceImpl`（実装クラス）| `test/data/services/web_api/{endpoint}/` |
| `Stub*ApiServiceImpl`（Fake クラス）| 同上（既存テストファイルに追記） |
| `*ApiServiceProvider`（統合 Provider）| 同上（既存テストファイルに追記） |
| `StubApiEnabledNotifier` | `test/data/services/web_api/mock_api_enabled_provider_test.dart`（共通・追加不要） |

---

##### 1. `*ApiServiceImpl` のテスト

実装クラス本体のテスト。他のサービス実装と変わらない。

```dart
group('fetch', () {
  test('取得成功時、SuccessResult を返すこと', () async { ... });
  test('ApiClientException 発生時、FailureResult を返すこと', () async { ... });
  test('その他例外発生時、FailureResult を返すこと', () async { ... });
});
```

---

##### 2. `Stub*ApiServiceImpl` のテスト

Fake クラスが Interface を正しく実装しており、スタブデータを返すことを検証する。
「Fake 自体が正しく動くか」を担保することで、Repository / Notifier のテストで Fake を使う際の前提条件を保証できる。

```dart
group('Stub*ApiServiceImpl', () {
  late Stub*ApiServiceImpl fakeService;

  setUp(() {
    fakeService = Stub*ApiServiceImpl();
  });

  // Provider 宣言行（stub_service_impl.dart の先頭）もカバレッジに含めるため Provider テストを置く
  test('stub*ApiServiceImplProvider は Stub*ApiServiceImpl を返すこと', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(stub*ApiServiceImplProvider), isA<Stub*ApiServiceImpl>());
  });

  test('fetch は SuccessResult を返すこと', () async { ... });
  test('Interface を実装していること', () { expect(fakeService, isA<*ApiService>()); });
  test('返却データは必須フィールドを持つこと', () async { ... });
});
```

**ポイント**: `stub_service_impl.dart` の先頭 2 行（Provider 宣言）は Provider テストを置かないとカバレッジ 0 になる。`addTearDown(container.dispose)` を使えば `tearDown` を別途書かなくて済む。

---

##### 3. 統合 Provider（`*ApiServiceProvider`）のテスト

モック切り替えの核心部分。3 つのケースを検証する。

```dart
group('*ApiServiceProvider', () {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        // 実 ApiClient が不要なようにダミーを注入
        apiClientProvider.overrideWithValue(MockApiClient()),
      ],
    );
  });

  tearDown(() { container.dispose(); });

  test('isStub=false のとき *ApiServiceImpl を返すこと', () {
    // isStubApiEnabledProvider のデフォルトは false なので overrides 不要
    expect(container.read(*ApiServiceProvider), isA<*ApiServiceImpl>());
  });

  test('isStub=true のとき Stub*ApiServiceImpl を返すこと', () {
    container.read(isStubApiEnabledProvider.notifier).enabled = true;
    expect(container.read(*ApiServiceProvider), isA<Stub*ApiServiceImpl>());
  });

  test('isStub=false → true → false と切り替えると型が変わること', () {
    expect(container.read(*ApiServiceProvider), isA<*ApiServiceImpl>());
    container.read(isStubApiEnabledProvider.notifier).enabled = true;
    expect(container.read(*ApiServiceProvider), isA<Stub*ApiServiceImpl>());
    container.read(isStubApiEnabledProvider.notifier).enabled = false;
    expect(container.read(*ApiServiceProvider), isA<*ApiServiceImpl>());
  });
});
```

**ポイント一覧**:

| ポイント | 理由 |
|---|---|
| `apiClientProvider` をオーバーライドする | 統合 Provider 内部で `*ApiServiceImpl` を生成する際に `apiClientProvider` を読む。オーバーライドしないと未提供エラーになる |
| `isStubApiEnabledProvider` はオーバーライド不要 | デフォルト `false` のため、切り替えテストは `notifier.enabled = true/false` で行う |
| `ProviderContainer` を各テストで使い回す | `isStub` のトグルが同一コンテナ内で伝播することを確認するため |
| `if (!kDebugMode)` ブランチは coverage:ignore | `flutter test` は常に `kDebugMode = true` なので到達不能。`// coverage:ignore-start` / `// coverage:ignore-end` で除外する |

---

##### 4. カバレッジ確認（`fix-and-test.sh`）

`scripts/fix-and-test.sh` の `lcov --extract` パターンに `service_impl.dart`（プレフィックスなし）を追加済み。新しいエンドポイントを追加しても同パターンで自動収集される。

```sh
lcov --extract coverage/lcov.info 'lib/data/**/*_service_impl.dart' \   # fake_*_service_impl.dart など
  --extract coverage/lcov.info 'lib/data/**/service_impl.dart' \         # service_impl.dart（実装本体）
  ...
```

`*_service_impl.dart` は `_` プレフィックスを要求するため `service_impl.dart` 単体にはマッチしない。**両パターンが必要**。
