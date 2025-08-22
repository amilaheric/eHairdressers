import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@JsonSerializable()
class PaymentMethod {
  @JsonKey(name: 'Id')
  final int? id;

  @JsonKey(name: 'Name')
  final String? name;

  @JsonKey(name: 'Description')
  final String? description;

  @JsonKey(name: 'IsActive')
  final bool? isActive;

  PaymentMethod({
    this.id,
    this.name,
    this.description,
    this.isActive,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);
}

@JsonSerializable()
class PaymentRequest {
  @JsonKey(name: 'OrderId')
  final int orderId;

  @JsonKey(name: 'Amount')
  final double amount;

  @JsonKey(name: 'PaymentMethodId')
  final int paymentMethodId;

  @JsonKey(name: 'CardNumber')
  final String? cardNumber;

  @JsonKey(name: 'CardHolderName')
  final String? cardHolderName;

  @JsonKey(name: 'ExpiryMonth')
  final int? expiryMonth;

  @JsonKey(name: 'ExpiryYear')
  final int? expiryYear;

  @JsonKey(name: 'Cvv')
  final String? cvv;

  @JsonKey(name: 'IsTestPayment')
  final bool isTestPayment;

  PaymentRequest({
    required this.orderId,
    required this.amount,
    required this.paymentMethodId,
    this.cardNumber,
    this.cardHolderName,
    this.expiryMonth,
    this.expiryYear,
    this.cvv,
    this.isTestPayment = true,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentRequestToJson(this);
}

@JsonSerializable()
class PaymentResponse {
  @JsonKey(name: 'PaymentId')
  final int paymentId;

  @JsonKey(name: 'OrderId')
  final int orderId;

  @JsonKey(name: 'Amount')
  final double amount;

  @JsonKey(name: 'PaymentStatus')
  final String status;

  @JsonKey(name: 'TransactionId')
  final String? transactionId;

  @JsonKey(name: 'Message')
  final String? message;

  @JsonKey(name: 'PaymentDate')
  final String timestamp;

  PaymentResponse({
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.status,
    this.transactionId,
    this.message,
    required this.timestamp,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentResponseToJson(this);
}
