using Microsoft.AspNetCore.SignalR;
using eHairdressers.Model;
using eHairdressers.Services;
using eHairdressers.Model.Requests;
using eHairdressers.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace eHairdressers.Hubs
{
    public class UnreadCountInfo
    {
        public int UserId { get; set; }
        public int Count { get; set; }
    }

    public class ChatHub : Hub
    {
        private readonly IMessageService _messageService;
        private readonly IChatRoomService _chatRoomService;
        private readonly eHairdressersContext _context;
        private static readonly Dictionary<string, string> _userConnections = new();

        public ChatHub(IMessageService messageService, IChatRoomService chatRoomService, eHairdressersContext context)
        {
            _messageService = messageService;
            _chatRoomService = chatRoomService;
            _context = context;
        }

        public async Task TestMessage(string message)
        {
            try
            {
                await Clients.Caller.SendAsync("TestMessageResponse", $"Server received: {message}");
                
            
                await Clients.All.SendAsync("TestMessageBroadcast", $"Broadcast: {message}");
                
              
            }
            catch (Exception ex)
            {
              
                await Clients.Caller.SendAsync("TestMessageError", ex.Message);
            }
        }

    
        public async Task Echo(string message)
        {
            await Clients.Caller.SendAsync("EchoResponse", $"Echo: {message}");
        }


        public async Task Broadcast(string message)
        {
            await Clients.All.SendAsync("BroadcastMessage", $"Broadcast: {message}");
        }

   
        public async Task SendMessageSimple(string chatRoomId, string messageText, string senderId, string senderType)
        {
            try
            {
              
                var messageRequest = new MessageInsertRequest
                {
                    ChatRoomId = int.Parse(chatRoomId),
                    SenderId = int.Parse(senderId),
                    Content = messageText
                };
                
                var message = await _messageService.Insert(messageRequest);
                
                await Clients.Group(chatRoomId).SendAsync("ReceiveMessage", message);
                
            }
            catch (Exception ex)
            {
  
                await Clients.Caller.SendAsync("MessageError", ex.Message);
            }
        }

        public async Task JoinChatRoom(string chatRoomId)
        {
            try
            {
               
                await Groups.AddToGroupAsync(Context.ConnectionId, chatRoomId);
              
                await Groups.AddToGroupAsync(Context.ConnectionId, $"ChatRoom_{chatRoomId}");
                
               
                var userId = _userConnections.ContainsKey(Context.ConnectionId) 
                    ? _userConnections[Context.ConnectionId] 
                    : Context.UserIdentifier ?? Context.ConnectionId;
                
             
                if (int.TryParse(chatRoomId, out int chatRoomIdInt) && int.TryParse(userId, out int userIdInt))
                {
            
                    var existingMembership = await _context.ChatRoomUsers
                        .FirstOrDefaultAsync(m => m.ChatRoomId == chatRoomIdInt && m.UserId == userIdInt && m.IsActive);
                    
                    if (existingMembership == null)
                    {
                        var membership = new ChatRoomUser
                        {
                            ChatRoomId = chatRoomIdInt,
                            UserId = userIdInt,
                            JoinedDate = DateTime.Now,
                            IsActive = true
                        };
                        
                        _context.ChatRoomUsers.Add(membership);
                        await _context.SaveChangesAsync();
                        
                       
                    }
                    else
                    {
                        Console.WriteLine($"=== USER {userId} ALREADY A MEMBER OF CHAT ROOM {chatRoomId} ===");
                    }
                }
                
             
                await Clients.Group(chatRoomId).SendAsync("UserJoined", userId, chatRoomId);
                
            
                await Clients.Caller.SendAsync("JoinedChatRoom", chatRoomId);
            }
            catch (Exception ex)
            {
               
                await Clients.Caller.SendAsync("JoinError", ex.Message);
            }
        }

        public async Task LeaveChatRoom(string chatRoomId)
        {
            try
            {
             
                await Groups.RemoveFromGroupAsync(Context.ConnectionId, chatRoomId);
                await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"ChatRoom_{chatRoomId}");
                
           
                var userId = _userConnections.ContainsKey(Context.ConnectionId) 
                    ? _userConnections[Context.ConnectionId] 
                    : Context.UserIdentifier ?? Context.ConnectionId;
                
           
                if (int.TryParse(chatRoomId, out int chatRoomIdInt) && int.TryParse(userId, out int userIdInt))
                {
                    var membership = await _context.ChatRoomUsers
                        .FirstOrDefaultAsync(m => m.ChatRoomId == chatRoomIdInt && m.UserId == userIdInt && m.IsActive);
                    
                    if (membership != null)
                    {
                        membership.IsActive = false;
                        await _context.SaveChangesAsync();
                        
                       
                    }
                }
                
              
                await Clients.Group(chatRoomId).SendAsync("UserLeft", userId, chatRoomId);
                
          
                await Clients.Caller.SendAsync("LeftChatRoom", chatRoomId);
                
      
            }
            catch (Exception ex)
            {
             
                await Clients.Caller.SendAsync("LeaveError", ex.Message);
            }
        }

        public async Task SendMessage(string chatRoomId, string messageText, string senderId, string senderType)
        {
            try
            {
               
                
            
                if (string.IsNullOrEmpty(messageText))
                {
                    await Clients.Caller.SendAsync("MessageError", "Message text cannot be empty");
                    return;
                }

                if (!int.TryParse(senderId, out int senderIdInt))
                {
                    await Clients.Caller.SendAsync("MessageError", "Invalid sender ID");
                    return;
                }

                if (!int.TryParse(chatRoomId, out int chatRoomIdInt))
                {
                    await Clients.Caller.SendAsync("MessageError", "Invalid chat room ID");
                    return;
                }

            
                var messageRequest = new MessageInsertRequest
                {
                    ChatRoomId = chatRoomIdInt,
                    SenderId = senderIdInt,
                    Content = messageText
                };

            
                var message = await _messageService.Insert(messageRequest);

           
                var messageObject = new
                {
                    MessageId = message.MessageId,
                    ChatRoomId = chatRoomId,
                    SenderId = senderId,
                    SenderType = senderType,
                    Content = messageText,
                    SentDate = message.SentDate,
                    IsRead = false
                };

             
                await Clients.Group(chatRoomId).SendAsync("ReceiveMessage", messageObject);
                
         
                await Clients.Group($"ChatRoom_{chatRoomId}").SendAsync("ReceiveMessage", messageObject);

                var unreadCounts = await GetUnreadCountsForChatRoom(chatRoomIdInt, senderIdInt);
                foreach (var unreadCount in unreadCounts)
                {
                    await Clients.User(unreadCount.UserId.ToString()).SendAsync("UpdateUnreadCount", unreadCount.Count);
                }

          
                await Clients.Caller.SendAsync("MessageSent", messageObject);
                
           
            }
            catch (Exception ex)
            {
            
                await Clients.Caller.SendAsync("MessageError", ex.Message);
            }
        }

        public async Task SendTypingIndicator(string chatRoomId, string senderId, string isTyping)
        {
            try
            {
          
                if (!bool.TryParse(isTyping, out bool isTypingBool))
                {
                    await Clients.Caller.SendAsync("TypingIndicatorError", "Invalid typing indicator value");
                    return;
                }

                var typingIndicator = new
                {
                    ChatRoomId = chatRoomId,
                    SenderId = senderId,
                    IsTyping = isTypingBool,
                    Timestamp = DateTime.UtcNow
                };

             
                await Clients.OthersInGroup($"ChatRoom_{chatRoomId}").SendAsync("UserTyping", typingIndicator);
            
            }
            catch (Exception ex)
            {
              
                await Clients.Caller.SendAsync("TypingIndicatorError", ex.Message);
            }
        }

        public async Task MarkMessageAsRead(string chatRoomId, string messageId, string userId)
        {
            try
            {
              
                if (!int.TryParse(chatRoomId, out int chatRoomIdInt))
                {
                    await Clients.Caller.SendAsync("MarkAsReadError", "Invalid chat room ID");
                    return;
                }

                if (!int.TryParse(messageId, out int messageIdInt))
                {
                    await Clients.Caller.SendAsync("MarkAsReadError", "Invalid message ID");
                    return;
                }

                if (!int.TryParse(userId, out int userIdInt))
                {
                    await Clients.Caller.SendAsync("MarkAsReadError", "Invalid user ID");
                    return;
                }

                await _messageService.MarkMessagesAsRead(chatRoomIdInt, userIdInt);
             
                var readReceipt = new
                {
                    ChatRoomId = chatRoomId,
                    MessageId = messageId,
                    UserId = userId,
                    ReadAt = DateTime.UtcNow
                };

              
                await Clients.OthersInGroup($"ChatRoom_{chatRoomId}").SendAsync("MessageRead", readReceipt);
    
                await Clients.Caller.SendAsync("MessageMarkedAsRead", readReceipt);
                
            
            }
            catch (Exception ex)
            {
                await Clients.Caller.SendAsync("MarkAsReadError", ex.Message);
            }
        }

  
        public async Task GetChatRoomMembers(string chatRoomId)
        {
            try
            {
                
                if (int.TryParse(chatRoomId, out int chatRoomIdInt))
                {
                    var members = await _context.ChatRoomUsers
                        .Where(m => m.ChatRoomId == chatRoomIdInt && m.IsActive)
                        .Include(m => m.User)
                        .Select(m => new
                        {
                            UserId = m.UserId,
                            UserName = m.User.Name,
                            JoinedDate = m.JoinedDate
                        })
                        .ToListAsync();
                    
                    await Clients.Caller.SendAsync("ChatRoomMembers", chatRoomId, members);
                    
                   
                }
                else
                {
                    await Clients.Caller.SendAsync("GetMembersError", "Invalid chat room ID");
                }
            }
            catch (Exception ex)
            {
                await Clients.Caller.SendAsync("GetMembersError", ex.Message);
            }
        }

        public async Task GetUnreadCount(string userId)
        {
            try
            {
                if (!int.TryParse(userId, out int userIdInt))
                {
                    await Clients.Caller.SendAsync("UnreadCountError", "Invalid user ID");
                    return;
                }

                var unreadCount = await _messageService.GetUnreadMessageCount(userIdInt);
                await Clients.Caller.SendAsync("UnreadCount", unreadCount);
            }
            catch (Exception ex)
            {
                await Clients.Caller.SendAsync("UnreadCountError", ex.Message);
            }
        }

        public async Task GetChatRoomMessages(string chatRoomId)
        {
            try
            {
                if (!int.TryParse(chatRoomId, out int chatRoomIdInt))
                {
                    await Clients.Caller.SendAsync("GetMessagesError", "Invalid chat room ID");
                    return;
                }

                var messages = await _messageService.GetMessagesByChatRoomId(chatRoomIdInt);
                await Clients.Caller.SendAsync("ChatRoomMessages", messages);
            }
            catch (Exception ex)
            {
                await Clients.Caller.SendAsync("GetMessagesError", ex.Message);
            }
        }

        private async Task<List<UnreadCountInfo>> GetUnreadCountsForChatRoom(int chatRoomId, int excludeUserId)
        {
           
            var chatRoom = await _chatRoomService.GetChatRoomWithUsers(chatRoomId);
            var unreadCounts = new List<UnreadCountInfo>();

            foreach (var user in chatRoom.Users.Where(u => u.UserId != excludeUserId))
            {
                var unreadCount = await _messageService.GetUnreadMessageCount(user.UserId);
                unreadCounts.Add(new UnreadCountInfo { UserId = user.UserId, Count = unreadCount });
            }

            return unreadCounts;
        }

        public override async Task OnConnectedAsync()
        {
           
            _userConnections[Context.ConnectionId] = Context.UserIdentifier ?? "anonymous";
            
            await Clients.Caller.SendAsync("Connected", "Welcome to the chat hub!");
            
            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            if (_userConnections.ContainsKey(Context.ConnectionId))
            {
                _userConnections.Remove(Context.ConnectionId);
            }

            await base.OnDisconnectedAsync(exception);
        }
    }
}
