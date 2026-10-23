import 'dart:io' show Platform;

import 'package:braze_plugin/braze_plugin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';
import 'package:travel_app/config/braze_config.dart';
import 'package:travel_app/data/services/braze/braze_plugin_provider.dart';
import 'package:travel_app/data/services/local_storage/preferences/shared_preferences_service_impl.dart';
import 'package:travel_app/domain/use_cases/push_token/register_push_token_use_case.dart';
import 'package:travel_app/firebase_options.dart';
import 'package:travel_app/router/router.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/talker.dart';
import 'package:travel_app/utils/unauthorized_error_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    BrazePlugin.logLevel = BrazeLogLevel.debug;
  }
  final brazePlugin = BrazePlugin();
  if (Platform.isAndroid) {
    brazePlugin.initialize(BrazeConfig.androidApiKey, BrazeConfig.endpoint);
  } else if (Platform.isIOS) {
    brazePlugin.initialize(BrazeConfig.iosApiKey, BrazeConfig.endpoint);
  }

  final sharedPreferencesWithCache = await SharedPreferencesWithCache.create(
    // allowList: null（デフォルト）で全キーをキャッシュ対象にする。
    // キーを明示管理する集約クラス案と比較検討したが、新キー追加のたびに
    // 集約クラスの更新が必要になる保守コストを回避するために null を採用。
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
  final sharedPreferencesServiceImpl = SharedPreferencesServiceImpl(
    sharedPreferences: sharedPreferencesWithCache,
  );

  final container = ProviderContainer(
    observers: [
      UnauthorizedErrorObserver(),
      TalkerRiverpodObserver(
        talker: talker,
        settings: const TalkerRiverpodLoggerSettings(
          printProviderAdded: false,
          printProviderUpdated: false,
        ),
      ),
    ],
    overrides: [
      sharedPreferencesServiceImplProvider.overrideWithValue(
        sharedPreferencesServiceImpl,
      ),
      brazePluginProvider.overrideWithValue(brazePlugin),
    ],
  );

  // logger.i(message: '[main.dart] register(): start');
  // await container.read(registerPushTokenUseCaseProvider).register();

  try {
    logger.i(message: '[main.dart] register(): start');
    await container.read(registerPushTokenUseCaseProvider).register();
  } on Exception catch (error) {
    talker.warning(
      'Push token registration failed. App continues without push token.',
      error,
    );
  }

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

///
class MyApp extends ConsumerStatefulWidget {
  /// コンストラクタ
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    const MethodChannel('deepLinkChannel').setMethodCallHandler((call) async {
      final url = call.arguments as String?;
      if (url == null) return;
      final path = _toRouterPath(url: url);
      if (path != null) ref.read(routerProvider).go(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

// travelapp://task → /task, travelapp://booking/BK-123 → /booking/BK-123
String? _toRouterPath({required String url}) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.scheme != 'travelapp') return null;
  final path = '/${uri.host}${uri.path}';
  return path == '/' ? null : path;
}
