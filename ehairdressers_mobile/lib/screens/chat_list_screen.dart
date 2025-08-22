import 'package:flutter/material.dart';
import 'package:ehairdressers_mobile/models/chat.dart';
import 'package:ehairdressers_mobile/providers/chat_provider.dart';
import 'package:ehairdressers_mobile/screens/chat_screen.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:ehairdressers_mobile/utils/chat_notification_helper.dart';
import 'package:ehairdressers_mobile/utils/util.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  final int userId;

  const ChatListScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late ChatProvider _chatProvider;
  List<ChatRoom> _chatRooms = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    // Don't load data here - wait for provider to be available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = context.read<ChatProvider>();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('=== LOADING CHAT ROOMS ===');
      
      // Get chat rooms for the user
      var chatRooms = await _chatProvider.getUserChatRooms(widget.userId);
      print('Found ${chatRooms.length} chat rooms');
      
      // Get unread message count
      var unreadCount = await _chatProvider.getUnreadMessageCount(widget.userId);
      print('Unread message count: $unreadCount');
      
      setState(() {
        _chatRooms = chatRooms;
        _unreadCount = unreadCount;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading chat rooms: $e');
      setState(() {
        _isLoading = false;
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading chat rooms: $e')),
          );
        }
      });
    }
  }

  void _navigateToChat(ChatRoom chatRoom) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatRoom: chatRoom,
          userId: widget.userId,
        ),
      ),
    );
    
    // If we returned from chat screen, refresh the list
    if (result == true) {
      print('🔄 Returning from chat, refreshing chat rooms...');
      await _loadChatRooms();
    }
  }

  void _startNewChat() async {
    try {
      print('=== STARTING ROLE-BASED CHAT ===');
      
             // Use actual logged-in user ID
       int actualUserId = Authorization.currentUserId;
      
      print('🔄 ACTUAL USER INFO ===');
      print('User ID: $actualUserId');
             print('User ID: $actualUserId');
      
      // Create a role-based chat room
      var roleBasedChatRoom = ChatRoom(
        chatRoomId: 1, // Use chat room 1 for customer-employee communication
        userId: actualUserId,
        salonId: 1,
        roomName: 'Customer Support Chat',
        name: 'Customer Support Chat',
        createdDate: DateTime.now().toIso8601String(),
        isActive: true,
      );
      
      print('🔄 JOINING ROLE-BASED CHAT ROOM: ${roleBasedChatRoom.chatRoomId}');
      print('🔄 USER ID: $actualUserId');
      print('🔄 ROOM NAME: ${roleBasedChatRoom.roomName}');
      
      // Navigate to the role-based chat room
      _navigateToChat(roleBasedChatRoom);
      
    } catch (e) {
      print('Error starting role-based chat: $e');
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error starting chat: $e'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  Widget _buildChatRoomCard(ChatRoom chatRoom) {
    var lastMessageDate = chatRoom.lastMessageDate != null 
        ? DateTime.tryParse(chatRoom.lastMessageDate!) 
        : null;
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(
            Icons.chat,
            color: Colors.white,
          ),
        ),
        title: Text(
          chatRoom.roomName ?? 'Chat with Salon',
          style: TextStyle(
            fontWeight: chatRoom.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
                 subtitle: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisSize: MainAxisSize.min,
           children: [
             if (chatRoom.lastMessage != null) ...[
               Flexible(
                 child: Text(
                   chatRoom.lastMessage!,
                   maxLines: 2,
                   overflow: TextOverflow.ellipsis,
                   style: TextStyle(
                     color: chatRoom.unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                     fontWeight: chatRoom.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                   ),
                 ),
               ),
             ],
             if (lastMessageDate != null) ...[
               SizedBox(height: 2),
               Text(
                 DateFormat('MMM dd, HH:mm').format(lastMessageDate),
                 style: TextStyle(
                   fontSize: 12,
                   color: Colors.grey[500],
                 ),
               ),
             ],
           ],
         ),
        trailing: chatRoom.unreadCount > 0
            ? Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${chatRoom.unreadCount}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () => _navigateToChat(chatRoom),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
                     Text(
             'Customer Support Chat',
             style: TextStyle(
               fontSize: 18,
               fontWeight: FontWeight.bold,
               color: Colors.grey[600],
             ),
           ),
           SizedBox(height: 8),
           Text(
             'Chat with customer support for\nassistance and inquiries.',
             textAlign: TextAlign.center,
             style: TextStyle(
               fontSize: 14,
               color: Colors.grey[500],
             ),
           ),
          SizedBox(height: 24),
                     ElevatedButton.icon(
             onPressed: _startNewChat,
             icon: Icon(Icons.chat),
             label: Text('Start Support Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: "Live Chat",
      userId: widget.userId,
      showFloatingChat: false, // Disable floating chat on chat screen
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () async {
            print('🔄 Manual refresh triggered');
            await _loadChatRooms();
          },
          tooltip: 'Refresh chats',
        ),
        IconButton(
          icon: Icon(Icons.chat),
          onPressed: _startNewChat,
          tooltip: 'Start new chat',
        ),
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () {
            ChatNotificationHelper.showChatInfo(context);
          },
          tooltip: 'Chat info',
        ),
      ],
      child: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading chat conversations...'),
                ],
              ),
            )
          : _chatRooms.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadChatRooms,
                  child: Column(
                    children: [
                      if (_unreadCount > 0) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          color: Colors.orange.withOpacity(0.1),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications,
                                size: 16,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '$_unreadCount unread message${_unreadCount == 1 ? '' : 's'}',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Expanded(
                        child: ListView.builder(
                          itemCount: _chatRooms.length,
                          itemBuilder: (context, index) {
                            return _buildChatRoomCard(_chatRooms[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
