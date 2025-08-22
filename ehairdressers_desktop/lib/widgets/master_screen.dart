import 'package:flutter/material.dart';
import '../screens/reservation_list.dart';
import '../screens/product_insert_screen.dart';
import '../screens/employee_add_screen.dart';
import '../screens/product_sales_report_screen.dart';
import '../screens/salon_operations_report_screen.dart';
import '../providers/EmployeeProvider.dart';
import '../models/SearchResult.dart';
import '../models/employee.dart';
import '../models/user.dart';
import 'package:provider/provider.dart';

class MasterScreenWidget extends StatefulWidget {
  Widget? child;
  String? title;
  User? user;
  MasterScreenWidget({this.child, this.title, this.user, Key? key})
      : super(key: key);
  @override
  State<MasterScreenWidget> createState() => _MasterScreenWidgetState();
}

class _MasterScreenWidgetState extends State<MasterScreenWidget> {
  late EmployeeProvider _employeeProvider;
  SearchResult<Employee>? employeeResult;

  @override
  void initState() {
    super.initState();

    _employeeProvider = context.read<EmployeeProvider>();
    initForm();
  }

  Future initForm() async {
    try {
      employeeResult = await _employeeProvider.get();
      print(employeeResult?.result?.firstOrNull?.name);
    } catch (e) {
      print("Error loading employees: $e");
      // Set empty result if there's an error
      employeeResult = SearchResult<Employee>();
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "",
            style: TextStyle(color: Color(0x0FFe5c89d))),
        backgroundColor: Color(0x0FF13414b),
        actions: [
          // Notification widget temporarily removed
          // NotificationWidget(),
          SizedBox(width: 16),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text("Reservations"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ReservationList()));
              },
            ),
            ListTile(
              title: Text("Upload product"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProductInsert()));
              },
            ),
            ListTile(
              title: Text("Upload employee"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => EmployeeAdd()));
              },
            ),
            ListTile(
              title: Text("Product Sales Report"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProductSalesReportScreen()));
              },
            ),
            ListTile(
              title: Text("Salon Operations Report"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SalonOperationsReportScreen()));
              },
            ),
            ListTile(
              title: Text("Back"),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      body: widget.child!,
    );
  }
}
