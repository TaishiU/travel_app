# テスト戦略・方針

## 基本思想

**目的**: 変化を可能にするための信頼性の高いテストスイートの構築  
**指針**: テストサイズ（Small/Medium/Large）で分類し、**Integration × Small** を最厚にするピラミッドを構築する

### なぜテストを書くのか

| 目的 | 視点 | 帰結 |
|---|---|---|
| **コスト削減** | テスト = 手動テストを自動化してコストを下げるツール | 学習・保守コストが積み上がり「やめる」判断へ |
| **変化を可能にする** | テスト = 変更時の安全網 | 変更のたびにコストが回収される |

コスト削減目的は「手動テストを自動化すれば楽になる」という動機で始まるが、自動テストの学習コスト・保守コストが積み上がり、期待したコスト削減効果が出ないと判断されて手動テストへ戻ってしまう。
変化目的は「テストなしに変更するコスト（恐怖・手動確認・デグレ）」を正面に置く。

### テストの本質

リグレッション検知（変更でコードが壊れたことを検知する）は正しい。ただし、それだけではない。

**テストは「壊れたことを教えてくれる道具」であると同時に、「変更することへの心理的障壁を取り除く道具」でもある。**

テストがなければ変更が怖くなり、変更しなくなる。信頼性の高いテストがあれば変更が気軽になり、コードがクリーンな状態を保てる。

| 状況 | 結果 |
|---|---|
| テストなし | 変更が怖い → 変更しない → コードが硬直化 |
| フラジャイル（壊れやすい）なテスト（mockito乱用） | リファクタリングでテストが壊れる → 変更が面倒 → やはり変更しない |
| ****信頼性の高いテスト（スタブ注入）**** | 変更しても30秒で安全確認 → 気軽に変更できる → コードが常にクリーン |

「コードが変化し続けられる状態を維持する」 = ソフトウェアが「ソフト（変更容易）」であり続けること。

*フラジャイルなテスト（mockito乱用）の詳細は「**テストダブル：mockito vs スタブ**」セクションを参照。

---

## テスト仕様の設計原則（契約による設計）

AIにテストコードを高精度で実装させるための核心。**3条件を先に設計することで、AIが「何をテストすべきか」を自力推測せずに済む。**

### 3条件の定義

| 条件 | 定義 | Dartでの対応 |
|---|---|---|
| **事前条件** | メソッド実行前に満たすべき条件 | コンストラクタ・メソッドの引数バリデーション |
| **事後条件** | メソッド実行後に満たすべき条件 | 戻り値・state変化の期待値 |
| **不変条件** | インスタンス生存中の常に満たすべき条件 | Freezedの不変オブジェクト・値オブジェクトのガード節 |

### 本プロジェクトへの適用

```
事前条件: 正常系・異常系の入力境界（null, 空文字, 範囲外値 等）
事後条件: UseCase/Repository が返す Result の内容、Notifier の state 遷移先
不変条件: Entity/値オブジェクトの制約（Freezed + コンストラクタガード）
```

3条件のないテストは**自作自演**または**偽陰性**のリスクが高い。
テストを書く前に3条件を仕様として言語化する。

| 種類 | 定義 |
|---|---|
| 自作自演 | テストコード側で、プロダクトコードと同じ計算式や期待する振る舞いをそのまま再現・トレースしてしまい、実質的に検証になっていない状態 |
| 偽陽性 | プロダクトコードは悪くない（正しい）のに、テストが失敗する状態 |
| 偽陰性 | プロダクトコードにバグ（誤り）があるのに、テストが失敗しない（成功してしまう）状態 |

---

## テストサイズとFlutter対応

| テストサイズ | 定義 | Flutterでの対応 |
|---|---|---|
| Small | 1プロセス内 | `flutter_test`（unit test / widget test） |
| Medium | 1マシン内 | ローカルモックサーバー + `flutter_test` |
| Large | 複数マシン / 実デバイス | `integration_test`（実機 / エミュレータ） |

---

## テストダブル：mockito vs スタブ

### mockitoとは

「特定のメソッドが呼ばれたかどうか」と「その呼び出しに何を返すか」を制御するツール。

```dart
when(mockUseCase.toggleTodo(1)).thenAnswer((_) async => SuccessResult(null));
verify(mockUseCase.toggleTodo(1)).called(1); // ← 呼ばれたことを検証
```

