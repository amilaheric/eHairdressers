
import 'package:ehairdressers_mobile/screens/appointment_screen.dart';
import 'package:ehairdressers_mobile/screens/cart_screen.dart';
import 'package:ehairdressers_mobile/screens/completed_appointments_screen.dart';
import 'package:ehairdressers_mobile/screens/product_list_screen.dart';
import 'package:ehairdressers_mobile/screens/user_account_screen.dart';
import 'package:ehairdressers_mobile/utils/util.dart';
import 'package:ehairdressers_mobile/widgets/floating_chat_bubble.dart';

import 'package:flutter/material.dart';

class MasterScreenWidget extends StatefulWidget {
  Widget? child;
  String? title;
  List<Widget>? actions;
  int? userId;
  bool showFloatingChat;
  MasterScreenWidget({
    this.child, 
    this.title, 
    this.actions, 
    this.userId,
    this.showFloatingChat = true,
    Key? key
  }) : super(key: key);

  @override
  State<MasterScreenWidget> createState() => _MasterScreenWidgetState();
}

class _MasterScreenWidgetState extends State<MasterScreenWidget> {
  int currentIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
    if (currentIndex == 0) {
      
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => ProductListScreen()));
    } else if (currentIndex == 1) {
      
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => CartScreen()));
    } else if (currentIndex == 2) {
      
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => AppointmentScreen()));
    } else if (currentIndex == 3) {
      
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => CompletedAppointmentsScreen(userId: widget.userId ?? 1)));
    } else if (currentIndex == 4) {
          
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => UserAccountScreen(userId: widget.userId ?? 1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? "",
            style: TextStyle(color: Color(0x0FFe5c89d))),
        backgroundColor: Color(0x0FF13414b),
        actions: widget.actions,
      ),
      body: Stack(
        children: [
          SafeArea(child: widget.child!),
          if (widget.showFloatingChat && widget.userId != null)
            FloatingChatBubble(userId: widget.userId!),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_view_month), label: 'Appointment'),
          BottomNavigationBarItem(icon: Icon(Icons.reviews), label: 'Reviews'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        selectedItemColor: Color(0x0FFe5c89d),
        currentIndex: currentIndex,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
