import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/repositories/push_token/push_token_repository_impl.dart';
import 'package:travel_app/data/services/braze/push_token/stub_push_token_service_impl.dart';
import 'package:travel_app/domain/use_cases/push_token/register_push_token_use_case.dart';

/// ## 概要
/// [RegisterPushTokenUseCase] → [PushTokenRepositoryImpl]
/// → [StubPushTokenServiceImpl] を実物のまま繋いだ Integration × Small テスト。
/// I/O 境界（[StubPushTokenServiceImpl]）のみスタブに差し替え、
/// その上の UseCase・Repository・Interface は本物を実行する。
///
/// ## 目的
/// UseCase → Repository の委譲経路が正しく配線されているかを保証する。
///
/// ## スタブ境界
/// ```dart
/// UseCase (real)
///   → RepositoryImpl (real)
///   → StubPushTokenServiceImpl  ← ここだけスタブ
/// ```
void main() {
  group('RegisterPushTokenUseCase', () {
    ProviderContainer buildContainer() {
      final container = ProviderContainer(
        overrides: [
          stubPushTokenServiceImplProvider.overrideWith(
            (_) => StubPushTokenServiceImpl(),
          ),
          pushTokenRepositoryProvider.overrideWith(
            (ref) => PushTokenRepositoryImpl(
              pushTokenService: ref.read(stubPushTokenServiceImplProvider),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    group('register', () {
      test('正常系: 例外をスローせずに完了すること', () async {
        final container = buildContainer();
        final useCase = container.read(registerPushTokenUseCaseProvider);

        await expectLater(useCase.register(), completes);
      });

      test('正常系: 複数回呼び出しても例外をスローしないこと', () async {
        final container = buildContainer();
        final useCase = container.read(registerPushTokenUseCaseProvider);

        await expectLater(useCase.register(), completes);
        await expectLater(useCase.register(), completes);
      });
    });
  });
}
