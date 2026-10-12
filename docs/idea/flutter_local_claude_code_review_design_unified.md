# Flutter ローカル AI レビュー仕組みの検討記録

## ユーザー：初回相談

flutterでアプリ開発をしている。リモートにコードをpushしてからPRレビューをするのではなく、pushするまでにローカルでclaude codeを使ってPRレビューが実施される仕組みを作りたい。
実装は主に開発時のタスクは以下aで分類される。3つの層があり、さらに各層にレイヤーがある。
参照: /travel_app/docs/architecture/architecture_responsibilities.md

例えば、実際の開発プロセスでは、Viewのみ作業ブランチを作成して作業し、pushする。Notifier, UseCaseなどその他も同じです。
この時、claude codeでPRレビュー用のskill（aの各層・レイヤーに応じたPRレビュー用のskill）を作っておき、git pushする際に差分ファイルの末尾（例：Viewなら*_screen.dart、Notifierならnotifier.dart、UseCaseならuse_case.dart）を判定して、対応するレビュー用のskillを起動させレビューを実施する。pushして良いかどうかはapproveかrejectの結果をskillが判定する。レビュー結果は指定したパスのディレクトリ配下にmarkdownファイルとして保存し、rejectであれば修正用のskillをもとに修正を行う。
このような形で、なるべくリモートにprが作成されてからレビューを始めるのではなく、ローカルでほぼレビュー・修正も済んだ状態でpushできるようになっておけば、後はリモートでciを実行してパスすればマージ、という流れを作ることができると思う。
上記を実現するためのアイデア（特に、pushする前にskillでレビューしたかをどう判定するか、一時的な判定フラグをどう持たせるか）を複数案として出して

```a
プレゼンテーション層
View
ViewModel
Notifier
UseCase（特定の画面の関心事に属すロジック・画面ユースケース）
ドメイン層
Entity
Interface
UseCase（特定の画面に属さないドメイン概念・ドメインユースケース）
データ層
Repository
Service
```

---

## アシスタント：初回回答

ローカルで「push 前に Claude Code のレビュー skill を必ず通す」仕組みを作るには、主に 3 つの軸で設計します。

- **トリガー**: 何をきっかけにレビュー skill を走らせるか（git hook / CLI ラッパー / IDE 連携など）
- **判定とフラグ**: 「レビュー済み・approve 済み」をどう記録・検証するか（ファイル / git metadata / 一時的な状態）
- **ポリシー強制**: レビュー未実施の push をどう防ぐか（hook でブロック / CI で弾く / 運用ルール）

以下に、実装アイデアを複数案出します。特に「push 前に skill でレビューしたかの判定」「一時的な判定フラグの持ち方」に焦点を当てています。

---

## 案 1：pre-push フック + ローカルレビュー記録ファイル（シンプル・堅牢）

### 仕組みの概要

- `git push` 時に `pre-push` フックが発火。
- フック内で：
  - 直近の未 push コミットの差分ファイルを取得
  - 末尾パターン（`*_screen.dart`, `notifier.dart`, `use_case.dart` など）で層・レイヤーを判定
  - 対応する「レビュー記録ファイル」が最新コミットに対して存在するかチェック
  - 存在しない or 内容が reject なら push をブロック

### 判定フラグの持ち方

- ディレクトリ例：`.local_review/`
- ファイル名例：
  - `.local_review/view_review_<commit_hash>.md`
  - `.local_review/notifier_review_<commit_hash>.md`
- 中身：
  - レビュー結果（approve / reject）
  - 対象コミットハッシュ
  - 対象ファイル一覧
  - 使用 skill 名

pre-push フックは、以下のような擬似ロジックになります。

