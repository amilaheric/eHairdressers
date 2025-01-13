// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Orders _$OrdersFromJson(Map<String, dynamic> json) => Orders()
  ..orderId = (json['orderId'] as num?)?.toInt()
  ..orderNumber = json['orderNumber'] as String?
  ..customerId = (json['customerId'] as num?)?.toInt()
  ..date = json['date'] as String?
  ..status = json['status'] as bool?
  ..canceled = json['canceled'] as bool?
  ..paymentId = json['paymentId'] as String?;

Map<String, dynamic> _$OrdersToJson(Orders instance) => <String, dynamic>{
      'orderId': instance.orderId,
      'orderNumber': instance.orderNumber,
      'customerId': instance.customerId,
      'date': instance.date,
      'status': instance.status,
      'canceled': instance.canceled,
      'paymentId': instance.paymentId,
    };