### 乱用の本質

mockitoの問題は道具そのものではなく「内部の呼び出し構造をテストの正解にしてしまう」こと。

- `verify(mock.method()).called(1)` = 「このメソッドがこの回数呼ばれること」を仕様とする
- → リファクタリングで内部構造が変わるたびにテストが壊れる
- → テストを直す手間が発生する
- → リファクタリングが面倒になる = 変化を阻む

テストが検証すべきは「契約（何が起きるか・結果）」であって「実装（どう実現するか・過程）」ではない。
スタブ注入は「スタブServiceというI/O境界だけを差し替え、実際のRepository・UseCase・Notifierの本物を動かす」ので、内部実装を変えてもテストは壊れない。

### 本物のロジックが動かない問題

mockito乱用だと本物のロジックが一切動かない。

```
Notifier.toggleTodo(1)
  └→ [MockUseCase] ← ここで止まる
```

MockUseCaseは「呼ばれたら成功を返せ」と命令されているだけなので、UseCaseの中のビジネスロジック・RepositoryのDTO変換・エラーハンドリングは一度も実行されない。

- mockito乱用：「Notifierが正しくメソッドを呼んだか」は確認できるが「実際にstateが正しく変わるか」は確認できない
- スタブ注入：Serviceより上のレイヤーがすべて本物で動くので、本来テストしたいロジックが実際に検証される

### verifyが適切な場面

「verifyが悪い」ではなく「**verifyを主軸にしたテストが悪い**」。verifyにも適切な用途はある。

```dart
// 副作用の確認（結果がstateに現れない場合）例：分析イベントの発火
verify(mockAnalyticsService.logEvent('todo_completed')).called(1);
```

ログ送信・分析イベントは戻り値もstateの変化もないので「呼ばれたか」でしか検証できない。この用途ではverifyは正当。問題は「stateで確認できるのにverifyで確認している」ケース。

| 状況 | 適切な検証方法 |
|---|---|
| 結果がstateや戻り値に現れる | `expect` でstate/戻り値を検証 |
| 結果が外部への副作用のみ（ログ・イベント等） | `verify` で呼び出しを検証 |

**「結果で確認できるならverifyではなくexpect」が原則。**

---

## レイヤー別テスト設計

### テストダブル戦略

本プロジェクトは既に `StubServiceImpl` を持つ → **スタブ注入でSmallに保てる**

```
View → Notifier → UseCase → Interface ← [Repository] → [Service実装] → [末端I/Oスタブ]
                                                                               ↑
                                                                  ここでスタブ注入 → 1プロセスで完結（Small）
```

末端I/Oとは `flutter_secure_storage` や HTTP クライアントのように、プロセス外と通信する箇所を指す。
`AuthSecureStorageServiceImpl` のようにその上に乗るService実装は実物を使う。

### 各レイヤーのテスト方針

| レイヤー | テストサイズ | テスト種別 | 何をテストするか | スタブ境界 |
|---|---|---|---|---|
| **Entity** | Small | Unit | ビジネスロジック（変換・バリデーション） | なし（純粋関数） |
| **Service（実装）** | Small | Unit | 末端I/O以外のロジック（キー管理・メモリキャッシュ等） | 末端I/Oスタブ注入 |
| **Service（スタブ）** | - | テスト対象外 | テストダブル自体はテストしない | - |
| **Repository** | Small | Unit | DTO→Entity変換・SSOT・エラー変換 | 末端I/Oスタブ注入 |
| **UseCase（Domain）** | Small | Unit | 業務ロジック・複数Repository協調 | 末端I/Oスタブ注入 |
| **UseCase（Screen）** | Small | Unit | 画面固有ロジック・バリデーション | 末端I/Oスタブ注入 |
| **Notifier** | Small | Integration | state遷移・UseCase呼び出し結果の反映 | 末端I/Oスタブ注入 ※1 |
| **Widget** | Small | Widget | 状態→UI描画・ユーザーアクション→Notifier委譲 | スタブNotifier（Provider override） |
| **Happy path** | Large | E2E | クリティカルな一連の操作フロー | なし（実環境） |

