import 'package:ehairdressers_mobile/models/cart.dart';
import 'package:ehairdressers_mobile/models/order.dart';
import 'package:ehairdressers_mobile/models/order_item.dart';
import 'package:ehairdressers_mobile/models/user.dart';
import 'package:ehairdressers_mobile/providers/cart_provider.dart';
import 'package:ehairdressers_mobile/providers/order_item_provider.dart';
import 'package:ehairdressers_mobile/providers/order_provider.dart';
import 'package:ehairdressers_mobile/providers/user_provider.dart';
import 'package:ehairdressers_mobile/screens/payment_screen.dart';
import 'package:ehairdressers_mobile/utils/util.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartProvider _cartProvider;
  final OrderProvider _orderProvider = OrderProvider();
  final UserProvider _userProvider = UserProvider();
  Orders _orders = Orders();
  final OrderItemProvider _orderItemProvider = OrderItemProvider();
  Map<String, dynamic>? payementIntentData;
  double checkout = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cartProvider = context.read<CartProvider>();
  }

  @override
  Widget build(BuildContext context) {
    if (_cartProvider == null) {
      return MasterScreenWidget(
        title: "Cart",
        userId: Authorization.currentUserId,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return MasterScreenWidget(
      title: "Cart",
      userId: Authorization.currentUserId,
      child: Column(
        children: [Expanded(child: _buildProductCardlist()), _buildBuyButton()],
      ),
    );
  }

  Widget _buildProductCardlist() {
    if (_cartProvider.cart.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add some products to get started!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      child: ListView.builder(
          itemCount: _cartProvider.cart.items.length,
          itemBuilder: (context, index) {
            return _buildProductCard(_cartProvider.cart.items[index]);
          }),
    );
  }

  Widget _buildProductCard(CartItem item) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 100,
          height: 100,
          child: item.product.image != null 
              ? imageFromBase64String(item.product.image!)
              : Icon(Icons.image, size: 50, color: Colors.grey),
        ),
        title: Text(item.product.name ?? "Unknown Product"),
        subtitle: Text(item.product.price?.toString() ?? "Price not available"),
        trailing: Column(children: [
          Expanded(
              child: Text(
            item.count.toString(),
            style: TextStyle(
              fontSize: 18,
            ),
          )),
                            Expanded(
                      child: IconButton(
                          onPressed: () {
                            if (_cartProvider != null) {
                              _cartProvider.removeFromCart(item.product);
                            }
                          },
                          icon: Icon(Icons.delete)))
        ]),
      ),
    );
  }

  Widget _buildBuyButton() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Total amount display
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${sumAll().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Buy button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _cartProvider.cart.items.isEmpty ? null : _processOrder,
              child: Text(
                "Proceed to Payment",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 247, 233, 211),
                foregroundColor: Color(0xFF938F94),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double sumAll() {
    double total = 0;
    if (_cartProvider?.cart?.items != null) {
      _cartProvider!.cart.items.forEach((element) {
        if (element.product.price != null) {
          total += (element.product.price! * element.count).toDouble();
        }
      });
    }
    return total;
  }

  Future<void> _processOrder() async {
    if (_cartProvider.cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    try {
      print('=== PROCEEDING TO PAYMENT ===');
      print('Cart items: ${_cartProvider.cart.items.length}');
      print('Total amount: ${sumAll()}');
      print('============================');

      // Use the correct Cart/ProceedToPayment endpoint
      final createdOrder = await _cartProvider.proceedToPayment();
      
      if (createdOrder != null) {
        print('Order created successfully with ID: ${createdOrder.orderId}');
        print('Order returned from backend:');
        print('  - OrderId: ${createdOrder.orderId}');
        print('  - OrderNumber: ${createdOrder.orderNumber}');
        print('  - UserId: ${createdOrder.userId}');
        print('  - TotalWithVAT: ${createdOrder.totalWithVAT}');
        print('  - TotalWithoutVAT: ${createdOrder.totalWithoutVAT}');
        
        // Create a proper order number
        String orderNumber = createdOrder.orderNumber ?? 'ORD-${createdOrder.orderId?.toString().padLeft(6, '0') ?? 'Unknown'}';
        
        // Store current cart items for this order
        List<CartItem> orderCartItems = List.from(_cartProvider.cart.items);
        
        print('Cart items for this order:');
        for (var item in orderCartItems) {
          print('  - Product ID: ${item.product.id}, Name: ${item.product.name}, Quantity: ${item.count}');
        }
        
        // Navigate to payment screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              orderId: createdOrder.orderId ?? 0,
              amount: createdOrder.totalWithVAT ?? sumAll(),
              orderNumber: orderNumber,
              cartItems: orderCartItems,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create order')),
        );
      }
    } catch (e) {
      print('Error in _processOrder: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
