import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app/presentation/debug/screen.dart';
import 'package:travel_app/presentation/login/screen.dart';
import 'package:travel_app/presentation/profile/screen.dart';
import 'package:travel_app/presentation/task/screen.dart';

/// 画面遷移ヘルパー。
extension NavigationExtension on BuildContext {
  /// デバッグメニュー画面へ遷移する。
  void toDebugMenuScreen() => push(DebugMenuScreen.path);

  /// ログイン画面へ遷移する。
  void toLoginScreen() => go(LoginScreen.path);

  /// タスク画面へ遷移する。
  void toTaskScreen() => go(TaskScreen.path);

  /// プロフィール画面へ遷移する。
  void toProfileScreen() => go(ProfileScreen.path);
}
