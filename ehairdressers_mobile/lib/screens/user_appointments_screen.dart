import 'package:flutter/material.dart';
import 'package:ehairdressers_mobile/models/appointment.dart';
import 'package:ehairdressers_mobile/providers/appointment_provider.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:ehairdressers_mobile/models/search_result.dart';
import 'package:intl/intl.dart';

class UserAppointmentsScreen extends StatefulWidget {
  final int userId;

  const UserAppointmentsScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserAppointmentsScreen> createState() => _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState extends State<UserAppointmentsScreen> {
  late AppointmentProvider _appointmentProvider;
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _appointmentProvider = AppointmentProvider();
    _loadUserAppointments();
  }

  Future<void> _loadUserAppointments() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get all appointments for the specific user using the dedicated endpoint
      List<Appointment> appointments = await _appointmentProvider.getUserAppointments(widget.userId);

      // Process appointments to mark past ones as completed
      List<Appointment> processedAppointments = _processAppointments(appointments);

      // Sort appointments by date (most recent first)
      processedAppointments.sort((a, b) {
        try {
          DateTime dateA = _parseAppointmentDateTime(a.appointmentDate, a.appointmentTime);
          DateTime dateB = _parseAppointmentDateTime(b.appointmentDate, b.appointmentTime);
          return dateB.compareTo(dateA); // Most recent first
        } catch (e) {
          return 0; // Keep original order if sorting fails
        }
      });

      // Debug: Print all appointments and their cancellation status
      print('=== ALL APPOINTMENTS LOADED ===');
      for (var appointment in processedAppointments) {
        print('Appointment ID: ${appointment.id}');
        print('  Status: ${appointment.status}');
        print('  Date: ${appointment.appointmentDate}');
        print('  Time: ${appointment.appointmentTime}');
        print('  Can Cancel: ${_canCancelAppointment(appointment)}');
        print('---');
      }

