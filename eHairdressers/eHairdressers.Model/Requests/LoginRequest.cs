namespace eHairdressers.Model.Requests
{
    // Sent as the POST body of /User/login - never as query string parameters,
    // per the course rubric's auth requirements.
    public class LoginRequest
    {
        public string Username { get; set; } = null!;
        public string Password { get; set; } = null!;
    }
}
