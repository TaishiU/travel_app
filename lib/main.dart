import 'package:travel_app/data/services/local_storage/preferences/shared_preferences_service_impl.dart';
import 'package:travel_app/router/router.dart';
import 'package:travel_app/utils/talker.dart';
import 'package:travel_app/utils/unauthorized_error_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferencesWithCache = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: <String>{
        'access_token',
        'refresh_token',
      },
    ),
  );

  final sharedPreferencesServiceImpl = SharedPreferencesServiceImpl(
    sharedPreferences: sharedPreferencesWithCache,
  );

  runApp(
    ProviderScope(
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
      ],
      child: const MyApp(),
    ),
  );
}

///
class MyApp extends ConsumerWidget {
  /// コンストラクタ
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
