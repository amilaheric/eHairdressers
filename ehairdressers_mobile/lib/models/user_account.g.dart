// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAccount _$UserAccountFromJson(Map<String, dynamic> json) => UserAccount(
      userId: (json['UserId'] as num).toInt(),
      username: json['Username'] as String,
      email: json['Email'] as String,
      firstName: json['Name'] as String?,
      lastName: json['Surname'] as String?,
      phoneNumber: json['Phone'] as String?,
      profileImage: json['ProfileImage'] as String?,
      totalAppointments: (json['TotalAppointments'] as num?)?.toInt() ?? 0,
      completedAppointments:
          (json['CompletedAppointments'] as num?)?.toInt() ?? 0,
      totalOrders: (json['TotalOrders'] as num?)?.toInt() ?? 0,
      completedOrders: (json['CompletedOrders'] as num?)?.toInt() ?? 0,
      totalSpent: (json['TotalSpent'] as num?)?.toDouble() ?? 0.0,
      loyaltyPoints: (json['LoyaltyPoints'] as num?)?.toInt() ?? 0,
      loyaltyTier: json['LoyaltyTier'] as String? ?? 'Bronze',
      loyaltyDiscount: (json['LoyaltyDiscount'] as num?)?.toDouble() ?? 0.0,
      memberSince: json['RegistrationDate'] as String?,
      isActive: json['IsActive'] as bool? ?? true,
      lastLoginDate: json['LastLoginDate'] as String?,
    );

Map<String, dynamic> _$UserAccountToJson(UserAccount instance) =>
    <String, dynamic>{
      'UserId': instance.userId,
      'Username': instance.username,
      'Email': instance.email,
      'Name': instance.firstName,
      'Surname': instance.lastName,
      'Phone': instance.phoneNumber,
      'ProfileImage': instance.profileImage,
      'TotalAppointments': instance.totalAppointments,
      'CompletedAppointments': instance.completedAppointments,
      'TotalOrders': instance.totalOrders,
      'CompletedOrders': instance.completedOrders,
      'TotalSpent': instance.totalSpent,
      'LoyaltyPoints': instance.loyaltyPoints,
      'LoyaltyTier': instance.loyaltyTier,
      'LoyaltyDiscount': instance.loyaltyDiscount,
      'RegistrationDate': instance.memberSince,
      'IsActive': instance.isActive,
      'LastLoginDate': instance.lastLoginDate,
    };

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
      userId: (json['UserId'] as num).toInt(),
      totalAppointments: (json['TotalAppointments'] as num?)?.toInt() ?? 0,
      completedAppointments:
          (json['CompletedAppointments'] as num?)?.toInt() ?? 0,
      cancelledAppointments:
          (json['CancelledAppointments'] as num?)?.toInt() ?? 0,
      noShowAppointments: (json['NoShowAppointments'] as num?)?.toInt() ?? 0,
      totalSpent: (json['TotalSpent'] as num?)?.toDouble() ?? 0.0,
      averageAppointmentValue:
          (json['AverageAppointmentValue'] as num?)?.toDouble() ?? 0.0,
      loyaltyPoints: (json['LoyaltyPoints'] as num?)?.toInt() ?? 0,
      loyaltyTier: json['LoyaltyTier'] as String? ?? 'Bronze',
      totalReviews: (json['TotalReviews'] as num?)?.toInt() ?? 0,
      averageRating: (json['AverageRating'] as num?)?.toDouble() ?? 0.0,
      firstAppointment: json['FirstAppointment'] as String,
      lastAppointment: json['LastAppointment'] as String,
      favoriteServiceId: (json['FavoriteServiceId'] as num?)?.toInt(),
      favoriteServiceName: json['FavoriteServiceName'] as String?,
      monthlyStatistics: (json['MonthlyStatistics'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
      'UserId': instance.userId,
      'TotalAppointments': instance.totalAppointments,
      'CompletedAppointments': instance.completedAppointments,
      'CancelledAppointments': instance.cancelledAppointments,
      'NoShowAppointments': instance.noShowAppointments,
      'TotalSpent': instance.totalSpent,
      'AverageAppointmentValue': instance.averageAppointmentValue,
      'LoyaltyPoints': instance.loyaltyPoints,
      'LoyaltyTier': instance.loyaltyTier,
      'TotalReviews': instance.totalReviews,
      'AverageRating': instance.averageRating,
      'FirstAppointment': instance.firstAppointment,
      'LastAppointment': instance.lastAppointment,
      'FavoriteServiceId': instance.favoriteServiceId,
      'FavoriteServiceName': instance.favoriteServiceName,
      'MonthlyStatistics': instance.monthlyStatistics,
    };

LoyaltyBonus _$LoyaltyBonusFromJson(Map<String, dynamic> json) => LoyaltyBonus(
      bonusId: (json['BonusId'] as num?)?.toInt(),
      userId: (json['UserId'] as num).toInt(),
      bonusType: json['BonusType'] as String,
      bonusValue: (json['BonusValue'] as num).toDouble(),
      description: json['Description'] as String,
      isRedeemed: json['IsRedeemed'] as bool? ?? false,
      expiryDate: json['ExpiryDate'] as String?,
      createdDate: json['CreatedDate'] as String,
      redeemedDate: json['RedeemedDate'] as String?,
    );

Map<String, dynamic> _$LoyaltyBonusToJson(LoyaltyBonus instance) =>
    <String, dynamic>{
      'BonusId': instance.bonusId,
      'UserId': instance.userId,
      'BonusType': instance.bonusType,
      'BonusValue': instance.bonusValue,
      'Description': instance.description,
      'IsRedeemed': instance.isRedeemed,
      'ExpiryDate': instance.expiryDate,
      'CreatedDate': instance.createdDate,
      'RedeemedDate': instance.redeemedDate,
    };
