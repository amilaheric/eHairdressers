// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem()
  ..orderItemId = (json['OrderItemId'] as num?)?.toInt()
  ..orderId = (json['OrderId'] as num?)?.toInt()
  ..productId = (json['ProductId'] as num?)?.toInt()
  ..productName = json['ProductName'] as String?
  ..productImage = json['ProductImage'] as String?
  ..quantity = (json['Quantity'] as num?)?.toInt()
  ..unitPrice = (json['UnitPrice'] as num?)?.toDouble()
  ..price = (json['Price'] as num?)?.toDouble()
  ..amount = (json['Amount'] as num?)?.toInt()
  ..total = (json['Total'] as num?)?.toDouble()
  ..discount = (json['Discount'] as num?)?.toDouble()
  ..vatRate = (json['VATRate'] as num?)?.toDouble()
  ..vatAmount = (json['VATAmount'] as num?)?.toDouble();

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
      'OrderItemId': instance.orderItemId,
      'OrderId': instance.orderId,
      'ProductId': instance.productId,
      'ProductName': instance.productName,
      'ProductImage': instance.productImage,
      'Quantity': instance.quantity,
      'UnitPrice': instance.unitPrice,
      'Price': instance.price,
      'Amount': instance.amount,
      'Total': instance.total,
      'Discount': instance.discount,
      'VATRate': instance.vatRate,
      'VATAmount': instance.vatAmount,
    };
