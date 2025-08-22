// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Orders _$OrdersFromJson(Map<String, dynamic> json) => Orders()
  ..orderId = (json['OrderId'] as num?)?.toInt()
  ..orderNumber = json['OrderNumber'] as String?
  ..customerId = (json['CustomerId'] as num?)?.toInt()
  ..userId = (json['UserId'] as num?)?.toInt()
  ..cartId = (json['CartId'] as num?)?.toInt()
  ..totalWithoutVAT = (json['TotalWithoutVAT'] as num?)?.toDouble()
  ..totalWithVAT = (json['TotalWithVAT'] as num?)?.toDouble()
  ..totalPrice = (json['TotalPrice'] as num?)?.toDouble()
  ..subtotal = (json['Subtotal'] as num?)?.toDouble()
  ..vatAmount = (json['VATAmount'] as num?)?.toDouble()
  ..date = json['Date'] as String?
  ..orderDate = json['OrderDate'] as String?
  ..status = json['Status'] as String?
  ..canceled = json['Canceled'] as bool?
  ..paymentId = json['PaymentId'] as String?
  ..orderItems = json['OrderItems'] as List<dynamic>?
  ..createdDate = json['CreatedDate'] as String?
  ..lastModifiedDate = json['LastModifiedDate'] as String?
  ..notes = json['Notes'] as String?;

Map<String, dynamic> _$OrdersToJson(Orders instance) => <String, dynamic>{
      'OrderId': instance.orderId,
      'OrderNumber': instance.orderNumber,
      'CustomerId': instance.customerId,
      'UserId': instance.userId,
      'CartId': instance.cartId,
      'TotalWithoutVAT': instance.totalWithoutVAT,
      'TotalWithVAT': instance.totalWithVAT,
      'TotalPrice': instance.totalPrice,
      'Subtotal': instance.subtotal,
      'VATAmount': instance.vatAmount,
      'Date': instance.date,
      'OrderDate': instance.orderDate,
      'Status': instance.status,
      'Canceled': instance.canceled,
      'PaymentId': instance.paymentId,
      'OrderItems': instance.orderItems,
      'CreatedDate': instance.createdDate,
      'LastModifiedDate': instance.lastModifiedDate,
      'Notes': instance.notes,
    };
