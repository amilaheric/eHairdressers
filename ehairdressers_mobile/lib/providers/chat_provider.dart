import 'dart:convert';
import 'package:ehairdressers_mobile/models/chat.dart';
import 'package:ehairdressers_mobile/models/search_result.dart';
import 'package:ehairdressers_mobile/providers/base_provider.dart';

class ChatProvider extends BaseProvider<ChatRoom> {
  ChatProvider() : super('ChatRoom');

  // Get chat rooms for a user
  Future<List<ChatRoom>> getUserChatRooms(int userId) async {
    try {
     
      
      var result = await getResult(filter: {'UserId': userId});
 
      
      if (result?.result != null) {
     
        return result.result!;
      } else {
    
        return [];
      }
    } catch (e) {
  
      return [];
    }
  }

  // Get messages for a chat room
  Future<List<Message>> getChatMessages(int chatRoomId) async {
    try {
     
      var response = await http!.get(
        Uri.parse('http://10.0.2.2:7051/Message/$chatRoomId'),
        headers: createHeaders(),
      );
      
     
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        var messages = <Message>[];
        
                 if (jsonData is List) {
         
           messages = jsonData.map((json) {
             try {
               return Message.fromJson(json);
             } catch (e) {
             
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
        
      
        return messages;
      } else {
       
        return [];
      }
    } catch (e) {
    
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
      
   
      
      var response = await http!.post(
        Uri.parse('http://10.0.2.2:7051/Message'),
        headers: createHeaders(),
        body: json.encode(requestBody),
      );
      
    
      
             if (response.statusCode == 200 || response.statusCode == 201) {
         var jsonData = json.decode(response.body);
         
         // The backend returns a Message object, not ChatResponse
         // Create a ChatResponse manually from the Message data
         var chatResponse = ChatResponse(
           messageId: jsonData['MessageId'] ?? 0,
           success: true,
           message: 'Message sent successfully',
         );
         
       
         return chatResponse;
       } else {
      
         return null;
       }
    } catch (e) {
   
      return null;
    }
  }

  // Create a new chat room
  Future<ChatRoom?> createChatRoom(ChatRoom chatRoom) async {
    try {
 
      
      var response = await http!.post(
        Uri.parse('http://10.0.2.2:7051/ChatRoom'),
        headers: createHeaders(),
        body: json.encode(chatRoom.toJson()),
      );
      
 
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonData = json.decode(response.body);
   
        
        try {
        
          if (jsonData.containsKey('ChatRoomId')) {
           
            var createdRoom = ChatRoom(
              chatRoomId: jsonData['ChatRoomId'],
              userId: chatRoom.userId,
              salonId: chatRoom.salonId,
              roomName: jsonData['Name'] ?? jsonData['RoomName'] ?? chatRoom.roomName,
              createdDate: jsonData['CreatedDate'] ?? DateTime.now().toIso8601String(),
              isActive: jsonData['IsActive'] ?? true,
            );
       
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
        
            return createdRoom;
          }
        } catch (e) {
      
          rethrow;
        }
      } else {
       
        return null;
      }
    } catch (e) {
    
      return null;
    }
  }

  // Mark messages as read
  Future<bool> markMessagesAsRead(int chatRoomId, int userId) async {
    try {

      var response = await http!.put(
        Uri.parse('http://10.0.2.2:7051/Message/Read/$chatRoomId/$userId'),
        headers: createHeaders(),
      );
      
   
      
      if (response.statusCode == 200) {

        return true;
      } else {
 
        return false;
      }
    } catch (e) {
     
      return false;
    }
  }

  // Get unread message count for a user
  Future<int> getUnreadMessageCount(int userId) async {
    try {
     
      var response = await http!.get(
        Uri.parse('http://10.0.2.2:7051/Message/UnreadCount/$userId'),
        headers: createHeaders(),
      );
      

      if (response.statusCode == 200) {

        var responseBody = response.body.trim();
        if (responseBody.startsWith('{')) {
          // JSON response
          var jsonData = json.decode(responseBody);
          var count = jsonData['count'] ?? jsonData['unreadCount'] ?? 0;
       
          return count;
        } else {
          // Plain integer response
          var count = int.tryParse(responseBody) ?? 0;
        
          return count;
        }
      } else {
      
        return 0;
      }
    } catch (e) {
 
      return 0;
    }
  }
}
