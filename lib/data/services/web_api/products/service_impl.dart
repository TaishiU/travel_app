import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:travel_app/data/services/web_api/api_client.dart';
import 'package:travel_app/data/services/web_api/api_exception.dart';
import 'package:travel_app/data/services/web_api/products/dto.dart';
import 'package:travel_app/data/services/web_api/products/service.dart';
import 'package:travel_app/data/services/web_api/products/stub_service_impl.dart';
import 'package:travel_app/data/services/web_api/stub_api_enabled_provider.dart';
import 'package:travel_app/utils/logger.dart';
import 'package:travel_app/utils/result.dart';

/// プロバイダ
final productsApiServiceImplProvider = Provider<ProductsApiServiceImpl>(
  (ref) => ProductsApiServiceImpl(apiClient: ref.read(apiClientProvider)),
);

/// スタブ切り替え対応の統合Provider
final productsApiServiceProvider = Provider<ProductsApiService>((ref) {
  // coverage:ignore-start
  if (!kDebugMode) {
    return ProductsApiServiceImpl(apiClient: ref.read(apiClientProvider));
  }
  // coverage:ignore-end
  final isStub = ref.watch<bool>(isStubApiEnabledProvider);
  return isStub
      ? StubProductsApiServiceImpl()
      : ProductsApiServiceImpl(apiClient: ref.read(apiClientProvider));
});

/// 商品APIサービス実装クラス
class ProductsApiServiceImpl implements ProductsApiService {
  /// コンストラクタ
  ProductsApiServiceImpl({required this.apiClient});

  /// ApiClient
  final ApiClient apiClient;

  /// エンドポイント
  static const endpoint = 'products';

  @override
  Future<Result<ProductsDto>> fetch({
    String? q,
    int? categoryId,
    int? minPrice,
    int? maxPrice,
    String? sort,
    int? limit,
    int? offset,
    String? cursor,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'q': ?q,
        'category_id': ?categoryId,
        'min_price': ?minPrice,
        'max_price': ?maxPrice,
        'sort': ?sort,
        'limit': ?limit,
        'offset': ?offset,
        'cursor': ?cursor,
      };
      final response = await apiClient.get(
        endpoint: endpoint,
        queryParameters: queryParameters,
      );
      final dto = ProductsDto.fromJson(response);
      return SuccessResult(dto);
    } on ApiClientException catch (error) {
      logger.e(message: '[ProductsApiServiceImpl] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e(message: '[ProductsApiServiceImpl] Unexpected Error: $error');
      return FailureResult(error);
    }
  }

  @override
  Future<Result<ProductDetailDto>> fetchById({required int id}) async {
    try {
      final response = await apiClient.get(endpoint: '$endpoint/$id');
      final dto = ProductDetailDto.fromJson(response);
      return SuccessResult(dto);
    } on ApiClientException catch (error) {
      logger.e(message: '[ProductsApiServiceImpl] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e(message: '[ProductsApiServiceImpl] Unexpected Error: $error');
      return FailureResult(error);
    }
  }

  @override
  Future<Result<ProductDetailDto>> create({
    required int categoryId,
    required String name,
    required int price,
    required int stock,
    String? description,
    String? status,
    List<String>? images,
  }) async {
    try {
      final body = <String, dynamic>{
        'category_id': categoryId,
        'name': name,
        'price': price,
        'stock': stock,
        'description': ?description,
        'status': ?status,
        'images': ?images,
      };
      final response = await apiClient.post(
        endpoint: endpoint,
        body: body,
      );
      final dto = ProductDetailDto.fromJson(response);
      return SuccessResult(dto);
    } on ApiClientException catch (error) {
      logger.e(message: '[ProductsApiServiceImpl] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e(message: '[ProductsApiServiceImpl] Unexpected Error: $error');
      return FailureResult(error);
    }
  }

  @override
  Future<Result<ProductDetailDto>> update({
    required int id,
    int? categoryId,
    String? name,
    String? description,
    int? price,
    int? stock,
    String? status,
    List<String>? images,
  }) async {
    try {
      final body = <String, dynamic>{
        'category_id': ?categoryId,
        'name': ?name,
        'description': ?description,
        'price': ?price,
        'stock': ?stock,
        'status': ?status,
        'images': ?images,
      };
      final response = await apiClient.patch(
        endpoint: '$endpoint/$id',
        body: body,
      );
      final dto = ProductDetailDto.fromJson(response);
      return SuccessResult(dto);
    } on ApiClientException catch (error) {
      logger.e(message: '[ProductsApiServiceImpl] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e(message: '[ProductsApiServiceImpl] Unexpected Error: $error');
      return FailureResult(error);
    }
  }

  @override
  Future<Result<void>> delete({required int id}) async {
    try {
      await apiClient.delete(endpoint: '$endpoint/$id');
      return const SuccessResult(null);
    } on ApiClientException catch (error) {
      logger.e(message: '[ProductsApiServiceImpl] ApiClientException: $error');
      return FailureResult(error);
    } on Exception catch (error) {
      logger.e(message: '[ProductsApiServiceImpl] Unexpected Error: $error');
      return FailureResult(error);
    }
  }
}
