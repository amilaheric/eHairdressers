import 'package:flutter/material.dart' hide Card;
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:ehairdressers_mobile/models/payment.dart' as models;
import 'package:ehairdressers_mobile/models/order_item.dart';
import 'package:ehairdressers_mobile/models/cart.dart';
import 'package:ehairdressers_mobile/providers/payment_provider.dart';
import 'package:ehairdressers_mobile/providers/order_item_provider.dart';
import 'package:ehairdressers_mobile/providers/cart_provider.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:ehairdressers_mobile/utils/util.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;

class PaymentScreen extends StatefulWidget {
  final int orderId;
  final double amount;
  final String orderNumber;
  final List<CartItem> cartItems;

  const PaymentScreen({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.orderNumber,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late PaymentProvider _paymentProvider;

  bool _isCardComplete = false;
  bool _isProcessing = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _paymentProvider = context.read<PaymentProvider>();
    _ensureStripeInitialized();
  }

  Future<void> _ensureStripeInitialized() async {
    try {
      if (Stripe.publishableKey.isEmpty) {
        Stripe.publishableKey = StripeConfig.publishableKey;
      }

      await Stripe.instance.applySettings();

      print('Stripe initialization check complete');
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error ensuring Stripe initialization: $e');
      await Future.delayed(Duration(milliseconds: 2000));
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _processPayment() async {
    if (!_isCardComplete) {
      _showErrorDialog('Please enter valid card details');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      String? clientSecret = await _paymentProvider.createStripePaymentIntent(
        orderId: widget.orderId,
        amount: widget.amount,
        currency: 'usd',
      );

      if (clientSecret == null) {
        setState(() {
          _isProcessing = false;
        });
        _showErrorDialog('Failed to create payment intent. Please try again.');
        return;
      }

      String paymentIntentId = clientSecret.split('_secret_')[0];

      try {
        await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret,
          data: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: BillingDetails(),
            ),
          ),
        );

        models.PaymentResponse? response =
            await _paymentProvider.confirmStripePayment(
          orderId: widget.orderId,
          paymentIntentId: paymentIntentId,
        );

        setState(() {
          _isProcessing = false;
        });

        final status = response?.status.toLowerCase();
        if (response != null &&
            (status == 'completed' || status == 'pending')) {
          _showSuccessDialog(response);
        } else {
          _showErrorDialog(
              'Payment failed. Please try again. Status: ${response?.status}');
        }
      } on StripeException catch (e) {
        setState(() {
          _isProcessing = false;
        });
        _showErrorDialog(
            'Stripe error: ${e.error.message ?? 'Payment failed'}');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Error: $e');
    }
  }

  void _showSuccessDialog(models.PaymentResponse response) async {
    await _createOrderItems();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Payment Successful!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order: ${widget.orderNumber}'),
              Text('Amount: \$${response.amount.toStringAsFixed(2)}'),
              Text('Transaction ID: ${response.transactionId}'),
              Text('Status: ${response.status}'),
              Text('Payment Date: ${response.timestamp}'),
              SizedBox(height: 10),
              Text('Thank you for your purchase!',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createOrderItems() async {
    try {
      final orderItemProvider = OrderItemProvider();

      for (var item in widget.cartItems) {
        final orderItem = OrderItem()
          ..orderId = widget.orderId
          ..productId = item.product.id
          ..quantity = item.count
          ..price = item.product.price
          ..amount = item.count
          ..total = (item.product.price ?? 0) * item.count;

        await orderItemProvider.insert(orderItem);
      }

      final cartProvider = context.read<CartProvider>();
      cartProvider.clearCart();
    } catch (e) {
      print('Error creating order items: $e');
      print('This is likely due to missing backend endpoint for OrderItems');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Text('Payment Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MasterScreenWidget(
        title: "Payment",
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing payment...'),
            ],
          ),
        ),
      );
    }

    return MasterScreenWidget(
      title: "Payment",
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummary(),
            SizedBox(height: 24),
            _buildStripeCardForm(),
            SizedBox(height: 32),
            _buildProcessButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return material.Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order Number:'),
                Text(widget.orderNumber,
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount:'),
                Text(
                  '\$${widget.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStripeCardForm() {
    return material.Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stripe Credit Card Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              constraints: BoxConstraints(
                minHeight: 50,
                maxHeight: 200,
              ),
              child: CardField(
                onCardChanged: (card) {
                  setState(() {
                    _isCardComplete = card?.complete ?? false;
                  });
                },
              ),
            ),
            SizedBox(height: 8),
            if (!_isCardComplete)
              Text(
                'Please enter your card details above',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        child: _isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Processing...'),
                ],
              )
            : Text('Pay \$${widget.amount.toStringAsFixed(2)}'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
