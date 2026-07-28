import 'package:flutter/material.dart';
import 'package:ehairdressers_mobile/models/user_account.dart';
import 'package:ehairdressers_mobile/providers/user_account_provider.dart';
import 'package:ehairdressers_mobile/screens/order_history_screen.dart';
import 'package:ehairdressers_mobile/screens/user_appointments_screen.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class UserAccountScreen extends StatefulWidget {
  final int userId;

  const UserAccountScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  late UserAccountProvider _userAccountProvider;
  
  UserAccount? _userAccount;
  List<LoyaltyBonus> _loyaltyBonuses = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userAccountProvider = context.read<UserAccountProvider>();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

     
      final comprehensiveData = await _userAccountProvider.getComprehensiveUserData(widget.userId);
      
      if (comprehensiveData['success'] == true) {
        setState(() {
          _userAccount = comprehensiveData['userAccount'] as UserAccount?;
          _loyaltyBonuses = comprehensiveData['loyaltyBonuses'] as List<LoyaltyBonus>;
          _isLoading = false;
        });
        
       
        if (_userAccount != null) {
          print('=== USER ACCOUNT DATA ===');
          print('Total Appointments: ${_userAccount!.totalAppointments}');
          print('Completed Appointments: ${_userAccount!.completedAppointments}');
          print('Total Orders: ${_userAccount!.totalOrders}');
          print('Completed Orders: ${_userAccount!.completedOrders}');
          print('Total Spent: ${_userAccount!.totalSpent}');
          print('Loyalty Points: ${_userAccount!.loyaltyPoints}');
          print('Loyalty Tier: ${_userAccount!.loyaltyTier}');
          print('Loyalty Discount: ${_userAccount!.loyaltyDiscount}');
        }
      } else {
       
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
     
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: 'My Account',
      userId: widget.userId,
      showFloatingChat: true,
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userAccount == null
              ? _buildErrorState()
              : _buildAccountContent(),
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
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Failed to load account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadUserData,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          _buildProfileHeader(),
          
          SizedBox(height: 24),
          
         
          _buildQuickStats(),
          
          SizedBox(height: 24),
          
         
          _buildOrdersSection(),
          
          SizedBox(height: 24),
          
         
          _buildAppointmentsSection(),
          
          SizedBox(height: 24),
          
         
          _buildLoyaltySection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
           
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.orange.shade100,
              child: Icon(Icons.person, size: 30, color: Colors.orange),
            ),
            
            SizedBox(width: 16),
            
           
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userAccount!.displayName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _userAccount!.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_userAccount!.loyaltyTier} Member',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Logout button
            IconButton(
              onPressed: _showLogoutDialog,
              icon: Icon(
                Icons.logout,
                color: Colors.red[600],
                size: 24,
              ),
              tooltip: 'Logout',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Appointments',
            '${_userAccount!.totalAppointments}',
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Orders',
            '${_userAccount!.totalOrders}',
            Icons.shopping_bag,
            Colors.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Points',
            '${_userAccount!.loyaltyPoints}',
            Icons.stars,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersSection() {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OrderHistoryScreen(
                userId: widget.userId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_bag, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'My Orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'Total Orders: ${_userAccount!.totalOrders}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'Total Spent: \$${_userAccount!.totalSpent.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              if (_userAccount!.loyaltyDiscount > 0) ...[
                SizedBox(height: 4),
                Text(
                  'Discount: ${_userAccount!.loyaltyDiscount.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
              SizedBox(height: 8),
              Text(
                'Tap to view order history',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserAppointmentsScreen(
                userId: widget.userId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'My Appointments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'Total Appointments: ${_userAccount!.totalAppointments}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              if (_userAccount!.memberSince != null) ...[
                SizedBox(height: 8),
                Text(
                  'Member since: ${DateFormat('MMM yyyy').format(DateTime.parse(_userAccount!.memberSince!))}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
              SizedBox(height: 8),
              Text(
                'Tap to view all appointments',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoyaltySection() {
    final nextTierInfo = _userAccount!.getNextTierInfo();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stars, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Loyalty Program',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Tier: ${_userAccount!.loyaltyTier}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4),
                                  Text(
              'Points: ${_userAccount!.loyaltyPoints}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'Discount: ${_userAccount!.loyaltyDiscount.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 14, color: Colors.green),
            ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_loyaltyBonuses.where((b) => b.isAvailable).length} Bonuses',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
            if (nextTierInfo['pointsNeeded'] > 0) ...[
              SizedBox(height: 12),
              Text(
                'Progress to ${nextTierInfo['nextTier']}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              LinearProgressIndicator(
                value: _userAccount!.loyaltyPoints / (nextTierInfo['pointsNeeded'] + _userAccount!.loyaltyPoints),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              SizedBox(height: 4),
              Text(
                '${nextTierInfo['pointsNeeded']} more points needed',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            if (_loyaltyBonuses.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Available Bonuses:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              ..._loyaltyBonuses
                  .where((bonus) => bonus.isAvailable)
                  .take(3) 
                  .map((bonus) => Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.card_giftcard, size: 16, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            bonus.description,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        if (bonus.bonusValue > 0)
                          Text(
                            '${bonus.bonusValue.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                      ],
                    ),
                  )),
            ],

          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: Colors.red[600],
                size: 24,
              ),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          content: Text(
            'Are you sure you want to logout? You will need to sign in again to access your account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: _performLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout() async {
    try {
      // Close the dialog
      Navigator.of(context).pop();
      
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

      // Call backend logout API
      final logoutResult = await _userAccountProvider.logout(widget.userId);
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      if (logoutResult == true) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully logged out'),
            backgroundColor: Colors.green[600],
            duration: Duration(seconds: 2),
          ),
        );
        
        // Clear local user data (if any)
        // You might want to clear stored tokens, user preferences, etc.
        
        // Navigate back to login screen or main screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/', // Replace with your actual login route
          (route) => false, // This removes all previous routes
        );
      } else {
        throw Exception('Logout failed on server');
      }
      
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during logout: $e'),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showLoyaltyTierInfo(Map<String, dynamic> tierInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${tierInfo['currentTier']} Tier Benefits'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Points: ${tierInfo['currentPoints']}',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                if (tierInfo['tierBenefits'] != null) ...[
                  Text(
                    'Current Benefits:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  ...(tierInfo['tierBenefits']['benefits'] as List<dynamic>? ?? [])
                      .map((benefit) => Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Colors.green),
                            SizedBox(width: 8),
                            Expanded(child: Text(benefit.toString())),
                          ],
                        ),
                      )),
                ],
                SizedBox(height: 12),
                if (tierInfo['nextTierInfo']['pointsNeeded'] > 0) ...[
                  Text(
                    'Next Tier: ${tierInfo['nextTierInfo']['nextTier']}',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text('Points needed: ${tierInfo['nextTierInfo']['pointsNeeded']}'),
                  SizedBox(height: 8),
                  Text('Benefits:'),
                  ...(tierInfo['nextTierInfo']['benefits'] as List<dynamic>)
                      .map((benefit) => Padding(
                        padding: EdgeInsets.only(bottom: 4, left: 16),
                        child: Text('• $benefit'),
                      )),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }


}
