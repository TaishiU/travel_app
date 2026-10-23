import 'package:braze_plugin/braze_plugin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_app/data/services/braze/analytics/braze_analytics_service.dart';
import 'package:travel_app/data/services/braze/analytics/braze_analytics_service_impl.dart';
import 'package:travel_app/data/services/braze/braze_plugin_provider.dart';

import 'braze_analytics_service_impl_test.mocks.dart';

@GenerateMocks([BrazePlugin])
void main() {
  late MockBrazePlugin mockBrazePlugin;

  setUp(() {
    mockBrazePlugin = MockBrazePlugin();
  });

  group('brazeAnalyticsServiceImplProvider', () {
    group('正常系', () {
      test('BrazeAnalyticsServiceのインスタンスを返すこと', () {
        // Given
        final container = ProviderContainer(
          overrides: [brazePluginProvider.overrideWithValue(mockBrazePlugin)],
        );
        addTearDown(container.dispose);

        // When / Then
        expect(
          container.read(brazeAnalyticsServiceImplProvider),
          isA<BrazeAnalyticsService>(),
        );
      });
    });
  });

  group('BrazeAnalyticsServiceImpl', () {
    late BrazeAnalyticsServiceImpl service;

    setUp(() {
      service = BrazeAnalyticsServiceImpl(brazePlugin: mockBrazePlugin);
    });

    group('logCustomEvent', () {
      group('正常系', () {
        test('propertiesなし: brazePlugin.logCustomEvent()が呼ばれること', () {
          // When
          service.logCustomEvent(eventName: 'test_event');

          // Then
          verify(mockBrazePlugin.logCustomEvent('test_event')).called(1);
        });

        test(
          'propertiesあり: brazePlugin.logCustomEvent()がpropertiesつきで呼ばれること',
          () {
            // Given
            final props = <String, dynamic>{'key': 'value'};

            // When
            service.logCustomEvent(eventName: 'test_event', properties: props);

            // Then
            verify(
              mockBrazePlugin.logCustomEvent('test_event', properties: props),
            ).called(1);
          },
        );
      });
    });

    group('setStringAttribute', () {
      group('正常系', () {
        test('brazePlugin.setStringCustomUserAttribute()が呼ばれること', () {
          // When
          service.setStringAttribute(key: 'attr_key', value: 'attr_val');

          // Then
          verify(
            mockBrazePlugin.setStringCustomUserAttribute(
              'attr_key',
              'attr_val',
            ),
          ).called(1);
        });
      });
    });

    group('setBoolAttribute', () {
      group('正常系', () {
        test('brazePlugin.setBoolCustomUserAttribute()が呼ばれること', () {
          // When
          service.setBoolAttribute(key: 'bool_key', value: true);

          // Then
          verify(
            mockBrazePlugin.setBoolCustomUserAttribute('bool_key', true),
          ).called(1);
        });
      });
    });

    group('setIntAttribute', () {
      group('正常系', () {
        test('brazePlugin.setIntCustomUserAttribute()が呼ばれること', () {
          // When
          service.setIntAttribute(key: 'int_key', value: 42);

          // Then
          verify(
            mockBrazePlugin.setIntCustomUserAttribute('int_key', 42),
          ).called(1);
        });
      });
    });

    group('requestImmediateDataFlush', () {
      group('正常系', () {
        test('brazePlugin.requestImmediateDataFlush()が呼ばれること', () {
          // When
          service.requestImmediateDataFlush();

          // Then
          verify(mockBrazePlugin.requestImmediateDataFlush()).called(1);
        });
      });
    });
  });
}