**※1 Notifier統合テストの重要点**
Notifier + UseCase + Repository + Service実装 を**まとめてテスト**し、末端I/O（`flutter_secure_storage`・APIクライアント等）のスタブのみ注入する。これが「**Integration × Small で最もコスパが良い**」領域。

---

### Integration テストのファイル配置原則

Integration テストは複数レイヤーを横断するため、Unit テストのように「対象ファイルと1対1でミラー」できない。配置の判断軸は **「テストのエントリーポイント（最上位の被テスト層）にミラーする」**。

#### 原則

テストコード内でどの層のメソッドを呼び出しているか（= 公開 API として扱っているか）が配置先を決める。

```
UseCase → RepositoryImpl → StubService
   ↑
 useCase.checkStatus() を呼ぶ → UseCase が entry point
 → test/domain/use_cases/{feature}/ に配置
```

スタブの境界（StubService）の場所ではなく、**テストの主語（何をテストしているか）** に合わせる。

#### 各パターンの配置

| テスト内容 | Entry point | 配置先 |
|---|---|---|
| UseCase → RepositoryImpl → StubService | UseCase | `test/domain/use_cases/{feature}/` |
| Notifier → UseCase → RepositoryImpl → StubService | Notifier | `test/presentation/{feature}/` |
| Repository → StubService | Repository | `test/data/repositories/{feature}/` |

#### Unit テストとの共存

同じディレクトリに Unit テストと Integration テストが共存する場合、ファイル名サフィックスで区別する。

```
test/domain/use_cases/permission/notification/
  notification_permission_use_case_test.dart              ← Unit
  notification_permission_use_case_integration_test.dart  ← Integration
```

#### StubService の場所に置いてはいけない理由

`test/data/services/{feature}/` に Integration テストを置くと：

- 「Service をテストしている」と読み手が誤解する
- スタブ境界（= テストが通り抜けた場所）で分類しており本末転倒
- Unit テストの配置規則（対象ファイルとミラー）と命名規則が崩れる

---

## テスト記述規約（Given-When-Then）

全テストを **Given-When-Then 構文** で記述する。3条件との対応を明示することで、AI実装指示の精度が上がり、テストの意図が自明になる。

### 構文とマッピング

```dart
test('正常系: 有効な注文数でインスタンスが生成される', () {
  // Given（事前条件: 有効な入力値）
  const quantity = 5;

  // When（操作）
  final result = Quantity(quantity);

  // Then（事後条件: 期待する結果）
  expect(result.value, equals(quantity));
});

test('異常系: 範囲外の注文数で例外が発生する', () {
  // Given（事前条件: 不変条件を破る入力）
  const invalidQuantity = 0;

  // When / Then（不変条件違反 → 例外）
  expect(() => Quantity(invalidQuantity), throwsA(isA<Exception>()));
});
```

### グルーピング規約

```dart
group('クラス名 or メソッド名', () {
  group('正常系', () {
    test('具体的なケース（日本語）', () { /* Given-When-Then */ });
  });
  group('異常系', () {
    test('具体的なケース（日本語）', () { /* Given-When-Then */ });
  });
});
```

---

## 優先度とフォーカス

### 問題（アイスクリームコーン化のリスク）

```
現在: 各レイヤーを個別にUnit test → 手動E2E
           ↑
     レイヤー間の連携が抜けている
     手動E2Eに依存しすぎている
```

### 目指すピラミッド

```
         △      Large（E2E）: 最小限 / CIの夜間実行のみ
        △△△     Medium: Service実装が必要な場合のみ
       △△△△△    Small Unit（Entity/UseCase/Repository）
     █████████  Small Integration（Notifier統合 / Widget）← ここを厚くする
```

---

## 新たに追加すべきテスト

### 1. Notifier統合テスト（最優先）

`ProviderContainer` でStubServiceのみ上書きし、Notifier〜Serviceまで一気通貫でテスト。

```dart
// テスト構成のイメージ
final container = ProviderContainer(
  overrides: [
    todosServiceProvider.overrideWithValue(StubTodosServiceImpl()),
    // Repository・UseCase・Notifierは本物を使う
  ],
);
```

**テスト対象**:
- `build()` 後の初期stateが正しいか
- アクション（`toggleTodo` 等）後のstate遷移
- Serviceがエラーを返したときの`AsyncError`への遷移

### 2. Widgetテスト（次点）

