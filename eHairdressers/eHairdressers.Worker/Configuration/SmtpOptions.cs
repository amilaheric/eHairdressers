namespace eHairdressers.Worker.Configuration
{
    // Bound from the "Smtp" section in appsettings.json / environment variables.
    // Never hardcode these values in source code.
    public class SmtpOptions
    {
        public string Host { get; set; } = string.Empty;
        public int Port { get; set; } = 587;
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public bool UseSsl { get; set; } = true;
        public string FromAddress { get; set; } = string.Empty;
        public string FromName { get; set; } = "eHairdressers";
    }
}
