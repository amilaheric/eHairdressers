import 'dart:convert';
import '../models/order.dart';
import 'base_provider.dart';

class OrderProvider extends BaseProvider<Orders> {
  OrderProvider() : super("Orders");

  @override
  Orders fromJson(data) {
    return Orders.fromJson(data);
  }

  @override
  Future<Orders?> insert(dynamic request) async {
   
    
    var result = await super.insert(request);
    
    if (result != null && request is Orders) {
      if (result.userId != request.userId || result.totalWithVAT != request.totalWithVAT) {
        
        result.userId = request.userId;
        result.totalWithVAT = request.totalWithVAT;
        result.totalWithoutVAT = request.totalWithoutVAT;
        result.customerId = request.customerId;
      }
    }
    
    return result;
  }
}
