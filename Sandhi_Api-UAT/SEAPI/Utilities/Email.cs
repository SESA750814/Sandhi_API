using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.IO;
using System.Net;
using System.Net.Mail;
using System.Threading.Tasks;

namespace SE.API.Utilities
{
    public static class Email
    {
        private static (string toEmail, string ccEmail, string bccEmail) GetTestModeEmails(IConfiguration config, string originalToEmail, string originalCcEmail, string originalBccEmail)
        {
            var isTestMode = config.GetSection("newEnhancement").GetValue<bool>("IsTestMode");
            if (!isTestMode)
            {
                return (originalToEmail, originalCcEmail, originalBccEmail);
            }

            return (
                config.GetSection("newEnhancement").GetValue<string>("TestMailToRecipients") ?? originalToEmail,
                config.GetSection("newEnhancement").GetValue<string>("TestMailCCRecipients") ?? originalCcEmail,
                config.GetSection("newEnhancement").GetValue<string>("TestMailBCCRecipients") ?? originalBccEmail
            );
        }

        public static bool SendEmail(IConfiguration config, ILogger logger, string subject, string body, string toEmail, string ccEmail = "", string bccEmail = "")
        {
            try
            {           
                string fromEmail = config.GetSection("Email").GetValue<String>("From");
                string emailHost = config.GetSection("Email").GetValue<String>("Host");
                string userName = config.GetSection("Email").GetValue<String>("UserName");
                string pwd = config.GetSection("Email").GetValue<String>("Password");

                if (!string.IsNullOrEmpty(config.GetSection("Email").GetValue<String>("Override")))
                {
                    toEmail = config.GetSection("Email").GetValue<String>("Override");
                }

                var (finalToEmail, finalCcEmail, finalBccEmail) = GetTestModeEmails(config, toEmail, ccEmail, bccEmail);

                using (MailMessage mm = new MailMessage(fromEmail, finalToEmail))
                {
                    if (!string.IsNullOrEmpty(finalCcEmail))
                    {
                        mm.CC.Add(finalCcEmail);
                    }

                    if (!string.IsNullOrEmpty(finalBccEmail))
                    {
                        mm.Bcc.Add(finalBccEmail);
                    }

                    mm.Subject = subject;
                    mm.Body = body;
                    mm.IsBodyHtml = true;

                    System.Net.ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
                    SmtpClient smtp = new SmtpClient();
                    smtp.Host = emailHost;
                    smtp.EnableSsl = true;
                    smtp.UseDefaultCredentials = false;
                    NetworkCredential networkCred = new NetworkCredential(userName, pwd);
                    smtp.Credentials = networkCred;
                    smtp.Port = 587;
                    smtp.Send(mm);
                }
                logger.LogInformation($"Mail Sent to: {finalToEmail} with subject: {subject}");
                return true;
            }
            catch (Exception ex)
            {
                logger.LogError($"Error in sending email to: {toEmail} with subject: {subject} {ex}");
                throw;
            }
        }

        public static async Task<bool> SendEmailAsync(IConfiguration config, ILogger logger, string subject, string body, string toEmail, string ccEmail = "", string bccEmail = "")
        {
            try
            {
                string fromEmail = config.GetSection("Email").GetValue<String>("From");
                string emailHost = config.GetSection("Email").GetValue<String>("Host");
                string userName = config.GetSection("Email").GetValue<String>("UserName");
                string pwd = config.GetSection("Email").GetValue<String>("Password");

                if (!string.IsNullOrEmpty(config.GetSection("Email").GetValue<String>("Override")))
                {
                    toEmail = config.GetSection("Email").GetValue<String>("Override");
                }

                var (finalToEmail, finalCcEmail, finalBccEmail) = GetTestModeEmails(config, toEmail, ccEmail, bccEmail);

                using (MailMessage mm = new MailMessage(fromEmail, finalToEmail))
                {
                    if (!string.IsNullOrEmpty(finalCcEmail))
                    {
                        mm.CC.Add(finalCcEmail);
                    }

                    if (!string.IsNullOrEmpty(finalBccEmail))
                    {
                        mm.Bcc.Add(finalBccEmail);
                    }

                    mm.Subject = subject;
                    mm.Body = body;
                    mm.IsBodyHtml = true;

                    System.Net.ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
                    SmtpClient smtp = new SmtpClient();
                    smtp.Host = emailHost;
                    smtp.EnableSsl = true;
                    smtp.UseDefaultCredentials = false;
                    NetworkCredential networkCred = new NetworkCredential(userName, pwd);
                    smtp.Credentials = networkCred;
                    smtp.Port = 587;
                    await smtp.SendMailAsync(mm);
                }
                logger.LogInformation($"Mail Sent to: {finalToEmail} with subject: {subject}");
                return true;
            }
            catch (Exception ex)
            {
                logger.LogError($"Error in sending email to: {toEmail} with subject: {subject} {ex}");
                throw;
            }
        }

