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
    public class GradationController : BaseController
    {


        public GradationController(IWorkOrderRepository seRepository, IMapper mapper, IPropertyCheckerService propertyChecker,
            ILogger<WorkOrderRepository> logger, UserManager<StoreUser> userManager, IConfiguration config)
            : base(seRepository, mapper, propertyChecker, logger, userManager, config)
        {
        }



        [HttpGet(Name = "GetGradationList")]
        [Route("GetGradationList")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetGradationList([FromQuery] GradationResourceParameter gradeResourceParameter,
            [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.CSSManager)
                    && (this.UserModel.UserType ?? -1) != ((int)UserType.CSSUser)
                    && (this.UserModel.UserType ?? -1) != ((int)UserType.CentralUser)
                    && (this.UserModel.UserType ?? -1) != ((int)UserType.FinanceUser)
                    )
                {
                    return Unauthorized();
                }


                List<Int64> cssIds = new List<Int64>();
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                {
                    List<CSS> lstCss = _seRepository.GetCSS(new CSSResourceParameter() { CSSManagerId = this.UserModel.Id }).ToList();
                    cssIds.AddRange(lstCss.Select(u => u.Id).ToList());
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.FinanceUser))
                {
                    List<CSS> lstCss = _seRepository.GetCSS(new CSSResourceParameter() { FINUserId = this.UserModel.Id }).ToList();
                    cssIds.AddRange(lstCss.Select(u => u.Id).ToList());
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    cssIds.Add(Convert.ToInt64(this.UserModel.CSSCode));
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.CentralUser))
                {
                    //workOrderResourceParameter.Statuses.Add(((Int32)StatusType.Imported).ToString());
                }
                gradeResourceParameter.CSSIds = cssIds;
                var css = _seRepository.GetGradation(gradeResourceParameter);
                if (css == null)
                {
                    return StatusCode(StatusCodes.Status404NotFound);
                }

                if (!_propChecker.TypeHasProperties<WorkOrder>(gradeResourceParameter.Fields))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }

                var shapedData = _mapper.Map<IEnumerable<GradationByCSSModel>>(css)
                    .ShapeData(gradeResourceParameter.Fields);

                return Ok(shapedData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get Gradation:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }



    }
}
