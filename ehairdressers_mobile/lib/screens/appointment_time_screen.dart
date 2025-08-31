import 'package:flutter/material.dart';
import 'package:ehairdressers_mobile/providers/appointment_provider.dart';
import 'package:ehairdressers_mobile/models/appointment_insert_request.dart';
import 'package:ehairdressers_mobile/models/appointment.dart';
import 'package:ehairdressers_mobile/screens/user_appointments_screen.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AppointmentTimeScreen extends StatefulWidget {
  final DateTime appointmentDate;
  final int userId;
  final int serviceId;
  final int employeeId;
  final String employeeName;
  final String userName;
  final String serviceName;

  AppointmentTimeScreen({
    required this.userId,
    required this.serviceId,
    required this.employeeId,
    required this.employeeName,
    required this.userName,
    required this.serviceName,
    required this.appointmentDate,
  });

  @override
  State<AppointmentTimeScreen> createState() => _AppointmentTimeScreenState();
}

class _AppointmentTimeScreenState extends State<AppointmentTimeScreen> {
  late AppointmentProvider _appointmentProvider;
  List<TimeOfDay>? availableTimes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _appointmentProvider = context.read<AppointmentProvider>();
    _loadAvailableTimes();
  }

  Future<void> _loadAvailableTimes() async {
    try {
      // Fetch available times for the selected date
      availableTimes = await _appointmentProvider
          .getTime(widget.appointmentDate.toLocal().toString().split(' ')[0]);
    } catch (e) {
      print("Error fetching available times: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text("Appointment Booked!"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your appointment has been booked successfully!"),
            SizedBox(height: 16),
            Text(
              "What would you like to do next?",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog
              Navigator.pop(context);
              // Navigate to user appointments screen to show all user's appointments
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UserAppointmentsScreen(
                    userId: widget.userId,
                  ),
                ),
              );
            },
            child: Text("View My Appointments"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }



  void _showFailureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Error"),
        content: Text("Failed to book the appointment. Please try again."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Error"),
        content: Text("Error: $errorMessage"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _bookAppointment(TimeOfDay time) async {
    // Format the date and time correctly for the backend
    String appointmentDate =
        DateFormat('yyyy-MM-dd').format(widget.appointmentDate);
    String appointmentTime =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00"; // Ensure seconds are included
    
    // Create the complete request with all required fields
          // Try without the id field - maybe the backend doesn't expect it
      final request = AppointmentInsertRequest(
        employeeId: widget.employeeId,
        employeeName: widget.employeeName,
        userId: widget.userId,
        username: widget.userName,
        serviceId: widget.serviceId,
        serviceName: widget.serviceName,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
      );

print('Final JSON to send: ${request.toJson()}');
    
    // Validate the request before sending
    if (widget.employeeName.isEmpty || widget.userName.isEmpty || widget.serviceName.isEmpty) {
      _showErrorDialog("Missing required information. Please go back and try again.");
      return;
    }

    try {
      var response = await _appointmentProvider.insert(request);

      if (response != null) {
        _showSuccessDialog();
      } else {
        _showFailureDialog();
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Appointment Time"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Available Times",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableTimes?.length ?? 0,
                    itemBuilder: (context, index) {
                      final time = availableTimes![index];
                      return ListTile(
                        title: Text(
                          time.format(context),
                          style: TextStyle(color: Color(0xFFE5C89D)),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            _bookAppointment(time);
                          },
                          child: Text("Book"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 247, 233, 211),
                            foregroundColor: Color(0xFF938F94),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
