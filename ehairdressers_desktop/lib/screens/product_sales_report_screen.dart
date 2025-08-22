import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/product_sales_report.dart';
import '../providers/ProductSalesReportProvider.dart';
import '../widgets/master_screen.dart';

class ProductSalesReportScreen extends StatefulWidget {
  @override
  _ProductSalesReportScreenState createState() => _ProductSalesReportScreenState();
}

class _ProductSalesReportScreenState extends State<ProductSalesReportScreen> {
  late ProductSalesReportProvider _reportProvider;
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedReportType = 'sales';
  List<ProductSalesReport> _reportData = [];
  bool _isLoading = false;

  final List<String> _reportTypes = [
    'sales',
    'revenue', 
    'frequency'
  ];

  @override
  void initState() {
    super.initState();
    _reportProvider = context.read<ProductSalesReportProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Product Sales Report",
      child: Container(
        margin: EdgeInsets.only(top: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildReportControls(),
              SizedBox(height: 20),
              _buildReportData(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportControls() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Parameters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    'Start Date',
                    _startDate,
                    (date) => setState(() => _startDate = date),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: _buildDatePicker(
                    'End Date',
                    _endDate,
                    (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedReportType,
              decoration: InputDecoration(
                labelText: 'Report Type',
                border: OutlineInputBorder(),
              ),
              items: _reportTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getReportTypeDisplayName(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReportType = value!;
                });
              },
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateReport,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Generate Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 247, 233, 211),
                  foregroundColor: Color(0x0FF938f94),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('yyyy-MM-dd').format(date)),
                Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportData() {
    if (_reportData.isEmpty && !_isLoading) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Text(
              'No report data available. Generate a report to see results.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getReportTypeDisplayName(_selectedReportType),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _buildReportTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: _getTableColumns(),
        rows: _reportData.map((item) {
          return DataRow(
            cells: _getTableCells(item),
          );
        }).toList(),
      ),
    );
  }

  List<DataColumn> _getTableColumns() {
    switch (_selectedReportType) {
      case 'sales':
        return [
          DataColumn(label: Text('Product Name')),
          DataColumn(label: Text('Quantity Sold')),
          DataColumn(label: Text('Total Revenue')),
        ];
      case 'revenue':
        return [
          DataColumn(label: Text('Product Name')),
          DataColumn(label: Text('Total Revenue')),
          DataColumn(label: Text('Percentage')),
        ];
      case 'frequency':
        return [
          DataColumn(label: Text('Product Name')),
          DataColumn(label: Text('Order Count')),
          DataColumn(label: Text('Quantity Sold')),
        ];
      default:
        return [
          DataColumn(label: Text('Product Name')),
          DataColumn(label: Text('Data')),
        ];
    }
  }

  List<DataCell> _getTableCells(ProductSalesReport item) {
    switch (_selectedReportType) {
      case 'sales':
        return [
          DataCell(Text(item.productName ?? 'N/A')),
          DataCell(Text('${item.quantitySold ?? 0}')),
          DataCell(Text('\$${(item.totalRevenue ?? 0).toStringAsFixed(2)}')),
        ];
      case 'revenue':
        double totalRevenue = _reportData.fold(0, (sum, item) => sum + (item.totalRevenue ?? 0));
        double percentage = totalRevenue > 0 ? ((item.totalRevenue ?? 0) / totalRevenue * 100) : 0;
        return [
          DataCell(Text(item.productName ?? 'N/A')),
          DataCell(Text('\$${(item.totalRevenue ?? 0).toStringAsFixed(2)}')),
          DataCell(Text('${percentage.toStringAsFixed(1)}%')),
        ];
      case 'frequency':
        return [
          DataCell(Text(item.productName ?? 'N/A')),
          DataCell(Text('${item.orderCount ?? 0}')),
          DataCell(Text('${item.quantitySold ?? 0}')),
        ];
      default:
        return [
          DataCell(Text(item.productName ?? 'N/A')),
          DataCell(Text('N/A')),
        ];
    }
  }

  String _getReportTypeDisplayName(String type) {
    switch (type) {
      case 'sales':
        return 'Product Sales Report';
      case 'revenue':
        return 'Revenue Report';
      case 'frequency':
        return 'Most Frequently Ordered Products';
      default:
        return 'Report';
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<ProductSalesReport> data;
      
      switch (_selectedReportType) {
        case 'sales':
          data = await _reportProvider.generateSalesReport(_startDate, _endDate);
          break;
        case 'revenue':
          data = await _reportProvider.generateRevenueReport(_startDate, _endDate);
          break;
        case 'frequency':
          data = await _reportProvider.generateFrequencyReport(_startDate, _endDate);
          break;
        default:
          data = [];
      }

      setState(() {
        _reportData = data;
        _isLoading = false;
      });

      if (data.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No data found for the selected period.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
