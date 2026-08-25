import 'package:ehairdressers_mobile/models/employees.dart';
import 'package:ehairdressers_mobile/models/search_result.dart' as models;
import 'package:ehairdressers_mobile/models/service.dart';
import 'package:ehairdressers_mobile/models/user.dart';
import 'package:ehairdressers_mobile/providers/employees_provider.dart';
import 'package:ehairdressers_mobile/providers/service_provider.dart';
import 'package:ehairdressers_mobile/providers/user_provider.dart';
import 'package:ehairdressers_mobile/screens/appointment_time_screen.dart';
import 'package:ehairdressers_mobile/screens/user_appointments_screen.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:ehairdressers_mobile/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  bool isLoading = true;
  String defaultImagePath = 'assets/images/logo.png';
  late ServiceProvider _serviceProvider;
  late UserProvider _userProvider;
  late EmployeesProvider _employeesProvider;

  models.SearchResult<Service>? serviceResult;
  models.SearchResult<Employees>? employeesResult;
  @override
  void initState() {
    super.initState();
    _initialValue = {};
    _serviceProvider = context.read<ServiceProvider>();
    _userProvider = context.read<UserProvider>();
    _employeesProvider = context.read<EmployeesProvider>();
    isLoading = true;
    loadData();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future loadData() async {
    try {
      print('=== LOADING DATA ===');

      print('Loading services...');
      serviceResult = await _serviceProvider.getResult();
      print('Services loaded: ${serviceResult?.result?.length ?? 0} items');

      print('Loading employees...');
      employeesResult = await _employeesProvider.getResult();
      print('Employees loaded: ${employeesResult?.result?.length ?? 0} items');

      if (serviceResult?.result != null) {
        print('=== SERVICES ===');
        for (var item in serviceResult!.result!) {
          print('Service ID: ${item.serviceId}, Name: ${item.serviceName}');
        }
      } else {
        print('WARNING: serviceResult.result is null!');
      }

      if (employeesResult?.result != null) {
        print('=== EMPLOYEES ===');
        for (var item in employeesResult!.result!) {
          print('Employee ID: ${item.employeeId}, Name: ${item.name}');
        }
      } else {
        print('WARNING: employeesResult.result is null!');
      }

      print('=== DATA LOADING COMPLETE ===');
    } catch (e) {
      print('ERROR loading data: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Appointment",
      userId: Authorization.currentUserId,
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              isLoading ? Container() : _buildForm(),
              SizedBox(height: 20),
        
              ElevatedButton(
                  onPressed: () async {
                    try {
                      _formKey.currentState!.saveAndValidate();
                      var formData = _formKey.currentState!.value;

                      print(
                          'formData raw employeeId: ${formData['employeeId']}');
                      print('formData raw serviceId: ${formData['serviceId']}');
                      print('formData raw date: ${formData['date']}');
                      // Simple validation - just check if required fields are selected
                      if (formData['employeeId'] == null ||
                          formData['serviceId'] == null ||
                          formData['date'] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Please select employee, service, and date')),
                        );
                        return;
                      }
                      // Parse employeeId safely
                      final dynamic rawEmployeeId = formData['employeeId'];
                      int employeeId;
                      if (rawEmployeeId is int) {
                        employeeId = rawEmployeeId;
                      } else if (rawEmployeeId is String) {
                        employeeId = int.tryParse(rawEmployeeId) ?? 0;
                      } else {
                        employeeId = 0;
                      }

                      // Parse serviceId safely
                      final dynamic rawServiceId = formData['serviceId'];
                      int serviceId;
                      if (rawServiceId is int) {
                        serviceId = rawServiceId;
                      } else if (rawServiceId is String) {
                        serviceId = int.tryParse(rawServiceId) ?? 0;
                      } else {
                        serviceId = 0;
                      }
                      DateTime appointmentDate = formData['date'];

                      // Get actual employee and service names from database
                      String? employeeName;
                      String? serviceName;

                      if (employeesResult?.result != null) {
                        var employee = employeesResult!.result!.firstWhere(
                          (e) => e.employeeId == employeeId,
                          orElse: () => Employees(0, "Unknown", "Employee"),
                        );
                        employeeName = employee.name ?? "Unknown Employee";
                      } else {
                        employeeName = "Unknown Employee";
                      }

                      if (serviceResult?.result != null) {
                        var service = serviceResult!.result!.firstWhere(
                          (s) => s.serviceId == serviceId,
                          orElse: () => Service(0, "Unknown"),
                        );
                        serviceName = service.serviceName ?? "Unknown Service";
                      } else {
                        serviceName = "Unknown Service";
                      }

                      // Get the actual user ID from database
                      int? userId;
                      String userName = Authorization.username ?? "user";

                      try {
                        var userResult = await _userProvider.getResult();
                        if (userResult?.result != null) {
                          var user = userResult!.result!.firstWhere(
                            (u) => u.username == userName,
                            orElse: () => User(userId: 0, username: "Unknown"),
                          );
                          if (user.userId != null && user.userId != 0) {
                            userId = user.userId;
                          }
                        }
                      } catch (e) {
                        print('Error getting user ID: $e');
                      }

                      // Fallback to ID 1 if we couldn't get the real user ID
                      if (userId == null) {
                        userId = 1;
                        print('Warning: Using fallback user ID 1');
                      }

                      // Ensure all required values are non-null
                      if (employeeName == null || serviceName == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Error: Could not get employee or service names')),
                        );
                        return;
                      }

                      print('Navigating to appointment time screen with:');
                      print(
                          'UserID: $userId, Employee: $employeeId (${employeeName}), Service: $serviceId (${serviceName})');

                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AppointmentTimeScreen(
                                userId: userId!,
                                employeeId: employeeId,
                                serviceId: serviceId,
                                employeeName: employeeName!,
                                userName: userName,
                                serviceName: serviceName!,
                                appointmentDate: appointmentDate,
                              )));
                    } catch (e) {
                      print('Error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: Text('Check time'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 247, 233, 211),
                      foregroundColor: Color(0x0FF938f94))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: _initialValue,
      child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                width: 600,
                child: Image.asset(defaultImagePath),
              ),
              FormBuilderDropdown<int>(
                name: 'employeeId',
                decoration: InputDecoration(
                  labelText: 'Select Employee',
                ),
                items: (() {
                  print(
                      'Building employee dropdown with ${employeesResult?.result?.length ?? 0} items');
                  if (employeesResult?.result != null) {
                    return employeesResult!.result!
                        .map((item) => DropdownMenuItem<int>(
                              alignment: AlignmentDirectional.center,
                              value: item.employeeId,
                              child: Text(item.name ?? "Empty "),
                            ))
                        .toList();
                  } else {
                    print(
                        'WARNING: employeesResult.result is null in dropdown!');
                    return <DropdownMenuItem<int>>[];
                  }
                })(),
              ),
              SizedBox(height: 10),
              // User is automatically set to logged-in user
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFE5C89D)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Color(0xFFE5C89D)),
                    SizedBox(width: 10),
                    Text(
                      'Logged in as: ${Authorization.username ?? "Not logged in"}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF938F94),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              FormBuilderDropdown<int>(
                name: 'serviceId',
                decoration: InputDecoration(
                  labelText: 'Select Service',
                ),
                items: (() {
                  print(
                      'Building service dropdown with ${serviceResult?.result?.length ?? 0} items');
                  if (serviceResult?.result != null) {
                    return serviceResult!.result!
                        .map((item) => DropdownMenuItem<int>(
                              alignment: AlignmentDirectional.center,
                              value: item.serviceId,
                              child: Text(item.serviceName ?? "Empty "),
                            ))
                        .toList();
                  } else {
                    print('WARNING: serviceResult.result is null in dropdown!');
                    return <DropdownMenuItem<int>>[];
                  }
                })(),
              ),
              SizedBox(height: 10),
              FormBuilderDateTimePicker(
                name: 'date',
                decoration: InputDecoration(
                  labelText: 'Select Date',
                ),
                inputType: InputType.date,
                format: DateFormat('dd/MM/yyyy'),
                enabled: true,
                firstDate: DateTime.now(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a date';
                  }
                  final today = DateTime.now();
                  final selectedDay = DateTime(value.year, value.month, value.day);
                  final todayDay = DateTime(today.year, today.month, today.day);
                  if (selectedDay.isBefore(todayDay)) {
                    return 'Date cannot be in the past';
                  }
                  return null;
                },
              ),
            ],
          )),
    );
  }

}
