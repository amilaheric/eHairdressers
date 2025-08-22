// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethod _$PaymentMethodFromJson(Map<String, dynamic> json) =>
    PaymentMethod(
      id: (json['Id'] as num?)?.toInt(),
      name: json['Name'] as String?,
      description: json['Description'] as String?,
      isActive: json['IsActive'] as bool?,
    );

Map<String, dynamic> _$PaymentMethodToJson(PaymentMethod instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Description': instance.description,
      'IsActive': instance.isActive,
    };

PaymentRequest _$PaymentRequestFromJson(Map<String, dynamic> json) =>
    PaymentRequest(
      orderId: (json['OrderId'] as num).toInt(),
      amount: (json['Amount'] as num).toDouble(),
      paymentMethodId: (json['PaymentMethodId'] as num).toInt(),
      cardNumber: json['CardNumber'] as String?,
      cardHolderName: json['CardHolderName'] as String?,
      expiryMonth: (json['ExpiryMonth'] as num?)?.toInt(),
      expiryYear: (json['ExpiryYear'] as num?)?.toInt(),
      cvv: json['Cvv'] as String?,
      isTestPayment: json['IsTestPayment'] as bool? ?? true,
    );

Map<String, dynamic> _$PaymentRequestToJson(PaymentRequest instance) =>
    <String, dynamic>{
      'OrderId': instance.orderId,
      'Amount': instance.amount,
      'PaymentMethodId': instance.paymentMethodId,
      'CardNumber': instance.cardNumber,
      'CardHolderName': instance.cardHolderName,
      'ExpiryMonth': instance.expiryMonth,
      'ExpiryYear': instance.expiryYear,
      'Cvv': instance.cvv,
      'IsTestPayment': instance.isTestPayment,
    };

PaymentResponse _$PaymentResponseFromJson(Map<String, dynamic> json) =>
    PaymentResponse(
      paymentId: (json['PaymentId'] as num).toInt(),
      orderId: (json['OrderId'] as num).toInt(),
      amount: (json['Amount'] as num).toDouble(),
      status: json['PaymentStatus'] as String,
      transactionId: json['TransactionId'] as String?,
      message: json['Message'] as String?,
      timestamp: json['PaymentDate'] as String,
    );

Map<String, dynamic> _$PaymentResponseToJson(PaymentResponse instance) =>
    <String, dynamic>{
      'PaymentId': instance.paymentId,
      'OrderId': instance.orderId,
      'Amount': instance.amount,
      'PaymentStatus': instance.status,
      'TransactionId': instance.transactionId,
      'Message': instance.message,
      'PaymentDate': instance.timestamp,
    };
