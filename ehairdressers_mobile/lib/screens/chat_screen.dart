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
  bool _hasChatRoom = false;
  int? _currentChatRoomId;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<Message>? _messageSubscription;
  StreamSubscription<String>? _connectionSubscription;
  StreamSubscription<String>? _joinErrorSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('=== DID CHANGE DEPENDENCIES ===');
    print('Widget chat room ID: ${widget.chatRoom.chatRoomId}');
    print('Widget chat room: ${widget.chatRoom.toJson()}');
    
    _chatProvider = context.read<ChatProvider>();
    _signalRService = SignalRService();
    
    _messages.clear();
    _signalRService.clearSentMessageTracking();
    
    // Check if we have a valid chat room
    if (widget.chatRoom.chatRoomId != null && widget.chatRoom.chatRoomId! > 0) {
      print('✅ Using existing chat room: ${widget.chatRoom.chatRoomId}');
      _currentChatRoomId = widget.chatRoom.chatRoomId;
      _hasChatRoom = true;
      _initializeSignalR();
      _loadMessages();
    } else {
      print('❌ Invalid chat room, cannot start chat');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid chat room. Please select a valid room.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _joinErrorSubscription?.cancel();
    if (_currentChatRoomId != null) {
      _signalRService.leaveChatRoom(_currentChatRoomId.toString());
    }
    _messages.clear();
    super.dispose();
  }



  Future<void> _initializeSignalR() async {
    try {
      await _signalRService.initializeConnection();
      
      if (_currentChatRoomId != null) {
        await _signalRService.joinChatRoom(
          _currentChatRoomId.toString(),
          userId: Authorization.currentUserId,
          userRole: Authorization.userRole ?? (Authorization.currentUserId == 1 ? 'User' : 'Admin'),
        );
      }
      
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

      _joinErrorSubscription = _signalRService.joinErrorStream.listen((error) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      });
    } catch (e) {
      print('Error initializing SignalR: $e');
    }
  }

  Future<void> _loadMessages() async {
    try {
      if (_currentChatRoomId == null) return;

      var messages = await _chatProvider.getChatMessages(_currentChatRoomId!);
      await _chatProvider.markMessagesAsRead(_currentChatRoomId!, Authorization.currentUserId);

      setState(() {
        _messages = messages;
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

    // Check if we have a valid chat room
    if (!_hasChatRoom || _currentChatRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No active chat room. Please select a valid room.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      setState(() {
        _isSending = true;
      });

      _messageController.clear();
      
      String senderType = Authorization.userRole ?? (Authorization.currentUserId == 1 ? 'User' : 'Admin');
      
      if (_signalRService.isConnected) {
        try {
          await _signalRService.sendMessage(
            _currentChatRoomId.toString(),
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
        chatRoomId: _currentChatRoomId!,
        senderId: Authorization.currentUserId,
        senderType: senderType,
        messageText: messageText,
      );
      
      var response = await _chatProvider.sendMessage(request);
      
      if (response != null && response.success) {
        var newMessage = Message(
          messageId: response.messageId,
          chatRoomId: _currentChatRoomId!,
          senderId: Authorization.currentUserId,
          senderType: senderType,
          messageText: messageText,
          messageDate: DateTime.now().toUtc().toIso8601String(),
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
    
    bool isCustomerMessage = message.senderType == 'User' ||
        message.senderType == 'Customer' ||
        message.senderType == null;
    bool isEmployeeMessage = message.senderType == 'Admin' || message.senderType == 'Employee';

    // Backend sends message dates as UTC ("...Z"); convert to local before
    // formatting, otherwise the timestamp shown under each bubble is off by
    // the device's UTC offset.
    var messageDate = DateTime.tryParse(message.messageDate)?.toLocal();
    
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
    if (_isTyping != isTyping && _currentChatRoomId != null) {
      _isTyping = isTyping;
      _signalRService.sendTypingIndicator(
        _currentChatRoomId.toString(),
        Authorization.currentUserId,
        isTyping,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreenWidget(
      title: widget.chatRoom.name ?? widget.chatRoom.roomName ?? 'Chat Room',
      userId: widget.userId,
      showFloatingChat: false,
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
                                 : !_hasChatRoom
                     ? Center(
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Icon(
                               Icons.error_outline,
                               size: 64,
                               color: Colors.red[400],
                             ),
                             SizedBox(height: 16),
                             Text(
                               'Invalid Chat Room',
                               style: TextStyle(
                                 fontSize: 18,
                                 fontWeight: FontWeight.bold,
                                 color: Colors.red[600],
                               ),
                             ),
                             SizedBox(height: 8),
                             Text(
                               'Please select a valid chat room from the list.',
                               style: TextStyle(
                                 fontSize: 14,
                                 color: Colors.grey[500],
                               ),
                             ),
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
          
          // Message input area
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
                    enabled: _hasChatRoom,
                    decoration: InputDecoration(
                      hintText: _hasChatRoom ? 'Type your message...' : 'Start conversation to chat',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: _hasChatRoom ? Colors.grey[100] : Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                    onChanged: (text) {
                      if (_hasChatRoom) {
                        _handleTyping(text.isNotEmpty);
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _hasChatRoom ? Colors.orange : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _hasChatRoom && !_isSending ? _sendMessage : null,
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
