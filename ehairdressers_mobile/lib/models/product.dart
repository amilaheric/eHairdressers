import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  @JsonKey(name: 'Id')
  int? id;
  
  @JsonKey(name: 'Name')
  String? name;
  
  @JsonKey(name: 'Description')
  String? description;
  
  @JsonKey(name: 'Code')
  String? code;
  
  @JsonKey(name: 'Price')
  double? price;
  
  @JsonKey(name: 'BrandId')
  int? brandId;
  
  @JsonKey(name: 'CategoryId')
  int? categoryId;
  
  @JsonKey(name: 'Image')
  String? image;

  Product(this.id, this.name, this.description, this.price, this.code,
      this.brandId, this.categoryId, this.image);

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
