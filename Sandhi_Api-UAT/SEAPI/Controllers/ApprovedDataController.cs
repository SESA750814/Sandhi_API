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
    public class ApprovedDataController : BaseController
    {


        public ApprovedDataController(IWorkOrderRepository seRepository, IMapper mapper, IPropertyCheckerService propertyChecker,
            ILogger<WorkOrderRepository> logger, UserManager<StoreUser> userManager, IConfiguration config)
            : base(seRepository, mapper, propertyChecker, logger, userManager, config)
        {
        }


        [HttpGet(Name = "GetApprovedData")]
        [Route("GetApprovedData")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetApprovedData([FromQuery] ApprovedDataResourceParameter currentParams,
            [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.FinanceUser) && (this.UserModel.UserType ?? -1) != ((int)UserType.CentralUser))
                {
                    return StatusCode(StatusCodes.Status401Unauthorized);
                }
                    List<Int64> cssIds = new List<Int64>();
           
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.FinanceUser))
                {
                    currentParams.FinUserId = this.UserModel.Id;
                }
               

                var approvedData = _seRepository.GetApprovedData(currentParams);
                if (approvedData == null)
                {
                    return StatusCode(StatusCodes.Status404NotFound);
                }

                if (!_propChecker.TypeHasProperties<Invoice>(currentParams.Fields))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }



                var shapedData = _mapper.Map<IEnumerable<ApprovedDataModel>>(approvedData)
                    .ShapeData(currentParams.Fields);

                return Ok(shapedData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in GetApprovedData:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }



    }
}
