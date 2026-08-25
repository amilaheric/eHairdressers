using AutoMapper;
using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace eHairdressers.Services
{
    public class ChatRoomService : BaseCRUDService<Model.ChatRoom, Database.ChatRoom, BaseSearchObject, ChatRoomInsertRequest, object>, IChatRoomService
    {
        public ChatRoomService(eHairdressersContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<List<Model.ChatRoom>> GetChatRoomsByUserId(int userId)
        {
            var chatRooms = await _context.ChatRoomUsers
                .Include(cru => cru.ChatRoom)
                .Include(cru => cru.ChatRoom.ChatRoomUsers)
                .ThenInclude(cru => cru.User)
                .Where(cru => cru.UserId == userId && cru.IsActive && cru.ChatRoom.IsActive)
                .Select(cru => cru.ChatRoom)
                .ToListAsync();

            return _mapper.Map<List<Model.ChatRoom>>(chatRooms);
        }

        public override IQueryable<Database.ChatRoom> AddFilter(IQueryable<Database.ChatRoom> query, BaseSearchObject? search = null)
        {
            return query.Where(cr => cr.IsActive);
        }

        public async Task<int> DeactivateInactiveChatRooms(int retentionDays)
        {
            var cutoffDate = DateTime.UtcNow.AddDays(-retentionDays);

            var candidateRooms = await _context.ChatRooms
                .Where(cr => cr.IsActive)
                .Include(cr => cr.Messages)
                .ToListAsync();

            var roomsToDeactivate = candidateRooms.Where(cr =>
            {
                var lastActivity = cr.Messages.Any()
                    ? cr.Messages.Max(m => m.SentDate)
                    : cr.CreatedDate;

                return lastActivity < cutoffDate;
            }).ToList();

            foreach (var room in roomsToDeactivate)
            {
                room.IsActive = false;
            }

            if (roomsToDeactivate.Count > 0)
            {
                await _context.SaveChangesAsync();
            }

            return roomsToDeactivate.Count;
        }

        // A chat room's "customer" is whichever Customer-role user is first
        // to join it. Any Admin/Employee can always join (that's the support
        // side), but a second, different Customer-role user cannot join a
        // room that already has one - each support chat belongs to exactly
        // one customer.
        public async Task<(bool Allowed, string? Error)> CanUserJoinAsync(int chatRoomId, int userId)
        {
            var isCustomer = await IsUserInRoleAsync(userId, "Customer");
            if (!isCustomer)
            {
                return (true, null);
            }

            var activeMemberIds = await _context.ChatRoomUsers
                .Where(cru => cru.ChatRoomId == chatRoomId && cru.IsActive && cru.UserId != userId)
                .Select(cru => cru.UserId)
                .ToListAsync();

            if (activeMemberIds.Count == 0)
            {
                return (true, null);
            }

            var hasOtherCustomer = await _context.UserRole
                .Include(ur => ur.Role)
                .AnyAsync(ur => activeMemberIds.Contains(ur.UserId) && ur.Role.Name == "Customer");

            if (hasOtherCustomer)
            {
                return (false, "This chat room already has a customer assigned. A customer cannot join another customer's support chat.");
            }

            return (true, null);
        }

        private async Task<bool> IsUserInRoleAsync(int userId, string roleName)
        {
            return await _context.UserRole
                .Include(ur => ur.Role)
                .AnyAsync(ur => ur.UserId == userId && ur.Role.Name == roleName);
        }

        public async Task<Model.ChatRoom> GetChatRoomWithUsers(int chatRoomId)
        {
            var chatRoom = await _context.ChatRooms
                .Include(cr => cr.ChatRoomUsers)
                .ThenInclude(cru => cru.User)
                .Include(cr => cr.Messages)
                .ThenInclude(m => m.Sender)
                .FirstOrDefaultAsync(cr => cr.ChatRoomId == chatRoomId && cr.IsActive);

            if (chatRoom == null)
                throw new Exception("Chat room not found");

            return _mapper.Map<Model.ChatRoom>(chatRoom);
        }

        public override async Task<Model.ChatRoom> Insert(ChatRoomInsertRequest insert)
        {
           
            var users = await _context.User
                .Where(u => insert.UserIds.Contains(u.UserId))
                .ToListAsync();

            if (users.Count != insert.UserIds.Count)
            {
                throw new Exception("One or more users not found");
            }

            var customerCount = 0;
            foreach (var userId in insert.UserIds)
            {
                if (await IsUserInRoleAsync(userId, "Customer"))
                {
                    customerCount++;
                }
            }
            if (customerCount > 1)
            {
                throw new Exception("A chat room can only have one customer.");
            }

            var chatRoom = new Database.ChatRoom
            {
                Name = insert.Name,
                CreatedDate = DateTime.UtcNow,
                IsActive = true
            };

            _context.ChatRooms.Add(chatRoom);
            await _context.SaveChangesAsync();

           
            var chatRoomUsers = insert.UserIds.Select(userId => new Database.ChatRoomUser
            {
                ChatRoomId = chatRoom.ChatRoomId,
                UserId = userId,
                JoinedDate = DateTime.UtcNow,
                IsActive = true
            }).ToList();

            _context.ChatRoomUsers.AddRange(chatRoomUsers);
            await _context.SaveChangesAsync();

            return await GetChatRoomWithUsers(chatRoom.ChatRoomId);
        }
    }
}