```bash
# pre-push フック内（bash 風 疑似コード）
COMMITS=$(git rev-list --reverse @{push}..HEAD)
for COMMIT in $COMMITS; do
  FILES=$(git diff-tree --no-commit-id --name-only -r $COMMIT)
  for FILE in $FILES; do
    if [[ $FILE == *_screen.dart ]]; then
      LAYER="view"
    elif [[ $FILE == *notifier.dart ]]; then
      LAYER="notifier"
    # ...
    fi

    REVIEW_FILE=".local_review/${LAYER}_review_${COMMIT}.md"
    if [ ! -f "$REVIEW_FILE" ]; then
      echo "Review not found for $LAYER at commit $COMMIT"
      exit 1
    fi
    # 中身が reject なら弾く
    if grep -q "^status: reject" "$REVIEW_FILE"; then
      echo "Review status is reject for $LAYER at commit $COMMIT"
      exit 1
    fi
  done
done
```

### 利点

- git 標準機能だけで完結。CI や特殊インフラ不要。
- 「レビュー済みフラグ」がファイルとして残るので、あとから参照可能。
- フックで push を物理的にブロックできる。

### 課題・対策

- レビュー記録ファイルをコミットに含めるかどうか：
  - 含めない（`.gitignore`）：ローカル専用フラグ。チームメンバーごとに別管理。
  - 含める：レビュー記録も資産化。ただし機密性やノイズに注意。
- 複数人で共有する場合は、レビュー記録をどう扱うか設計が必要（例：個人用 `.local_review_<user>/`）。

---

## 案 2：git notes + pre-push フック（コミットメタデータとしてレビュー状態を管理）

### 仕組みの概要

- `git notes` を使って、コミットに「レビュー結果」をメタデータとして付与。
- レビュー skill 実行後に、以下のようなノートを付与：
  - `git notes add -m "layer:view status:approve skill:pr_review_view_v1" <commit>`
- pre-push フックで `git notes show <commit>` を見て、approve 済みか判定。

### 判定フラグの持ち方

- フラグ実体：`git notes`（refs/notes/commits 以下）
- 内容例：
  - `layer: view`
  - `status: approve`
  - `skill: pr_review_view_v1`
  - `reviewed_at: 2025-10-06T01:00:00+09:00`

pre-push フックの擬似ロジック：

```bash
for COMMIT in $COMMITS; do
  NOTE=$(git notes show "$COMMIT" 2>/dev/null || echo "")
  if ! echo "$NOTE" | grep -q "status: approve"; then
    echo "Commit $COMMIT has no approve review note"
    exit 1
  fi
done
```

### 利点

- 余分なファイルを管理しなくて良い。
- コミットとレビュー状態が 1:1 で紐付く。
- `git log --show-notes` で履歴と一緒にレビュー状態を確認可能。

### 課題・対策

- `git notes` はデフォルトでリモートに push されないため、必要なら `refs/notes/*` も共有設定にする必要がある。
- ローカル専用で良い場合は、そのまま運用可能。

---

## 案 3：CLI ラッパーコマンド（`git-push-reviewed`）+ 状態ファイル

### 仕組みの概要

- 直接 `git push` させず、専用コマンド `git-push-reviewed` を使う運用。
- このコマンド内で：
  - 差分ファイルから層を判定
  - 対応する Claude Code skill を呼び出してレビュー実行
  - 結果を `.review_state.json` などに記録
  - approve なら内部で `git push` を実行、reject なら中止

### 判定フラグの持ち方

- 状態ファイル例：`.review_state.json`
- 構造例：

```json
{
  "commits": [
    {
      "hash": "abc123",
      "layers": {
        "view": { "status": "approve", "skill": "pr_review_view_v1", "file": ".local_review/view_review_abc123.md" },
        "notifier": { "status": "approve", "skill": "pr_review_notifier_v1", "file": ".local_review/notifier_review_abc123.md" }
      }
    }
  ]
}
```

- `git-push-reviewed` は：
  - 未 push コミットを列挙
  - 各コミットに対して必要な層の `status: approve` があるかチェック
  - なければレビュー skill を起動 → 結果を状態ファイルに追記 → approve なら push

### 利点

- フックより柔軟な制御が可能（対話・再レビュー・部分 approve など）。
- 「レビューしてから push」がコマンド 1 つで完結。

### 課題・対策

- 運用ルールとして「`git push` 禁止、必ず `git-push-reviewed` を使う」徹底が必要。
- 誤って `git push` されないよう、pre-push フックと組み合わせるとより堅牢。

---

