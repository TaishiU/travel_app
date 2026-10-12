import 'package:flutter/material.dart';

/// Widgetbookのユースケース表示用の基本的なScaffold。
///
/// このウィジェットは、Widgetbookのユースケースを表示するための
/// 共通レイアウトを提供する、Scaffoldのラッパークラスです。
class BaseScaffold extends StatelessWidget {
  /// [BaseScaffold]を生成する。
  const BaseScaffold({required this.body, required this.title, super.key});

  /// タイトル
  final String title;

  /// ボディ
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: body),
    );
  }
}
