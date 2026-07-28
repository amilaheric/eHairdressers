import '../models/order_item.dart';
import 'base_provider.dart';

class OrderItemProvider extends BaseProvider<OrderItem> {
  OrderItemProvider() : super("OrderItems");

  @override
  OrderItem fromJson(data) {
    return OrderItem.fromJson(data);
  }

  Future<List<OrderItem>> getByOrderId(int orderId) {
    return getSubRoute("order/$orderId");
  }
}
