using SE.API.DbContexts;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using SE.API.HostedService;

namespace SE.API
{
    public class Program
    {

        public static void Main(string[] args)
        {
            
            var host = CreateHostBuilder(args).Build();

            // migrate the database.  Best practice = in Main, using service scope
            using (var scope = host.Services.CreateScope())
            {
                try
                {
                    var context = scope.ServiceProvider.GetService<SEDBContext>();
                    // for demo purposes, delete the database & migrate on startup so 
                    // we can start with a clean slate
                    //context.Database.EnsureDeleted();
                    //if (args.Length == 1 && args[0].ToLower() == "/seed")
                    //{
                    var seeder = scope.ServiceProvider.GetService<SESeeder>();
                    seeder.Seed().Wait();
                    //}
                    //context.Database.Migrate();
                }
                catch (Exception ex)
                {
                    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
                    logger.LogError(ex, "An error occurred while migrating the database.");
                }
            }

            // run the web app
            host.Run();
        }
        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                //.ConfigureAppConfiguration(SetupConfiguration)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                })
                .ConfigureServices((hostContext, services) =>
                {
                    services.AddHostedService<HostedBackgroundService>(); // 👈 Add this line
                });
        //private static void SetupConfiguration(HostBuilderContext ctx, IConfigurationBuilder builder)
        //{
        //    builder.Sources.Clear();
        //    builder.AddJsonFile("config.json", false, true);
        //}

    }
}
