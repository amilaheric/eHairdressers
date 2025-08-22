// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      reviewId: (json['ReviewId'] as num?)?.toInt(),
      appointmentId: (json['AppointmentId'] as num).toInt(),
      userId: (json['UserId'] as num).toInt(),
      serviceId: (json['ServiceId'] as num).toInt(),
      employeeId: (json['EmployeeId'] as num).toInt(),
      rating: (json['Rate'] as num).toInt(),
      comment: json['Comment'] as String?,
      reviewDate: json['ReviewDate'] as String,
      isActive: json['IsActive'] as bool? ?? true,
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'ReviewId': instance.reviewId,
      'AppointmentId': instance.appointmentId,
      'UserId': instance.userId,
      'ServiceId': instance.serviceId,
      'EmployeeId': instance.employeeId,
      'Rate': instance.rating,
      'Comment': instance.comment,
      'ReviewDate': instance.reviewDate,
      'IsActive': instance.isActive,
    };

ReviewRequest _$ReviewRequestFromJson(Map<String, dynamic> json) =>
    ReviewRequest(
      appointmentId: (json['AppointmentId'] as num).toInt(),
      userId: (json['UserId'] as num).toInt(),
      serviceId: (json['ServiceId'] as num).toInt(),
      employeeId: (json['EmployeeId'] as num).toInt(),
      rating: (json['Rate'] as num).toInt(),
      comment: json['Comment'] as String?,
    );

Map<String, dynamic> _$ReviewRequestToJson(ReviewRequest instance) =>
    <String, dynamic>{
      'AppointmentId': instance.appointmentId,
      'UserId': instance.userId,
      'ServiceId': instance.serviceId,
      'EmployeeId': instance.employeeId,
      'Rate': instance.rating,
      'Comment': instance.comment,
    };

ReviewResponse _$ReviewResponseFromJson(Map<String, dynamic> json) =>
    ReviewResponse(
      reviewId: (json['ReviewId'] as num).toInt(),
      appointmentId: (json['AppointmentId'] as num).toInt(),
      message: json['Message'] as String,
      success: json['Success'] as bool,
    );

Map<String, dynamic> _$ReviewResponseToJson(ReviewResponse instance) =>
    <String, dynamic>{
      'ReviewId': instance.reviewId,
      'AppointmentId': instance.appointmentId,
      'Message': instance.message,
      'Success': instance.success,
    };
