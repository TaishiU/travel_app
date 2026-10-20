import 'package:travel_app/data/services/web_api/products/dto.dart';
import 'package:travel_app/utils/result.dart';

/// 商品APIサービスインターフェース
abstract class ProductsApiService {
  /// 商品一覧を取得
  Future<Result<ProductsDto>> fetch({
    String? q,
    int? categoryId,
    int? minPrice,
    int? maxPrice,
    String? sort,
    int? limit,
    int? offset,
    String? cursor,
  });

  /// 商品詳細を取得
  Future<Result<ProductDetailDto>> fetchById({required int id});

  /// 商品を出品
  Future<Result<ProductDetailDto>> create({
    required int categoryId,
    required String name,
    required int price,
    required int stock,
    String? description,
    String? status,
    List<String>? images,
  });

  /// 商品を更新
  Future<Result<ProductDetailDto>> update({
    required int id,
    int? categoryId,
    String? name,
    String? description,
    int? price,
    int? stock,
    String? status,
    List<String>? images,
  });

  /// 商品を出品停止（論理削除）
  Future<Result<void>> delete({required int id});
}
