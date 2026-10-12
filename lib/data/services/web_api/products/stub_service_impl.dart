import 'package:travel_app/data/services/web_api/products/dto.dart';
import 'package:travel_app/data/services/web_api/products/service.dart';
import 'package:travel_app/utils/result.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// プロバイダ
final stubProductsApiServiceImplProvider = Provider<StubProductsApiServiceImpl>(
  (ref) => StubProductsApiServiceImpl(),
);

/// スタブ実装クラス
class StubProductsApiServiceImpl implements ProductsApiService {
  /// コンストラクタ
  StubProductsApiServiceImpl();

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
    final items = List.generate(2, (index) {
      return ProductSummaryDto(
        id: index + 1,
        sellerId: 1,
        categoryId: 1,
        name: 'test name ${index + 1}',
        price: 1000,
        stock: 10,
        status: 'published',
        createdAt: '2024-01-01T00:00:00Z',
      );
    });
    return SuccessResult(ProductsDto(data: items, total: 2));
  }

  @override
  Future<Result<ProductDetailDto>> fetchById({required int id}) async {
    return SuccessResult(
      ProductDetailDto(
        id: id,
        sellerId: 1,
        categoryId: 1,
        name: 'test name $id',
        description: 'test description',
        price: 1000,
        stock: 10,
        status: 'published',
        images: [
          ProductImageDto(
            id: 1,
            url: 'https://placehold.jp/400x400.png?text=product-$id',
            displayOrder: 1,
          ),
        ],
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      ),
    );
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
    return SuccessResult(
      ProductDetailDto(
        id: 1,
        sellerId: 1,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        status: status ?? 'draft',
        images: [],
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      ),
    );
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
    return SuccessResult(
      ProductDetailDto(
        id: id,
        sellerId: 1,
        categoryId: categoryId ?? 1,
        name: name ?? 'test name',
        description: description,
        price: price ?? 1000,
        stock: stock ?? 10,
        status: status ?? 'published',
        images: [],
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-01T00:00:00Z',
      ),
    );
  }

  @override
  Future<Result<void>> delete({required int id}) async {
    return const SuccessResult(null);
  }
}
