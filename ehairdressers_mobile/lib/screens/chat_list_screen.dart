import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ehairdressers_mobile/models/chat.dart';
import 'package:ehairdressers_mobile/providers/chat_provider.dart';
import 'package:ehairdressers_mobile/screens/chat_screen.dart';
import 'package:ehairdressers_mobile/services/signalr_service.dart';
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
  final SignalRService _signalRService = SignalRService();
  List<ChatRoom> _chatRooms = [];
  bool _isLoading = true;
  int _unreadCount = 0;
  StreamSubscription<void>? _chatRoomCreatedSubscription;

  // "Customer" side vs "Admin"/"Employee" side is enforced server-side
  // (ChatRoomService.CanUserJoinAsync) where the real role data lives.
  // Authorization.userRole on this client is a legacy "Employee"/"User"
  // flag, not the actual role name, so it can't be trusted here - anyone
  // can tap "create", and the backend rejects it if it would violate the
  // one-customer-per-room rule.
  bool get _canStartNewChat => true;

  @override
  void initState() {
    super.initState();
    // Don't load data here - wait for provider to be available
    _listenForNewChatRooms();
  }

  Future<void> _listenForNewChatRooms() async {
    if (!_signalRService.isConnected) {
      try {
        await _signalRService.initializeConnection();
      } catch (_) {
        // If this fails, the manual refresh button still works.
      }
    }
    _chatRoomCreatedSubscription =
        _signalRService.chatRoomCreatedStream.listen((_) {
      if (mounted) {
        _loadChatRooms();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = context.read<ChatProvider>();
    _loadChatRooms();
  }

  @override
  void dispose() {
    _chatRoomCreatedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadChatRooms() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('=== LOADING ALL AVAILABLE CHAT ROOMS ===');
      
      // Get all available chat rooms (not just user-specific ones)
      var chatRooms = await _chatProvider.getAllAvailableChatRooms();
      print('Found ${chatRooms.length} available chat rooms');
      
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
    try {
      // Membership + role eligibility (customer vs support) is checked
      // server-side when ChatScreen joins the SignalR group for this room.
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
    } catch (e) {
      print('Error joining chat room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error joining chat room: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _startNewChat() async {
    try {
      print('=== CREATING NEW CHAT ROOM ===');
      
      // Use actual logged-in user ID
      int actualUserId = Authorization.currentUserId;
      
      print('🔄 ACTUAL USER INFO ===');
      print('User ID: $actualUserId');
      
      // Create a new chat room with a unique name
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var roomName = 'Chat Room ${timestamp}';
      
      var newChatRoom = ChatRoom(
        chatRoomId: null, // This will trigger chat room creation
        userId: actualUserId,
        salonId: 1,
        roomName: roomName,
        name: roomName,
        createdDate: DateTime.now().toIso8601String(),
        isActive: true,
      );
      
      print('🔄 CREATING NEW CHAT ROOM');
      print('🔄 USER ID: $actualUserId');
      print('🔄 ROOM NAME: ${newChatRoom.roomName}');
      
      // Create the chat room in the database
      var createdRoom = await _chatProvider.createChatRoom(newChatRoom);
      
      if (createdRoom != null) {
        print('✅ Chat room created successfully: ${createdRoom.chatRoomId}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New chat room created!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to the chat room
        _navigateToChat(createdRoom);
        
        // Refresh the chat room list
        await _loadChatRooms();
      } else {
        throw Exception('Failed to create chat room');
      }
      
    } catch (e) {
      print('Error creating new chat: $e');
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating chat room: $e'),
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
    var createdDate = chatRoom.createdDate != null 
        ? DateTime.tryParse(chatRoom.createdDate!) 
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
          chatRoom.name ?? chatRoom.roomName ?? 'Chat Room',
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
            SizedBox(height: 2),
            Row(
              children: [
                if (lastMessageDate != null) ...[
                  Text(
                    'Last: ${DateFormat('MMM dd, HH:mm').format(lastMessageDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ] else if (createdDate != null) ...[
                  Text(
                    'Created: ${DateFormat('MMM dd, HH:mm').format(createdDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Join',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
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
            'No Chat Rooms Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create a new chat room to start\ncommunicating with customers and employees.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          if (_canStartNewChat)
            ElevatedButton.icon(
              onPressed: _startNewChat,
              icon: Icon(Icons.add),
              label: Text('Create New Chat Room'),
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
      title: "Chat Rooms",
      userId: widget.userId,
      showFloatingChat: false, // Disable floating chat on chat screen
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () async {
            print('🔄 Manual refresh triggered');
            await _loadChatRooms();
          },
          tooltip: 'Refresh chat rooms',
        ),
        if (_canStartNewChat)
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _startNewChat,
            tooltip: 'Create new chat room',
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
                  Text('Loading chat rooms...'),
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
