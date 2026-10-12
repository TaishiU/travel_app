#!/usr/bin/env dart

// check_named_args.dart
//
// Dartファイル内の関数・メソッド・コンストラクタ宣言に
// 位置引数（positional parameter）が使われていないか検査する。
//
// ─────────────────────────────────────────────────────────────────────
// 実行方法
// ─────────────────────────────────────────────────────────────────────
// # スコープ指定（デフォルト: changed）
// dart scripts/check_named_args.dart                           # デフォルト = --scope=changed
// dart scripts/check_named_args.dart --scope=changed           # staged + unstaged（git add 不要）
// dart scripts/check_named_args.dart --scope=staged            # staged ファイルのみ（pre-commit 用）
// dart scripts/check_named_args.dart --scope=branch            # ブランチ差分（base: main）
// dart scripts/check_named_args.dart --scope=branch --base=develop  # base ブランチ変更
// dart scripts/check_named_args.dart --scope=all               # lib/ 全件
//
// # ファイル直接指定（後方互換）
// dart scripts/check_named_args.dart lib/foo/bar.dart
// find lib -name "*.dart" ! -name "*.freezed.dart" ! -name "*.g.dart" | xargs dart scripts/check_named_args.dart
// echo "lib/foo/bar.dart" | dart scripts/check_named_args.dart
//
// ─────────────────────────────────────────────────────────────────────
// 検知対象
// ─────────────────────────────────────────────────────────────────────
// - メソッド宣言      戻り値型 + 関数名 + 型アノテーション付き位置引数
//                     例: Future<void> setAppTheme(String theme)
// - コンストラクタ    大文字始まりの名前 + 位置引数
//                     例: ApiClientImpl(this._client, {...})
// - 混在              {} の外に型付き引数がある
//                     例: updateCompletion(int id, {required bool done})
// - オプショナル位置引数  [] 内に型アノテーション
//                     例: AppDatabase([QueryExecutor? executor])
// - コンストラクタ shorthand  {} の外に this.field / super.field
//                     例: ApiClientException(this.message)
//
// ─────────────────────────────────────────────────────────────────────
// 検知対象外
// ─────────────────────────────────────────────────────────────────────
// - 生成ファイル      .freezed.dart / .g.dart / .gen.dart / .gr.dart / .mocks.dart
// - @override メソッド  Flutter フレームワーク・ユーザー定義 interface の実装
//                     ※ interface の宣言側は検知対象。宣言を修正すると
//                        実装側もコンパイルエラーになるため実質的に両方直る
// - 特定関数名        main / toString / hashCode / noSuchMethod
// - 呼び出し側        return Foo(value) / final x = bar(y) 等
//                     宣言側を修正するとコンパイルエラーで呼び出し側も強制修正される
// - 引数ゼロ          void refresh()
// - 名前付き引数のみ  void foo({required String a})

import 'dart:io';

const _skippedSuffixes = [
  '.freezed.dart',
  '.g.dart',
  '.gen.dart',
  '.gr.dart',
  '.mocks.dart',
];

// return type には使えないキーワード（文statement先頭に来うるが宣言ではないもの）
const _statementKeywords = {
  'return',
  'await',
  'throw',
  'yield',
  'new',
  'if',
  'else',
  'for',
  'while',
  'switch',
  'case',
  'final',
  'var',
  'const',
  'late',
  'assert',
  'break',
  'continue',
  'print',
  'debugPrint',
};

// 常に除外する関数名
const _alwaysExcludedNames = {'main', 'toString', 'hashCode', 'noSuchMethod'};

