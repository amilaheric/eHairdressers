namespace eHairdressers.Auth
{
    // Bound from configuration section "Jwt". The signing Key is never
    // hardcoded or committed to appsettings.json - it is injected at
    // container start from the JWT_SECRET_KEY value in .env via the
    // Jwt__Key environment variable in docker-compose.yml (same pattern
    // used for the Stripe secret key and RabbitMQ credentials).
    public class JwtOptions
    {
        public const string SectionName = "Jwt";

        public string Issuer { get; set; } = "eHairdressers";
        public string Audience { get; set; } = "eHairdressersClient";
        public string Key { get; set; } = string.Empty;
        public int ExpiryMinutes { get; set; } = 120;
    }
}
