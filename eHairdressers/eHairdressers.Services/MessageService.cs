using AutoMapper;
using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace eHairdressers.Services
{
    public class MessageService : BaseCRUDService<Model.Message, Database.Message, BaseSearchObject, MessageInsertRequest, object>, IMessageService
    {
        private readonly IUserRoleService _userRoleService;

        public MessageService(eHairdressersContext context, IMapper mapper, IUserRoleService userRoleService) : base(context, mapper)
        {
            _userRoleService = userRoleService;
        }

        public async Task<List<Model.Message>> GetMessagesByChatRoomId(int chatRoomId)
        {
            var messages = await _context.Messages
                .Include(m => m.Sender)
                .Where(m => m.ChatRoomId == chatRoomId)
                .OrderBy(m => m.SentDate)
                .ToListAsync();

            return _mapper.Map<List<Model.Message>>(messages);
        }

        public async Task<int> GetUnreadMessageCount(int userId)
        {
            
            var userChatRoomIds = await _context.ChatRoomUsers
                .Where(cru => cru.UserId == userId && cru.IsActive)
                .Select(cru => cru.ChatRoomId)
                .ToListAsync();

            var unreadCount = await _context.Messages
                .Where(m => userChatRoomIds.Contains(m.ChatRoomId) && 
                           m.SenderId != userId && 
                           !m.IsRead)
                .CountAsync();

            return unreadCount;
        }

        public async Task MarkMessagesAsRead(int chatRoomId, int userId)
        {
           
            var unreadMessages = await _context.Messages
                .Where(m => m.ChatRoomId == chatRoomId && 
                           m.SenderId != userId && 
                           !m.IsRead)
                .ToListAsync();

            foreach (var message in unreadMessages)
            {
                message.IsRead = true;
            }

            await _context.SaveChangesAsync();
        }

        public override async Task<Model.Message> Insert(MessageInsertRequest insert)
        {
           
            var chatRoom = await _context.ChatRooms.FindAsync(insert.ChatRoomId);
            if (chatRoom == null)
            {
                throw new Exception("Chat room not found");
            }

           
            var sender = await _context.User.FindAsync(insert.SenderId);
            if (sender == null)
            {
                throw new Exception("Sender not found");
            }


            var userRoles = await _userRoleService.GetUserRoles(insert.SenderId);
            var primaryRole = userRoles.FirstOrDefault() ?? "Customer"; 

           
            if (string.IsNullOrEmpty(insert.SenderType))
            {
                
                if (await _userRoleService.IsAdmin(insert.SenderId))
                    insert.SenderType = "Admin";
                else if (await _userRoleService.IsEmployee(insert.SenderId))
                    insert.SenderType = "Employee";
                else
                    insert.SenderType = "Customer";
            }

            
            var chatRoomUser = await _context.ChatRoomUsers
                .FirstOrDefaultAsync(cru => cru.ChatRoomId == insert.ChatRoomId && 
                                          cru.UserId == insert.SenderId && 
                                          cru.IsActive);

            
            if (chatRoomUser == null)
            {
                chatRoomUser = new ChatRoomUser
                {
                    ChatRoomId = insert.ChatRoomId,
                    UserId = insert.SenderId,
                    JoinedDate = DateTime.UtcNow,
                    IsActive = true
                };
                
                _context.ChatRoomUsers.Add(chatRoomUser);
                await _context.SaveChangesAsync();
            }

            var message = new Database.Message
            {
                ChatRoomId = insert.ChatRoomId,
                SenderId = insert.SenderId,
                Content = insert.Content,
                SentDate = DateTime.UtcNow,
                IsRead = false,
                SenderType = insert.SenderType ?? primaryRole
            };

            _context.Messages.Add(message);
            await _context.SaveChangesAsync();

            
            var createdMessage = await _context.Messages
                .Include(m => m.Sender)
                .FirstOrDefaultAsync(m => m.MessageId == message.MessageId);

            var mappedMessage = _mapper.Map<Model.Message>(createdMessage);
            
                        
            
            return mappedMessage;
        }
    }
}