        public static bool SendEmail(IConfiguration config, string subject, string body, byte[] pdfBytes, string toEmail, string fileName, string ccEmail = "", string bccEmail = "")
        {
            try
            {
                string fromEmail = config.GetSection("Email").GetValue<String>("From");
                string emailHost = config.GetSection("Email").GetValue<String>("Host");
                string userName = config.GetSection("Email").GetValue<String>("UserName");
                string pwd = config.GetSection("Email").GetValue<String>("Password");

                if (!string.IsNullOrEmpty(config.GetSection("Email").GetValue<String>("Override")))
                {
                    toEmail = config.GetSection("Email").GetValue<String>("Override");
                }

                var (finalToEmail, finalCcEmail, finalBccEmail) = GetTestModeEmails(config, toEmail, ccEmail, bccEmail);

                using (MailMessage mm = new MailMessage(fromEmail, finalToEmail))
                {
                    if (!string.IsNullOrEmpty(finalCcEmail))
                    {
                        mm.CC.Add(finalCcEmail);
                    }

                    if (!string.IsNullOrEmpty(finalBccEmail))
                    {
                        mm.Bcc.Add(finalBccEmail);
                    }

                    mm.Subject = subject;
                    mm.Body = body;
                    mm.IsBodyHtml = true;
                    MemoryStream pdfStream = new MemoryStream(pdfBytes);
                    Attachment pdf = new Attachment(pdfStream, fileName + ".pdf", "application/pdf");
                    mm.Attachments.Add(pdf);
                    SmtpClient smtp = new SmtpClient();
                    smtp.Host = emailHost;
                    smtp.EnableSsl = true;
                    smtp.UseDefaultCredentials = false;
                    NetworkCredential networkCred = new NetworkCredential(userName, pwd);
                    smtp.Credentials = networkCred;
                    smtp.Port = 587;
                    smtp.Send(mm);
                }
                return true;
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        public static bool SendEmail(IConfiguration config, string subject, string body, byte[] pdfBytes, string fileName, byte[] pdfBytes2, string fileName2, byte[] excelbytes, string toEmail, string ccEmail = "", string bccEmail = "")
        {
            try
            {
                string fromEmail = config.GetSection("Email").GetValue<String>("From");
                string emailHost = config.GetSection("Email").GetValue<String>("Host");
                string userName = config.GetSection("Email").GetValue<String>("UserName");
                string pwd = config.GetSection("Email").GetValue<String>("Password");

                if (!string.IsNullOrEmpty(config.GetSection("Email").GetValue<String>("Override")))
                {
                    toEmail = config.GetSection("Email").GetValue<String>("Override");
                }

                var (finalToEmail, finalCcEmail, finalBccEmail) = GetTestModeEmails(config, toEmail, ccEmail, bccEmail);

                using (MailMessage mm = new MailMessage(fromEmail, finalToEmail))
                {
                    if (!string.IsNullOrEmpty(finalCcEmail))
                    {
                        mm.CC.Add(finalCcEmail);
                    }

                    if (!string.IsNullOrEmpty(finalBccEmail))
                    {
                        mm.Bcc.Add(finalBccEmail);
                    }

                    mm.Subject = subject;
                    mm.Body = body;
                    mm.IsBodyHtml = true;

                    if (pdfBytes != null)
                    {
                        MemoryStream pdfStream = new MemoryStream(pdfBytes);
                        Attachment pdf = new Attachment(pdfStream, fileName + ".pdf", "application/pdf");
                        mm.Attachments.Add(pdf);
                    }
                    if (pdfBytes2 != null)
                    {
                        MemoryStream pdfStream2 = new MemoryStream(pdfBytes2);
                        Attachment pdf2 = new Attachment(pdfStream2, fileName2 + ".pdf", "application/pdf");
                        mm.Attachments.Add(pdf2);
                    }
                    if (excelbytes != null)
                    {
                        MemoryStream excelStream = new MemoryStream(excelbytes);
                        Attachment excel = new Attachment(excelStream, fileName + ".xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                        mm.Attachments.Add(excel);
                    }

                    SmtpClient smtp = new SmtpClient();
                    smtp.Host = emailHost;
                    smtp.EnableSsl = true;
                    smtp.UseDefaultCredentials = false;
                    NetworkCredential networkCred = new NetworkCredential(userName, pwd);
                    smtp.Credentials = networkCred;
                    smtp.Port = 587;
                    smtp.Send(mm);
                }
                return true;
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        public static bool EASendEmail(IConfiguration config, ILogger logger, string subject, string body, string toEmail, string ccEmail = "", string bccEmail = "")
        {
            try
            {
                string fromEmail = config.GetSection("Email").GetValue<String>("From");
                string emailHost = config.GetSection("Email").GetValue<String>("Host");
                string userName = config.GetSection("Email").GetValue<String>("UserName");
                string pwd = config.GetSection("Email").GetValue<String>("Password");
                string domain = config.GetSection("Email").GetValue<String>("Domain");
                string adminEmail = config.GetSection("Email").GetValue<String>("Admin");

                if (!string.IsNullOrEmpty(config.GetSection("Email").GetValue<String>("CC")))
                {
                    ccEmail = config.GetSection("Email").GetValue<String>("CC");
                }
                bccEmail = config.GetSection("Email").GetValue<String>("BCC");
                toEmail = config.GetSection("Email").GetValue<String>("Override") != "" ? config.GetSection("Email").GetValue<String>("Override") : toEmail;

                var (finalToEmail, finalCcEmail, finalBccEmail) = GetTestModeEmails(config, toEmail, ccEmail, bccEmail);

                if (config.GetSection("Email").GetValue<String>("UseSMTP") == "yes")
                {
                    using (MailMessage mm = new MailMessage(fromEmail, finalToEmail))
                    {
                        mm.Subject = subject;
                        mm.Body = body;
                        mm.IsBodyHtml = true;

                        System.Net.ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
                        SmtpClient smtp = new SmtpClient();
                        smtp.DeliveryMethod = SmtpDeliveryMethod.Network;
                        smtp.Host = emailHost;
                        smtp.Port = 587;
                        smtp.EnableSsl = true;
                        smtp.UseDefaultCredentials = false;
                        NetworkCredential networkCred = new NetworkCredential(userName, pwd, domain);
                        smtp.Credentials = networkCred;
                        smtp.Timeout = 20000;
                        smtp.Send(mm);
                    }
                }
                else
                {
                    EASendMail.SmtpMail oMail = new EASendMail.SmtpMail(config.GetSection("Email").GetValue<String>("LicenseKey"));
                    oMail.From = fromEmail;
                    oMail.To = finalToEmail;
                    oMail.Subject = subject;
                    oMail.HtmlBody = body;

                    EASendMail.SmtpServer oServer = new EASendMail.SmtpServer(emailHost);
                    oServer.User = userName;
                    oServer.Password = pwd;
                    oServer.Port = Convert.ToInt32(config.GetSection("Email").GetValue<String>("Port"));
                    oServer.ConnectType = EASendMail.SmtpConnectType.ConnectNormal;
                    System.Net.ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
                    EASendMail.SmtpClient oSmtp = new EASendMail.SmtpClient();
                    oSmtp.SendMail(oServer, oMail);
                }

                return true;
            }
            catch (Exception ex)
            {
                logger.LogError("Send Email " + ex.ToString());
                throw;
            }
        }

        public static bool IsEmailValid(string emailaddress)
        {
            try
            {
                if (string.IsNullOrEmpty(emailaddress))
                {
                    return false;
                }

                MailAddress m = new MailAddress(emailaddress);
                return true;
            }
            catch (FormatException)
            {
                return false;
            }
        }
    }
}
