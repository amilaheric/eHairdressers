import 'dart:convert';
import 'package:ehairdressers_mobile/models/chat.dart';
import 'package:ehairdressers_mobile/models/search_result.dart';
import 'package:ehairdressers_mobile/providers/base_provider.dart';
import 'package:ehairdressers_mobile/utils/util.dart';

class ChatProvider extends BaseProvider<ChatRoom> {
  ChatProvider() : super('ChatRoom');


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


  Future<List<ChatRoom>> getAllAvailableChatRooms() async {
    try {

      var response = await http!.get(
        Uri.parse('${baseUrl}ChatRoom'),
        headers: createHeaders(),
      );
      

      
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        var chatRooms = <ChatRoom>[];
        
        
        if (jsonData is List) {
          chatRooms = jsonData.map((json) {
            try {
              return ChatRoom.fromJson(json);
            } catch (e) {
        
              return ChatRoom(
                chatRoomId: json['ChatRoomId'] ?? json['chatroomid'] ?? json['Id'] ?? json['id'],
                name: json['Name'] ?? json['name'] ?? 'Chat Room',
                createdDate: json['CreatedDate'] ?? json['createddate'] ?? DateTime.now().toIso8601String(),
                isActive: json['IsActive'] ?? json['isactive'] ?? true,
                userId: json['UserId'] ?? json['userid'] ?? 1,
                salonId: json['SalonId'] ?? json['salonid'] ?? 1,
              );
            }
          }).toList();
        } else if (jsonData['result'] != null) {
      
          chatRooms = (jsonData['result'] as List).map((json) {
            try {
              return ChatRoom.fromJson(json);
            } catch (e) {
          
              return ChatRoom(
                chatRoomId: json['ChatRoomId'] ?? json['chatroomid'] ?? json['Id'] ?? json['id'],
                name: json['Name'] ?? json['name'] ?? 'Chat Room',
                createdDate: json['CreatedDate'] ?? json['createddate'] ?? DateTime.now().toIso8601String(),
                isActive: json['IsActive'] ?? json['isactive'] ?? true,
                userId: json['UserId'] ?? json['userid'] ?? 1,
                salonId: json['SalonId'] ?? json['salonid'] ?? 1,
              );
            }
          }).toList();
        } else if (jsonData['Result'] != null) {
        
          chatRooms = (jsonData['Result'] as List).map((json) {
            try {
              return ChatRoom.fromJson(json);
            } catch (e) {
           
              return ChatRoom(
                chatRoomId: json['ChatRoomId'] ?? json['chatroomid'] ?? json['Id'] ?? json['id'],
                name: json['Name'] ?? json['name'] ?? 'Chat Room',
                createdDate: json['CreatedDate'] ?? json['createddate'] ?? DateTime.now().toIso8601String(),
                isActive: json['IsActive'] ?? json['isactive'] ?? true,
                userId: json['UserId'] ?? json['userid'] ?? 1,
                salonId: json['SalonId'] ?? json['salonid'] ?? 1,
              );
            }
          }).toList();
        }
        

        return chatRooms.where((room) => room.isActive == true).toList();
      } else {
    
        return [];
      }
    } catch (e) {
    
      return [];
    }
  }

  Future<List<ChatRoom>> getAllActiveChatRooms() async {
    return getAllAvailableChatRooms();
  }

 
  Future<ChatRoom?> findExistingCustomerSupportChat() async {
    try {
    
      
  
      var response = await http!.get(
        Uri.parse('${baseUrl}ChatRoom'),
        headers: createHeaders(),
      );
      

      if (response.statusCode != 200 || response.body.isEmpty) {
     
        return null;
      }
    
  
      var jsonData = json.decode(response.body);
      var allRooms = <ChatRoom>[];

      if (jsonData is List) {
       
        allRooms = jsonData.map((json) {
          try {
            return ChatRoom.fromJson(json);
          } catch (e) {
   
            return ChatRoom(
              chatRoomId: json['ChatRoomId'] ?? json['chatroomid'] ?? json['Id'] ?? json['id'],
              name: json['Name'] ?? json['name'] ?? 'Customer Support Chat',
              createdDate: json['CreatedDate'] ?? json['createddate'] ?? DateTime.now().toIso8601String(),
              isActive: json['IsActive'] ?? json['isactive'] ?? true,
              userId: json['UserId'] ?? json['userid'] ?? 1,
              salonId: json['SalonId'] ?? json['salonid'] ?? 1,
            );
          }
        }).toList();
      } else if (jsonData['result'] != null) {
     
        allRooms = (jsonData['result'] as List).map((json) {
          try {
            return ChatRoom.fromJson(json);
          } catch (e) {
       
            return ChatRoom(
              chatRoomId: json['ChatRoomId'] ?? json['chatroomid'] ?? json['Id'] ?? json['id'],
              name: json['Name'] ?? json['name'] ?? 'Customer Support Chat',
              createdDate: json['CreatedDate'] ?? json['createddate'] ?? DateTime.now().toIso8601String(),
              isActive: json['IsActive'] ?? json['isactive'] ?? true,
              userId: json['UserId'] ?? json['userid'] ?? 1,
              salonId: json['SalonId'] ?? json['salonid'] ?? 1,
            );
          }
        }).toList();
      } else if (jsonData['Result'] != null) {
  
        allRooms = (jsonData['Result'] as List).map((json) {
          try {
            return ChatRoom.fromJson(json);
          } catch (e) {
           
            return ChatRoom(
              chatRoomId: json['ChatRoomId'] ?? json['chatroomid'] ?? json['Id'] ?? json['id'],
              name: json['Name'] ?? json['name'] ?? 'Customer Support Chat',
              createdDate: json['CreatedDate'] ?? json['createddate'] ?? DateTime.now().toIso8601String(),
              isActive: json['IsActive'] ?? json['isactive'] ?? true,
              userId: json['UserId'] ?? json['userid'] ?? 1,
              salonId: json['SalonId'] ?? json['salonid'] ?? 1,
            );
          }
        }).toList();
      } else {
        print('Unexpected response format: $jsonData');
      }
      
   
      
      // Return the FIRST chat room (any room, we want only one)
      if (allRooms.isNotEmpty) {
        var firstRoom = allRooms.first;
 
        return firstRoom;
      }
      
      
      return ChatRoom(
        chatRoomId: 1,
        name: 'Customer Support Chat',
        createdDate: DateTime.now().toIso8601String(),
        isActive: true,
        userId: 1,
        salonId: 1,
      );
    } catch (e) {
     
      return ChatRoom(
        chatRoomId: 1,
        name: 'Customer Support Chat',
        createdDate: DateTime.now().toIso8601String(),
        isActive: true,
        userId: 1,
        salonId: 1,
      );
    }
  }


  Future<List<Message>> getChatMessages(int chatRoomId) async {
    try {
      var response = await http!.get(
        Uri.parse('${baseUrl}Message/$chatRoomId'),
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


  Future<ChatResponse?> sendMessage(ChatRequest request) async {
    try {
      
      var requestBody = {
        'ChatRoomId': request.chatRoomId,
        'SenderId': request.senderId,
        'MessageText': request.messageText, 
        'SenderType': request.senderType ?? 'User', 
      };
      
      var response = await http!.post(
        Uri.parse('${baseUrl}Message'),
        headers: createHeaders(),
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonData = json.decode(response.body);
        
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

  Future<ChatRoom?> createChatRoom(ChatRoom chatRoom) async {
    try {

      var requestBody = {
        'name': chatRoom.name ?? 'Customer Support Chat',
        'createddate': chatRoom.createdDate,
        'isactive': chatRoom.isActive,
      };

      
      var response = await http!.post(
        Uri.parse('${baseUrl}ChatRoom'),
        headers: createHeaders(),
        body: json.encode(requestBody),
      );
      
  
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonData = json.decode(response.body);
    
        
        try {
          // Extract chat room ID from response
          int? newChatRoomId;
          if (jsonData.containsKey('chatroomid')) {
            newChatRoomId = jsonData['chatroomid'];
          } else if (jsonData.containsKey('ChatRoomId')) {
            newChatRoomId = jsonData['ChatRoomId'];
          } else if (jsonData.containsKey('id')) {
            newChatRoomId = jsonData['id'];
          } else if (jsonData.containsKey('Id')) {
            newChatRoomId = jsonData['Id'];
          }
          
       
          
          if (newChatRoomId != null) {
       
            var userAdded = await addUserToChatRoom(newChatRoomId, chatRoom.userId ?? Authorization.currentUserId);
          
            
            var createdRoom = ChatRoom(
              chatRoomId: newChatRoomId,
              name: jsonData['name'] ?? jsonData['Name'] ?? chatRoom.name,
              createdDate: jsonData['createddate'] ?? jsonData['CreatedDate'] ?? chatRoom.createdDate,
              isActive: jsonData['isactive'] ?? jsonData['IsActive'] ?? chatRoom.isActive,
              userId: chatRoom.userId,
              salonId: chatRoom.salonId,
            );
            
        
            return createdRoom;
          } else {
           
            return null;
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

  // Add user to chat room in chatroomusers table
  Future<bool> addUserToChatRoom(int chatRoomId, int userId) async {
    try {
      print('=== ADDING USER TO CHAT ROOM ===');
      print('Chat Room ID: $chatRoomId');
      print('User ID: $userId');
      
      var requestBody = {
        'chatroomid': chatRoomId,
        'userid': userId,
        'joineddate': DateTime.now().toIso8601String(),
        'isactive': true,
      };
      
      print('Request body: $requestBody');
      
      var endpoints = [
        '${baseUrl}ChatRoomUsers',
        '${baseUrl}ChatRoom/Users',
        '${baseUrl}ChatRoom/$chatRoomId/Users',
        '${baseUrl}Users/ChatRoom',
      ];
      
      for (var endpoint in endpoints) {
        try {
          print('Trying endpoint: $endpoint');
          var response = await http!.post(
            Uri.parse(endpoint),
            headers: createHeaders(),
            body: json.encode(requestBody),
          );
          
        
          
          if (response.statusCode == 200 || response.statusCode == 201) {
           
            return true;
          }
        } catch (e) {
         
          continue;
        }
      }
      
      return true;
    } catch (e) {
  
      return false;
    }
  }

  // Mark messages as read
  Future<bool> markMessagesAsRead(int chatRoomId, int userId) async {
    try {
      var response = await http!.put(
        Uri.parse('${baseUrl}Message/Read/$chatRoomId/$userId'),
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

  
  Future<int> getUnreadMessageCount(int userId) async {
    try {
      var response = await http!.get(
        Uri.parse('${baseUrl}Message/UnreadCount/$userId'),
        headers: createHeaders(),
      );
      
      if (response.statusCode == 200) {
        var responseBody = response.body.trim();
        if (responseBody.startsWith('{')) {
       
          var jsonData = json.decode(responseBody);
          var count = jsonData['count'] ?? jsonData['unreadCount'] ?? 0;
          return count;
        } else {
          
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
