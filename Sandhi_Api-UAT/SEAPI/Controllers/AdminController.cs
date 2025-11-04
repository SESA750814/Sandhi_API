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
    public class AdminController : BaseController
    {


        public AdminController(IWorkOrderRepository seRepository, IMapper mapper, IPropertyCheckerService propertyChecker,
            ILogger<WorkOrderRepository> logger, UserManager<StoreUser> userManager, IConfiguration config)
            : base(seRepository, mapper, propertyChecker, logger, userManager, config)
        {
        }


        [HttpGet]
        [Route("GetUsers")]
        public ActionResult GetUsers()
        {
            
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.Admin))
                {
                    return StatusCode(StatusCodes.Status401Unauthorized);
                }
                var result = _seRepository.GetUsers();
               
            
            return Ok(result);
        }
        [HttpPost(Name = "DeleteUser")]
        [Route("DeleteUser")]
        public async Task<IActionResult> DeleteUser([FromBody] DeleteUserModel model)
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.Admin))
                {
                    return StatusCode(StatusCodes.Status401Unauthorized);
                }
                if (ModelState.IsValid)
                {

                    var user = await _userManager.FindByIdAsync(model.UserId);
                    if (user == null)
                    {
                        return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Invalid User." });

                    }
                    var result = _seRepository.DeleteUser(user);
                    if (result)
                    {
                        return Ok(new ResponseModel { Status = "Success", Message = "User Deleted Successfully!!!" });
                    }
                    else
                    {
                        return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Update Failed." });
                    }

                }
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in admin/DeleteUser:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());

            }
            return BadRequest();
        }

        [HttpPost(Name = "CreateUser")]
        [Route("CreateUser")]
        public async Task<IActionResult> CreateUser([FromBody] RegisterUserModel model)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var userExist = await _userManager.FindByNameAsync(model.UserName);
                    if (userExist != null)
                        return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "User Already Exist." });
                    string businessUnit = "";
                    if (model.UserTypeId == (int)UserType.CSSUser)
                    {

                        CSS userCSS = _seRepository.GetCSS(new ResourceParameters.CSSResourceParameter() { CSSId = model.CSSCode }).First();
                        if (userCSS == null)
                        {
                            return StatusCode(StatusCodes.Status400BadRequest, new ResponseModel { Status = "Error", Message = "Invalid CSS." });
                        }
                        businessUnit = userCSS.Business_Unit ?? "";
                    }

                    StoreUser seuser = new StoreUser()
                    {
                        FirstName = model.FirstName,
                        LastName = model.LastName,
                        UserType = model.UserTypeId,
                        UserZone = "",
                        Address = "",
                        Email = model.Email,
                        EmployeeCode = "",
                        CSSCode = model.CSSCode ?? "",
                        SecurityStamp = Guid.NewGuid().ToString(),
                        UserName = model.UserName,
                        UserStatus = 1,
                        BusinessUnit = businessUnit,
                        EmailConfirmed = true
                    };

                    var result = await _userManager.CreateAsync(seuser, model.Password);

                    if (!result.Succeeded)
                        return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "User Creation Failed." });


                    var confirmUser = await _userManager.FindByEmailAsync(model.Email);
                    if (confirmUser == null)
                    {
                        return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "User Creation Failed." });
                    }


                    //string code = await _userManager.GeneratePasswordResetTokenAsync(confirmUser);
                    //var resetPassword = await _userManager.ResetPasswordAsync(confirmUser, code, model.Password);

                    return Ok(new ResponseModel { Status = "Success", Message = "User Created Successfully." });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in admin/DeleteUser:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());

            }
            return BadRequest();
        }



        [HttpGet]
        [Route("GetCSSList")]
        public ActionResult GetCSSList()
        {
            if ((this.UserModel.UserType ?? -1) != ((int)UserType.Admin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }
            CSSResourceParameter cssParam = new CSSResourceParameter();

            var result = _seRepository.GetCSS(cssParam);


            var shapedData = _mapper.Map<IEnumerable<CSSModel>>(result)
                .ShapeData(cssParam.Fields);

            return Ok(shapedData);
        }


        // Update CSS Manager, Invoice Validator, Finance Validator

        [HttpPost(Name = "UpdateCSS")]
        [Route("UpdateCSS")]
        public IActionResult UpdateCSS([FromBody] CSSUpdateResourceParameter currentParams)
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.Admin))
                {
                    return StatusCode(StatusCodes.Status401Unauthorized);
                }
                if (ModelState.IsValid)
                {


                    var result = _seRepository.UpdateCss(currentParams);
                    if (result)
                    {
                        return Ok(new ResponseModel { Status = "Success", Message = "CSS Updated Successfully!!!" });
                    }
                    else
                    {
                        return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Update Failed." });
                    }

                }
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in admin/UpdateCSS:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());

            }
            return BadRequest();
        }
        [HttpPost(Name = "UpdateCSSEditData")]
        [Route("UpdateCSSEditData")]
        public IActionResult UpdateCSSUserData([FromBody] CSSZipCodeUpdateResourceParameter currentParams)
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.Admin))
                {
                    return StatusCode(StatusCodes.Status401Unauthorized);
                }
                if (ModelState.IsValid)
                {


                    var result = _seRepository.UploadCSSUserData(currentParams);
                    if (result)
                    {
                        return Ok(new ResponseModel { Status = "Success", Message = "CSS Updated Successfully!!!" });
                    }
                    else
                    {
                        return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Update Failed." });
                    }

                }
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in admin/UpdateCSS:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());

            }
            return BadRequest();
        }


        [HttpPost(Name = "UploadCSS")]
        [Route("UploadCSS")]
        public IActionResult UploadCSS()
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.Admin))
                {
                    return StatusCode(StatusCodes.Status401Unauthorized);
                }
                if (ModelState.IsValid)
                {


                    var result = _seRepository.UploadCSS();
                    if (result)
                    {
                        return Ok(new ResponseModel { Status = "Success", Message = "CSS Uploaded Successfully!!!" });
                    }
                    else
                    {
                        return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Update Failed." });
                    }

                }
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in admin/UploadCSS:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());

            }
            return BadRequest();
        }


     
        [HttpGet]
        [Route("GetProductCategoryList")]
        public ActionResult GetProductCategoryList()
        {

            if ((this.UserModel.UserType ?? -1) != ((int)UserType.Admin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }

            var cooling = _seRepository.GetProductCategoryCooling();
            var hbn = _seRepository.GetProductCategoryHBN();
            var ppi = _seRepository.GetProductCategoryPPI();

            var coolingModel = _mapper.Map<IEnumerable<ProductCategoryCoolingModel>>(cooling);
            var hbnModel = _mapper.Map<IEnumerable<ProductCategoryHBNModel>>(hbn);
            var ppiModel = _mapper.Map<IEnumerable<ProductCategoryPPIModel>>(ppi);

            return Ok(new
            {
                status = StatusCode(StatusCodes.Status200OK),
                cooling = coolingModel,
                hbn = hbnModel,
                ppi = ppiModel,
                coolingGroup = coolingModel.Select(u => u.Group).Distinct().ToList<string>(),
                hbnGroup = hbnModel.Select(u => u.Group).Distinct().ToList<string>(),
                ppiGroup = ppiModel.Select(u => u.Group).Distinct().ToList<string>()
            });
        }
        [HttpPost(Name = "InsertCoolingProduct")]
        [Route("InsertCoolingProduct")]
        public IActionResult InsertCoolingProduct(ProductCategoryCoolingSubmitParameter currentParam)
        {
            if ((this.UserModel.UserType ?? -1) != ((int)UserType.Admin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }
            if (ModelState.IsValid)
            {


                var result = _seRepository.InsertCoolingProduct(currentParam);
                if (result)
                {
                    return Ok(new ResponseModel { Status = "Success", Message = "Product Category Inserted Successfully!!!" });
                }
                else
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Insert Failed." });
                }

            }
            return BadRequest();
        }

        [HttpPost(Name = "UpdateCoolingProduct")]
        [Route("UpdateCoolingProduct")]
        public IActionResult UpdateCoolingProduct(ProductCategoryCoolingSubmitParameter currentParam)
        {
            if ((this.UserModel.UserType ?? -1) != ((int)UserType.Admin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }
            if (ModelState.IsValid)
            {


                var result = _seRepository.UpdateCoolingProduct(currentParam);
                if (result)
                {
                    return Ok(new ResponseModel { Status = "Success", Message = "Product Category Updated Successfully!!!" });
                }
                else
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Update Failed." });
                }

            }
            return BadRequest();
        }
        [HttpPost(Name = "InsertHBNProduct")]
        [Route("InsertHBNProduct")]
        public IActionResult InsertHBNProduct(ProductCategoryHBNSubmitParameter currentParam)
        {
            if ((this.UserModel.UserType ?? -1) != ((int)UserType.Admin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }
            if (ModelState.IsValid)
            {


                var result = _seRepository.InsertHBNProduct(currentParam);
                if (result)
                {
                    return Ok(new ResponseModel { Status = "Success", Message = "Product Category Inserted Successfully!!!" });
                }
                else
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Insert Failed." });
                }

            }
            return BadRequest();
        }

        [HttpPost(Name = "UpdateHBNProduct")]
        [Route("UpdateHBNProduct")]
        public IActionResult UpdateHBNProduct(ProductCategoryHBNSubmitParameter currentParam)
        {
            if ((this.UserModel.UserType ?? -1) != ((int)UserType.Admin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }
            if (ModelState.IsValid)
            {


                var result = _seRepository.UpdateHBNProduct(currentParam);
                if (result)
                {
                    return Ok(new ResponseModel { Status = "Success", Message = "Product Category Updated Successfully!!!" });
                }
                else
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Update Failed." });
                }

            }
            return BadRequest();
        }
        [HttpPost(Name = "InsertPPIProduct")]
        [Route("InsertPPIProduct")]
        public IActionResult InsertPPIProduct(ProductCategoryPPISubmitParameter currentParam)
        {
            if ((this.UserModel.UserType ?? -1) != ((int)UserType.Admin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }
            if (ModelState.IsValid)
            {


                var result = _seRepository.InsertPPIProduct(currentParam);
                if (result)
                {
                    return Ok(new ResponseModel { Status = "Success", Message = "Product Category Inserted Successfully!!!" });
                }
                else
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Insert Failed." });
                }

            }
            return BadRequest();
        }

        [HttpPost(Name = "UpdatePPIProduct")]
        [Route("UpdatePPIProduct")]
        public IActionResult UpdatePPIProduct(ProductCategoryPPISubmitParameter currentParam)
        {
            if ((this.UserModel.UserType ?? -1) != ((int)UserType.Admin))
            {
                return StatusCode(StatusCodes.Status401Unauthorized);
            }
            if (ModelState.IsValid)
            {


                var result = _seRepository.UpdatePPIProduct(currentParam);
                if (result)
                {
                    return Ok(new ResponseModel { Status = "Success", Message = "Product Category Updated Successfully!!!" });
                }
                else
                {
                    return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Update Failed." });
                }

            }
            return BadRequest();
        }

        [HttpPost(Name = "UploadPPIProduct")]
        [Route("UploadPPIProduct")]
        public IActionResult UploadPPIProduct()
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) != 0)
                    return (IActionResult)this.StatusCode(401);
                if (this.ModelState.IsValid)
                {
                    if (this._seRepository.UploadPPIProduct())
                        return (IActionResult)this.Ok((object)new ResponseModel()
                        {
                            Status = "Success",
                            Message = "PPI Product Uploaded Successfully!!!"
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

        [HttpPost(Name = "UploadHBNProduct")]
        [Route("UploadHBNProduct")]
        public IActionResult UploadHBNProduct()
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) != 0)
                    return (IActionResult)this.StatusCode(401);
                if (this.ModelState.IsValid)
                {
                    if (this._seRepository.UploadHBNProduct())
                        return (IActionResult)this.Ok((object)new ResponseModel()
                        {
                            Status = "Success",
                            Message = "HBN Product Uploaded Successfully!!!"
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
                LoggerExtensions.LogError((ILogger)this._logger, "Error in admin/UploadHBNProduct:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString(), Array.Empty<object>());
            }
            return (IActionResult)this.BadRequest();
        }

        [HttpPost(Name = "UploadCoolingProduct")]
        [Route("UploadCoolingProduct")]
        public IActionResult UploadCoolingProduct()
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) != 0)
                    return (IActionResult)this.StatusCode(401);
                if (this.ModelState.IsValid)
                {
                    if (this._seRepository.UploadCoolingProduct())
                        return (IActionResult)this.Ok((object)new ResponseModel()
                        {
                            Status = "Success",
                            Message = "Cooling Product Uploaded Successfully!!!"
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
                LoggerExtensions.LogError((ILogger)this._logger, "Error in admin/UploadCoolingProduct:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString(), Array.Empty<object>());
            }
            return (IActionResult)this.BadRequest();
        }
        [HttpPost(Name = "DeleteWorkOrderByMonth")]
        [Route("DeleteWorkOrderByMonth")]
        public IActionResult DeleteWorkOrderByMonth(int month, int year)
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) != 1)
                    return (IActionResult)this.StatusCode(401);
                if (this.ModelState.IsValid)
                {
                    if (this._seRepository.DeleteWorkOrderByMonth(month, year))
                        return (IActionResult)this.Ok((object)new ResponseModel()
                        {
                            Status = "Success",
                            Message = "Work Order Deleted Successfully!!!"
                        });
                    return (IActionResult)this.StatusCode(500, (object)new ResponseModel()
                    {
                        Status = "Error",
                        Message = "Work Order Deleted Failed."
                    });
                }
            }
            catch (Exception ex)
            {
                LoggerExtensions.LogError((ILogger)this._logger, "Error in DeleteWorkOrderByMonth:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString(), Array.Empty<object>());
            }
            return (IActionResult)this.BadRequest();
        }
        [HttpPost(Name = "DefaultPassword")]
        [Route("DefaultPassword")]
        public async Task<IActionResult> DefaultPassword([FromBody] ResetPasswordTokenModel model)
        {
            AdminController adminController = this;
            try
            {
                if (adminController.ModelState.IsValid)
                {
                    if (adminController._seRepository.ResetDefaultPassword(model.Email))
                        return (IActionResult)adminController.Ok((object)new ResponseModel()
                        {
                            Status = "Success",
                            Message = "Default Password Reset Successfully."
                        });
                    return (IActionResult)adminController.StatusCode(500, (object)new ResponseModel()
                    {
                        Status = "Error",
                        Message = "Password Reset Failed."
                    });
                }
            }
            catch (Exception ex)
            {
                LoggerExtensions.LogError((ILogger)adminController._logger, "Error in AccountController / DefaultPassword:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString(), Array.Empty<object>());
                return (IActionResult)adminController.BadRequest();
            }
            return (IActionResult)adminController.BadRequest();
        }
    }
}
