using AutoMapper;
using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using SE.API.Entities;
using SE.API.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using SE.API.Utilities;

namespace SE.API.Controllers
{
    public class BaseController : ControllerBase
    {
        protected StoreUser _userModel = null;
        protected IWorkOrderRepository _seRepository;
        protected IMapper _mapper;
        protected IPropertyCheckerService _propChecker;
        protected readonly IConfiguration _config;
        protected UserManager<StoreUser> _userManager;

        protected ILogger<WorkOrderRepository> _logger;
        // Sorting  is ignored here if needed look at ways to do it...
        // think sorting can be achieved by extension method
        // implementing shaping

        public BaseController(IWorkOrderRepository seRepository, IMapper mapper, IPropertyCheckerService propertyChecker,
            ILogger<WorkOrderRepository> logger, UserManager<StoreUser> userManager, IConfiguration config)
        {
            _seRepository = seRepository ?? throw new ArgumentNullException(nameof(seRepository));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _mapper = mapper ?? throw new ArgumentNullException(nameof(mapper));
            _propChecker = propertyChecker ?? throw new ArgumentNullException(nameof(propertyChecker));
            _config = config;
            _userManager = userManager;
        }
        // Populated user model from auth token
        public StoreUser UserModel
        {
            get
            {
                if (this._userModel == null)
                {
                    this._userModel = GetCurrentUser().Result;
                }

                return _userModel;
            }
        }

        public async Task<StoreUser> GetCurrentUser()
        {
            StoreUser user = await _userManager.FindByNameAsync(this.User.Identity.Name);
            return user;
        }

        protected async Task SendEmail()
        {
            try
            {

                if (_config.GetSection("Email").GetValue<String>("SendEmail") == "yes")
                {
                    List<Notification> notifications = _seRepository.GetNotification(new ResourceParameters.NotificationResourceParameter() { IsEmail = "yes" }).ToList();
                    foreach (Notification notification in notifications)
                    {
                        string template = "{{BODY}}";
                        string userEmail = notification.ToEmail.Substring(0, notification.ToEmail.IndexOf('@')).ToUpper().Replace(".", " ");
                        if ((notification.CSS_Id ?? -1) != -1)
                        {
                            template = _config.GetSection("EmailTemplate").GetValue<String>("CSS");
                        }
                        else if (!string.IsNullOrEmpty(notification.User_Id))
                        {
                            template = _config.GetSection("EmailTemplate").GetValue<String>("CSSMANAGER");
                        }
                        else if (!string.IsNullOrEmpty(notification.User_Type))
                        {
                            template = _config.GetSection("EmailTemplate").GetValue<String>("CENTRAL");
                        }
                        template = template.Replace("{{BODY}}", notification.Body);
                        template = template.Replace("{{USER}}", userEmail);
                        try
                        {
                            Email.SendEmail(_config, _logger, notification.SUBJECT, template, notification.ToEmail);
                        }
                        catch (Exception e)
                        {
                            _logger.LogError("ERROR IN SEND EMAIL1 :" + notification.ToEmail + " " + e.Message + " " + e.InnerException);
                            throw;
                        }

                        //Update Notification
                        notification.Email_Date = DateTime.Now;
                        _seRepository.UpdateEntity(notification);
                        _seRepository.Save();

                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError("ERROR IN SEND EMAIL :" + ex.InnerException + "  " + ex.Message );
                throw;
            }
        }


    
    }
}
