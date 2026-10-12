# 画面構成設計

## 1. 目的

画面全体を1つのスクロール領域として構成し、画面固有の責務、エリア単位のUI構成、純粋なUI部品を分離する。

画面は`CustomScrollView`をルートのスクロールコンテナとし、必要に応じて複数のSliverを組み合わせる。配列データの一覧表示には、表示形式に応じて
`SliverList`や`SliverGrid`などを使用する。

一覧のスクロール方向は、画面要件に応じて縦方向または横方向とする。`SliverList`
などの一覧用Widgetは、主軸方向やレイアウトに応じて適切なスクロール方向を設定する。通常の`ListView`
で横方向の一覧を実装する場合は、`scrollDirection`に`Axis.horizontal`を指定する。

本ドキュメントに登場する`Section`、`Label`、`Item`
などの名称は、特定の画面要素や固定ファイル名を示すものではない。実際の画面内容に応じて、適切な名称・構成へ置き換える。

## 2. 基本方針

- 画面全体のスクロールは、原則として1つの`CustomScrollView`で管理する。
- `CustomScrollView`の`slivers`には、画面に必要なSliverだけを配置する。
- 画面内の構成要素は、内容に応じて任意のSectionに分割する。
- すべての画面に同じSectionを配置する必要はない。
- Section内に見出しを必ず配置する必要はない。
- Sectionは一覧データ配列だけを表示してもよい。
- Sectionは単一のWidgetではなく、複数のSliverを構成する役割を持つ場合がある。
- Sectionごとに扱うデータ配列は、原則として1つとする（必要であれば`MultiSliver`を使用）。
- Componentは、受け取ったデータを描画する純粋なUI部品とする。

## 3. 構成要素

| 区分        | 役割                                                                                                                                                                                                                                                                                                                                                                                                                                   | ファイル                                             |
|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------|
| Screen    | ・パス定義（`static const path`）を保持する<br>・`Scaffold`を構築する<br>・`Scaffold.appBar`プロパティに画面の`AppBar`を設定する<br>・`Scaffold.body`プロパティに、`ref.watch`で取得した`AsyncValue`の状態（`AsyncLoading` / `AsyncData` / `AsyncError`）に応じたWidgetを設定する<br>・`AsyncData`時は、同一ファイル内のプライベートクラス`_Content`を生成する<br>・`_Content`はViewModelを受け取り、各SectionへデータとHandlerを渡す<br>・全ユーザー操作のHandlerを実装する<br>・partファイル（dialog / toast / analytics / bottom_sheet）でMixinに分割する<br>・画面遷移は `NavigationExtension`（`lib/router/navigation_extension.dart`）を使用する | `*_screen.dart`                                  |
| Section   | ・「〇〇エリア」として言語化できるUIのまとまり<br>・`_Content`から呼び出され、受け取ったデータ属性に応じて下位Componentの構成・出し分けを決定する<br>・各グループのSectionは、見出しと対応するデータ配列の`SliverList`を構成する<br>・AppBarに画面固有UIが含まれる場合は`*_app_bar_section.dart`として切り出す                                                                                                                                                                                                                                    | `*_section.dart`                                 |
| Component | ・Sectionから渡されたデータを描画する純粋なUI部品<br>・ロジックを持たず、RiverpodにもDomainにも依存しない<br>・粒度に応じてList / Item / Labelに分類する                                                                                                                                                                                                                                                                                                                                | `*_list.dart`<br>`*_item.dart`<br>`*_label.dart` |

## 4. 全体構造

画面の構成は、画面内容に応じて必要なSliverを組み合わせる。

```
Screen
└── Scaffold
    ├── AppBar
    └── _Content
        └── CustomScrollView
            ├── SliverToBoxAdapter
            │   └── Section
            ├── SliverList
            │   └── Component
            ├── SliverToBoxAdapter
            │   └── Section
            ├── SliverGrid
            │   └── Component
            └── その他の必要なSliver
```

上記は汎用的な構成例であり、すべての画面で同じSliverを配置することを意味しない。

画面によっては、以下のような構成になる。

```
Screen
└── _Content
    └── CustomScrollView
        ├── 画面上部のSection
        ├── データ一覧を表示するSection
        └── 画面下部のSection
```

また、一覧を持たない画面では、以下のような構成でもよい。

```
Screen
└── _Content
    └── CustomScrollView
        ├── 説明用のSection
        ├── 入力用のSection
        └── 操作用のSection
```

## 5. Screen・`_Content`の構成

Screenは `XxxScreen`（外側）と `_Content`（内側）の2クラス構成を取る。

`XxxScreen`・`_Content`ともに、`useEffect`や`useScrollController`などFlutter Hooksが必要な場合は
`HookConsumerWidget`、不要な場合は`ConsumerWidget`を使用する。

`_Content`はViewModelから必要なデータを受け取り、画面に必要なSectionを構成する。

