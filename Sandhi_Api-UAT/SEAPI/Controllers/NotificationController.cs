using AutoMapper;
using SE.API.Entities;
using SE.API.Helpers;
using SE.API.Models;
using SE.API.Services;
using Marvin.Cache.Headers;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.JsonPatch;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using SE.API.ResourceParameters;
using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Http;

namespace SE.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [ResponseCache(CacheProfileName = "240SecsCacheProfile")]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public class NotificationController : BaseController
    {


        public NotificationController(IWorkOrderRepository seRepository, IMapper mapper, IPropertyCheckerService propertyChecker,
            ILogger<WorkOrderRepository> logger, UserManager<StoreUser> userManager, IConfiguration config)
            : base(seRepository, mapper, propertyChecker, logger, userManager, config)
        {
        }


        [HttpGet(Name = "GetNotifications")]
        [Route("GetNotifications")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetNotifications([FromHeader(Name = "Accept")] string contentType)
        {
            try
            {
                NotificationResourceParameter notifyParams = new NotificationResourceParameter();

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }

                List<Int64> cssIds = new List<Int64>();
                List<CSS> lstCss = new List<CSS>();
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager)
                    || (this.UserModel.UserType ?? -1) == ((int)UserType.FinanceUser)
                    || (this.UserModel.UserType ?? -1) == ((int)UserType.SCMUser)
                    )
                {
                    notifyParams.UserId = this.UserModel.Id;
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.CentralUser))
                {
                    notifyParams.UserType = this.UserModel.UserType.ToString();
                }

                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    notifyParams.CSSId = Convert.ToInt64(this.UserModel.CSSCode);
                }

                List<Notification> lstNotify = _seRepository.GetNotification(notifyParams).ToList();


                var shapedData = _mapper.Map<IEnumerable<NotificationModel>>(lstNotify)
                    .ShapeData(notifyParams.Fields);

                return Ok(shapedData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get Notification:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }


        [HttpPost(Name = "UpdateNotification")]
        [Route("UpdateNotification")]
        /*
         * Parameters required is notificationid
         */
        public  IActionResult UpdateNotification(NotificationResourceParameter notifyParams)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var retVal = _seRepository.SetNotificationStatus(notifyParams);
                    if (retVal == true)
                    {
                        return StatusCode(StatusCodes.Status200OK);
                    }
                }
                return BadRequest();
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Set Notification:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                return BadRequest();
            }
        }

    }
}