void main(List<String> args) {
  String? scope;
  var base = 'main';
  final fileArgs = <String>[];

  for (final arg in args) {
    if (arg.startsWith('--scope=')) {
      scope = arg.substring('--scope='.length);
    } else if (arg.startsWith('--base=')) {
      base = arg.substring('--base='.length);
    } else {
      fileArgs.add(arg);
    }
  }

  final files = <String>[];
  if (scope != null) {
    files.addAll(_getFilesForScope(scope: scope, base: base));
  } else if (fileArgs.isNotEmpty) {
    files.addAll(fileArgs.where((f) => f.isNotEmpty));
  } else {
    // デフォルト: staged + unstaged（git add 不要）
    files.addAll(_getFilesForScope(scope: 'changed', base: base));
  }

  final allViolations = <_Violation>[];
  for (final path in files) {
    if (_isGenerated(path: path)) continue;
    final file = File(path);
    if (!file.existsSync()) continue;
    try {
      allViolations.addAll(
        _checkFile(path: path, rawContent: file.readAsStringSync()),
      );
    } on Exception catch (e) {
      stderr.writeln('警告: $path の解析中にエラー: $e');
    }
  }

  if (allViolations.isEmpty) {
    stdout.writeln('\x1B[32m ✅ 名前付き引数チェック: 違反なし\x1B[0m');
    exit(0);
  }

  for (final v in allViolations) {
    stderr
      ..writeln('\x1B[33m${v.path}\x1B[0m')
      ..writeln('  Line ${v.line}: ${v.signature}')
      ..writeln();
  }
  final affectedFileCount = allViolations.map((v) => v.path).toSet().length;
  stderr
    ..writeln(
      '\x1B[33m位置引数を名前付き引数（{ ... }）に変更してください。\x1B[0m\n',
    )
    ..writeln(
      '\x1B[31m ❌ 名前付き引数違反 ${allViolations.length}件を検出'
      ' （$affectedFileCountファイル）\x1B[0m\n',
    );
  exit(1);
}

List<String> _getFilesForScope({required String scope, required String base}) {
  switch (scope) {
    case 'changed':
      return _getChangedFiles();
    case 'staged':
      return _getStagedFiles();
    case 'branch':
      return _getBranchDiffFiles(base);
    case 'all':
      return _getAllLibFiles();
    default:
      stderr.writeln(
        '不明なスコープ: $scope。changed / staged / branch / all を指定してください。',
      );
      exit(1);
  }
}

List<String> _getChangedFiles() {
  final result = Process.runSync('git', ['diff', 'HEAD', '--name-only']);
  if (result.exitCode != 0) {
    stderr.writeln('git diff HEAD に失敗しました');
    exit(1);
  }
  return _filterLibDartFiles(result.stdout as String);
}

List<String> _getStagedFiles() {
  final result = Process.runSync('git', ['diff', '--cached', '--name-only']);
  if (result.exitCode != 0) {
    stderr.writeln('git diff --cached に失敗しました');
    exit(1);
  }
  return _filterLibDartFiles(result.stdout as String);
}

List<String> _getBranchDiffFiles(String base) {
  final result = Process.runSync('git', ['diff', base, '--name-only']);
  if (result.exitCode != 0) {
    stderr.writeln('git diff $base に失敗しました。--base=<branch> で基点ブランチを変更できます');
    exit(1);
  }
  return _filterLibDartFiles(result.stdout as String);
}

List<String> _getAllLibFiles() {
  final result = Process.runSync('find', [
    'lib',
    '-name',
    '*.dart',
    '-not',
    '-name',
    '*.freezed.dart',
    '-not',
    '-name',
    '*.g.dart',
  ]);
  if (result.exitCode != 0) {
    stderr.writeln('find lib に失敗しました');
    exit(1);
  }
  return (result.stdout as String)
      .split('\n')
      .where((f) => f.isNotEmpty)
      .toList();
}

List<String> _filterLibDartFiles(String output) {
  return output
      .split('\n')
      .where((f) => f.isNotEmpty && f.startsWith('lib/') && f.endsWith('.dart'))
      .toList();
}

bool _isGenerated({required String path}) =>
    _skippedSuffixes.any((s) => path.endsWith(s));

class _Violation {
  const _Violation({
    required this.path,
    required this.line,
    required this.signature,
  });

  final String path;
  final int line;
  final String signature;
}

