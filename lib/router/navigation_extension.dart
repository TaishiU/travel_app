import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app/presentation/debug/screen.dart';
import 'package:travel_app/presentation/home/todo_list/screen.dart';
import 'package:travel_app/presentation/login/screen.dart';
import 'package:travel_app/presentation/profile/screen.dart';
import 'package:travel_app/presentation/task/screen.dart';

/// 画面遷移ヘルパー。
extension NavigationExtension on BuildContext {
  /// デバッグメニュー画面へ遷移する。
  void toDebugMenuScreen() => push(DebugMenuScreen.path);

  /// ログイン画面へ遷移する。
  void toLoginScreen() => go(LoginScreen.path);

  /// Todoリスト画面へ遷移する。
  void toTodoListScreen() => go(TodoListScreen.path);

  /// Todo詳細画面へ遷移する。
  void toTodoDetailScreen({required int todoId}) =>
      push('${TodoListScreen.path}/$todoId');

  /// タスク画面へ遷移する。
  void toTaskScreen() => go(TaskScreen.path);

  /// プロフィール画面へ遷移する。
  void toProfileScreen() => go(ProfileScreen.path);
}
