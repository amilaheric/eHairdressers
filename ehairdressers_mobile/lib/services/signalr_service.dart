import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:ehairdressers_mobile/models/chat.dart';

class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;
  SignalRService._internal();

  HubConnection? _hubConnection;
  bool _isConnected = false;
  final StreamController<Message> _messageController = StreamController<Message>.broadcast();
  final StreamController<String> _connectionStatusController = StreamController<String>.broadcast();
  
  final Set<String> _sentMessageIds = <String>{};

  Stream<Message> get messageStream => _messageController.stream;
  Stream<String> get connectionStatusStream => _connectionStatusController.stream;
  bool get isConnected => _isConnected;
  HubConnection? get hubConnection => _hubConnection;

  Future<void> initializeConnection() async {
    try {
      
      
      _sentMessageIds.clear();
      
      _hubConnection = HubConnectionBuilder()
          .withUrl('https://10.0.2.2:7051/chatHub')
          .withAutomaticReconnect()
          .build();

      _hubConnection!.onclose(({Exception? error}) {
      
        _isConnected = false;
        _connectionStatusController.add('disconnected');
      });

      _hubConnection!.onreconnecting(({Exception? error}) {
      
        _connectionStatusController.add('reconnecting');
      });

      _hubConnection!.onreconnected(({String? connectionId}) {
      
        _isConnected = true;
        _connectionStatusController.add('connected');
      });

      _setupMessageHandlers();

      await _hubConnection!.start();
      _isConnected = true;
      _connectionStatusController.add('connected');
      
    
    } catch (e) {
    
      _connectionStatusController.add('error');
      rethrow;
    }
  }

  void _setupMessageHandlers() {
    _hubConnection!.on('ReceiveMessage', (arguments) {
    
      
      if (arguments != null && arguments.isNotEmpty) {
        try {
          var messageData = arguments[0] as Map<String, dynamic>;
          
        
          
            var message = Message(
              messageId: _parseInt(messageData['messageId'] ?? messageData['MessageId']),
              chatRoomId: _parseInt(messageData['chatRoomId'] ?? messageData['ChatRoomId']),
              senderId: _parseInt(messageData['senderId'] ?? messageData['SenderId']),
              senderType: (messageData['senderType'] ?? messageData['SenderType'] ?? 'User').toString(),
              messageText: (messageData['content'] ?? messageData['Content'] ?? messageData['messageText'] ?? messageData['MessageText'] ?? '').toString(),
              messageDate: (messageData['sentDate'] ?? messageData['SentDate'] ?? messageData['messageDate'] ?? messageData['MessageDate'] ?? DateTime.now().toIso8601String()).toString(),
              isRead: _parseBool(messageData['isRead'] ?? messageData['IsRead']),
              isActive: _parseBool(messageData['isActive'] ?? messageData['IsActive'] ?? true),
            );
          
      
          
          _messageController.add(message);
        } catch (e) {
          

          try {
            var messageData = arguments[0] as Map<String, dynamic>;
                                      var fallbackMessage = Message(
                messageId: DateTime.now().millisecondsSinceEpoch,
                chatRoomId: _parseInt(messageData['chatRoomId'] ?? messageData['ChatRoomId'] ?? 1),
                senderId: _parseInt(messageData['senderId'] ?? messageData['SenderId'] ?? 1),
                senderType: (messageData['senderType'] ?? messageData['SenderType'] ?? 'User').toString(),
                messageText: (messageData['content'] ?? messageData['Content'] ?? messageData['messageText'] ?? messageData['MessageText'] ?? 'Message received').toString(),
                messageDate: DateTime.now().toIso8601String(),
                isRead: false,
                isActive: true,
              );
            _messageController.add(fallbackMessage);
          } catch (fallbackError) {
           
          }
        }
      }
    });

    _hubConnection!.on('UserTyping', (arguments) {
      print('User typing: $arguments');
    });

    _hubConnection!.on('UserJoined', (arguments) {
      print('User joined: $arguments');
    });

    _hubConnection!.on('UserLeft', (arguments) {
      print('User left: $arguments');
    });
  }

  Future<void> joinChatRoom(String chatRoomId) async {
    try {
      if (_hubConnection != null && _isConnected) {

        
        await _hubConnection!.invoke('JoinChatRoom', args: [chatRoomId]);
     
      } else {
        print('Cannot join chat room: Connection not established');
      }
    } catch (e) {
  
      rethrow;
    }
  }

  Future<void> leaveChatRoom(String chatRoomId) async {
    try {
      if (_hubConnection != null && _isConnected) {
      
        
        await _hubConnection!.invoke('LeaveChatRoom', args: [chatRoomId]);
    
      }
    } catch (e) {
      print('Error leaving chat room: $e');
    }
  }

  Future<void> sendMessage(String chatRoomId, String messageText, int senderId, String senderType) async {
    try {
      if (_hubConnection != null && _isConnected) {
        String messageId = '${senderId}_${DateTime.now().millisecondsSinceEpoch}';
        
        if (_sentMessageIds.contains(messageId)) {
      
          return;
        }
        
  
        
        await _hubConnection!.invoke('SendMessage', args: [
          chatRoomId,
          messageText,
          senderId.toString(),
          senderType
        ]);
        
        _sentMessageIds.add(messageId);
        
    
      } else {
    
        throw Exception('SignalR connection not available');
      }
    } catch (e) {
    
      rethrow;
    }
  }

  Future<void> sendTypingIndicator(String chatRoomId, int senderId, bool isTyping) async {
    try {
      if (_hubConnection != null && _isConnected) {
        await _hubConnection!.invoke('SendTypingIndicator', args: [
          chatRoomId,
          senderId.toString(),
          isTyping.toString()
        ]);
      }
    } catch (e) {
    
    }
  }

  Future<void> disconnect() async {
    try {
      if (_hubConnection != null) {
    
        await _hubConnection!.stop();
        _isConnected = false;
        _connectionStatusController.add('disconnected');
    
      }
    } catch (e) {
    
    }
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is int) {
      return value != 0;
    }
    return false;
  }

  void clearSentMessageTracking() {
    _sentMessageIds.clear();

  }

  void dispose() {
    disconnect();
    _messageController.close();
    _connectionStatusController.close();
  }
}