// ────────────────────────────────────────────────────────────────────────
// ファイル全体を検査して Violation リストを返す
// ────────────────────────────────────────────────────────────────────────
List<_Violation> _checkFile({
  required String path,
  required String rawContent,
}) {
  final content = _stripCommentsAndStrings(src: rawContent);
  final lineStarts = _buildLineStarts(content: content);
  final violations = <_Violation>[];

  // 関数・メソッド・コンストラクタの宣言を検出するパターン。
  //
  // 設計方針:
  //   - ジェネリクス <...> を同一行内のみにマッチさせる ([^(\n]*)
  //     → マルチライン誤マッチを防止
  //   - 戻り値型をグループ1でキャプチャ
  //     → 戻り値型なし + ; = 関数呼び出し という判定に利用
  //   - コンストラクタ (大文字始まり, 戻り値型なし) は別途許容
  final pattern = RegExp(
    // 行頭インデント
    r'(?:^|(?<=\n))[ \t]*'
    // 修飾子 (static, abstract, late, external, factory, @annotation)
    r'(?:(?:static|abstract|late|external|factory|@\w+(?:\([^)]*\))?)\s+)*'
    // statement キーワードを return type として使わない
    '(?!(?:return|await|throw|yield|new|if|else|for|while|switch|case|'
    r'final|var|const|late|assert|break|continue|print|debugPrint)\b)'
    // 戻り値型 (オプション; group 1 でキャプチャ)
    '((?:void|Future|Stream|String|int|double|bool|num|dynamic|Object|Never|'
    r'(?:[A-Z]\w*))'
    r'(?:<[^(\n]*>)?\??\s+)?'
    // 関数名 (group 2)
    r'(\w+)\s*'
    // 型パラメータ (オプション、同一行のみ)
    r'(?:<[^(\n]*>)?\s*'
    // 開き括弧
    r'\(',
    multiLine: true,
  );

  for (final match in pattern.allMatches(content)) {
    // group(1) = 戻り値型 (存在しない場合は null)
    // group(2) = 関数名
    final returnType = match.group(1);
    final funcName = match.group(2)!;

    // 予約語・除外名チェック
    if (_isKeyword(name: funcName)) continue;
    if (_alwaysExcludedNames.contains(funcName)) continue;
    if (_statementKeywords.contains(funcName)) continue;

    final openParenPos = match.end - 1;

    // @override があれば除外
    // match 自体に @override が含まれる場合 (modifiers に @override が入る) と
    // match の直前に @override がある場合の両方を考慮する
    final matchText = match.group(0)!;
    if (matchText.contains('@override') || matchText.contains('@Override')) {
      continue;
    }
    final lookbackStart = (match.start - 300).clamp(0, content.length);
    final preceding = content.substring(lookbackStart, match.start);
    if (_hasOverrideAnnotation(preceding: preceding)) continue;

    // パラメータリストを抽出
    final result = _extractParamListWithEnd(content, openParenPos + 1);
    if (result == null) continue;
    final (paramList, closingParenPos) = result;

    // 閉じ括弧の後が宣言構文かチェック（呼び出しとの区別）
    // 判定ルール:
    //   { または async { → 無条件で宣言
    //   ; → 戻り値型あり OR コンストラクタ (大文字始まり) の場合のみ宣言
    //   => ... ; → 無条件で宣言 (arrow function)
    final hasReturnType = returnType != null && returnType.trim().isNotEmpty;
    final isConstructorName =
        funcName.isNotEmpty && funcName[0] == funcName[0].toUpperCase();
    if (!_isDeclarationSyntax(
      content: content,
      afterClosingParen: closingParenPos + 1,
      requireReturnTypeForSemicolon: !(hasReturnType || isConstructorName),
    )) {
      continue;
    }

    // 位置引数（型付き）が含まれているか
    if (!_hasPositionalParams(paramList: paramList)) continue;

    final lineNum = _getLineNumber(lineStarts: lineStarts, pos: match.start);
    final rawLines = rawContent.split('\n');
    final sigLine = lineNum <= rawLines.length
        ? rawLines[lineNum - 1].trim()
        : funcName;

    violations.add(
      _Violation(path: path, line: lineNum, signature: sigLine),
    );
  }

  return violations;
}

// ────────────────────────────────────────────────────────────────────────
// @override チェック: 直前の } より後に @override があれば true
// ────────────────────────────────────────────────────────────────────────
bool _hasOverrideAnnotation({required String preceding}) {
  final lastBrace = preceding.lastIndexOf(RegExp('[{}]'));
  final text = lastBrace >= 0 ? preceding.substring(lastBrace + 1) : preceding;
  return text.contains('@override') || text.contains('@Override');
}

