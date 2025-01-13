// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      (json['id'] as num?)?.toInt(),
      json['name'] as String?,
      json['description'] as String?,
      (json['price'] as num?)?.toDouble(),
      json['code'] as String?,
      (json['brandId'] as num?)?.toInt(),
      (json['categoryId'] as num?)?.toInt(),
      json['image'] as String?,
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'code': instance.code,
      'price': instance.price,
      'brandId': instance.brandId,
      'categoryId': instance.categoryId,
      'image': instance.image,
    };
