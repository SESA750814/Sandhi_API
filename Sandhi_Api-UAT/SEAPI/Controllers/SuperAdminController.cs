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
    public class SuperAdminController : BaseController
    {


        public SuperAdminController(IWorkOrderRepository seRepository, IMapper mapper, IPropertyCheckerService propertyChecker,
            ILogger<WorkOrderRepository> logger, UserManager<StoreUser> userManager, IConfiguration config)
            : base(seRepository, mapper, propertyChecker, logger, userManager, config)
        {
        }

        [HttpPost(Name = "GetInvoices")]
        [Route("GetInvoices")]
        public async Task<IActionResult> GetInvoices([FromBody] InvoiceFilter filter)
        {

            if ((this.UserModel.UserType ?? -1) != ((int)UserType.SuperAdmin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }

            var invoices =await _seRepository.GetInvoices(filter);
            var shapedData = _mapper.Map<IEnumerable<InvoiceModel>>(invoices);
            return Ok(new
            {
                status = 200,
                data = shapedData
            });
        }

        [HttpPost(Name = "GetWorkOrder")]
        [Route("GetWorkOrder")]
        public async Task<IActionResult> GetWorkOrder([FromBody] WorkOrderFilter filter)
        {

            if ((this.UserModel.UserType ?? -1) != ((int)UserType.SuperAdmin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }

            var workOrders = await _seRepository.GetWorkOrder(filter);
            var shapedData = _mapper.Map<IEnumerable<WorkOrderModel>>(workOrders);
            return Ok(new
            {
                status = 200,
                data = shapedData
            });
        }

        [HttpPost(Name = "RevertStatus")]
        [Route("RevertStatus")]
        public async Task<IActionResult> RevertStatus([FromBody] RevertInvoiceStatus revertInvoiceStatus)
        {

            if ((this.UserModel.UserType ?? -1) != ((int)UserType.SuperAdmin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }

            if(revertInvoiceStatus.From_Status == null || revertInvoiceStatus.To_Status == null)
            {
                return Ok(new ResponseModel { StatusCode = StatusCodes.Status204NoContent, Message = "Please Select From and To Status" });
            }

            var result = await _seRepository.RevertInvoiceStatus(revertInvoiceStatus, this.UserModel.UserName);
            if (result)
            {
                return Ok(new ResponseModel { Status = "Success", Message = "Revert Status Successfully!!!" });
            }
            else
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Revert Failed." });
            }
        }

        [HttpGet]
        [Route("GetRateCard")]
        public ActionResult GetRateCard()
        {

            if ((this.UserModel.UserType ?? -1) != ((int)UserType.SuperAdmin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }

            var cooling = _seRepository.GetCoolingRateCard();
            var hbn = _seRepository.GetHBNRateCard();
            var ppi = _seRepository.GetPSIRateCard();

            var coolingModel = _mapper.Map<IEnumerable<RateCardCoolingModel>>(cooling);
            var hbnModel = _mapper.Map<IEnumerable<RateCardHBNModel>>(hbn);
            var ppiModel = _mapper.Map<IEnumerable<RateCardPPIModel>>(ppi);

            return Ok(new
            {
                status = StatusCode(StatusCodes.Status200OK),
                cooling = coolingModel,
                hbn = hbnModel,
                ppi = ppiModel,
            });
        }

        [HttpPost(Name = "InsertPPIRateCard")]
        [Route("InsertPPIRateCard")]
        public IActionResult InsertPPIRateCard(RateCardPPIModel currentParam)
        {
            if ((this.UserModel.UserType ?? -1) != ((int)UserType.SuperAdmin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }
            if (ModelState.IsValid)
            {

                var result = _seRepository.InsertPPIRateCard(currentParam);
                if (result)
                {
                    return Ok(new ResponseModel { Status = "Success", Message = "Rate Card Inserted Successfully!!!" });
                }
                else
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Insert Failed." });
                }

            }
            return BadRequest();
        }

        [HttpPost(Name = "UpdatePPIRateCard")]
        [Route("UpdatePPIRateCard")]
        public IActionResult UpdatePPIRateCard(RateCardPPIModel currentParam)
        {
            if ((this.UserModel.UserType ?? -1) != ((int)UserType.SuperAdmin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }
            if (ModelState.IsValid)
            {


                var result = _seRepository.UpdatePPIRateCard(currentParam);
                if (result)
                {
                    return Ok(new ResponseModel { Status = "Success", Message = "Rate Card Updated Successfully!!!" });
                }
                else
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Update Failed." });
                }

            }
            return BadRequest();
        }

        [HttpPost(Name = "InsertHBNRateCard")]
        [Route("InsertHBNRateCard")]
        public IActionResult InsertHBNRateCard(RateCardHBNModel currentParam)
        {
            if ((this.UserModel.UserType ?? -1) != ((int)UserType.SuperAdmin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }
            if (ModelState.IsValid)
            {

                var result = _seRepository.InsertHBNRateCard(currentParam);
                if (result)
                {
                    return Ok(new ResponseModel { Status = "Success", Message = "Rate Card Inserted Successfully!!!" });
                }
                else
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Insert Failed." });
                }

            }
            return BadRequest();
        }

        [HttpPost(Name = "UpdateHBNRateCard")]
        [Route("UpdateHBNRateCard")]
        public IActionResult UpdateHBNRateCard(RateCardHBNModel currentParam)
        {
            if ((this.UserModel.UserType ?? -1) != ((int)UserType.SuperAdmin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }
            if (ModelState.IsValid)
            {

                var result = _seRepository.UpdateHBNRateCard(currentParam);
                if (result)
                {
                    return Ok(new ResponseModel { Status = "Success", Message = "Rate Card Updated Successfully!!!" });
                }
                else
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Update Failed." });
                }

            }
            return BadRequest();
        }


        [HttpPost(Name = "InsertCoolingRateCard")]
        [Route("InsertCoolingRateCard")]
        public IActionResult InsertCoolingRateCard(RateCardCoolingModel currentParam)
        {
            if ((this.UserModel.UserType ?? -1) != ((int)UserType.SuperAdmin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }
            if (ModelState.IsValid)
            {

                var result = _seRepository.InsertCoolingRateCard(currentParam);
                if (result)
                {
                    return Ok(new ResponseModel { Status = "Success", Message = "Rate Card Inserted Successfully!!!" });
                }
                else
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Insert Failed." });
                }

            }
            return BadRequest();
        }

        [HttpPost(Name = "UpdateCoolingRateCard")]
        [Route("UpdateCoolingRateCard")]
        public IActionResult UpdateCoolingRateCard(RateCardCoolingModel currentParam)
        {
            if ((this.UserModel.UserType ?? -1) != ((int)UserType.SuperAdmin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }
            if (ModelState.IsValid)
            {

                var result = _seRepository.UpdateCoolingRateCard(currentParam);
                if (result)
                {
                    return Ok(new ResponseModel { Status = "Success", Message = "Rate Card Updated Successfully!!!" });
                }
                else
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Update Failed." });
                }

            }
            return BadRequest();
        }



        [HttpPost(Name = "UploadPPIRateCard")]
        [Route("UploadPPIRateCard")]
        public IActionResult UploadPPIRateCard()
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.SuperAdmin))
                {
                    return StatusCode(StatusCodes.Status401Unauthorized);
                }
                if (this.ModelState.IsValid)
                {
                    if (this._seRepository.UploadPPIRateCard())
                        return (IActionResult)this.Ok((object)new ResponseModel()
                        {
                            Status = "Success",
                            Message = "PPI RateCard Uploaded Successfully!!!"
                        });
                    return (IActionResult)this.StatusCode(500, (object)new ResponseModel()
                    {
                        Status = "Error",
                        Message = "Update Failed."
                    });
                }
            }
            catch (Exception ex)
            {
                LoggerExtensions.LogError((ILogger)this._logger, "Error in admin/UploadPPIProduct:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString(), Array.Empty<object>());
            }
            return (IActionResult)this.BadRequest();
        }

        [HttpPost(Name = "UploadHBNRateCard")]
        [Route("UploadHBNRateCard")]
        public IActionResult UploadHBNRateCard()
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.SuperAdmin))
                {
                    return StatusCode(StatusCodes.Status401Unauthorized);
                }
                if (this.ModelState.IsValid)
                {
                    if (this._seRepository.UploadHBNRateCard())
                        return (IActionResult)this.Ok((object)new ResponseModel()
                        {
                            Status = "Success",
                            Message = "HBN Rate Card Uploaded Successfully!!!"
                        });
                    return (IActionResult)this.StatusCode(500, (object)new ResponseModel()
                    {
                        Status = "Error",
                        Message = "Update Failed."
                    });
                }
            }
            catch (Exception ex)
            {
                LoggerExtensions.LogError((ILogger)this._logger, "Error in admin/UploadPPIProduct:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString(), Array.Empty<object>());
            }
            return (IActionResult)this.BadRequest();
        }


        [HttpPost(Name = "UploadCoolingRateCard")]
        [Route("UploadCoolingRateCard")]
        public IActionResult UploadCoolingRateCard()
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.SuperAdmin))
                {
                    return StatusCode(StatusCodes.Status401Unauthorized);
                }
                if (this.ModelState.IsValid)
                {
                    if (this._seRepository.UploadCoolingRateCard())
                        return (IActionResult)this.Ok((object)new ResponseModel()
                        {
                            Status = "Success",
                            Message = "Cooling RateCard Uploaded Successfully!!!"
                        });
                    return (IActionResult)this.StatusCode(500, (object)new ResponseModel()
                    {
                        Status = "Error",
                        Message = "Update Failed."
                    });
                }
            }
            catch (Exception ex)
            {
                LoggerExtensions.LogError((ILogger)this._logger, "Error in admin/UploadPPIProduct:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString(), Array.Empty<object>());
            }
            return (IActionResult)this.BadRequest();
        }
    }
}
