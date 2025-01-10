import 'package:ehairdressers_mobile/providers/BaseProvider.dart';

import '../models/brand.dart';

class BrandProvider extends BaseProvider<Brand> {
  BrandProvider() : super("Brand");

  @override
  Brand fromJson(data) {
    // TODO: implement fromJson
    return Brand.fromJson(data);
  }
}
