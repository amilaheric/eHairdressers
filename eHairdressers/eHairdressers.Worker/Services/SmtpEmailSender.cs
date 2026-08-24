using System.Net;
using System.Net.Mail;
using eHairdressers.Worker.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace eHairdressers.Worker.Services
{
    // Sends real emails via SMTP using config from appsettings ("Smtp" section).
    // If no SMTP host is configured (e.g. local/dev environment without real
    // credentials), it logs instead of throwing, so the worker keeps running.
    public class SmtpEmailSender : IEmailSender
    {
        private readonly SmtpOptions _options;
        private readonly ILogger<SmtpEmailSender> _logger;

        public SmtpEmailSender(IOptions<SmtpOptions> options, ILogger<SmtpEmailSender> logger)
        {
            _options = options.Value;
            _logger = logger;
        }

        public async Task SendAsync(string toEmail, string toName, string subject, string body, CancellationToken cancellationToken = default)
        {
            if (string.IsNullOrWhiteSpace(_options.Host))
            {
                _logger.LogInformation(
                    "SMTP not configured (Smtp:Host is empty) - skipping real email send. Would have sent '{Subject}' to {ToEmail}.",
                    subject, toEmail);
                return;
            }

            if (string.IsNullOrWhiteSpace(toEmail))
            {
                _logger.LogWarning("Cannot send email '{Subject}' - recipient address is empty.", subject);
                return;
            }

            try
            {
                using var client = new SmtpClient(_options.Host, _options.Port)
                {
                    EnableSsl = _options.UseSsl,
                    Credentials = string.IsNullOrWhiteSpace(_options.Username)
                        ? CredentialCache.DefaultNetworkCredentials
                        : new NetworkCredential(_options.Username, _options.Password)
                };

                using var message = new MailMessage
                {
                    From = new MailAddress(_options.FromAddress, _options.FromName),
                    Subject = subject,
                    Body = body,
                    IsBodyHtml = false
                };
                message.To.Add(new MailAddress(toEmail, toName));

                await client.SendMailAsync(message, cancellationToken);
                _logger.LogInformation("Email '{Subject}' sent to {ToEmail}.", subject, toEmail);
            }
            catch (Exception ex)
            {
                // Never let a failed email crash the consumer - just log it.
                _logger.LogError(ex, "Failed to send email '{Subject}' to {ToEmail}.", subject, toEmail);
            }
        }
    }
}