// ────────────────────────────────────────────────────────────────────────
// 閉じ括弧の後が関数宣言構文かを判定
//   { / async { / async* { / sync* {  → メソッド本体
//   ;                                 → 抽象メソッド / インターフェース
//   :                                 → コンストラクタ初期化子リスト
//   => ... ;                          → アロー関数 (switch arm の , とは区別)
// ────────────────────────────────────────────────────────────────────────
// requireReturnTypeForSemicolon: true の場合、; のみでは宣言と判断しない
// (戻り値型もコンストラクタ名もない場合 = 関数呼び出しの可能性が高い)
bool _isDeclarationSyntax({
  required String content,
  required int afterClosingParen,
  bool requireReturnTypeForSemicolon = false,
}) {
  var i = afterClosingParen;
  while (i < content.length && _isWhitespace(c: content[i])) {
    i++;
  }
  if (i >= content.length) return false;

  // コンストラクタ初期化子リスト
  if (content[i] == ':') return true;

  // async / async* / sync*
  for (final kw in ['async*', 'async', 'sync*']) {
    if (content.startsWith(kw, i)) {
      i += kw.length;
      while (i < content.length && _isWhitespace(c: content[i])) {
        i++;
      }
      break;
    }
  }
  if (i >= content.length) return false;

  // メソッド本体
  if (content[i] == '{') return true;

  // 抽象メソッド / インターフェース宣言
  // 戻り値型なし + コンストラクタでもない場合は ; を宣言と判定しない
  if (content[i] == ';') return !requireReturnTypeForSemicolon;

  // アロー関数 => : switch arm の , と区別するため ; で終わるか確認
  if (i + 1 < content.length && content[i] == '=' && content[i + 1] == '>') {
    var j = i + 2;
    var depth = 0;
    while (j < content.length) {
      final ch = content[j];
      if (ch == '{' || ch == '[' || ch == '(') {
        depth++;
      } else if (ch == '}' || ch == ']' || ch == ')') {
        if (depth == 0) return false;
        depth--;
      } else if (depth == 0) {
        if (ch == ';') return true;
        if (ch == ',') return false; // switch arm
      }
      j++;
    }
  }

  return false;
}

// ────────────────────────────────────────────────────────────────────────
// 位置引数の有無を判定
//
// 「位置引数」と判断する条件:
//   1. {} の外側に型アノテーション付きのパラメータがある
//      例: String theme, List<Task> items, int count
//   2. [] (オプショナル位置引数) が存在する
//   3. this. / super. が {} の外側に存在する (コンストラクタ shorthand)
// ────────────────────────────────────────────────────────────────────────
bool _hasPositionalParams({required String paramList}) {
  final trimmed = paramList.trim();
  if (trimmed.isEmpty) return false;

  var angleDepth = 0;
  var parenDepth = 0;
  var inNamed = false;
  final positional = StringBuffer();

  for (var i = 0; i < trimmed.length; i++) {
    final c = trimmed[i];
    switch (c) {
      case '<':
        angleDepth++;
      case '>':
        if (angleDepth > 0) angleDepth--;
      case '(':
        parenDepth++;
      case ')':
        if (parenDepth > 0) parenDepth--;
      case '{':
        if (angleDepth == 0 && parenDepth == 0) inNamed = true;
      case '}':
        if (angleDepth == 0 && parenDepth == 0) inNamed = false;
      case '[':
      // オプショナル位置引数 [...] も違反だが、リテラル [...] との区別が必要。
      // type annotation check で自然に判定されるため即時 return しない。
    }

    if (angleDepth == 0 &&
        parenDepth == 0 &&
        !inNamed &&
        c != '{' &&
        c != '}' &&
        c != '[' &&
        c != ']') {
      positional.write(c);
    }
  }

  final pos = positional.toString().trim();
  if (pos.isEmpty) return false;

  // コンストラクタ shorthand (this.field / super.field)
  if (pos.contains('this.') || pos.contains('super.')) return true;

  // 型アノテーションパターン: TypeName varName
  // 型名は大文字始まり or プリミティブ (String/int 等)
  // → 関数呼び出しの位置引数 (型なし) とを区別する
  return _hasTypeAnnotation(content: pos);
}

bool _hasTypeAnnotation({required String content}) {
  final pattern = RegExp(
    r'\b(?:[A-Z]\w*|void|String|int|double|bool|num|dynamic|Object|'
    'List|Map|Set|Iterable|Future|Stream|Never|Function|Uint8List|'
    r'Duration|DateTime|Color|Size|Offset|Rect|EdgeInsets|TextStyle)\b'
    r'(?:<[^>]*>)?\??\s+'
    r'(?:this\.|super\.)?\w+',
  );
  return pattern.hasMatch(content);
}

