import 'package:json_annotation/json_annotation.dart';

part 'order_item.g.dart';

@JsonSerializable()
class OrderItem {
  @JsonKey(name: 'OrderItemId')
  int? orderItemId;
  
  @JsonKey(name: 'OrderId')
  int? orderId;
  
  @JsonKey(name: 'ProductId')
  int? productId;
  
  @JsonKey(name: 'ProductName')
  String? productName;
  
  @JsonKey(name: 'Quantity')
  int? quantity;
  
  @JsonKey(name: 'UnitPrice')
  double? unitPrice;
  
  @JsonKey(name: 'Price')
  double? price;
  
  @JsonKey(name: 'Amount')
  int? amount;
  
  @JsonKey(name: 'Total')
  double? total;
  
  @JsonKey(name: 'Discount')
  double? discount;
  
  @JsonKey(name: 'VATRate')
  double? vatRate;
  
  @JsonKey(name: 'VATAmount')
  double? vatAmount;

  OrderItem();

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
  
  // Getter for calculated total
  double get calculatedTotal {
    if (total != null) return total!;
    if (price != null && quantity != null) return price! * quantity!;
    if (unitPrice != null && quantity != null) return unitPrice! * quantity!;
    return 0.0;
  }
  
  // Getter for display price
  double get displayPrice => price ?? unitPrice ?? 0.0;
  
  // Getter for display quantity
  int get displayQuantity => quantity ?? 1;
  
  // Getter for product display name
  String get displayProductName => productName ?? 'Product #$productId';
  
  // Check if item has discount
  bool get hasDiscount => discount != null && discount! > 0;
  
  // Get final price after discount
  double get finalPrice {
    if (hasDiscount) {
      return calculatedTotal * (1 - (discount! / 100));
    }
    return calculatedTotal;
  }
}
