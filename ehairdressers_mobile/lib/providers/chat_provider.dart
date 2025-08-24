import 'dart:convert';
import 'package:ehairdressers_mobile/models/chat.dart';
import 'package:ehairdressers_mobile/models/search_result.dart';
import 'package:ehairdressers_mobile/providers/base_provider.dart';

class ChatProvider extends BaseProvider<ChatRoom> {
  ChatProvider() : super('ChatRoom');

  // Get chat rooms for a user
  Future<List<ChatRoom>> getUserChatRooms(int userId) async {
    try {
      print('=== GETTING USER CHAT ROOMS ===');
      print('User ID: $userId');
      
      var result = await getResult(filter: {'UserId': userId});
      print('Chat rooms result: $result');
      
      if (result?.result != null) {
        print('Found ${result!.result!.length} chat rooms');
        return result.result!;
      } else {
        print('No chat rooms found');
        return [];
      }
    } catch (e) {
      print('Error getting user chat rooms: $e');
      return [];
    }
  }

  // Get messages for a chat room
  Future<List<Message>> getChatMessages(int chatRoomId) async {
    try {
      print('=== GETTING CHAT MESSAGES ===');
      print('Chat Room ID: $chatRoomId');
      
      var response = await http!.get(
        Uri.parse('http://10.0.2.2:7051/Message/$chatRoomId'),
        headers: createHeaders(),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        var messages = <Message>[];
        
                 if (jsonData is List) {
           // Parse messages with proper error handling
           messages = jsonData.map((json) {
             try {
               return Message.fromJson(json);
             } catch (e) {
               print('Error parsing message: $e');
               print('Message JSON: $json');
               // Return a default message if parsing fails
               return Message(
                 messageId: json['MessageId'] ?? json['Id'] ?? 0,
                 chatRoomId: json['ChatRoomId'] ?? 0,
                 senderId: json['SenderId'] ?? 0,
                 senderType: json['SenderType'] ?? 'User',
                 messageText: json['MessageText'] ?? json['Content'] ?? 'Error loading message',
                 messageDate: json['MessageDate'] ?? json['SentDate'] ?? DateTime.now().toIso8601String(),
                 isRead: json['IsRead'] ?? false,
               );
             }
           }).toList();
         } else if (jsonData['result'] != null) {
           messages = (jsonData['result'] as List)
               .map((json) {
                 try {
                   return Message.fromJson(json);
                 } catch (e) {
                   print('Error parsing message: $e');
                   print('Message JSON: $json');
                   // Return a default message if parsing fails
                   return Message(
                     messageId: json['MessageId'] ?? json['Id'] ?? 0,
                     chatRoomId: json['ChatRoomId'] ?? 0,
                     senderId: json['SenderId'] ?? 0,
                     senderType: json['SenderType'] ?? 'User',
                     messageText: json['MessageText'] ?? json['Content'] ?? 'Error loading message',
                     messageDate: json['MessageDate'] ?? json['SentDate'] ?? DateTime.now().toIso8601String(),
                     isRead: json['IsRead'] ?? false,
                   );
                 }
               })
               .toList();
         }
        
        print('Found ${messages.length} messages');
        return messages;
      } else {
        print('Failed to get messages: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting chat messages: $e');
      return [];
    }
  }

  // Send a message
  Future<ChatResponse?> sendMessage(ChatRequest request) async {
    try {
      print('=== SENDING MESSAGE ===');
      
             // Create request body with SenderType
       var requestBody = {
         'ChatRoomId': request.chatRoomId,
         'SenderId': request.senderId,
         'MessageText': request.messageText, // Use 'MessageText' as backend expects
         'SenderType': request.senderType ?? 'User', // Include SenderType
       };
      
      print('Request: $requestBody');
      
      var response = await http!.post(
        Uri.parse('http://10.0.2.2:7051/Message'),
        headers: createHeaders(),
        body: json.encode(requestBody),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
             if (response.statusCode == 200 || response.statusCode == 201) {
         var jsonData = json.decode(response.body);
         
         // The backend returns a Message object, not ChatResponse
         // Create a ChatResponse manually from the Message data
         var chatResponse = ChatResponse(
           messageId: jsonData['MessageId'] ?? 0,
           success: true,
           message: 'Message sent successfully',
         );
         
         print('Message sent successfully: ${chatResponse.messageId}');
         return chatResponse;
       } else {
         print('Failed to send message: ${response.statusCode}');
         return null;
       }
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  // Create a new chat room
  Future<ChatRoom?> createChatRoom(ChatRoom chatRoom) async {
    try {
      print('=== CREATING CHAT ROOM ===');
      print('Chat Room: ${chatRoom.toJson()}');
      
      var response = await http!.post(
        Uri.parse('http://10.0.2.2:7051/ChatRoom'),
        headers: createHeaders(),
        body: json.encode(chatRoom.toJson()),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonData = json.decode(response.body);
        print('=== PARSING CHAT ROOM RESPONSE ===');
        print('JSON Data: $jsonData');
        
        try {
          // Handle different response formats from backend
          if (jsonData.containsKey('ChatRoomId')) {
            // Direct ChatRoom response - create manually to avoid parsing issues
            var createdRoom = ChatRoom(
              chatRoomId: jsonData['ChatRoomId'],
              userId: chatRoom.userId,
              salonId: chatRoom.salonId,
              roomName: jsonData['Name'] ?? jsonData['RoomName'] ?? chatRoom.roomName,
              createdDate: jsonData['CreatedDate'] ?? DateTime.now().toIso8601String(),
              isActive: jsonData['IsActive'] ?? true,
            );
            print('Chat room created successfully: ${createdRoom.chatRoomId}');
            return createdRoom;
          } else if (jsonData.containsKey('result')) {
            // Wrapped response
            var resultData = jsonData['result'];
            var createdRoom = ChatRoom(
              chatRoomId: resultData['ChatRoomId'] ?? resultData['Id'],
              userId: chatRoom.userId,
              salonId: chatRoom.salonId,
              roomName: resultData['Name'] ?? resultData['RoomName'] ?? chatRoom.roomName,
              createdDate: resultData['CreatedDate'] ?? DateTime.now().toIso8601String(),
              isActive: resultData['IsActive'] ?? true,
            );
            print('Chat room created successfully: ${createdRoom.chatRoomId}');
            return createdRoom;
          } else {
            // Create a ChatRoom from available fields
            var createdRoom = ChatRoom(
              chatRoomId: jsonData['ChatRoomId'] ?? jsonData['Id'],
              userId: chatRoom.userId,
              salonId: chatRoom.salonId,
              roomName: jsonData['Name'] ?? jsonData['RoomName'] ?? chatRoom.roomName,
              createdDate: jsonData['CreatedDate'] ?? DateTime.now().toIso8601String(),
              isActive: jsonData['IsActive'] ?? true,
            );
            print('Chat room created successfully: ${createdRoom.chatRoomId}');
            return createdRoom;
          }
        } catch (e) {
          print('Error parsing chat room response: $e');
          print('JSON Data that caused error: $jsonData');
          rethrow;
        }
      } else {
        print('Failed to create chat room: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating chat room: $e');
      return null;
    }
  }

  // Mark messages as read
  Future<bool> markMessagesAsRead(int chatRoomId, int userId) async {
    try {
      print('=== MARKING MESSAGES AS READ ===');
      print('Chat Room ID: $chatRoomId, User ID: $userId');
      
      var response = await http!.put(
        Uri.parse('http://10.0.2.2:7051/Message/Read/$chatRoomId/$userId'),
        headers: createHeaders(),
      );
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Messages marked as read successfully');
        return true;
      } else {
        print('Failed to mark messages as read: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error marking messages as read: $e');
      return false;
    }
  }

  // Get unread message count for a user
  Future<int> getUnreadMessageCount(int userId) async {
    try {
      print('=== GETTING UNREAD MESSAGE COUNT ===');
      print('User ID: $userId');
      
      var response = await http!.get(
        Uri.parse('http://10.0.2.2:7051/Message/UnreadCount/$userId'),
        headers: createHeaders(),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Handle both JSON and plain integer responses
        var responseBody = response.body.trim();
        if (responseBody.startsWith('{')) {
          // JSON response
          var jsonData = json.decode(responseBody);
          var count = jsonData['count'] ?? jsonData['unreadCount'] ?? 0;
          print('Unread message count: $count');
          return count;
        } else {
          // Plain integer response
          var count = int.tryParse(responseBody) ?? 0;
          print('Unread message count: $count');
          return count;
        }
      } else {
        print('Failed to get unread count: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error getting unread message count: $e');
      return 0;
    }
  }
}
