import '../models/order.dart';
import 'base_provider.dart';

class OrderProvider extends BaseProvider<Orders> {
  OrderProvider() : super("Orders");

  @override
  Orders fromJson(data) {
    return Orders.fromJson(data);
  }
}
