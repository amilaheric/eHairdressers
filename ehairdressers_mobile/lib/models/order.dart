import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Orders {
  @JsonKey(name: 'OrderId')
  int? orderId;
  
  @JsonKey(name: 'OrderNumber')
  String? orderNumber;
  
  @JsonKey(name: 'CustomerId')
  int? customerId;
  
  @JsonKey(name: 'UserId')
  int? userId;
  
  @JsonKey(name: 'CartId')
  int? cartId;
  
  @JsonKey(name: 'TotalWithoutVAT')
  double? totalWithoutVAT;
  
  @JsonKey(name: 'TotalWithVAT')
  double? totalWithVAT;
  
  @JsonKey(name: 'TotalPrice')
  double? totalPrice;
  
  @JsonKey(name: 'Subtotal')
  double? subtotal;
  
  @JsonKey(name: 'VATAmount')
  double? vatAmount;
  
  @JsonKey(name: 'Date')
  String? date;
  
  @JsonKey(name: 'OrderDate')
  String? orderDate;
  
  @JsonKey(name: 'Status')
  String? status;
  
  @JsonKey(name: 'Canceled')
  bool? canceled;
  
  @JsonKey(name: 'PaymentId')
  String? paymentId;
  
  @JsonKey(name: 'OrderItems')
  List<dynamic>? orderItems;
  
  @JsonKey(name: 'CreatedDate')
  String? createdDate;
  
  @JsonKey(name: 'LastModifiedDate')
  String? lastModifiedDate;
  
  @JsonKey(name: 'Notes')
  String? notes;

  Orders();

  factory Orders.fromJson(Map<String, dynamic> json) => _$OrdersFromJson(json);
  Map<String, dynamic> toJson() => _$OrdersToJson(this);
  
  // Getter for display total
  double get displayTotal => totalPrice ?? totalWithVAT ?? totalWithoutVAT ?? 0.0;
  
  // Getter for order status display
  String get statusDisplay {
    if (canceled == true) return 'Canceled';
    return status ?? 'Pending';
  }
  
  // Check if order is active
  bool get isActive => canceled != true && status != 'Completed';
  
  // Get order date as DateTime, converted from UTC (the wire format the
  // backend always sends) to the device's local timezone for display.
  DateTime? get orderDateTime {
    try {
      if (orderDate != null) return DateTime.parse(orderDate!).toLocal();
      if (date != null) return DateTime.parse(date!).toLocal();
      return null;
    } catch (e) {
      return null;
    }
  }

  // Format order date for display
  String get formattedOrderDate {
    final dateTime = orderDateTime;
    if (dateTime == null) return 'N/A';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  // Format order date and time for display
  String get formattedOrderDateTime {
    final dateTime = orderDateTime;
    if (dateTime == null) return 'N/A';
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} $hour:$minute';
  }
}
