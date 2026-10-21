# UnauthorizedErrorObserver と認証フロー整理

## 結論

`lib/utils/unauthorized_error_observer.dart` の`UnauthorizedErrorObserver` は残す。ただし役割を正しく理解する。

---

## ループの本当の原因

Observer でも router でもなく、`ProfileScreenUseCase.initState()` が `isLoggedIn` を確認せずに
`fetchMe()` を呼んでいたことが原因。 対象パス: `lib/presentation/profile/use_case.dart`

```
fetchMe() → 401 → UnauthorizedError → AsyncError
    ↓
Observer 検知 → logout() → _isLoggedIn=false → notifyListeners()
    ↓
ProfileScreenNotifier の rebuild リスナー → invalidateSelf()
    ↓
build() 再実行 → initState() → fetchMe() (isLoggedIn確認なし) → 401 → ...
```

修正（`isLoggedIn = false` なら early return）でループは断ち切られた。

---

## Observer が本当に必要な場面

**セッション切れ（ログイン済み中のトークン期限）**

```
ログイン済みで使用中
    ↓
アクセストークン期限切れ → ApiClient がリフレッシュ試行 → 失敗
    ↓
clearAuthData() はストレージをクリアするが…
AuthRepositoryImpl._isLoggedIn のキャッシュは true のまま
    ↓
Observer なし: isLoggedIn が true を返し続ける → refresh しても API 失敗が続く
Observer あり: logout() → _isLoggedIn=false → rebuild → isLoggedIn=false → early return → "未ログイン" 表示 ✓
```

Observer を削除すると `_isLoggedIn` キャッシュが stale のまま残り、ユーザーはエラー画面でスタックする。

---

## 各コンポーネントの役割

| コンポーネント                              | 実際の役割                                                            | 現状                                                                       |
|---------------------------------------------|-----------------------------------------------------------------------|----------------------------------------------------------------------------|
| `UnauthorizedErrorObserver`                 | セッション切れ時に `_isLoggedIn` キャッシュを false に更新            | ループの原因ではなかった                                                   |
| `router.dart` の redirect                   | ログイン済み + LoginScreen → TaskScreen へ遷移（Pattern C は future） | Pattern C 未実装のため、Observer が logout しても LoginScreen へは飛ばない |
| `ProfileScreenNotifier` の rebuild リスナー | auth 状態変化で画面を再構築                                           | `initState()` に `isLoggedIn` チェックがなかったのが問題（修正済み）       |

---

## TaskScreen は安全

`TaskScreenUseCase.initState()` は `isLoggedIn` を取得するだけで認証付き API
を呼ばないため、Observer → rebuild が発火しても無限ループにはならない。

---

## Pattern C 実装時の完成形

```
セッション切れ → UnauthorizedError
    ↓
Observer → logout() → notifyListeners()
    ↓
router.redirect: isLoggedIn=false かつ protected path → LoginScreen へリダイレクト ← ここを追加
    ↓
ログイン後 pendingDeepLink で元の画面へ復帰
```

Observer はその時点で初めて「自動 LoginScreen 遷移」という本来の役割を果たす。

---

## 今後の画面実装時のパターン

認証が必要な画面を追加するたびに、`initState()` で以下を守る。

```dart
Future<ScreenState> initState() async {
  final isLoggedIn = await ref.read(authUseCaseProvider).checkIsLoggedIn();
  if (!isLoggedIn) {
    return ScreenState(); // API を呼ばずに early return
  }
  // 認証が必要な API 呼び出し
}
```

これにより Observer がある限りループは発生しない。
