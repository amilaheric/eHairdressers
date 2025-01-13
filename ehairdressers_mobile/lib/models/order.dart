import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Orders {
  int? orderId;
  String? orderNumber;
  int? customerId;
  String? date;
  bool? status;
  bool? canceled;
  String? paymentId;

  Orders();

  factory Orders.fromJson(Map<String, dynamic> json) => _$OrdersFromJson(json);
  Map<String, dynamic> toJson() => _$OrdersToJson(this);
}
