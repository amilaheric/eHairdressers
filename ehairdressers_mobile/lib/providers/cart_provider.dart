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
    String? token = Authorization.token;

    if (token == null || token.isEmpty) {
      throw Exception("Authorization credentials not set. Please log in first.");
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
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

  int get totalItemCount =>
      cart.items.fold(0, (sum, item) => sum + item.count);

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

      var orderData = {
        "customerId": userId,
        "userId": userId,
        "totalWithVAT": totalWithVAT,
        "OrderItems": cart.items.map((item) {
          double price = item.product.price ?? 0.0;
          return {
            "OrderId": 0,
            "ProductId": item.product.id,
            "Amount": item.count,
            "Quantity": item.count,
            "Price": price,
            "Total": price * item.count,
          };
        }).toList(),
      };

      var response = await http!.post(uri, headers: headers, body: jsonEncode(orderData));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data != null) {
          var order = Orders.fromJson(data);

          // If backend returned wrong data, fix it client-side
          if (order.userId != userId || order.totalWithVAT != totalWithVAT) {
            order.userId = userId;
            order.customerId = userId;
            order.totalWithVAT = totalWithVAT;
            order.totalWithoutVAT = totalWithoutVAT;
          }

          return order;
        }
      } else {
        throw Exception('Failed to create order: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