## 案 4：IDE / エディタ連携（保存 or コミット時に自動レビュー）

### 仕組みの概要

- VS Code などのタスク・フックを使い、ファイル保存 or コミット時に自動でレビュー skill を実行。
- レビュー結果をサイドパネルや Problems タブに表示。
- 「レビュー approve 済み」のフラグを IDE 内部状態 or ローカルファイルで持ち、pre-push フックで参照。

### 判定フラグの持ち方

- 案 1,2 と同じく、ファイル or git notes をフラグとして使用。
- IDE は「レビュー skill 実行 → フラグ更新」までを自動化。

### 利点

- 開発フローに自然に組み込める（保存/コミット時に自動）。
- 開発者が意識しなくてもレビューが走る。

### 課題・対策

- IDE 設定の共有・標準化が必要。
- CLI / CI からも同じフラグを参照できる設計にしないと、抜けが発生する。

---

## 案 5：コミットメッセージ規約 + フックで検証

### 仕組みの概要

- コミットメッセージにレビュー情報を埋め込む規約を作る：
  - 例：`feat(view): add login screen [review:view:approve]`
- pre-commit / pre-push フックで：
  - 差分ファイルから必要な層を判定
  - コミットメッセージに `[review:<layer>:approve]` が含まれるかチェック

### 判定フラグの持ち方

- フラグ実体：コミットメッセージ文字列
- 例：
  - `[review:view:approve]`
  - `[review:notifier:reject]`

### 利点

- 余分なファイルやメタデータ不要。
- `git log` でレビュー状態が見える。

### 課題・対策

- 手動でメッセージを書くため、忘れ・ミスが発生しやすい。
- Claude Code skill との連携が間接的（skill は別途レビュー記録ファイルを作り、それを元に人間がメッセージを追加）。

---

## 案 6：ローカルブランチ保護ルール（レビュー済みブランチのみ push 許可）

### 仕組みの概要

- 開発ブランチ（例：`feature/*`）は直接 push 不可とし、以下のようなフローにする：
  - `feature/dev` で作業
  - レビュー skill 実行後、`feature/reviewed` ブランチにコピー
  - pre-push フックは `feature/reviewed` からの push だけ許可
- `feature/reviewed` へのコピー時に、レビュー記録ファイル or git notes を付与。

### 判定フラグの持ち方

- ブランチ名そのものが「レビュー済みフラグ」の役割。
- 必要に応じて、ブランチ切り替え時にレビュー記録を自動生成。

### 利点

- 概念的にわかりやすい（レビュー済みブランチ＝push 可能）。
- フックの実装が比較的シンプル。

### 課題・対策

- ブランチ運用が少し複雑になる。
- 複数層のレビューをどう表現するか（ブランチを層ごとに切るか、1 つにまとめるか）。

---

## 実装上のポイント（層・ファイル末尾の判定）

どの案でも共通して必要になるのが、「差分ファイルから層を判定するロジック」です。

例（bash 風）：

```bash
determine_layer() {
  local_storage file="$1"
  if [[ "$file" == *_screen.dart ]]; then
    echo "view"
  elif [[ "$file" == *view_model.dart ]]; then
    echo "view_model"
  elif [[ "$file" == *notifier.dart ]]; then
    echo "notifier"
  elif [[ "$file" == *use_case.dart ]]; then
    # ここでは画面ユースケースかドメインユースケースかの判定も必要
    # 例：パスに /feature/xxx/ が含まれるなら画面ユースケース、/domain/ ならドメインユースケース
    if [[ "$file" == */feature/* ]]; then
      echo "use_case_view"
    else
      echo "use_case_domain"
    fi
  elif [[ "$file" == *entity.dart ]]; then
    echo "entity"
  elif [[ "$file" == *repository.dart ]]; then
    echo "repository"
  elif [[ "$file" == *service.dart ]]; then
    echo "service"
  else
    echo "other"
  fi
}
```

この関数を使って、コミットごとのファイル一覧から「必要な層のセット」を算出し、それぞれに対してレビュー済みフラグがあるかチェックします。

---

## おすすめの組み合わせ