#### Widget test と Integration test の境界線

| 検証内容 | テスト種別 |
|---|---|
| ボタン押下 → Notifierメソッドが呼ばれる | **Widget test**（スタブNotifier注入で検証可能） |
| ボタン押下 → 画面Bに遷移する（画面Bが表示される） | **Integration test**（実デバイスが必要） |

「**何が起きたか（状態変化・ハンドラー呼び出し）**」はWidget test、「**どこへ行ったか（画面遷移の結果）**」はIntegration testの領域。

---

#### Screen（優先度: 高）

Screenの責務は `AsyncValue` の状態切り替えとHandlerの定義。デザイン変更の影響を**受けない**層。

**テストする契約**:

```
事前条件: StubNotifier が返す AsyncValue の状態
  AsyncLoading / AsyncData(viewModel) / AsyncError

事後条件:
  AsyncLoading → ローディングWidget が存在する
  AsyncData    → _Content が存在する（find by Key）
  AsyncError   → エラーWidget が存在する
```

```dart
testWidgets('AsyncLoading: ローディング表示', (tester) async {
  // Given
  final container = ProviderContainer(
    overrides: [
      xxxScreenProvider.overrideWith(() => StubXxxNotifier(const AsyncLoading())),
    ],
  );
  // When
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: XxxScreen()),
    ),
  );
  // Then
  expect(find.byType(CoreLoadingIndicator), findsOneWidget);
});
```

**Handlerの呼び出し検証も Screenレベルで行う**:

```dart
testWidgets('ボタンタップ: submit が呼ばれる', (tester) async {
  // Given: StubNotifier + AsyncData 状態
  final stubNotifier = StubXxxNotifier(AsyncData(initialState));
  // When
  await tester.tap(find.byKey(const Key('submit_button')));
  await tester.pump();
  // Then
  expect(stubNotifier.submitCallCount, equals(1));
});
```

---

#### Section（優先度: 中）

Sectionの責務は「**空状態・エラー状態などの表示判断**」。データ状態に応じた表示切り替えはロジックなのでデザイン変更の影響を受けにくい。

**テストする契約**:

```
事前条件: items が空リスト / データあり / エラー状態フラグ
事後条件:
  items 空   → 空状態コンポーネントが表示される
  items あり → SliverList のアイテム数が一致する
```

```dart
// SectionはStatelessWidget（Riverpod非依存）→ 直接 pumpWidget 可能
testWidgets('空リスト時: 空状態表示', (tester) async {
  // Given
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [SomeSection(items: [])],
        ),
      ),
    ),
  );
  // Then
  expect(find.byType(EmptyStateWidget), findsOneWidget);
  expect(find.byType(SomeItem), findsNothing);
});
```

---

#### Component（優先度: 低）

Componentは純粋な描画担当（Riverpod/Domain非依存）。テキストや色などの見た目はデザイン変更で頻繁に変わるためROIが低く、**原則スキップ**。

**例外: 条件分岐を持つComponentはテストする**:

```dart
// ❌ テストしない（デザイン変更で壊れる）
expect(find.text('完了'), findsOneWidget);
expect(tester.widget<Container>(find.byType(Container)).color, Colors.green);

// ✅ テストする（条件分岐の契約: isCompleted → 完了アイコン表示）
testWidgets('完了状態: 完了アイコンが表示される', (tester) async {
  // Given
  await tester.pumpWidget(
    MaterialApp(home: SomeItem(item: item.copyWith(isCompleted: true))),
  );
  // Then
  expect(find.byKey(const Key('completed_icon')), findsOneWidget);
  expect(find.byKey(const Key('incomplete_icon')), findsNothing);
});
```

---

#### NavigationExtension: Widget testの外

`context.toXxxScreen()` は `context.push/go(XxxScreen.path)` を呼ぶだけ。GoRouterのセットアップコストに対してリターンが小さく、実際の遷移結果（画面Bが表示される）はWidget testでは確認できない。
**→ ハッピーパスのIntegration testで一括カバー**。

`NavigationExtension` 自体のテストが必要な場合は、GoRouterをProviderでoverrideし `push/go` の呼び出し先パスを検証する形になるが、メソッド本体が1行のため通常は不要。

---

#### テスト対象サマリー

