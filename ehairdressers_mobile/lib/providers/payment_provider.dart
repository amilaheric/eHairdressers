import 'dart:convert';
import 'package:http/http.dart';
import 'package:ehairdressers_mobile/models/payment.dart' as models;
import 'package:ehairdressers_mobile/models/search_result.dart';
import 'base_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentProvider extends BaseProvider<models.PaymentMethod> {
  PaymentProvider() : super("Payment");

  @override
  models.PaymentMethod fromJson(data) {
    return models.PaymentMethod.fromJson(data);
  }

  Future<List<models.PaymentMethod>> getPaymentMethods() async {
    return [
      models.PaymentMethod(
          id: 1,
          name: 'Stripe',
          description: 'Secure payment via Stripe',
          isActive: true),
    ];
  }

  Future<String?> createStripePaymentIntent({
    required int orderId,
    required double amount,
    String currency = 'usd',
  }) async {
    try {
      var customEndpoint = "Payment/create-stripe-intent";
      var url = "${baseUrl}$customEndpoint";
      var uri = Uri.parse(url);

      Map<String, String> headers = createHeaders();
      var requestData = {
        'orderId': orderId,
        'amount': (amount * 100).toInt(),
        'currency': currency,
      };
      var jsonRequest = jsonEncode(requestData);

      print('Creating Stripe Payment Intent for order: $orderId');
      print('Amount: ${amount * 100} cents');

      var response = await http!.post(uri, headers: headers, body: jsonRequest);

      print('Stripe Payment Intent response status: ${response.statusCode}');
      print('Stripe Payment Intent response body: ${response.body}');

      if (isValidResponseCode(response)) {
        var data = jsonDecode(response.body);
        String? clientSecret = data['clientSecret'] ?? data['ClientSecret'];
        if (clientSecret != null) {
          print('Successfully created Stripe Payment Intent');
          return clientSecret;
        } else {
          print('No clientSecret in response');
          return null;
        }
      } else {
        print('Failed to create Payment Intent: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating Stripe Payment Intent: $e');
      return null;
    }
  }

  Future<models.PaymentResponse?> confirmStripePayment({
    required int orderId,
    required String paymentIntentId,
  }) async {
    try {
      var customEndpoint = "Payment/confirm-stripe-payment";
      var url = "${baseUrl}$customEndpoint";
      var uri = Uri.parse(url);

      Map<String, String> headers = createHeaders();
      var requestData = {
        'orderId': orderId,
        'paymentIntentId': paymentIntentId,
      };
      var jsonRequest = jsonEncode(requestData);

      print('Confirming Stripe Payment for order: $orderId');
      print('Payment Intent ID: $paymentIntentId');

      var response = await http!.post(uri, headers: headers, body: jsonRequest);

      print(
          'Stripe Payment Confirmation response status: ${response.statusCode}');
      print('Stripe Payment Confirmation response body: ${response.body}');

      if (isValidResponseCode(response)) {
        var data = jsonDecode(response.body);
        return models.PaymentResponse.fromJson(data);
      } else {
        print('Failed to confirm payment: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error confirming Stripe Payment: $e');
      return null;
    }
  }
}
