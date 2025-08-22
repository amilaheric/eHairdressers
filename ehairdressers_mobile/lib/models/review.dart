import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  @JsonKey(name: 'ReviewId')
  final int? reviewId;

  @JsonKey(name: 'AppointmentId')
  final int appointmentId;

  @JsonKey(name: 'UserId')
  final int userId;

  @JsonKey(name: 'ServiceId')
  final int serviceId;

  @JsonKey(name: 'EmployeeId')
  final int employeeId;

  @JsonKey(name: 'Rate')
  final int rating; // 1-5 stars

  @JsonKey(name: 'Comment')
  final String? comment;

  @JsonKey(name: 'ReviewDate')
  final String reviewDate;

  @JsonKey(name: 'IsActive')
  final bool isActive;

  Review({
    this.reviewId,
    required this.appointmentId,
    required this.userId,
    required this.serviceId,
    required this.employeeId,
    required this.rating,
    this.comment,
    required this.reviewDate,
    this.isActive = true,
  });

  factory Review.fromJson(Map<String, dynamic> json) =>
      _$ReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}

@JsonSerializable()
class ReviewRequest {
  @JsonKey(name: 'AppointmentId')
  final int appointmentId;

  @JsonKey(name: 'UserId')
  final int userId;

  @JsonKey(name: 'ServiceId')
  final int serviceId;

  @JsonKey(name: 'EmployeeId')
  final int employeeId;

  @JsonKey(name: 'Rate')
  final int rating;

  @JsonKey(name: 'Comment')
  final String? comment;

  ReviewRequest({
    required this.appointmentId,
    required this.userId,
    required this.serviceId,
    required this.employeeId,
    required this.rating,
    this.comment,
  });

  factory ReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$ReviewRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewRequestToJson(this);
}

@JsonSerializable()
class ReviewResponse {
  @JsonKey(name: 'ReviewId')
  final int reviewId;

  @JsonKey(name: 'AppointmentId')
  final int appointmentId;

  @JsonKey(name: 'Message')
  final String message;

  @JsonKey(name: 'Success')
  final bool success;

  ReviewResponse({
    required this.reviewId,
    required this.appointmentId,
    required this.message,
    required this.success,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) =>
      _$ReviewResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewResponseToJson(this);
}
