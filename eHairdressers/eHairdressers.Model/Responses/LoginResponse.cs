using System;
using System.Collections.Generic;

namespace eHairdressers.Model.Responses
{
    // Returned by POST /User/login. The mobile/desktop apps store Token and
    // send it as "Authorization: Bearer {Token}" on every subsequent request.
    public class LoginResponse
    {
        public string Token { get; set; } = null!;
        public DateTime ExpiresAtUtc { get; set; }
        public int UserId { get; set; }
        public string Username { get; set; } = null!;
        public string Name { get; set; } = null!;
        public string? Email { get; set; }
        public List<string> Roles { get; set; } = new List<string>();
    }
}
