import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/permission/notification/notification_permission_repository_impl.dart';
import 'package:travel_app/domain/entities/permission/notification/notification_permission_status.dart';
import 'package:travel_app/domain/interfaces/permission/notification/notification_permission_repository.dart';

/// [NotificationPermissionUseCase] のプロバイダー
final notificationPermissionUseCaseProvider =
    Provider<NotificationPermissionUseCase>(
      (ref) => NotificationPermissionUseCase(
        repository: ref.read(notificationPermissionRepositoryProvider),
      ),
    );

/// Push通知権限の取得・要求を担うドメインユースケース。
///
/// - アプリ起動時に権限状態を確認し `push_permission_status` 属性として Braze へ送信する（BRAZE-015 以降）
/// - 権限要求タイミングで [requestPermission] を呼び出す
class NotificationPermissionUseCase {
  /// コンストラクタ
  NotificationPermissionUseCase({required this.repository});

  /// 通知権限リポジトリインターフェース
  final NotificationPermissionRepository repository;

  /// 現在の通知権限状態を取得する。
  Future<NotificationPermissionStatus> checkStatus() =>
      repository.checkStatus();

  /// 通知権限をユーザーに要求し、結果を返す。
  ///
  /// 権限ダイアログを表示する可能性があるため、
  /// 予約確定後など「価値が伝わるタイミング」で呼び出すこと（design_doc.md 参照）。
  Future<NotificationPermissionStatus> requestPermission() =>
      repository.requestPermission();
}
