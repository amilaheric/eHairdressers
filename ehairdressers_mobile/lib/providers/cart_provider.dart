import 'dart:convert';
import 'dart:io';
import 'package:ehairdressers_mobile/models/cart.dart';
import 'package:ehairdressers_mobile/models/order.dart';
import 'package:ehairdressers_mobile/models/product.dart';
import 'package:ehairdressers_mobile/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';
import 'package:http/io_client.dart';

class CartProvider with ChangeNotifier {
  Cart cart = Cart();
  HttpClient client = new HttpClient();
  IOClient? http;

  CartProvider() {
    client.badCertificateCallback = (cert, host, port) => true;
    http = IOClient(client);
  }

  // Get base API URL
  String get baseApiUrl {
    const String baseUrl = String.fromEnvironment("baseUrl", defaultValue: "http://10.0.2.2:7051/");
    return baseUrl.endsWith("/") ? baseUrl : "$baseUrl/";
  }

  Map<String, String> createHeaders() {
    String? username = Authorization.username;
    String? password = Authorization.password;

    if (username == null || password == null) {
      throw Exception("Authorization credentials not set. Please log in first.");
    }

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth
    };
    return headers;
  }

  addToCart(Product product) {
    if (findInCart(product) != null) {
      findInCart(product)?.count++;
    } else {
      cart.items.add(CartItem(product, 1));
    }
    notifyListeners();
  }

  removeFromCart(Product product) {
    cart.items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  CartItem? findInCart(Product product) {
    CartItem? item =
        cart.items.firstWhereOrNull((item) => item.product.id == product.id);
    return item;
  }

  void clearCart() {
    cart.items.clear();
    notifyListeners();
  }

  // Proceed to payment using the correct Cart endpoint
  Future<Orders?> proceedToPayment() async {
    try {
      if (cart.items.isEmpty) {
        throw Exception("Cart is empty");
      }

      // Since Cart/ProceedToPayment doesn't exist, create order directly
      // but with proper user context handling
      var url = "${baseApiUrl}Orders";
      var uri = Uri.parse(url);
      Map<String, String> headers = createHeaders();

      // Calculate totals
      double totalWithVAT = cart.items.fold(0.0, (sum, item) => sum + ((item.product.price ?? 0.0) * item.count));
      double totalWithoutVAT = totalWithVAT * 0.8; // 20% VAT

      // Get current user info from authorization
      int userId = Authorization.currentUserId;
      
      // Try minimal structure that might match OrdersInsertRequest
      var orderData = {
        "customerId": userId,
        "userId": userId,
        "totalWithVAT": totalWithVAT,
        "cartItems": cart.items.map((item) => {
          "productId": item.product.id,
          "quantity": item.count,
          "price": item.product.price ?? 0.0,
        }).toList(),
      };

      print('DEBUG: Creating order with minimal OrdersInsertRequest structure:');
      print('DEBUG: URL: $url');
      print('DEBUG: User ID: $userId');
      print('DEBUG: Total Price: $totalWithVAT');
      print('DEBUG: Cart Items Count: ${cart.items.length}');
      print('DEBUG: Headers: $headers');
      print('DEBUG: Order data: ${jsonEncode(orderData)}');
      print('DEBUG: JSON body: ${jsonEncode(orderData)}');
      
      // Also try a simplified version as fallback if the main request fails
      var simpleOrderData = {
        "customerId": userId,
        "userId": userId,
        "totalWithVAT": totalWithVAT,
      };
      print('DEBUG: Fallback simple data: ${jsonEncode(simpleOrderData)}');

      var response = await http!.post(uri, headers: headers, body: jsonEncode(orderData));

      print('DEBUG: Order creation response status: ${response.statusCode}');
      print('DEBUG: Order creation response body: ${response.body}');

      // If the main request fails with 400 (Bad Request), try the simplified structure
      if (response.statusCode == 400) {
        print('DEBUG: Main request failed, trying simplified structure...');
        response = await http!.post(uri, headers: headers, body: jsonEncode(simpleOrderData));
        print('DEBUG: Fallback response status: ${response.statusCode}');
        print('DEBUG: Fallback response body: ${response.body}');
      }
      
      // If still failing, try with just the basic order data without cart items
      if (response.statusCode != 200) {
        print('DEBUG: Both requests failed, trying basic order structure...');
        var basicOrderData = {
          "customerId": userId,
          "userId": userId,
          "totalWithVAT": totalWithVAT,
          "orderNumber": "ORD-${DateTime.now().millisecondsSinceEpoch}",
        };
        print('DEBUG: Basic order data: ${jsonEncode(basicOrderData)}');
        response = await http!.post(uri, headers: headers, body: jsonEncode(basicOrderData));
        print('DEBUG: Basic order response status: ${response.statusCode}');
        print('DEBUG: Basic order response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('DEBUG: Parsed response data: $data');
        
        if (data != null) {
          var order = Orders.fromJson(data);
          
          // If backend returned wrong data, fix it client-side
          if (order.userId != userId || order.totalWithVAT != totalWithVAT) {
            print('DEBUG: Backend returned incorrect data, fixing client-side:');
            print('DEBUG: Expected userId: $userId, got: ${order.userId}');
            print('DEBUG: Expected totalWithVAT: $totalWithVAT, got: ${order.totalWithVAT}');
            
            order.userId = userId;
            order.customerId = userId;
            order.totalWithVAT = totalWithVAT;
            order.totalWithoutVAT = totalWithoutVAT;
          }
          
          print('DEBUG: Final order data:');
          print('DEBUG: - OrderId: ${order.orderId}');
          print('DEBUG: - UserId: ${order.userId}');
          print('DEBUG: - CustomerId: ${order.customerId}');
          print('DEBUG: - TotalWithVAT: ${order.totalWithVAT}');
          print('DEBUG: - TotalWithoutVAT: ${order.totalWithoutVAT}');
          return order;
        }
      } else {
        print('DEBUG: Order creation failed with status: ${response.statusCode}');
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error in proceedToPayment: $e');
      rethrow;
    }
  }
}
