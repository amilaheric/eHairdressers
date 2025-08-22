// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      messageId: (json['MessageId'] as num?)?.toInt(),
      chatRoomId: (json['ChatRoomId'] as num).toInt(),
      senderId: (json['SenderId'] as num).toInt(),
      senderType: json['SenderType'] as String?,
      messageText: json['MessageText'] as String? ?? '',
      content: json['Content'] as String?,
      messageDate: json['MessageDate'] as String,
      isRead: json['IsRead'] as bool? ?? false,
      isActive: json['IsActive'] as bool? ?? true,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'MessageId': instance.messageId,
      'ChatRoomId': instance.chatRoomId,
      'SenderId': instance.senderId,
      'SenderType': instance.senderType,
      'MessageText': instance.messageText,
      'Content': instance.content,
      'MessageDate': instance.messageDate,
      'IsRead': instance.isRead,
      'IsActive': instance.isActive,
    };

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) => ChatRoom(
      chatRoomId: (json['ChatRoomId'] as num?)?.toInt(),
      userId: (json['UserId'] as num).toInt(),
      salonId: (json['SalonId'] as num).toInt(),
      roomName: json['RoomName'] as String?,
      name: json['Name'] as String?,
      lastMessage: json['LastMessage'] as String?,
      lastMessageDate: json['LastMessageDate'] as String?,
      unreadCount: (json['UnreadCount'] as num?)?.toInt() ?? 0,
      isActive: json['IsActive'] as bool? ?? true,
      createdDate: json['CreatedDate'] as String,
    );

Map<String, dynamic> _$ChatRoomToJson(ChatRoom instance) => <String, dynamic>{
      'ChatRoomId': instance.chatRoomId,
      'UserId': instance.userId,
      'SalonId': instance.salonId,
      'RoomName': instance.roomName,
      'Name': instance.name,
      'LastMessage': instance.lastMessage,
      'LastMessageDate': instance.lastMessageDate,
      'UnreadCount': instance.unreadCount,
      'IsActive': instance.isActive,
      'CreatedDate': instance.createdDate,
    };

ChatRequest _$ChatRequestFromJson(Map<String, dynamic> json) => ChatRequest(
      chatRoomId: (json['ChatRoomId'] as num).toInt(),
      senderId: (json['SenderId'] as num).toInt(),
      senderType: json['SenderType'] as String?,
      messageText: json['MessageText'] as String,
    );

Map<String, dynamic> _$ChatRequestToJson(ChatRequest instance) =>
    <String, dynamic>{
      'ChatRoomId': instance.chatRoomId,
      'SenderId': instance.senderId,
      'SenderType': instance.senderType,
      'MessageText': instance.messageText,
    };

ChatResponse _$ChatResponseFromJson(Map<String, dynamic> json) => ChatResponse(
      messageId: (json['MessageId'] as num).toInt(),
      success: json['Success'] as bool,
      message: json['Message'] as String,
    );

Map<String, dynamic> _$ChatResponseToJson(ChatResponse instance) =>
    <String, dynamic>{
      'MessageId': instance.messageId,
      'Success': instance.success,
      'Message': instance.message,
    };
