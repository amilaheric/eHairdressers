import 'dart:convert';
import 'package:ehairdressers_mobile/models/user_account.dart';
import 'package:ehairdressers_mobile/models/search_result.dart';
import 'package:ehairdressers_mobile/providers/base_provider.dart';
import 'package:ehairdressers_mobile/utils/util.dart';

class UserAccountProvider extends BaseProvider<UserAccount> {
  UserAccountProvider() : super('UserAccount');

  Future<UserAccount?> getUserAccount(int userId) async {
    try {
      print('=== GETTING USER ACCOUNT ===');
      print('User ID: $userId');

      var response = await http!.get(
        Uri.parse('${baseUrl}api/UserAccount/$userId'),
        headers: createHeaders(),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          var userAccount = UserAccount.fromJson(jsonData['data']);
          print('User account loaded successfully: ${userAccount.displayName}');
          return userAccount;
        } else {
          print('API returned success: false or no data');
          return null;
        }
      } else {
        print('Failed to get user account: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting user account: $e');
      return null;
    }
  }

  Future<UserStats?> getUserStats(int userId) async {
    try {
      print('=== GETTING USER STATS ===');
      print('User ID: $userId');

      var response = await http!.get(
        Uri.parse('${baseUrl}api/UserAccount/Stats/$userId'),
        headers: createHeaders(),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          var userStats = UserStats.fromJson(jsonData['data']);
          print('User stats loaded successfully');
          return userStats;
        } else {
          print('API returned success: false or no data');
          return null;
        }
      } else {
        print('Failed to get user stats: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting user stats: $e');
      return null;
    }
  }

