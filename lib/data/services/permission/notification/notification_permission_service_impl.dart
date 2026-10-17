import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/local_storage/preferences/permission/notification/android_notification_permission_preferences_service.dart';
import 'package:travel_app/data/services/local_storage/preferences/permission/notification/android_notification_permission_preferences_service_impl.dart';
import 'package:travel_app/data/services/permission/notification/android_notification_permission_service_impl.dart';
import 'package:travel_app/data/services/permission/notification/ios_notification_permission_service_impl.dart';
import 'package:travel_app/data/services/permission/notification/notification_permission_service.dart';

/// [NotificationPermissionService] の実装クラスを提供する Provider。
/// iOS / Android それぞれの実装をプラットフォームに応じて切り替える。
final notificationPermissionServiceImplProvider =
    Provider<NotificationPermissionService>(
      (ref) => buildNotificationPermissionService(
        preferencesServiceFactory: () => ref.read(
          androidNotificationPermissionPreferencesServiceImplProvider,
        ),
        isIos: Platform.isIOS,
      ),
    );

/// [NotificationPermissionService] のインスタンスを生成する。
/// [isIos] を注入可能にすることでテスト時にプラットフォーム分岐を制御できる。
/// [preferencesServiceFactory] は lazy に評価されるため、[isIos] が true の場合は呼ばれない。
NotificationPermissionService buildNotificationPermissionService({
  required AndroidNotificationPermissionPreferencesService Function()
  preferencesServiceFactory,
  required bool isIos,
}) => isIos
    ? IosNotificationPermissionServiceImpl()
    : AndroidNotificationPermissionServiceImpl(
        preferencesService: preferencesServiceFactory(),
      );