現実的な導入ステップとしては、以下がバランス良いです。

1. **基本構造**: 案 1（pre-push フック + ローカルレビュー記録ファイル）
2. **メタデータ管理**: 必要なら案 2（git notes）を併用して、ファイル増を抑制
3. **開発者体験向上**: 案 3（CLI ラッパー）または案 4（IDE 連携）で「レビュー→フラグ更新→push」を半自動化

これにより：

- ローカルでレビューが必須になり、未レビュー push を物理的に防止
- レビュー結果が Markdown で残り、あとから参照可能
- 将来的に CI 側でも「リモート PR 作成前にローカルレビュー済み」を前提にしたフローが作りやすい

具体的な実装（pre-push フックのスクリプト例や、Claude Code skill との連携イメージ）が必要であれば、次にそこを詳しく設計します。



---

## ユーザー：開発体制・狙いの追加

開発体制、狙いを以下a, bに整理している。これらを満たすよう案を再設計してほしい（もしくは案を絞る・深める・組み合わせるなど）。

```a
〈開発体制〉
・開発チームは2名（メンバー構成：リードエンジニア1名、非エンジニア1名）
・AI x 少人数で開発を進めていく必要がある
・開発フェーズとしてはまだ始まったばかりのため、2名でも開発速度を維持し、ビジネス変化・要求に開発が追いついていけるだけの開発スピードを維持していきたい
・メンバー構成的にエンジニアにPRレビューが集中する。PRレビューを素早く捌けないと機能開発が遅くなっていくため、PRレビューの高速化・負担軽減を最重要として今回のローカルレビュー構築を重点的に行いたい
・理想としては、非エンジニアが書いたコードがPRとして作成された後にリードエンジニアのレビューが実施されるのではなく、非エンジニアがPRを上げる前にローカルでレビューが完結していること。PRが作成されてからはCIがパスすればマージできる状態にしたい
・各層/レイヤーの中でもView, Repository, Serviceなどは定型作業に近いのでほぼローカルでのレビューで完結できると思う。一方で、Notifier, UseCaseなど業務ロジックが関わるところはリードエンジニアのレビューが必要になるので、「ローカルレビューで完結できる範囲」と「リードエンジニアのレビューが必要な範囲」を区別できることが重要。そのためにファイル末尾から層を判定しておくことが自動化につながる
```

```b
〈狙い〉
・開発メンバーは2名だが、skillによりレビューした内容はチームの資産化にしたい
・例えば、作業ブランチでのレビューした結果をファイルとして特定のディレクトリ配下に残すだけでなく、そのレビュー結果から将来のレビュー観点として、また修正観点として使えそうなところは、別途各層ごとにファイルを作っておき、そこにポイントを貯めていくという運用もできれば良さそう
・ナレッジが溜まっていけば開発が進むにつれて複利的に効果を発揮する
```

---


# Flutter ローカル AI レビュー仕組みの再設計

> 開発メンバーを「リードエンジニア」「非エンジニア」に区別せず、変更内容に応じてレビュー責任を決める版

開発体制・狙い（a, b）を踏まえると、開発メンバーを役割で分断せず、すべてのメンバーが同じローカルレビューの仕組みを使い、必要に応じてレビュー担当者がコードに責任を持って確認する設計が適切です。設計の軸は以下 3 点に絞れます。

- **開発メンバーが「ローカルレビュー必須フロー」から外れられない仕組み**（人的ミスを許容しない）
- **定型レイヤー（View/Repository/Service など）はほぼ自動、業務ロジック系（Notifier/UseCase など）はレビュー担当者によるレビューを必須とする層別ポリシー**
- **レビュー結果を「その場の approve/reject」だけでなく、チーム資産（ナレッジ）として蓄積・再利用できる構造**

これらを満たすよう、先の案を再設計・統合した「推奨アーキテクチャ案」を 1 つに絞り、その中に複数の実装オプションを示します。

---

## 推奨アーキテクチャ：層別ポリシー + pre-push フック + ナレッジ蓄積

全体像を先に言うと、以下のような構成が a, b の両方をよく満たします。

