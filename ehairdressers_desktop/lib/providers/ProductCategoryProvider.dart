import 'package:ehairdressers_mobile/providers/BaseProvider.dart';

import '../models/product_category.dart';

class ProductCategoryProvider extends BaseProvider<ProductCategory> {
  ProductCategoryProvider() : super("Category");

  @override
  ProductCategory fromJson(data) {
    // TODO: implement fromJson
    return ProductCategory.fromJson(data);
  }
}
