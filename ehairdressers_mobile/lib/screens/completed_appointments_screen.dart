import 'package:flutter/material.dart';
import 'package:ehairdressers_mobile/models/appointment.dart';
import 'package:ehairdressers_mobile/providers/appointment_provider.dart';
import 'package:ehairdressers_mobile/providers/review_provider.dart';
import 'package:ehairdressers_mobile/screens/review_screen.dart';

import 'package:ehairdressers_mobile/utils/appointment_status_manager.dart';

import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CompletedAppointmentsScreen extends StatefulWidget {
  final int userId;

  const CompletedAppointmentsScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<CompletedAppointmentsScreen> createState() => _CompletedAppointmentsScreenState();
}

class _CompletedAppointmentsScreenState extends State<CompletedAppointmentsScreen> {
  late AppointmentProvider _appointmentProvider;
  late ReviewProvider _reviewProvider;
  List<Appointment> _completedAppointments = [];
  List<Appointment> _filteredAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appointmentProvider = context.read<AppointmentProvider>();
    _reviewProvider = context.read<ReviewProvider>();

    _loadAvailableAppointmentsForReview();
  }

  Future<void> _loadAvailableAppointmentsForReview() async {
    try {
      setState(() {
        _isLoading = true;
      });

      
      
      
      var appointments = await _appointmentProvider.getAvailableForReview(widget.userId);

      
      if (appointments?.result != null) {

        _completedAppointments = appointments!.result!;
        
      
  
        _filteredAppointments = _completedAppointments;

      } else {
        print('No available appointments for review returned from API');
        _completedAppointments = [];
        _filteredAppointments = [];
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading appointments: $e');
      setState(() {
        _isLoading = false;
      });
      

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading appointments: $e')),
          );
        }
      });
    }
  }

 

  void _navigateToReview(Appointment appointment) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReviewScreen(
          appointmentId: appointment.id,
          userId: appointment.userId,
          serviceId: appointment.serviceId,
          employeeId: appointment.employeeId,
          serviceName: appointment.serviceName ?? 'Unknown Service',
          employeeName: appointment.employeeName ?? 'Unknown Employee',
          appointmentDate: DateFormat('dd/MM/yyyy').format(
            AppointmentStatusManager.parseAppointmentDate(appointment.appointmentDate) ?? DateTime.now(),
          ),
          appointmentTime: appointment.appointmentTime,
          duration: appointment.duration,
        ),
      ),
    );
    

    if (result == true) {

      await _loadAvailableAppointmentsForReview();
    }
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    var appointmentDate = AppointmentStatusManager.parseAppointmentDate(appointment.appointmentDate) ?? DateTime.now();
    var isCompleted = AppointmentStatusManager.isAppointmentCompleted(appointment);
    var canReview = AppointmentStatusManager.canSubmitReview(appointment);
    var reviewStatus = AppointmentStatusManager.getReviewAvailabilityStatus(appointment);
    var timeSinceCompletion = AppointmentStatusManager.getTimeSinceCompletion(appointment);
    var timeUntilCompletion = AppointmentStatusManager.getTimeUntilCompletion(appointment);
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appointment #${appointment.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(appointment),
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
            Text(
              'Service: ${appointment.serviceName ?? 'Unknown'}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Employee: ${appointment.employeeName ?? 'Unknown'}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Date: ${DateFormat('dd/MM/yyyy').format(appointmentDate)}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Time: ${appointment.appointmentTime}',
              style: TextStyle(fontSize: 14),
            ),
            if (appointment.duration != null) ...[
              Text(
                'Duration: ${appointment.duration} minutes',
                style: TextStyle(fontSize: 14),
              ),
            ],
            
    
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(appointment),
                        size: 16,
                        color: _getStatusColor(appointment),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reviewStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(appointment),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isCompleted && timeSinceCompletion != null) ...[
                    SizedBox(height: 4),
                    Text(
                      'Completed ${_formatTimeAgo(timeSinceCompletion)} ago',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ] else if (!isCompleted && timeUntilCompletion != null) ...[
                    SizedBox(height: 4),
                    Text(
                      'Will be completed in ${_formatTimeUntil(timeUntilCompletion)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: canReview ? () => _navigateToReview(appointment) : null,
              icon: Icon(canReview ? Icons.rate_review : Icons.schedule),
              label: Text(canReview ? 'Leave Review' : 'Review Not Available Yet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: canReview ? Colors.orange : Colors.grey[400],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(Appointment appointment) {
    if (appointment.status == AppointmentStatusManager.STATUS_CANCELLED || 
        appointment.status == AppointmentStatusManager.STATUS_NO_SHOW) {
      return Colors.red;
    } else if (AppointmentStatusManager.isAppointmentCompleted(appointment)) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  String _getStatusText(Appointment appointment) {
    if (appointment.status == AppointmentStatusManager.STATUS_CANCELLED) {
      return 'Cancelled';
    } else if (appointment.status == AppointmentStatusManager.STATUS_NO_SHOW) {
      return 'No Show';
    } else if (AppointmentStatusManager.isAppointmentCompleted(appointment)) {
      return 'Completed';
    } else {
      return 'Scheduled';
    }
  }

  IconData _getStatusIcon(Appointment appointment) {
    if (appointment.status == AppointmentStatusManager.STATUS_CANCELLED || 
        appointment.status == AppointmentStatusManager.STATUS_NO_SHOW) {
      return Icons.cancel;
    } else if (AppointmentStatusManager.isAppointmentCompleted(appointment)) {
      return Icons.check_circle;
    } else {
      return Icons.schedule;
    }
  }

  String _formatTimeAgo(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'just now';
    }
  }

  String _formatTimeUntil(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'soon';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No Appointments to Review',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You don\'t have any completed appointments to review.\nAll your completed appointments have been reviewed!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Completed Appointments",
      userId: widget.userId,
      actions: [],
      child: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading completed appointments...'),
                ],
              ),
            )
          : _filteredAppointments.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadAvailableAppointmentsForReview,
                  child: ListView.builder(
                    itemCount: _filteredAppointments.length,
                    itemBuilder: (context, index) {
                      return _buildAppointmentCard(_filteredAppointments[index]);
                    },
                  ),
                ),
    );
  }
}