1. **git pre-push フックを「唯一のゲート」**にする  
   - `git push` 時に必ず走り、レビュー未実施・reject 状態なら物理的に push をブロック。
   - これにより「うっかり直接 push」を防ぎ、開発メンバーでもフローから外れられない。

2. **レビュー記録は 2 種類持つ**
   - **コミット単位のレビュー記録ファイル**（例：`.local_review/<layer>_<commit_hash>.md`）  
     - そのコミットに対する「approve/reject」「使用 skill」「指摘事項」「修正ポイント」を記録。
     - pre-push フックの判定フラグとして使用。
   - **層単位のナレッジファイル**（例：`.review_knowledge/<layer>_knowledge.md`）  
     - 複数コミットに跨る「レビュー観点の貯金」を蓄積。
     - 例：`view_knowledge.md` には「View レビューで毎回見るべきポイント一覧」が貯まる。
     - 将来的に skill のプロンプトやチェックリストとして再利用。

3. **層ごとに「ローカル完結」と「レビュー担当者によるレビュー必須」をポリシー定義**
   - 例：
     - **ローカル完結レイヤー**：`View`, `ViewModel`, `Repository`, `Service`  
       → Claude Code skill による自動レビューのみで approve 可能。
     - **レビュー担当者による確認を必須とするレイヤー**：`Notifier`, `UseCase（画面/ドメイン）`, `Entity`, `Interface`  
       → skill によるレビュー結果に加え、開発メンバーの approve フラグが必須。
   - pre-push フックは、このポリシーを参照して「どのレイヤーにどの approve が必要か」を判定。

4. **開発メンバー用 CLI/スクリプトで「レビュー→ナレッジ反映→コミット」を半自動化**
   - 開発メンバーは `dev-review` のようなラッパーコマンドを使う。
   - 内部で：
     - 差分ファイルから層を判定
     - 対応する skill を呼び出してレビュー実行
     - レビュー結果をコミット単位の記録ファイルに保存
     - 新規・重要な指摘があれば、層単位のナレッジファイルにも追記
     - approve ならコミット可能に、reject なら修正を促す

このアーキテクチャに対して、実装の「バリエーション」を 2〜3 案提示します。

---

## 案 A：pre-push フック + ローカルレビュー記録ファイル（基本形）

### フロー概要

1. 開発メンバーが機能開発：
   - 作業ブランチ（例：`feature/login`）で作業。
   - コミット前に `dev-review` コマンドを実行。

2. `dev-review` 内部：
   - staging された差分ファイルを取得。
   - ファイル末尾で層を判定（`*_screen.dart` → `view`、`*notifier.dart` → `notifier` など）。
   - 層に対応する Claude Code skill を実行：
     - 例：`pr_review_view_v1`, `pr_review_notifier_v1` など。
   - skill は：
     - 差分コードをレビュー
     - `approve` / `reject` を判定
     - 指摘事項・修正ポイントを Markdown で返す

3. レビュー結果の保存：
   - コミットハッシュ（または一時的な ID）ごとに：
     - `.local_review/view_<commit_hash>.md`
     - `.local_review/notifier_<commit_hash>.md`
   - 内容例：

```md
---
commit: abc123
layer: view
skill: pr_review_view_v1
status: approve
reviewed_at: 2025-10-06T01:30:00+09:00
---

## 指摘ポイント

- ボタンのタップターゲットが 48dp 未満
- 例外時のエラーメッセージ表示がない

## 修正内容

- ボタンサイズを 48dp 以上に修正
- エラーメッセージ表示を追加
```

4. ナレッジ蓄積（オプション）：
   - 重要な指摘・汎用的なポイントは、層単位のナレッジファイルに追記：
     - `.review_knowledge/view_knowledge.md`
   - 例：

```md
## View レビュー観点（蓄積）

- タップターゲットは 48dp 以上
- エラー時はユーザーに分かりやすいメッセージを表示
- ローディング状態の UI を忘れない
```

