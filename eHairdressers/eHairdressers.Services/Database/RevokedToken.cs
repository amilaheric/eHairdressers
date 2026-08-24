using System;
using System.ComponentModel.DataAnnotations;

namespace eHairdressers.Services.Database
{
    // Stores JWT ids (jti) that were explicitly revoked via /User/logout,
    // so a token can be invalidated server-side instead of only being
    // discarded on the client. Checked on every request in Program.cs's
    // JwtBearerEvents.OnTokenValidated.
    public class RevokedToken
    {
        [Key]
        public int RevokedTokenId { get; set; }

        public string Jti { get; set; }

        public DateTime ExpiresAtUtc { get; set; }

        public DateTime RevokedAtUtc { get; set; }
    }
}