  Future<List<LoyaltyBonus>> getUserLoyaltyBonuses(int userId) async {
    try {
      print('=== GETTING USER LOYALTY BONUSES ===');
      print('User ID: $userId');

      var response = await http!.get(
        Uri.parse(
            '${baseUrl}api/UserAccount/LoyaltyBonuses/$userId'),
        headers: createHeaders(),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        var bonuses = <LoyaltyBonus>[];

        if (jsonData['success'] == true && jsonData['data'] != null) {
          if (jsonData['data'] is List) {
            bonuses = (jsonData['data'] as List)
                .map((json) => LoyaltyBonus.fromJson(json))
                .toList();
          }
        } else if (jsonData is List) {
          bonuses =
              jsonData.map((json) => LoyaltyBonus.fromJson(json)).toList();
        } else if (jsonData['result'] != null) {
          bonuses = (jsonData['result'] as List)
              .map((json) => LoyaltyBonus.fromJson(json))
              .toList();
        }

        print('Found ${bonuses.length} loyalty bonuses');
        return bonuses;
      } else {
        print('Failed to get loyalty bonuses: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting loyalty bonuses: $e');
      return [];
    }
  }

  Future<bool> updateUserProfile(UserAccount userAccount) async {
    try {
      print('=== UPDATING USER PROFILE ===');
      print('User ID: ${userAccount.userId}');

      var response = await http!.put(
        Uri.parse('${baseUrl}api/UserAccount/${userAccount.userId}'),
        headers: createHeaders(),
        body: json.encode(userAccount.toJson()),
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('User profile updated successfully');
        return true;
      } else {
        print('Failed to update user profile: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  Future<int> calculateLoyaltyPoints(double orderAmount) async {
    try {
      print('=== CALCULATING LOYALTY POINTS ===');
      print('Order Amount: $orderAmount');

      var requestBody = {
        'orderAmount': orderAmount,
        'userId': Authorization.currentUserId,
      };

      var response = await http!.post(
        Uri.parse('${baseUrl}api/UserAccount/CalculatePoints'),
        headers: createHeaders(),
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        var points = 0;
        if (jsonData['success'] == true && jsonData['data'] != null) {
          points = jsonData['data']['points'] ?? jsonData['data'] ?? 0;
        } else if (jsonData['points'] != null) {
          points = jsonData['points'];
        } else if (jsonData['data'] != null) {
          points = jsonData['data'];
        }

        print('Calculated loyalty points: $points');
        return points;
      } else {
        print('Failed to calculate loyalty points: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error calculating loyalty points: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>?> getLoyaltyDiscount(int userId) async {
    try {
      print('=== GETTING LOYALTY DISCOUNT ===');
      print('User ID: $userId');

      var response = await http!.get(
        Uri.parse(
            '${baseUrl}api/UserAccount/LoyaltyDiscount/$userId'),
        headers: createHeaders(),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        Map<String, dynamic> discountData = {};
        if (jsonData['success'] == true && jsonData['data'] != null) {
          discountData = Map<String, dynamic>.from(jsonData['data']);
        } else if (jsonData is Map<String, dynamic>) {
          discountData = jsonData;
        }

        print('Loyalty discount loaded successfully');
        return discountData;
      } else {
        print('Failed to get loyalty discount: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting loyalty discount: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> redeemLoyaltyBonus(
      int bonusId, int userId) async {
    try {
      print('=== REDEEMING LOYALTY BONUS ===');
      print('Bonus ID: $bonusId, User ID: $userId');

      var response = await http!.put(
        Uri.parse(
            '${baseUrl}api/UserAccount/RedeemBonus/$bonusId/$userId'),
        headers: createHeaders(),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        print('Loyalty bonus redeemed successfully');
        return {
          'success': true,
          'message': 'Bonus redeemed successfully',
          'data': jsonData
        };
      } else {
        print('Failed to redeem loyalty bonus: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to redeem bonus',
          'error': response.body
        };
      }
    } catch (e) {
      print('Error redeeming loyalty bonus: $e');
      return {
        'success': false,
        'message': 'Error redeeming bonus',
        'error': e.toString()
      };
    }
  }

  Future<List<Map<String, dynamic>>> getUserAchievements(int userId) async {
    try {
      print('=== GETTING USER ACHIEVEMENTS ===');
      print('User ID: $userId');

      var response = await http!.get(
        Uri.parse('${baseUrl}api/UserAccount/Achievements/$userId'),
        headers: createHeaders(),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        var achievements = <Map<String, dynamic>>[];

        if (jsonData['success'] == true && jsonData['data'] != null) {
          if (jsonData['data'] is List) {
            achievements = List<Map<String, dynamic>>.from(jsonData['data']);
          }
        } else if (jsonData is List) {
          achievements = List<Map<String, dynamic>>.from(jsonData);
        } else if (jsonData['result'] != null) {
          achievements = List<Map<String, dynamic>>.from(jsonData['result']);
        }

        print('Found ${achievements.length} achievements');
        return achievements;
      } else {
        print('Failed to get user achievements: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting user achievements: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getLoyaltyTierBenefits(String tier) async {
    try {
      print('=== GETTING LOYALTY TIER BENEFITS ===');
      print('Tier: $tier');

      var response = await http!.get(
        Uri.parse('${baseUrl}api/UserAccount/LoyaltyBenefits/$tier'),
        headers: createHeaders(),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        print('Loyalty tier benefits loaded successfully');
        return jsonData;
      } else {
        print('Failed to get loyalty tier benefits: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting loyalty tier benefits: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserReferralInfo(int userId) async {
    try {
      print('=== GETTING USER REFERRAL INFO ===');
      print('User ID: $userId');

      var response = await http!.get(
        Uri.parse('${baseUrl}api/UserAccount/ReferralInfo/$userId'),
        headers: createHeaders(),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        print('User referral info loaded successfully');
        return jsonData;
      } else {
        print('Failed to get user referral info: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting user referral info: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getComprehensiveUserData(int userId) async {
    try {
      print('=== GETTING COMPREHENSIVE USER DATA ===');
      print('User ID: $userId');

      final results = await Future.wait([
        getUserAccount(userId),
        getUserStats(userId),
        getUserLoyaltyBonuses(userId),
        getLoyaltyDiscount(userId),
      ]);

      var userAccount = results[0] as UserAccount?;
      var userStats = results[1] as UserStats?;
      var loyaltyBonuses = results[2] as List<LoyaltyBonus>;
      var loyaltyDiscount = results[3] as Map<String, dynamic>?;

      return {
        'success': true,
        'userAccount': userAccount,
        'userStats': userStats,
        'loyaltyBonuses': loyaltyBonuses,
        'loyaltyDiscount': loyaltyDiscount,
      };
    } catch (e) {
      print('Error getting comprehensive user data: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>?> getLoyaltyTierInfo(int userId) async {
    try {
      print('=== GETTING LOYALTY TIER INFO ===');
      print('User ID: $userId');

      var userAccount = await getUserAccount(userId);
      if (userAccount == null) {
        print('Could not get user account for tier info');
        return null;
      }

      var tierBenefits = await getLoyaltyTierBenefits(userAccount.loyaltyTier);

      var loyaltyDiscount = await getLoyaltyDiscount(userId);

      return {
        'currentTier': userAccount.loyaltyTier,
        'currentPoints': userAccount.loyaltyPoints,
        'tierBenefits': tierBenefits,
        'loyaltyDiscount': loyaltyDiscount,
        'nextTierInfo': userAccount.getNextTierInfo(),
      };
    } catch (e) {
      print('Error getting loyalty tier info: $e');
      return null;
    }
  }

  Future<bool> logout(int userId) async {
    var serverRevoked = false;

    try {
      final uri = Uri.parse('${baseUrl}User/logout');
      final response = await http!.post(uri, headers: createHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        serverRevoked = data['success'] == true;
      }
    } catch (_) {}

    Authorization.clear();
    return serverRevoked;
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      print('=== GETTING CURRENT USER ===');

      var response = await http!.get(
        Uri.parse('${baseUrl}User/current-user'),
        headers: createHeaders(),
      );

      print('Current user response status: ${response.statusCode}');
      print('Current user response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        print('✅ Current user info loaded successfully');
        return jsonData;
      } else {
        print('❌ Failed to get current user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }
}