5. pre-push フック：
   - `git push` 時に発火。
   - 未 push コミットを列挙し、各コミットについて：
     - 差分ファイルから必要な層を算出。
     - 層ポリシー（ローカル完結 or レビュー担当者必須）を参照。
     - 各層に対して：
       - 対応する `.local_review/<layer>_<commit>.md` が存在するか
       - `status: approve` になっているか
       - レビュー担当者確認必須層なら、レビュー担当者 approve フラグ（後述）があるか
   - 条件を満たさない場合、push をブロック。

### 開発メンバーの approve フラグの持ち方

レビュー担当者確認必須レイヤーについては、以下のような追加フラグを持たせます。

- ファイル例：`.local_review/developer_<layer>_<commit>.md`
- 内容例：

```md
---
commit: abc123
layer: notifier
reviewer: lead_engineer
status: approve
reviewed_at: 2025-10-06T02:00:00+09:00
---

## チェックポイント

- 業務ルールの適用漏れなし
- エラーハンドリングが十分
```

運用フロー：

- 開発メンバーが `dev-review` を実行し、skill レビューまでは自動。
- レビュー担当者確認必須レイヤーが含まれる場合：
  - skill レビュー結果を開発メンバーに共有（例：Slack/メール/ローカルファイル）。
  - 開発メンバーが内容を確認し、`developer_<layer>_<commit>.md` を `status: approve` で作成。
  - これにより pre-push フックが通るようになる。

この「レビュー担当者 approve ファイル」も、将来的にはナレッジファイルにポイントを吸い上げ可能。

### 利点

- a の要件：
  - 開発メンバーが PR を上げる前にローカルレビューが必須（pre-push フックで強制）。
  - 定型レイヤーは skill だけで完結、業務ロジック系はレビュー担当者によるレビューを必須化。
- b の要件：
  - レビュー結果が Markdown で残り、チーム資産化。
  - 層単位のナレッジファイルにポイントを貯め、複利的に活用可能。

### 実装上のポイント

- 層ポリシーの設定ファイル（例：`.review_policy.yaml`）：

```yaml
layers:
  view:
    type: local_only
    file_suffix: _screen.dart
  view_model:
    type: local_only
    file_suffix: view_model.dart
  notifier:
    type: reviewer_required
    file_suffix: notifier.dart
  use_case_view:
    type: reviewer_required
    path_pattern: "*/feature/*use_case.dart"
  use_case_domain:
    type: reviewer_required
    path_pattern: "*/domain/*use_case.dart"
  entity:
    type: reviewer_required
    file_suffix: entity.dart
  repository:
    type: local_only
    file_suffix: repository.dart
  service:
    type: local_only
    file_suffix: service.dart
```

- pre-push フックはこのファイルを参照して、各コミットに必要な approve を判定。

---

## 案 B：git notes を使ったメタデータ管理（ファイル増を抑制）

案 A とほぼ同じ思想ですが、コミット単位のレビュー記録をファイルではなく `git notes` で管理します。

### 違い

- コミット単位のレビュー記録：
  - ファイル：`.local_review/<layer>_<commit>.md`
  - → git notes：`git notes add -m "<layer>:view status:approve skill:pr_review_view_v1" <commit>`

- レビュー担当者 approve も notes で管理：
  - `git notes add -m "layer:notifier reviewer:approve reviewer:lead_engineer" <commit>`

- ナレッジ蓄積用ファイル（`.review_knowledge/*`）はそのまま残す。

### 利点

- レビュー記録ファイルが増えすぎない。
- `git log --show-notes` でレビュー状態を履歴と一緒に確認可能。
- リモートに notes を共有すれば、チーム全体でレビュー履歴を参照可能（オプション）。

### 課題

- `git notes` の運用に少し慣れが必要。
- 詳細なレビュー内容（指摘事項など）は notes だと見にくいので、別途 Markdown ファイルを生成する運用と組み合わせるのが現実的。

実質的には「判定フラグは git notes、詳細記録は Markdown ファイル」というハイブリッドになります。

---

## 案 C：CLI ラッパーを「唯一の push 手段」にする（フックと併用）

案 A/B に加え、`git push` 自体を禁止し、`dev-push` のような専用コマンドだけを push 手段にする案です。

### フロー

- 開発メンバーともに：
  - `git push` ではなく `dev-push` を使う。
