import 'package:flutter/material.dart';
import 'package:ehairdressers_mobile/models/order.dart';
import 'package:ehairdressers_mobile/models/order_item.dart';
import 'package:ehairdressers_mobile/providers/order_item_provider.dart';
import 'package:ehairdressers_mobile/utils/util.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final Orders order;

  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderItemProvider _orderItemProvider;
  List<OrderItem> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _orderItemProvider = OrderItemProvider();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orderId = widget.order.orderId;
      if (orderId == null) {
        setState(() {
          _items = [];
          _isLoading = false;
        });
        return;
      }

      final items = await _orderItemProvider.getByOrderId(orderId);
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load order items: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Order #${widget.order.orderNumber ?? widget.order.orderId ?? ''}",
      showFloatingChat: false,
      child: RefreshIndicator(
        onRefresh: _loadItems,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummaryCard(),
              SizedBox(height: 16),
              Text(
                'Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              _buildItemsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    final order = widget.order;
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Order ${order.orderNumber ?? '#${order.orderId ?? ''}'}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(order.statusDisplay),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.statusDisplay,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Date: ${order.formattedOrderDate}'),
            SizedBox(height: 4),
            Text(
              'Total: \$${order.displayTotal.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'canceled':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildItemsList() {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Text(_error!, textAlign: TextAlign.center),
              SizedBox(height: 8),
              ElevatedButton(onPressed: _loadItems, child: Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('No products found for this order.')),
      );
    }

    return Column(
      children: _items.map((item) => _buildItemCard(item)).toList(),
    );
  }

  Widget _buildItemCard(OrderItem item) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            _buildItemImage(item),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayProductName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 4),
                  Text('Quantity: ${item.displayQuantity}'),
                  SizedBox(height: 2),
                  Text(
                    'Price: \$${item.displayPrice.toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Text(
              '\$${item.calculatedTotal.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage(OrderItem item) {
    final image = item.productImage;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 64,
        height: 64,
        color: Colors.grey[200],
        child: (image != null && image.isNotEmpty)
            ? Image(
                image: imageFromBase64String(image).image,
                fit: BoxFit.cover,
              )
            : Icon(Icons.shopping_bag, color: Colors.grey[400]),
      ),
    );
  }
}
