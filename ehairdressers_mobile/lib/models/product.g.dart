// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      (json['Id'] as num?)?.toInt(),
      json['Name'] as String?,
      json['Description'] as String?,
      (json['Price'] as num?)?.toDouble(),
      json['Code'] as String?,
      (json['BrandId'] as num?)?.toInt(),
      (json['CategoryId'] as num?)?.toInt(),
      json['Image'] as String?,
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Description': instance.description,
      'Code': instance.code,
      'Price': instance.price,
      'BrandId': instance.brandId,
      'CategoryId': instance.categoryId,
      'Image': instance.image,
    };
