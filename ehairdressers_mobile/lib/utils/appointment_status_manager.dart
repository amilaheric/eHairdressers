import 'package:ehairdressers_mobile/models/appointment.dart';
import 'package:flutter/material.dart';

class AppointmentStatusManager {
  static const String STATUS_SCHEDULED = 'Scheduled';
  static const String STATUS_IN_PROGRESS = 'In Progress';
  static const String STATUS_COMPLETED = 'Completed';
  static const String STATUS_CANCELLED = 'Cancelled';
  static const String STATUS_NO_SHOW = 'No Show';


  static bool isAppointmentCompleted(Appointment appointment) {

    if (appointment.status == STATUS_CANCELLED || 
        appointment.status == STATUS_NO_SHOW) {
      return false;
    }
    

    if (appointment.status == STATUS_COMPLETED) {
      return true;
    }
    

    return _isAppointmentTimePassed(appointment);
  }


  static bool _isAppointmentTimePassed(Appointment appointment) {
    try {
      var appointmentDate = parseAppointmentDate(appointment.appointmentDate);
      var appointmentTime = _parseTimeString(appointment.appointmentTime);
      
      if (appointmentDate == null || appointmentTime == null) {

        return false;
      }
      
      var appointmentDateTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        appointmentTime.hour,
        appointmentTime.minute,
      );
      
      var completionTime = appointmentDateTime.add(Duration(minutes: appointment.duration ?? 60));
      var currentTime = DateTime.now();
      
      
      
      return currentTime.isAfter(completionTime);
    } catch (e) {
      
      return false;
    }
  }


  static DateTime? parseAppointmentDate(String dateString) {
    try {

      if (dateString.contains('/')) {
        var parts = dateString.split(' ');
        if (parts.length >= 1) {
          var datePart = parts[0]; // "7/22/2025"
          var dateComponents = datePart.split('/');
          if (dateComponents.length == 3) {
            var month = int.parse(dateComponents[0]);
            var day = int.parse(dateComponents[1]);
            var year = int.parse(dateComponents[2]);
            return DateTime(year, month, day);
          }
        }
      }
      

      return DateTime.parse(dateString);
    } catch (e) {
      
      return null;
    }
  }


  static TimeOfDay? _parseTimeString(String timeString) {
    try {
      var parts = timeString.split(':');
      if (parts.length >= 2) {
        var hour = int.parse(parts[0]);
        var minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      
    }
    return null;
  }


  static DateTime? getEstimatedCompletionTime(Appointment appointment) {
    try {
      var appointmentDate = parseAppointmentDate(appointment.appointmentDate);
      var appointmentTime = _parseTimeString(appointment.appointmentTime);
      
      if (appointmentDate == null || appointmentTime == null) return null;
      
      var appointmentDateTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        appointmentTime.hour,
        appointmentTime.minute,
      );
      
      return appointmentDateTime.add(Duration(minutes: appointment.duration ?? 60));
    } catch (e) {

      return null;
    }
  }


  static Duration? getTimeSinceCompletion(Appointment appointment) {
    if (!isAppointmentCompleted(appointment)) return null;
    
    var completionTime = getEstimatedCompletionTime(appointment);
    if (completionTime == null) return null;
    
    var currentTime = DateTime.now();
    return currentTime.difference(completionTime);
  }


  static Duration? getTimeUntilCompletion(Appointment appointment) {
    if (isAppointmentCompleted(appointment)) return null;
    
    var completionTime = getEstimatedCompletionTime(appointment);
    if (completionTime == null) return null;
    
    var currentTime = DateTime.now();
    return completionTime.difference(currentTime);
  }


  static bool canSubmitReview(Appointment appointment) {
    return isAppointmentCompleted(appointment);
  }


  static bool canSubmitReviewWithProvider(Appointment appointment, bool hasUserReviewed) {
    return isAppointmentCompleted(appointment) && !hasUserReviewed;
  }


  static String getReviewAvailabilityStatus(Appointment appointment) {
    if (appointment.status == AppointmentStatusManager.STATUS_CANCELLED || 
        appointment.status == AppointmentStatusManager.STATUS_NO_SHOW) {
      return 'Review not available - Appointment cancelled';
    }
    
    if (isAppointmentCompleted(appointment)) {
      var timeSince = getTimeSinceCompletion(appointment);
      if (timeSince != null) {
        if (timeSince.inDays > 30) {
          return 'Review available (completed ${timeSince.inDays} days ago)';
        } else if (timeSince.inHours > 24) {
          return 'Review available (completed ${timeSince.inDays} days ago)';
        } else if (timeSince.inHours > 0) {
          return 'Review available (completed ${timeSince.inHours} hours ago)';
        } else if (timeSince.inMinutes > 0) {
          return 'Review available (completed ${timeSince.inMinutes} minutes ago)';
        } else {
          return 'Review available (just completed)';
        }
      }
      return 'Review available';
    } else {
      var timeUntil = getTimeUntilCompletion(appointment);
      if (timeUntil != null) {
        if (timeUntil.inDays > 0) {
          return 'Review available in ${timeUntil.inDays} days';
        } else if (timeUntil.inHours > 0) {
          return 'Review available in ${timeUntil.inHours} hours';
        } else if (timeUntil.inMinutes > 0) {
          return 'Review available in ${timeUntil.inMinutes} minutes';
        } else {
          return 'Review available soon';
        }
      }
      return 'Review not available yet';
    }
  }

    
  static String getStatusDescription(String status) {
    switch (status) {
      case STATUS_SCHEDULED:
        return 'Scheduled';
      case STATUS_IN_PROGRESS:
        return 'In Progress';
      case STATUS_COMPLETED:
        return 'Completed';
      case STATUS_CANCELLED:
        return 'Cancelled';
      case STATUS_NO_SHOW:
        return 'No Show';
      default:
        return 'Unknown';
    }
  }
}
