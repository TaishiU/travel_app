import 'dart:async';

import 'package:braze_plugin/braze_plugin.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_app/data/services/braze/braze_plugin_provider.dart';
import 'package:travel_app/data/services/braze/push_token/push_token_service.dart';
import 'package:travel_app/data/services/braze/push_token/push_token_service_impl.dart';

import 'push_token_service_impl_test.mocks.dart';

void _setupDummyValues() {
  provideDummy<Stream<String>>(const Stream.empty());
  provideDummy<Future<String?>>(Future.value());
}

@GenerateMocks([BrazePlugin, FirebaseMessaging])
void main() {
  _setupDummyValues();

  late MockBrazePlugin mockBrazePlugin;
  late MockFirebaseMessaging mockFirebaseMessaging;

  setUp(() {
    mockBrazePlugin = MockBrazePlugin();
    mockFirebaseMessaging = MockFirebaseMessaging();
  });

  group('pushTokenServiceImplProvider', () {
    test('PushTokenServiceのインスタンスを返すこと', () {
      final container = ProviderContainer(
        overrides: [
          brazePluginProvider.overrideWithValue(mockBrazePlugin),
          firebaseMessagingProvider.overrideWithValue(mockFirebaseMessaging),
        ],
      );
      addTearDown(container.dispose);

      final service = container.read(pushTokenServiceImplProvider);

      expect(service, isA<PushTokenService>());
    });
  });

  group('コンストラクタ', () {
    test('Android: onTokenRefreshリスナーを設定し、トークン更新時にBrazeへ登録すること', () async {
      final controller = StreamController<String>.broadcast();
      addTearDown(controller.close);
      when(
        mockFirebaseMessaging.onTokenRefresh,
      ).thenAnswer((_) => controller.stream);

      PushTokenServiceImpl(
        brazePlugin: mockBrazePlugin,
        firebaseMessaging: mockFirebaseMessaging,
        isAndroid: true,
      );

      controller.add('refreshed_token');
      await Future<void>.delayed(Duration.zero);

      verify(mockBrazePlugin.registerPushToken('refreshed_token')).called(1);
    });

    test('非Android: onTokenRefreshリスナーを設定しないこと', () {
      PushTokenServiceImpl(
        brazePlugin: mockBrazePlugin,
        firebaseMessaging: mockFirebaseMessaging,
        isAndroid: false,
      );

      verifyNever(mockFirebaseMessaging.onTokenRefresh);
    });
  });

  group('register', () {
    test('Android・トークンあり: FCMトークンを取得してBrazeに登録すること', () async {
      final controller = StreamController<String>.broadcast();
      addTearDown(controller.close);
      when(
        mockFirebaseMessaging.onTokenRefresh,
      ).thenAnswer((_) => controller.stream);
      when(
        mockFirebaseMessaging.getToken(),
      ).thenAnswer((_) async => 'fcm_token');

      final service = PushTokenServiceImpl(
        brazePlugin: mockBrazePlugin,
        firebaseMessaging: mockFirebaseMessaging,
        isAndroid: true,
      );

      await service.register();

      verify(mockFirebaseMessaging.getToken()).called(1);
      verify(mockBrazePlugin.registerPushToken('fcm_token')).called(1);
    });

    test('Android・トークンnull: Brazeへ登録しないこと', () async {
      final controller = StreamController<String>.broadcast();
      addTearDown(controller.close);
      when(
        mockFirebaseMessaging.onTokenRefresh,
      ).thenAnswer((_) => controller.stream);
      when(
        mockFirebaseMessaging.getToken(),
      ).thenAnswer((_) async => null);

      final service = PushTokenServiceImpl(
        brazePlugin: mockBrazePlugin,
        firebaseMessaging: mockFirebaseMessaging,
        isAndroid: true,
      );

      await service.register();

      verify(mockFirebaseMessaging.getToken()).called(1);
      verifyNever(mockBrazePlugin.registerPushToken(any));
    });

    test('非Android: getTokenを呼ばずno-opで終了すること', () async {
      final service = PushTokenServiceImpl(
        brazePlugin: mockBrazePlugin,
        firebaseMessaging: mockFirebaseMessaging,
        isAndroid: false,
      );

      await service.register();

      verifyNever(mockFirebaseMessaging.getToken());
      verifyNever(mockBrazePlugin.registerPushToken(any));
    });
  });
}
