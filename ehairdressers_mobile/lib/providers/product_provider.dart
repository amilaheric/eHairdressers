import '../models/product.dart';
import 'base_provider.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("Products");

  @override
  Product fromJson(data) {
    // TODO: implement fromJson
    return Product.fromJson(data);
  }
}