```dart
class _Content extends HookConsumerWidget {
  const _Content({
    required this.viewModel,
  });

  final XxxViewModel viewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textEditingController = useTextEditingController(
      text: 'Initial Value',
    );

    return CustomScrollView(
      slivers: [
        FirstSection(
          data: viewModel.firstData,
          textEditingController: textEditingController,
          onButtonTap: () async {
            await ref
                .read(homeScreenProvider.notifier)
                .submit();
          },
        ),
        SecondSection(
          data: viewModel.secondData,
          onItemTap: () {
            ref
                .read(homeScreenProvider.notifier)
                .update();
          },
        ),
      ],
    );
  }
}
```

`FirstSection`や`SecondSection`は具体的な固定名称ではなく、実際の画面の役割に応じた名称を付ける。

例：

```
通知エリア       → NotificationSection
検索結果エリア   → SearchResultSection
履歴エリア       → HistorySection
設定エリア       → SettingsSection
入力エリア       → FormSection
```

名称は、画面内で担当するUIの役割を表すものとする。

また、Screenの責務は`part`ファイルに分割したMixinとして整理する。各ファイルは画面の要件に応じて必要なものだけ作成する。

画面遷移は per-feature の Mixin ではなく、`lib/router/navigation_extension.dart` の `NavigationExtension` を使用する。複数の画面から同一の遷移先を呼ぶ場合も1箇所に集約されるため、パス変更時の修正コストを最小化できる。

```dart
// lib/router/navigation_extension.dart
extension NavigationExtension on BuildContext {
  void toTodoDetailScreen(int todoId) => push('${TodoListScreen.path}/$todoId');
  // ...
}

// Screen 呼び出し側
onTap: () => context.toTodoDetailScreen(todo.id),
```

| ファイル                | Mixin               | メソッド命名                | 戻り値            | 役割                                                                               |
|---------------------|---------------------|-----------------------|----------------|----------------------------------------------------------------------------------|
| `dialog.dart`       | `_DialogMixin`      | `open〇〇Dialog()`      | `Future<T?>`   | ・ダイアログの表示<br>・ユーザーの選択結果（`enum` / `null`）を返す<br>・エラー通知・確認・選択など、画面中央に表示するモーダルに使用する |
| `toast.dart`        | `_ToastMixin`       | `open〇〇Toast()`       | `void`         | ・トーストの表示<br>・操作完了の一時通知など、ユーザーの応答を要さない非ブロッキングなフィードバックに使用する                        |
| `analytics.dart`    | `_AnalyticsMixin`   | `impression()` など     | `void`         | ・アナリティクスイベントの送信<br>・主に画面表示時（`useEffect`内）に呼び出す                                   |
| `bottom_sheet.dart` | `_BottomSheetMixin` | `open〇〇BottomSheet()` | `Future<T?>`   | ・ボトムシートの表示<br>・ユーザーの選択結果を返す<br>・ソート順の変更・メニュー選択など、下部から表示するモーダルに使用する               |

## 6. スクロール構成

`CustomScrollView`の`slivers`には、画面に必要なSectionやSliverを順番に配置する。

```
CustomScrollView
├── Section用のSliver
├── List用のSliverList
├── Section用のSliver
├── List用のSliver
└── その他のSliver
```

通常のWidgetを`CustomScrollView.slivers`へ配置する場合は、`SliverToBoxAdapter`で包む。

```
通常のWidget
└── SliverToBoxAdapter
    └── SectionまたはComponent
```

配列データを一覧表示する場合は、`SliverList`を使用する。

```
配列データ
└── SliverList
    └── Item Component
```

グリッド表示が必要な場合は`SliverGrid`、固定的な余白や単一Widgetの配置には`SliverToBoxAdapter`
など、要件に応じたSliverを選択する。

## 7. Sectionの考え方

Sectionは、画面内で「〇〇エリア」と言語化できるUIのまとまりとする。

Sectionの内部構造は固定しない。画面の要件に応じて、以下のような構成を取る。

### 見出しと一覧を持つSection

```
Section
├── 見出し用のComponent
└── 一覧用のSliver
    └── Item Component
```

### 一覧だけを持つSection

```
Section
└── 一覧用のSliver
    └── Item Component
```

### 単一の情報表示を持つSection

```
Section
└── 情報表示用のComponent
```

### 複数のComponentを持つSection

```
Section
├── Component
├── Component
└── Component
```

### 表示条件を持つSection

```
Section
├── 条件に応じて表示するComponent
└── 条件に応じて表示するSliver
```

Sectionに含める要素は、画面上の役割やデータ構造に応じて決定する。見出し、一覧、空状態、ローディング表示、エラー表示などを必ず含める必要はない。

## 8. Sectionとデータ配列

Sectionが一覧データを扱う場合、原則として1つのデータ配列を受け取る。

```
Section
└── 1つのデータ配列
    └── 一覧表示用のSliver
```

例えば、ある画面で複数の異なる一覧を表示する場合は、データの役割ごとにSectionを分ける。

```
_Content
├── Section(data: firstItems)
├── Section(data: secondItems)
└── Section(data: thirdItems)
```

ただし、Sectionが複数のデータ配列を組み合わせることが画面要件上自然な場合は、無理に分割しない。重要なのは、Sectionが何のUIエリアを担当し、どのデータを表示しているかが明確であることである。

