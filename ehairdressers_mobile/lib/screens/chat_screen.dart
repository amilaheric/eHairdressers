import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ehairdressers_mobile/models/chat.dart';
import 'package:ehairdressers_mobile/providers/chat_provider.dart';
import 'package:ehairdressers_mobile/services/signalr_service.dart';
import 'package:ehairdressers_mobile/widgets/master_screen.dart';
import 'package:ehairdressers_mobile/utils/chat_notification_helper.dart';
import 'package:ehairdressers_mobile/utils/util.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final ChatRoom chatRoom;
  final int userId;

  const ChatScreen({
    Key? key,
    required this.chatRoom,
    required this.userId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatProvider _chatProvider;
  late SignalRService _signalRService;
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isTyping = false;
  bool _showTypingIndicator = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<Message>? _messageSubscription;
  StreamSubscription<String>? _connectionSubscription;

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = context.read<ChatProvider>();
    _signalRService = SignalRService();
    

    _messages.clear();
    

    _signalRService.clearSentMessageTracking();
    
    _initializeSignalR();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _signalRService.leaveChatRoom(widget.chatRoom.chatRoomId.toString());
    

    _messages.clear();
    
    super.dispose();
  }


  Future<void> _initializeSignalR() async {
    try {
    

      await _signalRService.initializeConnection();
      

      await _signalRService.joinChatRoom(widget.chatRoom.chatRoomId.toString());
      
       
       _messageSubscription = _signalRService.messageStream.listen((message) {
     
          bool messageExists = _messages.any((existingMessage) => 
            existingMessage.messageId == message.messageId ||
            (existingMessage.senderId == message.senderId && 
             existingMessage.displayText == message.displayText &&
             existingMessage.messageDate == message.messageDate) ||
   
            (existingMessage.senderId == message.senderId && 
             existingMessage.displayText == message.displayText &&
             DateTime.tryParse(existingMessage.messageDate) != null &&
             DateTime.tryParse(message.messageDate) != null &&
             DateTime.tryParse(existingMessage.messageDate)!.difference(DateTime.tryParse(message.messageDate)!).abs().inSeconds < 5)
          );
         
                   if (!messageExists) {
      
            setState(() {
              _messages.add(message);
            });
            
    
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          } else {
     
            print('   Message ID: ${message.messageId}');
            print('   Sender ID: ${message.senderId}');
            print('   Current messages count: ${_messages.length}');
          }
       });
      
      _connectionSubscription = _signalRService.connectionStatusStream.listen((status) {
  
        if (mounted && status == 'error') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connection failed. Messages will be sent via HTTP.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
      
      print('SignalR initialized successfully for chat room: ${widget.chatRoom.chatRoomId}');
    } catch (e) {
      print('Error initializing SignalR: $e');

    }
  }

  Future<void> _loadMessages() async {
    try {
      setState(() {
        _isLoading = true;
      });

  
      var messages = await _chatProvider.getChatMessages(widget.chatRoom.chatRoomId!);
    
      await _chatProvider.markMessagesAsRead(widget.chatRoom.chatRoomId!, Authorization.currentUserId);
      

      var now = DateTime.now();
      var recentMessages = messages.where((message) {
        var messageDate = DateTime.tryParse(message.messageDate);
        if (messageDate == null) return false;
        return now.difference(messageDate).inMinutes <= 10;
      }).toList();
      
  
      if (recentMessages.isEmpty) {
        print('No recent messages found, starting fresh chat');
      } else {
        print('Loaded ${recentMessages.length} recent messages');
 
        for (var message in recentMessages) {
          print('Message: ${message.displayText} | Sender: ${message.senderId} | Type: ${message.senderType}');
        }
      }
      
      setState(() {
        _messages = recentMessages;
        _isLoading = false;
      });
      

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Error loading messages: $e');
      setState(() {
        _isLoading = false;
      });
     
    }
  }

  Future<void> _sendMessage() async {
    var messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    try {
      setState(() {
        _isSending = true;
      });


      
      _messageController.clear();
      
    
      String senderType = Authorization.userRole ?? (Authorization.currentUserId == 1 ? 'User' : 'Admin');
      

      
    
      if (_signalRService.isConnected) {
        try {
     
          await _signalRService.sendMessage(
            widget.chatRoom.chatRoomId.toString(),
            messageText,
            Authorization.currentUserId,
            senderType,
          );

          return;
        } catch (signalRError) {
          print('SignalR failed, falling back to HTTP: $signalRError');
        }
      }
      
   
      var request = ChatRequest(
        chatRoomId: widget.chatRoom.chatRoomId!,
        senderId: Authorization.currentUserId,
        senderType: senderType,
        messageText: messageText,
      );
      

      
      var response = await _chatProvider.sendMessage(request);
      
      if (response != null && response.success) {
        

        var newMessage = Message(
          messageId: response.messageId,
          chatRoomId: widget.chatRoom.chatRoomId!,
          senderId: Authorization.currentUserId,
          senderType: senderType,
          messageText: messageText,
          messageDate: DateTime.now().toIso8601String(),
          isRead: false,
        );
        
        setState(() {
          _messages.add(newMessage);
        });
        

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        print('Failed to send message via HTTP');

      }
    } catch (e) {
      print('Error sending message: $e');

    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Widget _buildMessageBubble(Message message) {

    int actualUserId = Authorization.currentUserId;
    bool isUserMessage = message.senderId == actualUserId;
    

    bool isCustomerMessage = message.senderType == 'User' || message.senderType == null;
    bool isEmployeeMessage = message.senderType == 'Admin' || message.senderType == 'Employee';
    
    var messageDate = DateTime.tryParse(message.messageDate);
    
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUserMessage 
            ? Colors.orange 
            : isEmployeeMessage 
              ? Colors.blue[100] 
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(18),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            if (!isUserMessage) ...[
              Text(
                isEmployeeMessage ? 'Support Team' : 'Customer',
                style: TextStyle(
                  color: isEmployeeMessage ? Colors.blue[700] : Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
            ],
            Flexible(
              child: Text(
                message.displayText,
                style: TextStyle(
                  color: isUserMessage ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
            if (messageDate != null) ...[
              SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(messageDate),
                style: TextStyle(
                  color: isUserMessage ? Colors.white70 : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    if (!_showTypingIndicator) return SizedBox.shrink();
    
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Salon is typing',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _handleTyping(bool isTyping) {
    if (_isTyping != isTyping) {
      _isTyping = isTyping;
      _signalRService.sendTypingIndicator(
        widget.chatRoom.chatRoomId.toString(),
        Authorization.currentUserId,
        isTyping,
      );
    }
  }


  void _handleUserAction(String action) {
    switch (action) {
      case 'test_customer':
        Authorization.currentUserId = 1;
        Authorization.userRole = 'User';

        break;
      case 'test_employee':
        Authorization.currentUserId = 2;
        Authorization.userRole = 'Admin';

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: 'Customer Support Chat',
      userId: widget.userId,
      showFloatingChat: false, 
      actions: [

        PopupMenuButton<String>(
          icon: Icon(Icons.person),
          tooltip: 'User Info & Test',
          onSelected: (value) {
            _handleUserAction(value);
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'info',
              child: Text('User ID: ${Authorization.currentUserId}'),
            ),
            PopupMenuItem(
              value: 'role',
              child: Text('Role: ${Authorization.userRole ?? 'Unknown'}'),
            ),
            PopupMenuItem(
              value: 'test_customer',
              child: Text('Test as Customer'),
            ),
            PopupMenuItem(
              value: 'test_employee',
              child: Text('Test as Employee'),
            ),
          ],
        ),
      ],
      child: Column(
        children: [

          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading messages...'),
                      ],
                    ),
                  )
                : _messages.isEmpty
                    ? Center(
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
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMessages,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          itemCount: _messages.length + (_showTypingIndicator ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _messages.length && _showTypingIndicator) {
                              return _buildTypingIndicator();
                            }
                            return _buildMessageBubble(_messages[index]);
                          },
                        ),
                      ),
          ),
          

          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                    onChanged: (text) {
                      _handleTyping(text.isNotEmpty);
                    },
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _isSending ? null : _sendMessage,
                    icon: _isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
