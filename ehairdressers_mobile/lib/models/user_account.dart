import 'package:json_annotation/json_annotation.dart';

part 'user_account.g.dart';

@JsonSerializable()
class UserAccount {
  @JsonKey(name: 'UserId')
  final int userId;

  @JsonKey(name: 'Username')
  final String username;

  @JsonKey(name: 'Email')
  final String email;

  @JsonKey(name: 'Name')
  final String? firstName;

  @JsonKey(name: 'Surname')
  final String? lastName;

  @JsonKey(name: 'Phone')
  final String? phoneNumber;

  @JsonKey(name: 'ProfileImage')
  final String? profileImage;

  @JsonKey(name: 'TotalAppointments')
  final int totalAppointments;

  @JsonKey(name: 'CompletedAppointments')
  final int completedAppointments;

  @JsonKey(name: 'TotalOrders')
  final int totalOrders;

  @JsonKey(name: 'CompletedOrders')
  final int completedOrders;

  @JsonKey(name: 'TotalSpent')
  final double totalSpent;

  @JsonKey(name: 'LoyaltyPoints')
  final int loyaltyPoints;

  @JsonKey(name: 'LoyaltyTier')
  final String loyaltyTier;

  @JsonKey(name: 'LoyaltyDiscount')
  final double loyaltyDiscount;

  @JsonKey(name: 'RegistrationDate')
  final String? memberSince;

  @JsonKey(name: 'IsActive')
  final bool isActive;

  @JsonKey(name: 'LastLoginDate')
  final String? lastLoginDate;

  UserAccount({
    required this.userId,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profileImage,
    this.totalAppointments = 0,
    this.completedAppointments = 0,
    this.totalOrders = 0,
    this.completedOrders = 0,
    this.totalSpent = 0.0,
    this.loyaltyPoints = 0,
    this.loyaltyTier = 'Bronze',
    this.loyaltyDiscount = 0.0,
    this.memberSince,
    this.isActive = true,
    this.lastLoginDate,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) => _$UserAccountFromJson(json);
  Map<String, dynamic> toJson() => _$UserAccountToJson(this);

  // Getter for full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return username;
    }
  }

  // Getter for display name
  String get displayName => fullName;

  // Calculate loyalty tier based on points
  String calculateLoyaltyTier() {
    if (loyaltyPoints >= 1000) return 'Diamond';
    if (loyaltyPoints >= 500) return 'Platinum';
    if (loyaltyPoints >= 200) return 'Gold';
    if (loyaltyPoints >= 50) return 'Silver';
    return 'Bronze';
  }

  // Get next tier requirements
  Map<String, dynamic> getNextTierInfo() {
    switch (loyaltyTier) {
      case 'Bronze':
        return {
          'nextTier': 'Silver',
          'pointsNeeded': 50 - loyaltyPoints,
          'benefits': ['5% discount on services', 'Priority booking']
        };
      case 'Silver':
        return {
          'nextTier': 'Gold',
          'pointsNeeded': 200 - loyaltyPoints,
          'benefits': ['10% discount on services', 'Free consultation']
        };
      case 'Gold':
        return {
          'nextTier': 'Platinum',
          'pointsNeeded': 500 - loyaltyPoints,
          'benefits': ['15% discount on services', 'Free styling session']
        };
      case 'Platinum':
        return {
          'nextTier': 'Diamond',
          'pointsNeeded': 1000 - loyaltyPoints,
          'benefits': ['20% discount on services', 'VIP treatment']
        };
      default:
        return {
          'nextTier': 'Diamond',
          'pointsNeeded': 0,
          'benefits': ['Maximum benefits achieved']
        };
    }
  }
}

@JsonSerializable()
class UserStats {
  @JsonKey(name: 'UserId')
  final int userId;

  @JsonKey(name: 'TotalAppointments')
  final int totalAppointments;

  @JsonKey(name: 'CompletedAppointments')
  final int completedAppointments;

  @JsonKey(name: 'CancelledAppointments')
  final int cancelledAppointments;

