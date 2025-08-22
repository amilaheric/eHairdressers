import 'package:flutter/material.dart';
import 'package:ehairdressers_mobile/models/appointment.dart';
import 'package:ehairdressers_mobile/models/search_result.dart';
import 'package:ehairdressers_mobile/providers/appointment_provider.dart';
import 'package:ehairdressers_mobile/providers/review_provider.dart';
import 'package:ehairdressers_mobile/screens/review_screen.dart';
import 'package:ehairdressers_mobile/utils/appointment_status_manager.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AppointmentReviewOverviewScreen extends StatefulWidget {
  final int userId;

  const AppointmentReviewOverviewScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AppointmentReviewOverviewScreen> createState() => _AppointmentReviewOverviewScreenState();
}

class _AppointmentReviewOverviewScreenState extends State<AppointmentReviewOverviewScreen> {
  late AppointmentProvider _appointmentProvider;
  late ReviewProvider _reviewProvider;
  List<Appointment> _allAppointments = [];
  Map<int, bool> _appointmentReviewStatus = {};
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appointmentProvider = context.read<AppointmentProvider>();
    _reviewProvider = context.read<ReviewProvider>();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('=== LOADING AVAILABLE APPOINTMENTS FOR REVIEW ===');
      print('🚨🚨🚨 CALLING NEW REVIEW ENDPOINT 🚨🚨🚨');
      print('User ID: ${widget.userId}');
      
      // Use the new Review endpoint that only returns available appointments for review
      var appointments = await _appointmentProvider.getAvailableForReview(widget.userId);
      print('🚨🚨🚨 RECEIVED RESPONSE FROM REVIEW ENDPOINT 🚨🚨🚨');

      if (appointments?.result != null) {
        _allAppointments = appointments!.result!;
        print('Loaded ${_allAppointments.length} available appointments for review');

        // Since this endpoint only returns appointments that are available for review,
        // we can set all review statuses to false
        for (var appointment in _allAppointments) {
          _appointmentReviewStatus[appointment.id] = false;
        }
        print('Set all appointments as not reviewed (as per new Review endpoint)');
      } else {
        print('No available appointments for review returned from API');
        _allAppointments = [];
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading available appointments for review: $e');
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
    print('Navigating to review for appointment ${appointment.id}');
    
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
    
    // If a review was submitted, reload the appointments
    if (result == true) {
      print('Review was submitted, reloading appointments...');
      await _loadAppointments();
    }
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          SizedBox(width: 8),
          _buildFilterChip('Completed', 'completed'),
          SizedBox(width: 8),
          _buildFilterChip('Upcoming', 'upcoming'),
          SizedBox(width: 8),
          _buildFilterChip('Review Available', 'reviewable'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue,
    );
  }

  List<Appointment> get _filteredAppointments {
    switch (_selectedFilter) {
      case 'completed':
        return _allAppointments.where((appointment) => 
          AppointmentStatusManager.isAppointmentCompleted(appointment)).toList();
      case 'upcoming':
        return []; // New endpoint only returns reviewable appointments, so no upcoming
      case 'reviewable':
        return _allAppointments; // All appointments from new endpoint are reviewable
      default:
        return _allAppointments;
    }
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    var appointmentDate = AppointmentStatusManager.parseAppointmentDate(appointment.appointmentDate) ?? DateTime.now();
    var reviewStatus = _getReviewAvailabilityStatus(appointment, false);
    var timeSinceCompletion = AppointmentStatusManager.getTimeSinceCompletion(appointment);
    
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
            
            // Review status information
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
                        _getReviewStatusIcon(appointment, false),
                        size: 16,
                        color: _getReviewStatusColor(appointment, false),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reviewStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getReviewStatusColor(appointment, false),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (timeSinceCompletion != null) ...[
                    SizedBox(height: 4),
                    Text(
                      'Completed ${_formatTimeAgo(timeSinceCompletion)} ago',
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
              onPressed: () => _navigateToReview(appointment),
              icon: Icon(Icons.rate_review),
              label: Text('Leave Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReviewAvailabilityStatus(Appointment appointment, bool hasUserReviewed) {
    if (hasUserReviewed) {
      return 'Review Submitted';
    } else {
      return 'Review Available';
    }
  }

  Color _getReviewStatusColor(Appointment appointment, bool hasUserReviewed) {
    if (hasUserReviewed) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  Color _getReviewStatusTextColor(Appointment appointment, bool hasUserReviewed) {
    if (hasUserReviewed) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  IconData _getReviewStatusIcon(Appointment appointment, bool hasUserReviewed) {
    if (hasUserReviewed) {
      return Icons.check_circle;
    } else {
      return Icons.rate_review;
    }
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
            'No Appointments Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _selectedFilter == 'reviewable' 
                ? 'You don\'t have any appointments available for review.\nAll your completed appointments have been reviewed!'
                : 'No appointments found for the selected filter.',
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
      title: "All Appointments",
      userId: widget.userId,
      actions: [],
      child: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading appointments...'),
                      ],
                    ),
                  )
                : _filteredAppointments.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadAppointments,
                        child: ListView.builder(
                          itemCount: _filteredAppointments.length,
                          itemBuilder: (context, index) {
                            return _buildAppointmentCard(_filteredAppointments[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
