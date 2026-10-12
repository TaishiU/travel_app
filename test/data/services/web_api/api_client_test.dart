import 'dart:convert';
import 'dart:io';

import 'package:travel_app/data/services/local_storage/secure_storage/auth/auth_secure_storage_service.dart';
import 'package:travel_app/data/services/local_storage/secure_storage/auth/auth_secure_storage_service_impl.dart';
import 'package:travel_app/data/services/web_api/api_client.dart';
import 'package:travel_app/data/services/web_api/api_exception.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([http.Client, AuthSecureStorageService])
import 'api_client_test.mocks.dart';

const String testBaseUrl = 'https://test.com';

void main() {
  late MockClient mockHttpClient;
  late MockAuthSecureStorageService mockAuthService;
  late ApiClientImpl apiClient;
  late ProviderContainer container;

  setUp(() {
    mockHttpClient = MockClient();
    mockAuthService = MockAuthSecureStorageService();

    // AuthSecureStorageService の初期化関連のデフォルト動作
    when(mockAuthService.init()).thenAnswer((_) async {});
    when(mockAuthService.getAccessToken()).thenReturn('');
    when(mockAuthService.getRefreshToken()).thenReturn('');
    when(mockAuthService.clearAuthData()).thenAnswer((_) async => true);

    container = ProviderContainer(
      overrides: [
        baseUrlProvider.overrideWithValue(testBaseUrl),
        authSecureStorageServiceImplProvider.overrideWithValue(mockAuthService),
      ],
    );

    apiClient = ApiClientImpl(
      client: mockHttpClient,
      baseUrl: testBaseUrl,
      authSecureStorageService: mockAuthService,
      retryDelay: Duration.zero, // テストを高速化するために遅延をゼロにする
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('ApiClientImpl', () {
    test('初期化時に各フィールドが正しく設定されること', () {
      expect(apiClient.baseUrl, testBaseUrl);
      expect(apiClient.authSecureStorageService, mockAuthService);
    });

    group('GET', () {
      test('200 OKの場合、デコードされたMapを返すこと', () async {
        final responseBody = {'id': 1, 'name': 'test'};
        when(
          mockHttpClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(responseBody), 200));

        final result = await apiClient.get(endpoint: 'test');

        expect(result, responseBody);
        verify(
          mockHttpClient.get(
            Uri.parse('$testBaseUrl/test'),
            headers: anyNamed('headers'),
          ),
        ).called(1);
      });

      test('クエリパラメータが正しく付与されること', () async {
        when(
          mockHttpClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('{}', 200));

        await apiClient.get(
          endpoint: 'test',
          queryParameters: {'q': 'flutter', 'page': 1},
        );

        final capturedUri =
            verify(
                  mockHttpClient.get(captureAny, headers: anyNamed('headers')),
                ).captured.single
                as Uri;
        expect(capturedUri.queryParameters, {'q': 'flutter', 'page': '1'});
      });
    });

    group('POST', () {
      test('201 Createdの場合、デコードされたMapを返すこと', () async {
        final requestBody = {'name': 'new item'};
        final responseBody = {'id': 101, 'name': 'new item'};
        when(mockHttpClient.send(any)).thenAnswer(
          (_) async => http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode(responseBody))),
            201,
          ),
        );

        final result = await apiClient.post(
          endpoint: 'items',
          body: requestBody,
        );

        expect(result, responseBody);
        final captured =
            verify(mockHttpClient.send(captureAny)).captured.single
                as http.Request;
        expect(captured.url, Uri.parse('$testBaseUrl/items'));
        expect(captured.method, 'POST');
        expect(captured.body, jsonEncode(requestBody));
      });
    });

    group('認証ヘッダー', () {
      test('アクセストークンが存在する場合、Authorizationヘッダーが付与されること', () async {
        when(mockAuthService.getAccessToken()).thenReturn('valid_token');
        when(
          mockHttpClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('{}', 200));

        await apiClient.get(endpoint: 'test');

        final capturedHeaders =
            verify(
                  mockHttpClient.get(any, headers: captureAnyNamed('headers')),
                ).captured.single
                as Map<String, String>;
        expect(capturedHeaders['Authorization'], 'Bearer valid_token');
      });

      test('カスタムヘッダーを指定した場合、アクセストークンと共に出力されること', () async {
        when(mockAuthService.getAccessToken()).thenReturn('token123');
        when(
          mockHttpClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('{}', 200));

        final customHeaders = {'X-Custom-Header': 'custom_value'};
        await apiClient.get(endpoint: 'test', headers: customHeaders);

        final capturedHeaders =
            verify(
                  mockHttpClient.get(any, headers: captureAnyNamed('headers')),
                ).captured.single
                as Map<String, String>;

        expect(capturedHeaders['Authorization'], 'Bearer token123');
        expect(capturedHeaders['X-Custom-Header'], 'custom_value');
      });
    });

    group('PUT', () {
      test('200 OKの場合、デコードされたMapを返すこと', () async {
        final requestBody = {'name': 'updated item'};
        final responseBody = {'id': 1, 'name': 'updated item'};
        when(mockHttpClient.send(any)).thenAnswer(
          (_) async => http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode(responseBody))),
            200,
          ),
        );

        final result = await apiClient.put(
          endpoint: 'items/1',
          body: requestBody,
        );

        expect(result, responseBody);
        final captured =
            verify(mockHttpClient.send(captureAny)).captured.single
                as http.Request;
        expect(captured.url, Uri.parse('$testBaseUrl/items/1'));
        expect(captured.method, 'PUT');
        expect(captured.body, jsonEncode(requestBody));
      });
    });

    group('PATCH', () {
      test('200 OKの場合、デコードされたMapを返すこと', () async {
        final requestBody = {'name': 'patched item'};
        final responseBody = {'id': 1, 'name': 'patched item'};
        when(mockHttpClient.send(any)).thenAnswer(
          (_) async => http.StreamedResponse(
            Stream.value(utf8.encode(jsonEncode(responseBody))),
            200,
          ),
        );

        final result = await apiClient.patch(
          endpoint: 'items/1',
          body: requestBody,
        );

        expect(result, responseBody);
        final captured =
            verify(mockHttpClient.send(captureAny)).captured.single
                as http.Request;
        expect(captured.url, Uri.parse('$testBaseUrl/items/1'));
        expect(captured.method, 'PATCH');
        expect(captured.body, jsonEncode(requestBody));
      });
    });

    group('DELETE', () {
      test('200 OKの場合、デコードされたMapを返すこと', () async {
        final responseBody = {'success': true};
        when(
          mockHttpClient.delete(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(responseBody), 200));

        final result = await apiClient.delete(endpoint: 'items/1');

        expect(result, responseBody);
        verify(
          mockHttpClient.delete(
            Uri.parse('$testBaseUrl/items/1'),
            headers: anyNamed('headers'),
          ),
        ).called(1);
      });
    });

    group('ステータスコード別エラーハンドリング', () {
      final errorCodes = {
        400: isA<BadRequestException>(),
        403: isA<ForbiddenException>(),
        404: isA<NotFoundException>(),
        405: isA<MethodNotAllowedException>(),
        500: isA<InternalServerErrorException>(),
        503: isA<UnknownErrorException>(),
      };

      for (final entry in errorCodes.entries) {
        final code = entry.key;
        final matcher = entry.value;

        test('$code の場合に ${matcher.runtimeType} を投げること', () async {
          when(
            mockHttpClient.get(any, headers: anyNamed('headers')),
          ).thenAnswer(
            (_) async => http.Response('{"error": "message"}', code),
          );

          expect(() => apiClient.get(endpoint: 'error'), throwsA(matcher));
        });
      }
    });

    group('エラーハンドリング & トークンリフレッシュ', () {
      test('401エラー時にトークンリフレッシュが走り、成功すれば再試行すること', () async {
        when(mockAuthService.getRefreshToken()).thenReturn('old_refresh_token');

        var callCount = 0;
        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer((
          _,
        ) async {
          callCount++;
          if (callCount == 1) {
            return http.Response('{"message": "unauthorized"}', 401);
          }
          return http.Response('{"id": 1}', 200);
        });

        when(
          mockHttpClient.post(
            Uri.parse('$testBaseUrl/auth/refresh'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'accessToken': 'new_access_token',
              'refreshToken': 'new_refresh_token',
            }),
            200,
          ),
        );

        final result = await apiClient.get(endpoint: 'data');

        expect(result, {'id': 1});
        verify(
          mockAuthService.setAccessToken(token: 'new_access_token'),
        ).called(1);
        verify(
          mockAuthService.setRefreshToken(token: 'new_refresh_token'),
        ).called(1);
        verify(
          mockHttpClient.get(
            Uri.parse('$testBaseUrl/data'),
            headers: anyNamed('headers'),
          ),
        ).called(2);
      });

      test(
        '401エラー時にリフレッシュトークンが空の場合、リフレッシュせずUnauthorizedExceptionを投げること',
        () async {
          when(mockAuthService.getRefreshToken()).thenReturn('');

          when(
            mockHttpClient.get(any, headers: anyNamed('headers')),
          ).thenAnswer(
            (_) async => http.Response('{"message": "unauthorized"}', 401),
          );

          await expectLater(
            apiClient.get(endpoint: 'data'),
            throwsA(isA<UnauthorizedException>()),
          );
          verifyNever(
            mockHttpClient.post(
              Uri.parse('$testBaseUrl/auth/refresh'),
              headers: anyNamed('headers'),
              body: anyNamed('body'),
            ),
          );
        },
      );

      test('同時に複数の401が発生した場合、リフレッシュは1回のみ行われ、他は待機すること', () async {
        when(mockAuthService.getRefreshToken()).thenReturn('refresh_token');

        var refreshCallCount = 0;
        when(
          mockHttpClient.post(
            Uri.parse('$testBaseUrl/auth/refresh'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async {
          refreshCallCount++;
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return http.Response(
            jsonEncode({
              'accessToken': 'new_at',
              'refreshToken': 'new_rt',
            }),
            200,
          );
        });

        var getCallCount = 0;
        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async {
            getCallCount++;
            // 最初の2回（req1, req2）は401を返し、リトライ時は200を返す
            if (getCallCount <= 2) {
              return http.Response('{}', 401);
            }
            return http.Response('{}', 200);
          },
        );

        // 同時に2つのリクエスト
        final results = await Future.wait([
          apiClient.get(endpoint: 'req1'),
          apiClient.get(endpoint: 'req2'),
        ]);

        expect(results, [<String, dynamic>{}, <String, dynamic>{}]);
        expect(refreshCallCount, 1);
        expect(getCallCount, 4); // 初回2回 + リトライ2回
      });

      test('リフレッシュ中に例外が発生した場合、falseを返しUnauthorizedExceptionを投げること', () async {
        when(mockAuthService.getRefreshToken()).thenReturn('refresh_token');

        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response('{}', 401),
        );

        when(
          mockHttpClient.post(
            Uri.parse('$testBaseUrl/auth/refresh'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenThrow(Exception('Refresh error'));

        await expectLater(
          apiClient.get(endpoint: 'data'),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('401エラー時にリフレッシュが失敗した場合、UnauthorizedExceptionを投げること', () async {
        when(
          mockAuthService.getRefreshToken(),
        ).thenReturn('invalid_refresh_token');

        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response('{"message": "unauthorized"}', 401),
        );

        when(
          mockHttpClient.post(
            Uri.parse('$testBaseUrl/auth/refresh'),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('{"message": "expired"}', 400));

        await expectLater(
          apiClient.get(endpoint: 'data'),
          throwsA(isA<UnauthorizedException>()),
        );
        verify(mockAuthService.clearAuthData()).called(1);
      });

      test('loginエンドポイントで401が発生した場合、リフレッシュを試みずに例外を投げること', () async {
        when(mockHttpClient.send(any)).thenAnswer(
          (_) async => http.StreamedResponse(
            Stream.value(utf8.encode('{"message": "unauthorized"}')),
            401,
          ),
        );

        await expectLater(
          apiClient.post(endpoint: 'auth/login', body: {}),
          throwsA(isA<UnauthorizedException>()),
        );
        verifyNever(mockAuthService.getRefreshToken());
      });

      test('http.ClientExceptionが発生した場合、ApiClientExceptionを投げること', () async {
        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenThrow(
          http.ClientException('Client error'),
        );

        await expectLater(
          apiClient.get(endpoint: 'test'),
          throwsA(isA<ApiClientException>()),
        );
      });

      test('予期せぬ例外が発生した場合、そのままスローされること', () async {
        when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenThrow(
          ArgumentError('Unexpected error'),
        );

        await expectLater(
          apiClient.get(endpoint: 'test'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test(
        'リトライ上限に達してもSocketExceptionが続く場合、NoInternetConnectionExceptionを投げること',
        () {
          fakeAsync((async) {
            when(
              mockHttpClient.get(any, headers: anyNamed('headers')),
            ).thenAnswer(
              (_) async => throw const SocketException('No Network'),
            );

            expect(
              apiClient.get(endpoint: 'test'),
              throwsA(isA<NoInternetConnectionException>()),
            );

            for (var i = 0; i < apiClient.maxRetries; i++) {
              async.elapse(apiClient.retryDelay);
            }
            async.flushMicrotasks();

            verify(
              mockHttpClient.get(any, headers: anyNamed('headers')),
            ).called(4);
          });
        },
      );
    });

    test(
      'レスポンスがMapでない場合にApiClientException（Bad response format）を投げること',
      () async {
        when(
          mockHttpClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('["list", "not", "map"]', 200));

        expect(
          () => apiClient.get(endpoint: 'test'),
          throwsA(
            isA<ApiClientException>().having(
              (e) => e.message,
              'message',
              contains('Bad response format'),
            ),
          ),
        );
      },
    );
  });

  group('apiClientProvider', () {
    test('Provider経由でApiClientImplが取得できること', () {
      final client = container.read(apiClientProvider);
      expect(client, isA<ApiClientImpl>());
    });
  });
}