  @JsonKey(name: 'NoShowAppointments')
  final int noShowAppointments;

  @JsonKey(name: 'TotalSpent')
  final double totalSpent;

  @JsonKey(name: 'AverageAppointmentValue')
  final double averageAppointmentValue;

  @JsonKey(name: 'LoyaltyPoints')
  final int loyaltyPoints;

  @JsonKey(name: 'LoyaltyTier')
  final String loyaltyTier;

  @JsonKey(name: 'TotalReviews')
  final int totalReviews;

  @JsonKey(name: 'AverageRating')
  final double averageRating;

  @JsonKey(name: 'FirstAppointment')
  final String firstAppointment;

  @JsonKey(name: 'LastAppointment')
  final String lastAppointment;

  @JsonKey(name: 'FavoriteServiceId')
  final int? favoriteServiceId;

  @JsonKey(name: 'FavoriteServiceName')
  final String? favoriteServiceName;

  @JsonKey(name: 'MonthlyStatistics')
  final List<Map<String, dynamic>> monthlyStatistics;

  UserStats({
    required this.userId,
    this.totalAppointments = 0,
    this.completedAppointments = 0,
    this.cancelledAppointments = 0,
    this.noShowAppointments = 0,
    this.totalSpent = 0.0,
    this.averageAppointmentValue = 0.0,
    this.loyaltyPoints = 0,
    this.loyaltyTier = 'Bronze',
    this.totalReviews = 0,
    this.averageRating = 0.0,
    required this.firstAppointment,
    required this.lastAppointment,
    this.favoriteServiceId,
    this.favoriteServiceName,
    this.monthlyStatistics = const [],
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => _$UserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsToJson(this);

  // Calculate completion rate
  double get appointmentCompletionRate {
    if (totalAppointments == 0) return 0.0;
    return (completedAppointments / totalAppointments) * 100;
  }

  // Calculate cancellation rate
  double get cancellationRate {
    if (totalAppointments == 0) return 0.0;
    return (cancelledAppointments / totalAppointments) * 100;
  }

  // Calculate no-show rate
  double get noShowRate {
    if (totalAppointments == 0) return 0.0;
    return (noShowAppointments / totalAppointments) * 100;
  }

  // Get member duration in months
  int get memberDurationMonths {
    try {
      final firstDate = DateTime.parse(firstAppointment);
      final now = DateTime.now();
      return ((now.year - firstDate.year) * 12) + (now.month - firstDate.month);
    } catch (e) {
      return 0;
    }
  }

  // Get favorite service name
  String get favoriteServiceDisplay {
    return favoriteServiceName ?? 'No favorite service';
  }
}

@JsonSerializable()
class LoyaltyBonus {
  @JsonKey(name: 'BonusId')
  final int? bonusId;

  @JsonKey(name: 'UserId')
  final int userId;

  @JsonKey(name: 'BonusType')
  final String bonusType; // 'Discount', 'FreeService', 'Points'

  @JsonKey(name: 'BonusValue')
  final double bonusValue;

  @JsonKey(name: 'Description')
  final String description;

  @JsonKey(name: 'IsRedeemed')
  final bool isRedeemed;

  @JsonKey(name: 'ExpiryDate')
  final String? expiryDate;

  @JsonKey(name: 'CreatedDate')
  final String createdDate;

  @JsonKey(name: 'RedeemedDate')
  final String? redeemedDate;

  LoyaltyBonus({
    this.bonusId,
    required this.userId,
    required this.bonusType,
    required this.bonusValue,
    required this.description,
    this.isRedeemed = false,
    this.expiryDate,
    required this.createdDate,
    this.redeemedDate,
  });

  factory LoyaltyBonus.fromJson(Map<String, dynamic> json) => _$LoyaltyBonusFromJson(json);
  Map<String, dynamic> toJson() => _$LoyaltyBonusToJson(this);

  // Check if bonus is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    try {
      final expiry = DateTime.parse(expiryDate!);
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return false;
    }
  }

  // Check if bonus is available for redemption
  bool get isAvailable => !isRedeemed && !isExpired;
}
