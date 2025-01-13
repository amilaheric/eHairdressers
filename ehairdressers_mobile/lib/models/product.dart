import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  int? id;
  String? name;
  String? description;
  String? code;
  double? price;
  int? brandId;
  int? categoryId;
  String? image;

  Product(this.id, this.name, this.description, this.price, this.code,
      this.brandId, this.categoryId, this.image);

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
