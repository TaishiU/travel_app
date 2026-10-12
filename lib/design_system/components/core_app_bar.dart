import 'package:flutter/material.dart';

/// 共通 [AppBar]
class CoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// コンストラクタ
  const CoreAppBar({
    required this.title,
    this.actions,
    super.key,
  });

  /// タイトル
  final String title;

  /// アクションズ
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: actions,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
