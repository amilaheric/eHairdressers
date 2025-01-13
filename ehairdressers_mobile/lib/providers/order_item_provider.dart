import '../models/order.dart';
import 'base_provider.dart';

class OrderItemProvider extends BaseProvider<Orders> {
  OrderItemProvider() : super("OrderItem");

  Orders fromJson(data) {
    return Orders.fromJson(data);
  }
}
