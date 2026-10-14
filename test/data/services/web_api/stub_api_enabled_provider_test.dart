import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/web_api/stub_api_enabled_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('StubApiEnabledNotifier', () {
    group('正常系', () {
      test('初期値は false であること', () {
        final value = container.read(isStubApiEnabledProvider);
        expect(value, isFalse);
      });

      test('enabled=true に設定すると state が true になること', () {
        container.read(isStubApiEnabledProvider.notifier).enabled = true;
        expect(container.read(isStubApiEnabledProvider), isTrue);
      });

      test('enabled=false に設定すると state が false になること', () {
        container.read(isStubApiEnabledProvider.notifier).enabled = true;
        container.read(isStubApiEnabledProvider.notifier).enabled = false;
        expect(container.read(isStubApiEnabledProvider), isFalse);
      });

      test('enabled ゲッターは現在の state を返すこと', () {
        final notifier = container.read(isStubApiEnabledProvider.notifier);
        expect(notifier.enabled, isFalse);
        notifier.enabled = true;
        expect(notifier.enabled, isTrue);
      });
    });
  });
}
