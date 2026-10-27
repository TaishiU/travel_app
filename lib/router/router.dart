import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/auth/auth_repository_impl.dart';
import 'package:travel_app/domain/use_cases/auth/auth_use_case.dart';
import 'package:travel_app/presentation/debug/screen.dart';
import 'package:travel_app/presentation/login/screen.dart';
import 'package:travel_app/presentation/profile/screen.dart';
import 'package:travel_app/presentation/task/screen.dart';
import 'package:travel_app/utils/logger.dart';

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
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = location.startsWith(ProfileScreen.path) ? 1 : 0;
    return Scaffold(
      body: widget.child, // ここに現在のGoRouteの画面が表示される
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          // GoRouterを使ってナビゲーション
          switch (index) {
            // case 0:
            //   context.go(TodoListScreen.path);
            // case 1:
            //   context.go(TaskScreen.path);
            // case 2:
            //   context.go(ProfileScreen.path);
            case 0:
              context.go(TaskScreen.path);
            case 1:
              context.go(ProfileScreen.path);
            // case 2:
            //   context.go(ProfileScreen.path);
          }
        },
        items: const <BottomNavigationBarItem>[
          // BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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

bool _isProtectedPath({required String path}) {
  const protectedPrefixes = [
    '/booking', // ハードガード: booking系（Phase 3で使用）
    '/my-trips/', // ハードガード: 旅程詳細のみ（末尾スラッシュで一覧を除外）
  ];
  return protectedPrefixes.any((prefix) => path.startsWith(prefix));
}

// --- GoRouterの定義 ---
/// プロバイダ
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // initialLocation: TodoListScreen.path,
    initialLocation: TaskScreen.path,
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
          // GoRoute(
          //   path: TodoListScreen.path,
          //   builder: (context, state) => const TodoListScreen(),
          //   routes: [
          //     GoRoute(
          //       path: ':todoId', // /todo_list/:todoId
          //       builder: (context, state) {
          //         final todoId = int.parse(state.pathParameters['todoId']!);
          //         return TodoDetailScreen(todoId: todoId);
          //       },
          //     ),
          //   ],
          // ),
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
      try {
        final loggedIn = await ref.read(authUseCaseProvider).checkIsLoggedIn();
        logger.d(message: 'state.matchedLocation: ${state.matchedLocation}');
        final path = state.matchedLocation;

        if (!loggedIn && _isProtectedPath(path: path)) {
          ref.read(authUseCaseProvider).savePendingDeepLink(path: path);
          return LoginScreen.path;
        }

        if (loggedIn && path == LoginScreen.path) {
          return TaskScreen.path;
        }

        return null;
      } on Exception catch (error) {
        logger.e(message: '[Router] redirect error: $error');
        return null;
      }
    },
    onException: (context, state, router) {
      final uri = state.uri;
      if (uri.scheme != 'travelapp') {
        // deep link 以外のエラー（例: redirect 例外）は現在画面をキープ
        logger.e(
          message:
              '[Router] onException: uri=${state.uri}, '
              'error=${state.error}',
        );
        return;
      }
      final path = '/${uri.host}${uri.path}';
      final targetPath = path == '/' ? TaskScreen.path : path;
      // MethodChannel が先着済みの場合はスキップ（二重遷移防止）
      if (router.routeInformationProvider.value.uri.path == targetPath) {
        return;
      }
      router.go(targetPath);
    },
  );
});