| 検証内容 | テスト種別 | 変更頻度 | ROI |
|---|---|---|---|
| AsyncLoading/Data/Error → UI切り替え | Widget（Screen） | 低 | 高 |
| ボタンタップ → Notifierメソッド呼び出し | Widget（Screen） | 低 | 高 |
| 空/データあり → Section表示切り替え | Widget（Section） | 低 | 中 |
| Componentの条件分岐描画 | Widget（Component） | 中 | 中 |
| ピクセル単位レイアウト・色・文字列 | 対象外 | 高 | 低 |
| 画面遷移の結果（画面Bが表示される） | Integration（Large） | 低 | 高 |

**Widget testの軸は「Viewの責務が果たされているか」であり「UIがどう見えるか」ではない**。

### 3. E2E（Large）の扱い

- **手動テスト → `integration_test` への段階的移行**
- CIでは**夜間cronのみ実行**（メインパイプラインから除外）
- 対象: クリティカルなハッピーパスのみ（ログイン〜主要操作1〜2フロー）

---

## 偽陽性（脆いテスト）を避けるルール

| アンチパターン | 本プロジェクトでの発生箇所 | 対処 |
|---|---|---|
| モックだらけで実装依存 | Notifierテストでmockitoを乱用 | スタブ注入 + 本物を使う |
| 自作自演 | Repositoryテストでスタブがプロダクトコードと同じ変換ロジックを持つ | スタブはI/O最小化のみ、変換ロジックなし |
| フレーキー | `integration_test` を毎コミットで実行 | Large はcron専用 |

---

## CIパイプライン設計

```
git push
  ↓
[Small tests] ─ flutter test (Unit + Integration + Widget)
  → 数十秒で完了 / 失敗なら即ブレーク
  ↓
[build] ─ flutter build
  ↓
[Medium tests] ─ （Serviceレイヤーが必要な場合のみ）
  ↓
夜間cron
  ↓
[Large tests] ─ integration_test on emulator
```

---

## AI駆動テスト実装フロー

AIにテストコードを書かせる際の**3ステップ**。この順序を守ることで「自作自演」と「偽陰性」を防ぐ。

```
Step 1: 3条件を設計する（人間が行う）
         ↓
Step 2: 3条件を渡してAIにテストコードを実装させる
         ↓
Step 3: テストをパスするようにAIにプロダクションコードを実装させる（TDD）
```

### AIへの指示プロンプトテンプレート

```
以下「## 要件」を満たすようにテストコードを実装せよ

## 要件
- 事前条件、事後条件、不変条件を検証するテストであること
- Given-When-Then構文で記述すること
- 正常系・異常系をグルーピングすること

## 対象クラス / メソッド
{クラス名・メソッドシグニチャ}

## 3条件
- 事前条件: {入力の制約}
- 事後条件: {期待する戻り値・状態変化}
- 不変条件: {常に満たすべき制約}
```

### 設計とテスタビリティの関係

AIが正確にテストを書けるかどうかは**設計の質に依存する**。

| 設計原則 | 効果 | 本プロジェクトでの実現 |
|---|---|---|
| **純粋関数** | 入出力が明確 → 事後条件を固定値で書ける | UseCase / Entity のビジネスロジック |
| **副作用の隔離** | テスト境界が明確 → スタブのI/O最小化 | ServiceレイヤーにI/Oを集約 |
| **不変オブジェクト** | 不変条件がコードで保証される | Freezed + コンストラクタガード |
| **カプセル化** | 目的と手段が1クラスに一貫 → テスト対象が自己完結 | 値オブジェクト（Quantity等） |

「信頼できるコード」＝「仕様さえ分かれば内部を読まずに使えるコード」。  
テストはその**仕様通りに動くことの証明**であり、3条件がその仕様を形式化する。

---

## 移行ステップ（現状 → ピラミッド）

| フェーズ | 作業 | 優先度 |
|---|---|---|
| 1 | Notifier統合テストを既存featureに追加（StubService注入） | 高 |
| 2 | クリティカル画面のWidgetテスト追加（AsyncData/Error/Loading） | 高 |
| 3 | E2EをintegrationTestパッケージ化（Happy path 1〜2本のみ） | 中 |
| 4 | CI設定: Smallをコミット時、Largeを夜間cronへ分離 | 中 |
