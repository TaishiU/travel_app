import 'dart:async';

import 'package:travel_app/data/repositories/auth/auth_repository.dart';
import 'package:travel_app/domain/errors/app_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UnauthorizedError 発生時に自動ログアウトする ProviderObserver。
///
/// AsyncError の error が UnauthorizedError の場合、authRepository.logout() を呼ぶ。
/// logout() → notifyListeners() → GoRouter の refreshListenable が発火し、
/// redirect で LoginScreen へ自動遷移する。
base class UnauthorizedErrorObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (newValue is AsyncError && newValue.error is UnauthorizedError) {
      unawaited(context.container.read(authRepositoryProvider).logout());
    }
  }
}