// ────────────────────────────────────────────────────────────────────────
// 開き括弧の次の位置から対応する閉じ括弧までを返す
// 戻り値: (paramListContent, closingParenIndex)
// ────────────────────────────────────────────────────────────────────────
(String, int)? _extractParamListWithEnd(String content, int start) {
  var depth = 1;
  var angleDepth = 0;

  for (var i = start; i < content.length; i++) {
    final c = content[i];
    if (c == '<') {
      angleDepth++;
    } else if (c == '>') {
      if (angleDepth > 0) angleDepth--;
    } else if (angleDepth == 0) {
      if (c == '(') {
        depth++;
      } else if (c == ')') {
        depth--;
        if (depth == 0) return (content.substring(start, i), i);
      }
    }
  }
  return null;
}

// ────────────────────────────────────────────────────────────────────────
// コメントと文字列リテラルを空白に置換（改行は保持）
// ────────────────────────────────────────────────────────────────────────
String _stripCommentsAndStrings({required String src}) {
  final buf = StringBuffer();
  var i = 0;

  void blank({required String c}) => buf.write(c == '\n' ? '\n' : ' ');

  while (i < src.length) {
    final c = src[i];

    // 三重クォート
    if ((c == '"' || c == "'") &&
        i + 2 < src.length &&
        src[i + 1] == c &&
        src[i + 2] == c) {
      final q3 = src.substring(i, i + 3);
      final end = src.indexOf(q3, i + 3);
      final finish = end == -1 ? src.length : end + 3;
      for (var j = i; j < finish; j++) {
        blank(c: src[j]);
      }
      i = finish;
      continue;
    }

    // 単一クォート文字列
    if (c == '"' || c == "'") {
      blank(c: c);
      i++;
      while (i < src.length && src[i] != c) {
        if (src[i] == r'\') {
          blank(c: src[i]);
          i++;
          if (i < src.length) {
            blank(c: src[i]);
            i++;
          }
          continue;
        }
        blank(c: src[i]);
        i++;
      }
      if (i < src.length) {
        blank(c: src[i]);
        i++;
      }
      continue;
    }

    // 行コメント
    if (c == '/' && i + 1 < src.length && src[i + 1] == '/') {
      while (i < src.length && src[i] != '\n') {
        blank(c: src[i]);
        i++;
      }
      continue;
    }

    // ブロックコメント
    if (c == '/' && i + 1 < src.length && src[i + 1] == '*') {
      blank(c: '/');
      blank(c: '*');
      i += 2;
      while (i + 1 < src.length && !(src[i] == '*' && src[i + 1] == '/')) {
        blank(c: src[i]);
        i++;
      }
      if (i + 1 < src.length) {
        blank(c: '*');
        blank(c: '/');
        i += 2;
      }
      continue;
    }

    buf.write(c);
    i++;
  }

  return buf.toString();
}

List<int> _buildLineStarts({required String content}) {
  final starts = <int>[0];
  for (var i = 0; i < content.length; i++) {
    if (content[i] == '\n') starts.add(i + 1);
  }
  return starts;
}

int _getLineNumber({required List<int> lineStarts, required int pos}) {
  var lo = 0;
  var hi = lineStarts.length - 1;
  while (lo < hi) {
    final mid = (lo + hi + 1) ~/ 2;
    if (lineStarts[mid] <= pos) {
      lo = mid;
    } else {
      hi = mid - 1;
    }
  }
  return lo + 1;
}

bool _isWhitespace({required String c}) =>
    c == ' ' || c == '\t' || c == '\n' || c == '\r';

bool _isKeyword({required String name}) {
  const keywords = {
    'if',
    'for',
    'while',
    'switch',
    'catch',
    'assert',
    'return',
    'throw',
    'await',
    'yield',
    'new',
    'class',
    'extends',
    'implements',
    'mixin',
    'enum',
    'typedef',
    'import',
    'export',
    'part',
    'library',
    'final',
    'const',
    'var',
    'late',
    'abstract',
    'static',
    'super',
    'this',
    'null',
    'true',
    'false',
    'void',
    'dynamic',
    'Never',
    'required',
    'covariant',
    'external',
    'factory',
    'sealed',
    'base',
    'interface',
    'when',
    'in',
    'is',
    'as',
  };
  return keywords.contains(name);
}
