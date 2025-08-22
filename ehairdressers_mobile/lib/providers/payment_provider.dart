import 'dart:convert';
import 'package:http/http.dart';
import 'package:ehairdressers_mobile/models/payment.dart';
import 'package:ehairdressers_mobile/models/search_result.dart';
import 'base_provider.dart';

class PaymentProvider extends BaseProvider<PaymentMethod> {
  PaymentProvider() : super("Payment");

  @override
  PaymentMethod fromJson(data) {
    return PaymentMethod.fromJson(data);
  }

  // Get available payment methods
  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      var result = await getResult();
      var methods = result?.result ?? [];
      
      // If no methods from backend, return default methods
      if (methods.isEmpty) {
        print('No payment methods from backend, using defaults');
        return [
          PaymentMethod(id: 1, name: 'Credit Card', description: 'Visa, MasterCard, etc.', isActive: true),
          PaymentMethod(id: 2, name: 'Debit Card', description: 'Direct bank debit', isActive: true),
          PaymentMethod(id: 3, name: 'Cash on Delivery', description: 'Pay when you receive', isActive: true),
        ];
      }
      
      // Filter out any methods with null values that could cause issues
      var validMethods = methods.where((method) => 
        method.id != null && 
        method.name != null && 
        method.isActive != null
      ).toList();
      
      if (validMethods.isEmpty) {
        print('No valid payment methods from backend, using defaults');
        return [
          PaymentMethod(id: 1, name: 'Credit Card', description: 'Visa, MasterCard, etc.', isActive: true),
          PaymentMethod(id: 2, name: 'Debit Card', description: 'Direct bank debit', isActive: true),
          PaymentMethod(id: 3, name: 'Cash on Delivery', description: 'Pay when you receive', isActive: true),
        ];
      }
      
      return validMethods;
    } catch (e) {
      print('Error getting payment methods: $e');
      // Return default methods on error
      return [
        PaymentMethod(id: 1, name: 'Credit Card', description: 'Visa, MasterCard, etc.', isActive: true),
        PaymentMethod(id: 2, name: 'Debit Card', description: 'Direct bank debit', isActive: true),
        PaymentMethod(id: 3, name: 'Cash on Delivery', description: 'Pay when you receive', isActive: true),
      ];
    }
  }

  // Process payment
  Future<PaymentResponse?> processPayment(PaymentRequest request) async {
    try {
      // Use the base class insert method with a custom endpoint
      var customEndpoint = "Payment/process";
      var url = "https://10.0.2.2:7051/$customEndpoint";
      var uri = Uri.parse(url);
      
      Map<String, String> headers = createHeaders();
      var jsonRequest = jsonEncode(request.toJson());
      
      print('Processing payment for order: ${request.orderId}');
      print('Payment amount: ${request.amount}');
      print('Payment method: ${request.paymentMethodId}');
      
      var response = await http!.post(uri, headers: headers, body: jsonRequest);
      
      print('Payment response status: ${response.statusCode}');
      print('Payment response body: ${response.body}');

      if (isValidResponseCode(response)) {
        var data = jsonDecode(response.body);
        return PaymentResponse.fromJson(data);
      } else {
        print('Payment failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error processing payment: $e');
      return null;
    }
  }

  // Test payment - sends to backend but marks as test
  Future<PaymentResponse?> processTestPayment(PaymentRequest request) async {
    try {
      print('Processing TEST payment for order: ${request.orderId}');
      print('Test payment amount: ${request.amount}');
      
      // Create a new request with test flag
      final testRequest = PaymentRequest(
        orderId: request.orderId,
        amount: request.amount,
        paymentMethodId: request.paymentMethodId,
        cardNumber: request.cardNumber,
        cardHolderName: request.cardHolderName,
        expiryMonth: request.expiryMonth,
        expiryYear: request.expiryYear,
        cvv: request.cvv,
        isTestPayment: true,
      );
      
      // Send to backend for database storage
      var customEndpoint = "Payment/process";
      var url = "https://10.0.2.2:7051/$customEndpoint";
      var uri = Uri.parse(url);
      
      Map<String, String> headers = createHeaders();
      var jsonRequest = jsonEncode(testRequest.toJson());
      
      print('Sending test payment to backend for storage...');
      var response = await http!.post(uri, headers: headers, body: jsonRequest);
      
      print('Test payment response status: ${response.statusCode}');
      print('Test payment response body: ${response.body}');

      if (isValidResponseCode(response)) {
        try {
          var data = jsonDecode(response.body);
          var paymentResponse = PaymentResponse.fromJson(data);
          
          // Create a new response with test-specific values
          return PaymentResponse(
            paymentId: paymentResponse.paymentId,
            orderId: paymentResponse.orderId,
            amount: paymentResponse.amount,
            status: paymentResponse.status,
            transactionId: 'TEST_${paymentResponse.transactionId ?? DateTime.now().millisecondsSinceEpoch}',
            message: 'Test payment processed successfully',
            timestamp: paymentResponse.timestamp,
          );
        } catch (parseError) {
          print('Error parsing payment response: $parseError');
          print('Response body: ${response.body}');
          // Return mock response if parsing fails
          return PaymentResponse(
            paymentId: DateTime.now().millisecondsSinceEpoch,
            orderId: request.orderId,
            amount: request.amount,
            status: 'SUCCESS',
            transactionId: 'TEST_${DateTime.now().millisecondsSinceEpoch}',
            message: 'Test payment processed successfully',
            timestamp: DateTime.now().toIso8601String(),
          );
        }
      } else {
        print('Test payment failed with status: ${response.statusCode}');
        // Return mock response if backend fails
        return PaymentResponse(
          paymentId: DateTime.now().millisecondsSinceEpoch,
          orderId: request.orderId,
          amount: request.amount,
          status: 'SUCCESS',
          transactionId: 'TEST_${DateTime.now().millisecondsSinceEpoch}',
          message: 'Test payment processed successfully',
          timestamp: DateTime.now().toIso8601String(),
        );
      }
    } catch (e) {
      print('Error processing test payment: $e');
      // Return mock response on error
      return PaymentResponse(
        paymentId: DateTime.now().millisecondsSinceEpoch,
        orderId: request.orderId,
        amount: request.amount,
        status: 'SUCCESS',
        transactionId: 'TEST_${DateTime.now().millisecondsSinceEpoch}',
        message: 'Test payment processed successfully',
        timestamp: DateTime.now().toIso8601String(),
      );
    }
  }

  // Validate card details (basic validation)
  bool validateCardDetails({
    String? cardNumber,
    String? cardHolderName,
    int? expiryMonth,
    int? expiryYear,
    String? cvv,
  }) {
    if (cardNumber == null || cardNumber.isEmpty) return false;
    if (cardHolderName == null || cardHolderName.isEmpty) return false;
    if (expiryMonth == null || expiryMonth < 1 || expiryMonth > 12) return false;
    if (expiryYear == null || expiryYear < DateTime.now().year) return false;
    if (cvv == null || cvv.length < 3 || cvv.length > 4) return false;
    
    return true;
  }
}
