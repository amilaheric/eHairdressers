import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/salon_operations_report.dart';
import '../providers/SalonOperationsReportProvider.dart';
import '../widgets/master_screen.dart';

class SalonOperationsReportScreen extends StatefulWidget {
  @override
  _SalonOperationsReportScreenState createState() => _SalonOperationsReportScreenState();
}

class _SalonOperationsReportScreenState extends State<SalonOperationsReportScreen> {
  late SalonOperationsReportProvider _reportProvider;
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedReportType = 'operations';
  SalonOperationsReport? _reportData;
  bool _isLoading = false;

  final List<String> _reportTypes = [
    'operations',
    'customer',

    'appointments',
  ];

  final Map<String, String> _reportTypeLabels = {
    'operations': 'Operations Overview',
    'customer': 'Customer Analysis',
    
    'appointments': 'Appointments Summary',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reportProvider = context.read<SalonOperationsReportProvider>();
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      SalonOperationsReport? reportData;
      
      switch (_selectedReportType) {
        case 'operations':
          reportData = await _reportProvider.generateOperationsReport(_startDate, _endDate);
          break;
        case 'customer':
          reportData = await _reportProvider.generateCustomerReport(_startDate, _endDate);
          break;

        case 'appointments':
          reportData = await _reportProvider.generateAppointmentsReport(_startDate, _endDate);
          break;
      }

      setState(() {
        _reportData = reportData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Widget _buildDateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Date Range',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Start Date', style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('MMM dd, yyyy').format(_startDate)),
                              Icon(Icons.calendar_today, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('End Date', style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateFormat('MMM dd, yyyy').format(_endDate)),
                              Icon(Icons.calendar_today, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedReportType,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _reportTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(_reportTypeLabels[type] ?? type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedReportType = newValue;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _generateReport,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Generate Report',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildReportData() {
    if (_reportData == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'Generate a report to see data',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _reportTypeLabels[_selectedReportType] ?? 'Report',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Period: ${DateFormat('MMM dd').format(_reportData!.startDate!)} - ${DateFormat('MMM dd, yyyy').format(_reportData!.endDate!)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildMetricsGrid(),
            SizedBox(height: 24),
            _buildDetailedBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    List<Widget> metrics = [];
    
    if (_selectedReportType == 'operations' || _selectedReportType == 'customer') {
      metrics.addAll([
        _buildMetricCard('Total Customers', '${_reportData!.totalCustomers ?? 0}', Icons.people, Colors.blue),
        _buildMetricCard('New Customers', '${_reportData!.newCustomers ?? 0}', Icons.person_add, Colors.green),
        
      ]);
    }
    
          if (_selectedReportType == 'operations') {
      metrics.addAll([

        
      ]);
    }
    
    if (_selectedReportType == 'operations' || _selectedReportType == 'appointments') {
      metrics.addAll([
        _buildMetricCard('Total Appointments', '${_reportData!.totalAppointments ?? 0}', Icons.calendar_today, Colors.indigo),
        
      ]);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) => metrics[index],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBreakdown() {
    if (_selectedReportType == 'operations' && _reportData != null) {
             // Calculate returning customers from available data
       final totalCustomers = _reportData!.totalCustomers ?? 0;
       final totalAppointments = _reportData!.totalAppointments ?? 0;

      
      // Estimate returning customers (customers with multiple appointments)
      // This is a simplified calculation - in reality, you'd need appointment history per customer
      final estimatedReturningCustomers = totalCustomers > 0 && totalAppointments > totalCustomers 
          ? (totalAppointments - totalCustomers).clamp(0, totalCustomers) 
          : 0;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          if (totalCustomers > 0) _buildBreakdownRow('Customer Retention Rate', 
            '${((estimatedReturningCustomers / totalCustomers) * 100).toStringAsFixed(1)}%'),
          
          if (totalCustomers > 0) _buildBreakdownRow('Revenue per Customer', 
            'N/A'),
          if (totalAppointments > 0) _buildBreakdownRow('Average Appointments per Customer', 
            '${(totalAppointments / totalCustomers).toStringAsFixed(1)}'),
        ],
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildBreakdownRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: 'Salon Operations Report',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Salon Operations Report',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Generate comprehensive reports on customers and appointments',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            _buildDateSelector(),
            SizedBox(height: 16),
            _buildReportTypeSelector(),
            SizedBox(height: 24),
            _buildGenerateButton(),
            SizedBox(height: 24),
            _buildReportData(),
          ],
        ),
      ),
    );
  }
}
