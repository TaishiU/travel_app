import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/auth/auth_repository.dart';
import 'package:travel_app/domain/use_cases/auth/auth_use_case.dart';
import 'package:travel_app/presentation/debug/screen.dart';
import 'package:travel_app/presentation/home/todo_detail/screen.dart';
import 'package:travel_app/presentation/home/todo_list/screen.dart';
import 'package:travel_app/presentation/login/screen.dart';
import 'package:travel_app/presentation/profile/screen.dart';
import 'package:travel_app/presentation/task/screen.dart';

/// 共通UIシェルのウィジェット (Bottom Navigation Barを持つScaffold)
class ScaffoldWithNavBar extends StatefulWidget {
  /// コンストラクタ
  const ScaffoldWithNavBar({required this.child, super.key});

  /// 子Widget
  final Widget child;

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child, // ここに現在のGoRouteの画面が表示される
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // GoRouterを使ってナビゲーション
          switch (index) {
            case 0:
              context.go(TodoListScreen.path);
            case 1:
              context.go(TaskScreen.path);
            case 2:
              context.go(ProfileScreen.path);
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Task'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// --- Navigator Keys (ShellRouteごとに異なるキーを使用) ---
// Root Navigator Key (MaterialApp.routerのnavigatorKey)
final _rootNavigatorKey = GlobalKey<NavigatorState>();
// ボトムナビゲーション用のShellRouteのNavigator Key
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// --- GoRouterの定義 ---
/// プロバイダ
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: TodoListScreen.path,
    navigatorKey: _rootNavigatorKey,
    routes: [
      // ログイン画面 (共通のShellRouteとは独立したルート)
      GoRoute(
        path: LoginScreen.path,
        builder: (context, state) => const LoginScreen(),
      ),

      // デバッグメニュー（kDebugMode 限定）
      if (kDebugMode)
        GoRoute(
          path: DebugMenuScreen.path,
          builder: (context, state) => const DebugMenuScreen(),
        ),

      // Bottom Navigation Bar を持つShellRoute
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: TodoListScreen.path,
            builder: (context, state) => const TodoListScreen(),
            routes: [
              GoRoute(
                path: ':todoId', // /todo_list/:todoId
                builder: (context, state) {
                  final todoId = int.parse(state.pathParameters['todoId']!);
                  return TodoDetailScreen(todoId: todoId);
                },
              ),
            ],
          ),
          GoRoute(
            path: TaskScreen.path,
            builder: (context, state) => const TaskScreen(),
          ),
          GoRoute(
            path: ProfileScreen.path,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    refreshListenable: ref.read(authRepositoryProvider),
    redirect: (context, state) async {
      final loggedIn = await ref.read(authUseCaseProvider).checkIsLoggedIn();
      final loggingIn = state.matchedLocation == LoginScreen.path;
      if (!loggedIn) {
        return LoginScreen.path;
      }
      if (loggingIn) {
        return TodoListScreen.path;
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('エラー')),
      body: Center(child: Text('エラー: ${state.error}')),
    ),
  );
});