- `dev-push` 内部：
  - 未 push コミットを列挙。
  - 各コミットに対して：
    - 必要な層のレビューが未実施なら、対応する skill を自動起動。
    - レビュー担当者確認必須層なら、レビュー担当者 approve があるかチェック（なければレビュー担当者に通知）。
  - すべて approve になったら、内部で `git push` を実行。

### pre-push フックとの関係

- `dev-push` だけでも十分ですが、念のため pre-push フックも入れて「二重ゲート」にするとより堅牢。
- 万が一 `git push` を直接実行しても、フックで弾かれる。

### 利点

- 開発メンバーが「何をすればいいか」が明確（`dev-push` だけ使えば OK）。
- レビュー・ナレッジ蓄積・push を 1 コマンドにまとめられる。

---

## ナレッジ蓄積の設計（b の要件を最大化）

どの案でも共通して重要なのが、「レビュー結果をどうチーム資産化するか」です。

### 2 段構えの記録設計

1. **コミット単位レビュー記録**（短期・個別）
   - 目的：そのコミットの approve/reject 判定と、具体的な指摘・修正内容の記録。
   - 場所：
     - ファイル案：`.local_review/<layer>_<commit>.md`
     - または git notes + 簡易サマリ
   - 寿命：
     - 基本的には永続だが、必要に応じてアーカイブ化も可能。

2. **層単位ナレッジファイル**（長期・横断）
   - 目的：複数コミットに跨る「レビュー観点の貯金」。
   - 場所：`.review_knowledge/<layer>_knowledge.md`
   - 内容例：
     - 定型チェックリスト
     - よくあるミスとその対策
     - 設計方針・命名規則
     - 業務ルールのまとめ

### ナレッジ蓄積の運用

- レビュー skill が「新規・重要な指摘」を検知した場合：
  - コミット単位の記録ファイルに詳細を記載。
  - 同時に、層単位のナレッジファイルにも「観点」として追記。
- 開発メンバーがレビュー時に気づいたポイントも同様。
- 定期的に（例：スプリント終了時）ナレッジファイルを見直し：
  - 重複を整理
  - 優先度付け
  - skill のプロンプトに反映

これにより、「レビューするたびにナレッジが貯まり、次のレビューが楽になる」好循環が生まれます。

---

## 用語と責任範囲の整理

ここでいう「ローカルレビューで完結できる範囲」と「レビュー担当者による確認が必要な範囲」は、開発メンバーの属性を区別するものではありません。誰がコードを書いたかにかかわらず、変更された層・ファイルの性質によって必要な確認レベルを判定します。

- すべての開発メンバーが、作業前・PR作成前に同じローカルレビューを実行する。
- `View`, `Repository`, `Service` などの定型性が高い変更は、AI によるローカルレビューで完結できる可能性が高い。
- `Notifier`, `UseCase` など業務ロジックを含む変更は、AI のローカルレビューに加えて、コードに責任を持てるレビュー担当者の確認を必要とする。
- ファイル名の末尾やパスから層を判定することで、必要なレビュー手順を自動的に選択する。
- PR 作成後は、ローカルレビューと必要な確認が完了し、CI が成功していればマージできる状態を目指す。

## 推奨の組み合わせと次のステップ

2 名チーム・AI 活用・スピード重視という文脈では、以下が現実的で効果的です。

- **基本構造**: 案 A（pre-push フック + ローカルレビュー記録ファイル）
- **ナレッジ蓄積**: 層単位の `.review_knowledge/<layer>_knowledge.md` を併用
- **オプション**:
  - ファイル増が気になる場合、判定フラグは git notes（案 B）に置き換える。
  - 開発メンバーの操作性を高めるなら、`dev-review` / `dev-push` CLI（案 C）を追加。

次に具体化するとすれば、以下を設計します。

- 層ポリシーファイル（`.review_policy.yaml`）の具体例
- pre-push フックのスクリプト例（bash or Python）
- Claude Code skill の入出力フォーマット（どうやって approve/reject と Markdown 結果を返すか）
- ナレッジファイルのテンプレート