      setState(() {
        _appointments = processedAppointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading appointments: $e';
        _isLoading = false;
      });
      print('Error loading user appointments: $e');
    }
  }

  // Process appointments to automatically mark past ones as completed
  List<Appointment> _processAppointments(List<Appointment> appointments) {
    DateTime now = DateTime.now();
    
    return appointments.map((appointment) {
      try {
        // Parse appointment date and time
        DateTime appointmentDateTime = _parseAppointmentDateTime(
          appointment.appointmentDate, 
          appointment.appointmentTime
        );
        
        // If appointment is in the past and still marked as scheduled, mark as completed
        if (appointmentDateTime.isBefore(now) && 
            (appointment.status?.toLowerCase() == 'scheduled' || appointment.status == null)) {
          
          // Create a new appointment with updated status
          return Appointment(
            appointment.id,
            appointment.employeeId,
            appointment.employeeName,
            appointment.userId,
            appointment.username,
            appointment.serviceId,
            appointment.serviceName,
            appointment.appointmentDate,
            appointment.appointmentTime,
            status: 'Completed',
            duration: appointment.duration,
          );
        }
        
        return appointment;
      } catch (e) {
        print('Error processing appointment ${appointment.id}: $e');
        return appointment;
      }
    }).toList();
  }

  // Check if appointment can be cancelled
  bool _canCancelAppointment(Appointment appointment) {
    print('=== CHECKING IF APPOINTMENT CAN BE CANCELLED ===');
    print('Appointment ID: ${appointment.id}');
    print('Status: ${appointment.status}');
    print('Date: ${appointment.appointmentDate}');
    print('Time: ${appointment.appointmentTime}');
    
    // Only allow cancellation of scheduled appointments that are in the future
    if (appointment.status?.toLowerCase() != 'scheduled') {
      print('❌ Cannot cancel: Status is not "scheduled" (${appointment.status})');
      return false;
    }
    
    try {
      DateTime appointmentDateTime = _parseAppointmentDateTime(
        appointment.appointmentDate, 
        appointment.appointmentTime
      );
      
      DateTime now = DateTime.now();
      DateTime twoHoursFromNow = now.add(Duration(hours: 2));
      
      print('Appointment DateTime: $appointmentDateTime');
      print('Current DateTime: $now');
      print('Two hours from now: $twoHoursFromNow');
      print('Is appointment in future? ${appointmentDateTime.isAfter(now)}');
      print('Is appointment >2 hours away? ${appointmentDateTime.isAfter(twoHoursFromNow)}');
      
      // Allow cancellation if appointment is more than 2 hours in the future
      bool canCancel = appointmentDateTime.isAfter(twoHoursFromNow);
      print('✅ Can cancel appointment: $canCancel');
      return canCancel;
    } catch (e) {
      print('❌ Error checking if appointment can be cancelled: $e');
      return false;
    }
  }

  // Show cancellation confirmation dialog
  void _showCancelConfirmation(Appointment appointment) {
    print('=== SHOWING CANCELLATION DIALOG ===');
    print('Appointment ID: ${appointment.id}');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange[600], size: 24),
              SizedBox(width: 8),
              Text('Cancel Appointment'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel this appointment?',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Service: ${appointment.serviceName ?? 'Unknown'}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Date: ${_formatDate(appointment.appointmentDate)}',
              ),
              Text(
                'Time: ${_formatTime(appointment.appointmentTime)}',
              ),
              SizedBox(height: 16),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('User cancelled the dialog');
                Navigator.of(context).pop();
              },
              child: Text(
                'Keep Appointment',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                print('User confirmed cancellation');
                Navigator.of(context).pop();
                _cancelAppointment(appointment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: Text('Cancel Appointment'),
            ),
          ],
        );
      },
    );
  }

  // Cancel the appointment
  Future<void> _cancelAppointment(Appointment appointment) async {
    print('=== STARTING APPOINTMENT CANCELLATION ===');
    print('Appointment ID: ${appointment.id}');
    
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      print('Calling cancelAppointment API...');
      // Call the cancel appointment API
      bool success = await _appointmentProvider.cancelAppointment(appointment.id);
      
      print('API call completed. Success: $success');
      
      // Close loading dialog
      Navigator.of(context).pop();

      if (success) {
        print('✅ Appointment cancelled successfully');
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment cancelled successfully. Time slot is now available for others.'),
            backgroundColor: Colors.green[600],
            duration: Duration(seconds: 4),
          ),
        );
        
        // Immediately update the local appointment status to "Cancelled"
        setState(() {
          int index = _appointments.indexWhere((a) => a.id == appointment.id);
          if (index != -1) {
            _appointments[index] = Appointment(
              appointment.id,
              appointment.employeeId,
              appointment.employeeName,
              appointment.userId,
              appointment.username,
              appointment.serviceId,
              appointment.serviceName,
              appointment.appointmentDate,
              appointment.appointmentTime,
              status: 'Cancelled',
              duration: appointment.duration,
            );
          }
        });
        
        // Also reload from server to ensure consistency
        await _loadUserAppointments();
      } else {
        print('❌ Appointment cancellation failed');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel appointment. Please try again.'),
            backgroundColor: Colors.red[600],
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Error cancelling appointment: $e');
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cancelling appointment: $e'),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Parse appointment date and time into DateTime object
  DateTime _parseAppointmentDateTime(String dateString, String timeString) {
    try {
      DateTime date;
      
      // Handle different date formats
      if (dateString.contains('/')) {
        // Format: "08/17/2025 00:00:00" or "08/17/2025"
        String cleanDate = dateString.split(' ')[0]; // Remove time part if present
        List<String> parts = cleanDate.split('/');
        if (parts.length == 3) {
          int month = int.parse(parts[0]);
          int day = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          date = DateTime(year, month, day);
        } else {
          throw FormatException('Invalid date format: $dateString');
        }
      } else {
        // Try standard ISO format
        date = DateTime.parse(dateString);
      }
      
      // Parse time (assuming format like "14:30:00" or "14:30")
      int hour = 0;
      int minute = 0;
      
      if (timeString.isNotEmpty) {
        List<String> timeParts = timeString.split(':');
        if (timeParts.length >= 2) {
          hour = int.parse(timeParts[0]);
          minute = int.parse(timeParts[1]);
        }
      }
      
      // Create DateTime with the appointment date and time
      return DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
    } catch (e) {
      print('Error parsing appointment date/time: $e');
      print('Date string: $dateString, Time string: $timeString');
      // Return a default DateTime if parsing fails
      return DateTime.now();
    }
  }

  String _formatDate(String dateString) {
    try {
      // Handle date format like "09/23/2025 00:00:00" - extract only the date part
      if (dateString.contains(' ')) {
        String cleanDate = dateString.split(' ')[0]; // Remove time part
        if (cleanDate.contains('/')) {
          // Format: "09/23/2025"
          List<String> parts = cleanDate.split('/');
          if (parts.length == 3) {
            int month = int.parse(parts[0]);
            int day = int.parse(parts[1]);
            int year = int.parse(parts[2]);
            DateTime date = DateTime(year, month, day);
            return DateFormat('dd/MM/yyyy').format(date);
          }
        }
        return cleanDate;
      } else {
        // Try standard ISO format
        DateTime date = DateTime.parse(dateString);
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(String timeString) {
    try {
      // Handle time format like "14:30:00" or "14:30"
      if (timeString.contains(':')) {
        List<String> parts = timeString.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        TimeOfDay time = TimeOfDay(hour: hour, minute: minute);
        return time.format(context);
      }
      return timeString;
    } catch (e) {
      return timeString;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'scheduled':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDescription(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'scheduled':
        return 'Scheduled';
      default:
        return 'Unknown';
    }
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    appointment.serviceName ?? 'Unknown Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusDescription(appointment.status),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Employee: ${appointment.employeeName ?? 'Unknown'}',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Date: ${_formatDate(appointment.appointmentDate)}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  'Time: ${_formatTime(appointment.appointmentTime)}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            if (appointment.duration != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    'Duration: ${appointment.duration} minutes',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
            // Cancel button for scheduled appointments
            if (_canCancelAppointment(appointment)) ...[
              SizedBox(height: 16),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    print('Cancel button tapped for appointment ${appointment.id}');
                    _showCancelConfirmation(appointment);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Debug info: Show why appointment can't be cancelled
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600], size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cannot cancel: ${appointment.status?.toLowerCase() == 'scheduled' ? 'Appointment is too soon (within 2 hours)' : 'Status is ${appointment.status ?? 'unknown'}'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            

          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No Appointments Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You haven\'t booked any appointments yet.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Book New Appointment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE5C89D),
              foregroundColor: Color(0xFF938F94),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          SizedBox(height: 16),
          Text(
            'Error Loading Appointments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage ?? 'An unknown error occurred',
            style: TextStyle(
              fontSize: 16,
              color: Colors.red[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadUserAppointments,
            child: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE5C89D),
              foregroundColor: Color(0xFF938F94),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: 'My Appointments',
      userId: widget.userId,
      showFloatingChat: true,
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _appointments.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        await _loadUserAppointments();
                      },
                      child: ListView.builder(
                        itemCount: _appointments.length,
                        itemBuilder: (context, index) {
                          return _buildAppointmentCard(_appointments[index]);
                        },
                      ),
                    ),
    );
  }
}