## 9. Sectionの実装形式

Sectionが見出しと一覧など複数のSliverを必要とする場合、Sectionは`List<Widget>`を生成する形式で実装する。

```dart
/// 見出しと一覧を持つSection。
class SomeSection extends StatelessWidget {
  const SomeSection({
    required this.items,
    required this.onItemTap,
    super.key,
  });

  final List<XxxItem> items;
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        const SliverToBoxAdapter(
          child: SomeHeader(),
        ),
        SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return SomeItem(
              item: item,
              onTap: () => onItemTap(item),
            );
          },
        ),
      ],
    );
  }
}
```

一覧だけを持つSectionの場合は、見出し用のSliverを含めない。

```dart
/// 一覧だけを持つSection。
class SomeListSection extends StatelessWidget {
  const SomeListSection({
    required this.items,
    required this.onItemTap,
    super.key,
  });

  final List<XxxItem> items;
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return SomeItem(
          item: item,
          onTap: () => onItemTap(item),
        );
      },
    );
  }
}
```

単一のWidgetだけを表示するSectionでは、通常のWidgetを`SliverToBoxAdapter`で包む。

```dart
/// 単一のWidgetだけを表示するSection。
class SomeSingleContentSection extends StatelessWidget {
  const SomeSingleContentSection({
    required this.data,
    super.key,
  });

  final XxxData data;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SomeContent(
        data: data,
      ),
    );
  }
}
```

## 10. ファイル構成

画面の内容に応じて、必要なSectionとComponentだけを作成する。

```
feature/
├── screen.dart         # Scaffold・AsyncValue切替・Handler
├── dialog.dart         # ダイアログ表示
├── toast.dart          # トースト表示
├── analytics.dart      # アナリティクス送信
├── bottom_sheet.dart   # ボトムシート表示
├── state.dart          # UI表示状態（Freezed）
├── state.freezed.dart  # state.dartの自動生成ファイル
├── notifier.dart       # state更新・UseCase呼び出し
├── use_case.dart       # 業務ロジック・Repositoryアクセス
│
├── sections/           # UIエリア単位Widget群
│   ├── xxx_section.dart
│   ├── yyy_section.dart
│   └── zzz_section.dart
│
└── components/         # 純粋UI部品群
    ├── xxx_list.dart
    ├── xxx_item.dart
    ├── xxx_label.dart
    ├── yyy_item.dart
    └── zzz_content.dart
```

すべての画面で`list`、`item`、`label`を作成する必要はない。

例えば、一覧を持たない画面では次のようにする。

```
sections/
├── description_section.dart
└── form_section.dart

components/
├── description_content.dart
└── form_field.dart
```

一覧を持つ画面では、次のようにする。

```
sections/
└── result_section.dart

components/
├── result_list.dart
└── result_item.dart
```

## 11. 責務の境界

```
Screen
├── 画面のライフサイクル
├── Scaffold
├── AppBar
├── AsyncValueの状態切り替え
├── _Contentの生成
└── ユーザー操作のHandler

_Content
├── ViewModelからデータを受け取る
├── 必要なSectionを選択する
├── Sectionへデータを渡す
├── SectionへHandlerを渡す
└── CustomScrollViewを構成する

Section
├── UIエリア単位の構成
├── 必要なComponentの選択
├── 必要なSliverの選択
├── データ状態に応じた表示・非表示
├── 空状態・エラー状態などの表示判断
└── Componentへのデータ受け渡し

Component
├── 受け取ったデータの描画
├── List、Item、LabelなどのUI表現
└── 必要に応じたHandlerの呼び出し
```

## 12. Componentの依存関係

Componentは純粋なUI部品とし、以下に依存しない。

- Riverpod
- ViewModel
- Domain
- Repository
- API
- データ取得処理
- 画面遷移処理
- ダイアログ表示処理
- トースト表示処理

ユーザー操作はComponentからCallbackとして受け取り、Handlerの実装は`Screen（_Content）`側に置く。

```
Component
└── onTap()
    └── Screenから渡されたHandler
```

## 13. 最終的な汎用構造

```
Screen
└── Scaffold
    ├── AppBar
    └── _Content
        └── CustomScrollView
            ├── Section A
            │   ├── 任意のComponent
            │   └── 必要に応じたSliver
            ├── Section B
            │   └── SliverList
            │       └── Item Component
            ├── Section C
            │   ├── 見出し用Component
            │   └── SliverList
            │       └── Item Component
            └── Section D
                └── 任意のComponent
```

```
Sectionの構成は画面ごとに異なる。

- 見出しを持つSection
- 見出しを持たないSection
- 一覧データだけを表示するSection
- 単一の情報を表示するSection
- 複数のComponentを組み合わせるSection
- SliverListを使用するSection
- SliverGridを使用するSection
- 一覧を持たないSection
```

本設計における`Section`や`Component`
の名称・数・内部構造は固定しない。各画面のUI構造とデータ構造に応じて、責務が明確になるように分割する。FlutterではUIをWidgetの組み合わせとして構成できるため、画面単位・エリア単位・部品単位で責務を分離する方針と整合する。