import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

@JsonSerializable()
class Message {
  @JsonKey(name: 'MessageId')
  final int? messageId;

  @JsonKey(name: 'ChatRoomId')
  final int chatRoomId;

  @JsonKey(name: 'SenderId')
  final int senderId;

  @JsonKey(name: 'SenderType')
  final String? senderType; // 'User' or 'Salon' - optional for now

  @JsonKey(name: 'MessageText')
  final String messageText;

  @JsonKey(name: 'Content')
  final String? content;

  @JsonKey(name: 'MessageDate')
  final String messageDate;

  @JsonKey(name: 'IsRead')
  final bool isRead;

  @JsonKey(name: 'IsActive')
  final bool isActive;

  Message({
    this.messageId,
    required this.chatRoomId,
    required this.senderId,
    this.senderType,
    this.messageText = '',
    this.content,
    required this.messageDate,
    this.isRead = false,
    this.isActive = true,
  });

  // Getter to handle both messageText and content fields
  String get displayText => content?.isNotEmpty == true ? content! : messageText ?? '';

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class ChatRoom {
  @JsonKey(name: 'ChatRoomId')
  final int? chatRoomId;

  @JsonKey(name: 'UserId')
  final int userId;

  @JsonKey(name: 'SalonId')
  final int salonId;

  @JsonKey(name: 'RoomName')
  final String? roomName;

  @JsonKey(name: 'Name')
  final String? name;

  @JsonKey(name: 'LastMessage')
  final String? lastMessage;

  @JsonKey(name: 'LastMessageDate')
  final String? lastMessageDate;

  @JsonKey(name: 'UnreadCount')
  final int unreadCount;

  @JsonKey(name: 'IsActive')
  final bool isActive;

  @JsonKey(name: 'CreatedDate')
  final String createdDate;

  ChatRoom({
    this.chatRoomId,
    required this.userId,
    required this.salonId,
    this.roomName,
    this.name,
    this.lastMessage,
    this.lastMessageDate,
    this.unreadCount = 0,
    this.isActive = true,
    required this.createdDate,
  });

  // Getter to handle both roomName and name fields
  String? get displayName => roomName?.isNotEmpty == true ? roomName : name?.isNotEmpty == true ? name : null;

  factory ChatRoom.fromJson(Map<String, dynamic> json) => _$ChatRoomFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomToJson(this);
}

// Helper function to parse room name from either "RoomName" or "Name" field
String? _parseRoomName(dynamic value) {
  if (value is String) {
    return value.isEmpty ? null : value;
  }
  return null;
}

@JsonSerializable()
class ChatRequest {
  @JsonKey(name: 'ChatRoomId')
  final int chatRoomId;

  @JsonKey(name: 'SenderId')
  final int senderId;

  @JsonKey(name: 'SenderType')
  final String? senderType; // Optional for now since backend doesn't have this column

  @JsonKey(name: 'MessageText')
  final String messageText;

  ChatRequest({
    required this.chatRoomId,
    required this.senderId,
    this.senderType, // Optional
    required this.messageText,
  });

  factory ChatRequest.fromJson(Map<String, dynamic> json) => _$ChatRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRequestToJson(this);
}

@JsonSerializable()
class ChatResponse {
  @JsonKey(name: 'MessageId')
  final int messageId;

  @JsonKey(name: 'Success')
  final bool success;

  @JsonKey(name: 'Message')
  final String message;

  ChatResponse({
    required this.messageId,
    required this.success,
    required this.message,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) => _$ChatResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatResponseToJson(this);
}
