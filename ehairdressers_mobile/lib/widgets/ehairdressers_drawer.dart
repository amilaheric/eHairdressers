import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehairdressers_mobile/main.dart';
import 'package:ehairdressers_mobile/providers/user_account_provider.dart';
import 'package:ehairdressers_mobile/screens/product_list_screen.dart';
import 'package:ehairdressers_mobile/screens/cart_screen.dart';
import 'package:ehairdressers_mobile/screens/appointment_screen.dart';
import 'package:ehairdressers_mobile/screens/completed_appointments_screen.dart';
import 'package:ehairdressers_mobile/screens/appointment_review_overview_screen.dart';
import 'package:ehairdressers_mobile/screens/chat_list_screen.dart';
import 'package:ehairdressers_mobile/screens/user_account_screen.dart';

class EHairdressersDrawer extends StatelessWidget {
  final int userId;

  const EHairdressersDrawer({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'eHairdressers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'User ID: $userId',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductListScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Cart'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Book Appointment'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.rate_review),
            title: Text('Review Appointments'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompletedAppointmentsScreen(userId: userId),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list_alt),
            title: Text('All Appointments'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentReviewOverviewScreen(userId: userId),
                  ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text('Live Chat'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatListScreen(userId: userId),
                ),
              );
            },
          ),
          
          
          Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 32,
          ),
          
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'ACCOUNT & SETTINGS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          
          ListTile(
            leading: Icon(Icons.person, color: Colors.orange),
            title: Text(
              'My Account',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Profile, loyalty & achievements'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserAccountScreen(userId: userId),
                ),
              );
            },
          ),
          
          
          ListTile(
            leading: Icon(Icons.settings, color: Colors.grey[600]),
            title: Text('Settings'),
            subtitle: Text('App preferences & notifications'),
            onTap: () {
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Settings coming soon!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
          
          ListTile(
            leading: Icon(Icons.help_outline, color: Colors.grey[600]),
            title: Text('Help & Support'),
            subtitle: Text('FAQ, contact & troubleshooting'),
            onTap: () {
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Help & Support coming soon!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
          
          
          Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 32,
          ),
          
          
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red[600]),
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.red[600]),
            ),
            onTap: () async {
              Navigator.pop(context);

              // Asks the server to revoke this token (jti) and always
              // clears the local session too, even if the server call
              // fails - see UserAccountProvider.logout.
              final userAccountProvider = context.read<UserAccountProvider>();
              await userAccountProvider.logout(userId);

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => MyHomePage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
