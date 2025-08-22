import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ehairdressers_mobile/models/payment.dart';
import 'package:ehairdressers_mobile/models/order_item.dart';
import 'package:ehairdressers_mobile/models/cart.dart';
import 'package:ehairdressers_mobile/providers/payment_provider.dart';
import 'package:ehairdressers_mobile/providers/order_item_provider.dart';
import 'package:ehairdressers_mobile/providers/cart_provider.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';

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
  final _formKey = GlobalKey<FormState>();
  late PaymentProvider _paymentProvider;
  
  
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryMonthController = TextEditingController();
  final TextEditingController _expiryYearController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  

  int _selectedPaymentMethod = 1; 
  bool _isProcessing = false;
  bool _isTestMode = true;
  bool _isInitialized = false;
  
  
  List<PaymentMethod> _paymentMethods = [];
  
  @override
  void initState() {
    super.initState();
    _loadTestData(); 
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _paymentProvider = context.read<PaymentProvider>();
    _loadPaymentMethods(); 
  }

  Future<void> _loadPaymentMethods() async {
    try {
      var methods = await _paymentProvider.getPaymentMethods();
      setState(() {
        _paymentMethods = methods;
        _isInitialized = true;
      });
    } catch (e) {
      print('Error loading payment methods: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _loadTestData() {

    _cardNumberController.text = '4111111111111111';
    _cardHolderController.text = 'Test User';
    _expiryMonthController.text = '12';
    _expiryYearController.text = '2025';
    _cvvController.text = '123';
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {

      final paymentRequest = PaymentRequest(
        orderId: widget.orderId,
        amount: widget.amount,
        paymentMethodId: _selectedPaymentMethod,
        cardNumber: _cardNumberController.text.isNotEmpty ? _cardNumberController.text : null,
        cardHolderName: _cardHolderController.text.isNotEmpty ? _cardHolderController.text : null,
        expiryMonth: _expiryMonthController.text.isNotEmpty ? int.tryParse(_expiryMonthController.text) : null,
        expiryYear: _expiryYearController.text.isNotEmpty ? int.tryParse(_expiryYearController.text) : null,
        cvv: _cvvController.text.isNotEmpty ? _cvvController.text : null,
        isTestPayment: _isTestMode,
      );

      PaymentResponse? response;
      

      response = await _paymentProvider.processTestPayment(paymentRequest);

      setState(() {
        _isProcessing = false;
      });

      if (response != null && (response.status == 'SUCCESS' || response.status == 'Pending')) {
        _showSuccessDialog(response);
      } else {
        _showErrorDialog('Payment failed. Please try again. Status: ${response?.status}');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Error: $e');
    }
  }

  void _showSuccessDialog(PaymentResponse response) async {

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
              Text('Thank you for your purchase!', style: TextStyle(fontWeight: FontWeight.bold)),
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
              Text('Loading payment methods...'),
            ],
          ),
        ),
      );
    }

    return MasterScreenWidget(
      title: "Payment",
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildOrderSummary(),
              SizedBox(height: 24),
              

              _buildPaymentMethodSelection(),
              SizedBox(height: 24),
              

              if (_selectedPaymentMethod == 1) _buildCreditCardForm(),
              
              SizedBox(height: 24),
              
              SizedBox(height: 32),
              

              _buildProcessButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
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
                Text(widget.orderNumber, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount:'),
                Text(
                  '\$${widget.amount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    if (_paymentMethods.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No payment methods available'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        ...(_paymentMethods.map((method) => RadioListTile<int>(
          title: Text(method.name ?? 'Unknown'),
          subtitle: Text(method.description ?? ''),
          value: method.id ?? 0,
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            }
          },
        )).toList()),
      ],
    );
  }

  Widget _buildCreditCardForm() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Credit Card Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            

            TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card number';
                }
                if (value.length < 13) {
                  return 'Card number must be at least 13 digits';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            

            TextFormField(
              controller: _cardHolderController,
              decoration: InputDecoration(
                labelText: 'Card Holder Name',
                hintText: 'John Doe',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card holder name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryMonthController,
                    decoration: InputDecoration(
                      labelText: 'Month',
                      hintText: 'MM',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      int? month = int.tryParse(value);
                      if (month == null || month < 1 || month > 12) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _expiryYearController,
                    decoration: InputDecoration(
                      labelText: 'Year',
                      hintText: 'YYYY',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      int? year = int.tryParse(value);
                      if (year == null || year < DateTime.now().year) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (value.length < 3) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
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
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}
