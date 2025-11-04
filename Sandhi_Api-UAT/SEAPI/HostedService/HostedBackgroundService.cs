using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System.Threading;
using System;
using System.Threading.Tasks;
using SE.API.Services;
using DocumentFormat.OpenXml.Office2010.ExcelAc;
using SE.API.Entities;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace SE.API.HostedService
{
    public class HostedBackgroundService : BackgroundService
    {
        private readonly ILogger<HostedBackgroundService> _logger;
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly IConfiguration _config;

        public HostedBackgroundService(ILogger<HostedBackgroundService> logger, IConfiguration config, IServiceScopeFactory scopeFactory)
        {
            _logger = logger;
            _config = config;
            _scopeFactory = scopeFactory;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {

            while (!stoppingToken.IsCancellationRequested)
            {
                _logger.LogInformation("start at: {time}", DateTime.Now.ToString("HH:mm:ss"));

                await ResendFailedCollectorEmailsAsync(stoppingToken);
                await EscaltionEmailAlertAsync(stoppingToken);

                // Start timers for periodic execution
                var hourlyTask = RunHourlyTaskAsync(stoppingToken);
                var dailyTask = RunDailyTaskAsync(stoppingToken);

                await Task.WhenAll(hourlyTask, dailyTask);
            }
        }
        private async Task RunHourlyTaskAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                int? minute = _config.GetSection("HostedService").GetValue<int>("RunIntervalMinutes");
                await Task.Delay(TimeSpan.FromHours(minute ?? 60), stoppingToken);
                await ResendFailedCollectorEmailsAsync(stoppingToken);
            }
        }

        private async Task RunDailyTaskAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                DateTime now = DateTime.Now;
                DateTime nextRun = now.Date.AddDays(1); // Next 12 AM
                TimeSpan delay = nextRun - now;

                _logger.LogInformation("EscalationEmailAlertAsync current scheduled at: {time}", now.ToString("yyyy-MM-dd HH:mm:ss"));
                _logger.LogInformation("EscalationEmailAlertAsync Next scheduled at: {time}", nextRun.ToString("yyyy-MM-dd HH:mm:ss"));

                await Task.Delay(delay, stoppingToken);
                await EscaltionEmailAlertAsync(stoppingToken);

            }
        }

        private async Task ResendFailedCollectorEmailsAsync(CancellationToken cancellationToken)
        {
            try
            {
                _logger.LogInformation("ResendFailedCollectorEmailsAsync called at: {time}", DateTime.Now.ToString("HH:mm:ss"));

                using var scope = _scopeFactory.CreateScope();
                var repository = scope.ServiceProvider.GetRequiredService<IWorkOrderRepository>();

                var invoices = await repository.GetUnsentCollectorInvoices(cancellationToken);
                foreach (var invoice in invoices)
                {
                    // Process each work order
                    _logger.LogInformation("Processing resending collector invoice ID: {id}", invoice.Id);
                    //repository.SendCollectorEmail(invoice.Id, _logger, _config);
                }
            }
            catch (Exception ex)
            {
                //_logger.LogError(ex, "Error while resending collector emails.");
            }
        }

        private async Task EscaltionEmailAlertAsync(CancellationToken cancellationToken)
        {
            bool IsTATEscalationEmailSend = _config.GetSection("newEnhancement").GetValue<bool>("IsTATEscalationEmailSend");
            if (IsTATEscalationEmailSend)
            {
                _logger.LogInformation("!!!!EscaltionEmailAlertAsync Feature flage is true and start!!!!!!");

                using var scope = _scopeFactory.CreateScope();
                var repository = scope.ServiceProvider.GetRequiredService<IWorkOrderRepository>();

                var task1 = Task.Run(async () =>
                {
                    try
                    {
                        await repository.CheckAndSendOverdueEmails_CSS(cancellationToken, _config, _logger);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Error in CheckAndSendOverdueEmails_CSS");
                    }
                });

                //var task2 = Task.Run(async () =>
                //{
                //    try
                //    {
                //        await repository.CheckAndSendOverdueEmails_Invoice(cancellationToken, _config, _logger);
                //    }
                //    catch (Exception ex)
                //    {
                //        _logger.LogError(ex, "Error in CheckAndSendOverdueEmails_Invoice");
                //    }
                //});

                await Task.WhenAll(task1);
            }
            else
            {
                _logger.LogInformation("!!!!EscaltionEmailAlertAsync Feature flage is False!!!!!!");

            }
        }

    }
}
