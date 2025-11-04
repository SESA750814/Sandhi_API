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
    public class WorkOrderController : BaseController
    {


        public WorkOrderController(IWorkOrderRepository seRepository, IMapper mapper, IPropertyCheckerService propertyChecker,
            ILogger<WorkOrderRepository> logger, UserManager<StoreUser> userManager, IConfiguration config)
            : base(seRepository, mapper, propertyChecker, logger, userManager, config)
        {
        }



        [HttpGet(Name = "GetList")]
        [Route("GetList")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetWorkOrderList([FromQuery] WorkOrderResourceParameter workOrderResourceParameter,
            [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {
                if (string.IsNullOrEmpty(workOrderResourceParameter.BusinessUnit))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }
                workOrderResourceParameter.Statuses = new List<string>();
                workOrderResourceParameter.UserType = this.UserModel.UserType ?? -1;

                List<Int64> cssIds = new List<Int64>();
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                {
                    List<CSS> lstCss = _seRepository.GetCSS(new CSSResourceParameter() { CSSManagerId = this.UserModel.Id }).ToList();
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
                workOrderResourceParameter.CSSIds = cssIds;
                var workOrder = _seRepository.GetWorkOrderList(workOrderResourceParameter);
                if (workOrder == null)
                {
                    return StatusCode(StatusCodes.Status404NotFound);
                }

                if (!_propChecker.TypeHasProperties<WorkOrder>(workOrderResourceParameter.Fields))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }
                var paginationMetaData = new
                {
                    totalCount = workOrder.TotalCount,
                    pageSize = workOrder.PageSize,
                    currentPage = workOrder.CurrentPage,
                    totalPages = workOrder.TotalPages
                };
                Response.Headers.Add("X-Pagination", JsonSerializer.Serialize(paginationMetaData));


                var shapedData = _mapper.Map<IEnumerable<WorkOrderModel>>(workOrder)
                    .ShapeData(workOrderResourceParameter.Fields);

                return Ok(shapedData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get WO List:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }

        [HttpGet(Name = "GetPreviousMonths")]
        [Route("GetPreviousMonths")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetPreviousMonths([FromHeader(Name = "Accept")] string contentType)
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.CentralUser))
                {
                    return StatusCode(StatusCodes.Status401Unauthorized);
                }


                var prevMonths = _seRepository.GetPreviousMonthsWO();

                return Ok(prevMonths);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get WO List:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }

        [HttpPost(Name = "SetStatus")]
        [Route("SetStatus")]
        public async Task<IActionResult> SetStatus([FromQuery] WorkOrderStatusSubmitParameter woStatusResourceParameter)
        {
            try 
            { 
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.CentralUser) && (this.UserModel.UserType ?? -1) != ((int)UserType.CSSUser)
                    && (this.UserModel.UserType ?? -1) != ((int)UserType.CSSManager))
                {
                    return Unauthorized();
                }
                _logger.LogInformation("Inside setstatus");
                // Set Status value based on the user and status value.
                string errString = "";
                if (!CheckStatus(woStatusResourceParameter, out errString))
                {
                    _logger.LogInformation("CheckStatus failed");
                    return StatusCode(StatusCodes.Status400BadRequest, new ResponseModel { Status = "Bad Request", Message = errString });
                }
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CentralUser))
                {
                    woStatusResourceParameter.Status = ((int)(woStatusResourceParameter.Status.Trim().ToLower() == "approved" ? StatusType.Central_Approved : StatusType.Central_Rejected)).ToString();
                    woStatusResourceParameter.BusinessUnit = string.Empty;

                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    woStatusResourceParameter.Status = ((int)(woStatusResourceParameter.Status.Trim().ToLower() == "approved" ? StatusType.CSS_Approved : (woStatusResourceParameter.Status.Trim().ToLower() == "validated" ? StatusType.CSS_Validated : StatusType.CSS_Discrepancy))).ToString();
                    woStatusResourceParameter.CSSId = Convert.ToInt64(this.UserModel.CSSCode);

                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                {
                    woStatusResourceParameter.Status = ((int)(woStatusResourceParameter.Status.Trim().ToLower() == "approved" ? StatusType.CSS_MGR_Approved : (woStatusResourceParameter.Status.Trim().ToLower() == "discrepencyapproved" ? StatusType.CSS_MGR_Approve_Discrepancy : StatusType.CSS_MGR_Discrepancy))).ToString();
                }

                if (ModelState.IsValid)
                {
                    _logger.LogInformation("Going to Set Work Order Status: "+ woStatusResourceParameter.Month+" "+ woStatusResourceParameter.Status);
                    woStatusResourceParameter.UserName = this.UserModel.UserName;
                    var retVal = _seRepository.SetWorkOrderStatus(woStatusResourceParameter, _logger, _config);
                    if (retVal == true)
                    {
                        try
                        {
                            await SendEmail();
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError("Error in Invoice SetStatus:" + ex.Message);
                        }
                        return StatusCode(StatusCodes.Status200OK);
                    }
                }
                return StatusCode(StatusCodes.Status200OK);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in WO Set Status :" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                return BadRequest();
            }
        }

        private bool CheckStatus(WorkOrderStatusSubmitParameter woStatusResourceParameter, out string errString)
        {
            string tmpString = "";
            if (string.IsNullOrEmpty(woStatusResourceParameter.Status))
            {
                tmpString += "Enter a valid Status<br/>";
            }
            if (string.IsNullOrEmpty(woStatusResourceParameter.Month))
            {
                tmpString += "Enter a valid Month<br/>";
            }
            if (string.IsNullOrEmpty(woStatusResourceParameter.BusinessUnit))
            {
                tmpString += "Enter a valid BusinessUnit<br/>";
            }
            if (((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser) || (this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                && (woStatusResourceParameter.Status.Trim().ToLower() != "approved" && woStatusResourceParameter.Status.Trim().ToLower() != "validated")
                && string.IsNullOrEmpty(woStatusResourceParameter.WOIds))
            {
                tmpString += "Enter a valid Work Order";
            }

            errString = tmpString;
            if (!string.IsNullOrEmpty(tmpString))
            {
                return false;
            }
            return true;
        }
        [HttpGet(Name = "GetListByCSS")]
        [Route("GetListByCSS")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetWorkOrderListByCSS([FromQuery] WorkOrderResourceParameter workOrderResourceParameter,
           [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if ((this.UserModel.UserType ?? -1) != ((int)UserType.CSSManager))
                {
                    return StatusCode(StatusCodes.Status401Unauthorized);
                }

                if (string.IsNullOrEmpty(workOrderResourceParameter.BusinessUnit))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }
                workOrderResourceParameter.Statuses = new List<string>();
                workOrderResourceParameter.UserType = this.UserModel.UserType ?? -1;



                List<CSS> lstCSS = _seRepository.GetCSSWithWorkOrderByMonth(new CSSResourceParameter()
                {
                    CSSManagerId = this.UserModel.Id,
                    BusinessUnit = workOrderResourceParameter.BusinessUnit,
                    Month = workOrderResourceParameter.Month
                }).ToList();
                if (lstCSS == null)
                {
                    return StatusCode(StatusCodes.Status404NotFound);
                }

                if (!_propChecker.TypeHasProperties<WorkOrder>(workOrderResourceParameter.Fields))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }


                //var paginationMetaData = new
                //{
                //    totalCount = workOrder.TotalCount,
                //    pageSize = workOrder.PageSize,
                //    currentPage = workOrder.CurrentPage,
                //    totalPages = workOrder.TotalPages
                //};
                //Response.Headers.Add("X-Pagination", JsonSerializer.Serialize(paginationMetaData));


                var shapedData = _mapper.Map<IEnumerable<WorkOrderByCSSModel>>(lstCSS)
                    .ShapeData(workOrderResourceParameter.Fields);

                return Ok(shapedData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get WO By CSS:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }



    }
}
