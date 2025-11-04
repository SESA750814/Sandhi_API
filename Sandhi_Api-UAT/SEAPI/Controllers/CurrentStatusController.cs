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
    public class CurrentStatusController : BaseController
    {


        public CurrentStatusController(IWorkOrderRepository seRepository, IMapper mapper, IPropertyCheckerService propertyChecker,
            ILogger<WorkOrderRepository> logger, UserManager<StoreUser> userManager, IConfiguration config)
            : base(seRepository, mapper, propertyChecker, logger, userManager, config)
        {
        }


        [HttpGet(Name = "GetCSS")]
        [Route("GetCSS")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetCSS([FromQuery] CurrentStatusResourceParameter currentParams,
            [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }

                List<Int64> cssIds = new List<Int64>();
                List<CSS> lstCss = new List<CSS>();
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                {
                    lstCss = _seRepository.GetCSS(new CSSResourceParameter() { CSSManagerId = this.UserModel.Id }).ToList();
                    cssIds.AddRange(lstCss.Select(u => u.Id).ToList());
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.FinanceUser))
                {
                   lstCss = _seRepository.GetCSS(new CSSResourceParameter() { FINUserId = this.UserModel.Id }).ToList();
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.SCMUser))
                {
                    lstCss = _seRepository.GetCSS(new CSSResourceParameter() { GRNUserId = this.UserModel.Id }).ToList();
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    lstCss = _seRepository.GetCSS(new CSSResourceParameter() { CSSId = this.UserModel.CSSCode }).ToList();
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    lstCss = _seRepository.GetCSS(new CSSResourceParameter() { CSSId = this.UserModel.CSSCode }).ToList();
                }




                var shapedData = _mapper.Map<IEnumerable<CSSModel>>(lstCss)
                    .ShapeData(currentParams.Fields);

                return Ok(shapedData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Current Status Get CSS:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }


        [HttpGet(Name = "GetCurrentStatus")]
        [Route("GetCurrentStatus")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult CurrentStatus([FromQuery] CurrentStatusResourceParameter currentParams,
            [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
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
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.SCMUser))
                {
                    List<CSS> lstCss = _seRepository.GetCSS(new CSSResourceParameter() { GRNUserId = this.UserModel.Id }).ToList();
                    cssIds.AddRange(lstCss.Select(u => u.Id).ToList());
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    cssIds.Add(Convert.ToInt64(this.UserModel.CSSCode));
                }
                currentParams.CSSIds = cssIds;

                var currentStatus = _seRepository.GetCurrentStatus(currentParams);
                if (currentStatus == null)
                {
                    return StatusCode(StatusCodes.Status404NotFound);
                }

                if (!_propChecker.TypeHasProperties<Invoice>(currentParams.Fields))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }



                var shapedData = _mapper.Map<IEnumerable<CurrentStatusModel>>(currentStatus)
                    .ShapeData(currentParams.Fields);

                return Ok(shapedData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get Current Status:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }



    }
}
