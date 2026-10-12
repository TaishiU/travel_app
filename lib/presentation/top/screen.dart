import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// タブバー付きのScaffold
class TopScreen extends StatefulWidget {
  /// コンストラクタ
  const TopScreen({
    required this.child,
    super.key,
  });

  /// 子Widget
  final Widget child;

  @override
  State<TopScreen> createState() => _TopScreenState();
}

class _TopScreenState extends State<TopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 現在のパスに基づいてタブの初期インデックスを設定
    final currentPath = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.path;
    var initialIndex = 0;
    if (currentPath.startsWith('/home/tab2')) {
      initialIndex = 1;
    } else if (currentPath.startsWith('/home/tab3')) {
      initialIndex = 2;
    }
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      // タブが変更されたときにGoRouterでナビゲート
      switch (_tabController.index) {
        case 0:
          context.go('/home/tab1');
        case 1:
          context.go('/home/tab2');
        case 2:
          context.go('/home/tab3');
      }
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabSelection)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'タブ1'),
            Tab(text: 'タブ2'),
            Tab(text: 'タブ3'),
          ],
        ),
      ),
      body: widget.child, // ここに現在のGoRouteの画面が表示される
    );
  }
}
