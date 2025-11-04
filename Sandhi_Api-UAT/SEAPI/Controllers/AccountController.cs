using SE.API.Entities;
using SE.API.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using System.Web;
using Microsoft.Extensions.Logging;
using SE.API.Services;
using SE.API.Helpers;
using SE.API.Utilities;

namespace SE.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [ResponseCache(CacheProfileName = "240SecsCacheProfile")]
    public class AccountController : ControllerBase
    {
        private IWorkOrderRepository _seRepository;
        private IPropertyCheckerService _propChecker;
        private UserManager<StoreUser> _userManager;
        private SignInManager<StoreUser> _signInManager;
        protected readonly IConfiguration _config;

        private ILogger<WorkOrderRepository> _logger;
        // Sorting  is ignored here if needed look at ways to do it...
        // think sorting can be achieved by extension method
        // implementing shaping

        [HttpGet]
        [Route("GetUsers")]
        public ActionResult GetUsers()
        {

            var org = "Got Value";
            return Ok(org);
        }
        public AccountController(UserManager<StoreUser> userManager, IWorkOrderRepository libraryRepository, SignInManager<StoreUser> signInManager,
            IPropertyCheckerService propertyChecker, ILogger<WorkOrderRepository> logger, IConfiguration config)
        {
            _seRepository = libraryRepository ?? throw new ArgumentNullException(nameof(libraryRepository));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _propChecker = propertyChecker ?? throw new ArgumentNullException(nameof(propertyChecker));
            _signInManager = signInManager;
            _userManager = userManager;
            _config = config;
        }


        [HttpPost(Name = "Register")]
        [Route("Register")]
        public async Task<IActionResult> Register([FromBody] RegisterUserModel model)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var userExist = await _userManager.FindByNameAsync(model.UserName);
                    if (userExist != null)
                        return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "User Already Exist." });
                    CSS userCSS = _seRepository.GetCSS(new ResourceParameters.CSSResourceParameter() { UserEmail = model.Email }).FirstOrDefault();
                    if (userCSS == null)
                    {
                        return StatusCode(StatusCodes.Status400BadRequest, new ResponseModel { Status = "Error", Message = "Invalid User Email." });
                    }

                    // TO-DO : The CSS CODE, EmployeeCode AND Business unit should be picked up from the CSS Code
                    StoreUser seuser = new StoreUser()
                    {
                        FirstName = model.FirstName,
                        LastName = model.LastName,
                        UserType = (int)(UserType.CSSUser),
                        UserZone = "",
                        Address = "",
                        Email = model.Email,
                        EmployeeCode = "",
                        CSSCode = userCSS.Id.ToString(),
                        SecurityStamp = Guid.NewGuid().ToString(),
                        UserName = model.UserName,
                        UserStatus = 1,
                        BusinessUnit = userCSS?.Business_Unit,
                    };

                    var result = await _userManager.CreateAsync(seuser, model.Password);

                    if (!result.Succeeded)
                        return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = $"User Creation Failed. {result.ToString()}" });


                    var confirmUser = await _signInManager.UserManager.FindByEmailAsync(model.Email);
                    if (confirmUser == null)
                    {
                        return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "User Creation Failed." });
                    }


                    string code = await _signInManager.UserManager.GeneratePasswordResetTokenAsync(confirmUser);
                    var callbackurl = _config.GetSection("Parameters").GetValue<String>("WEBURL") + "/ResetPassword?userId=" + model.Email + "&code=" + code;
                    var template = _config.GetSection("EmailTemplate").GetValue<string>("CONFIRMUSER");
                    template = template.Replace("{BODY}", callbackurl);
                    string userEmail = model.Email.Substring(0, model.Email.IndexOf('@')).ToUpper().Replace(".", " ");
                    template = template.Replace("{{USER}}", userEmail);

                    Email.SendEmail(_config, _logger, "SE Confirm User", template, model.Email);

                    return Ok(new ResponseModel { Status = "Success", Message = "User Created Successfully." });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in AccountController/ Register:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());

            }
            return BadRequest();
        }

        [HttpGet("Confirm")]
        [Route("Confirm")]
        public async Task<IActionResult> Confirm(string userId = "", string code = null)
        {
            try
            {
                if (code == null)
                {
                    return StatusCode(StatusCodes.Status400BadRequest, new ResponseModel { Status = "Error", Message = "Invalid User Email/Code." });
                }
                var user = await _signInManager.UserManager.FindByNameAsync(userId);
                if (user == null)
                {
                    return StatusCode(StatusCodes.Status400BadRequest, new ResponseModel { Status = "Error", Message = "Invalid User Email/Code." });
                }
                user.EmailConfirmed = true;
                _seRepository.UpdateEntity(user);
                _seRepository.Save();
            }
            catch(Exception ex)
            {

                _logger.LogError("Error in AccountController / Confirm:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());

            }
            return StatusCode(StatusCodes.Status200OK);
        }
        [HttpPost(Name = "ResetPasswordToken")]
        [Route("ResetPasswordToken")]
        public async Task<IActionResult> ResetPasswordToken([FromBody] ResetPasswordTokenModel model)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var userExist = await _userManager.FindByEmailAsync(model.Email);
                    if (userExist != null)
                    {
                        string token = await _userManager.GeneratePasswordResetTokenAsync(userExist);
                        var callbackurl = _config.GetSection("Parameters").GetValue<String>("WEBURL") + "ResetPassword?userid=" + model.Email + "&token=" + token;
                        var template = _config.GetSection("EmailTemplate").GetValue<string>("RESETPASSWORD");
                        template = template.Replace("{BODY}", callbackurl);
                        string userEmail = model.Email.Substring(0, model.Email.IndexOf('@')).ToUpper().Replace(".", " ");
                        template = template.Replace("{{USER}}", userEmail);

                        //Email.SendEmail(_config, _logger, "SE Confirm User", template, model.Email);

                        Email.EASendEmail(_config, _logger, "SE Confirm User", template, model.Email, "", "");

                        return Ok(new ResponseModel { Status = "Success", Message = "Email sent to reset password" });
                    }

                }
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in AccountController / ResetPasswordToken:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                return BadRequest();
            }

            return BadRequest();
        }


        [HttpPost(Name = "ResetPassword")]
        [Route("ResetPassword")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordModel model)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var existingUser = await _userManager.FindByEmailAsync(model.Email);
                    if (existingUser != null)
                    {
                        var resetPassword = await _userManager.ResetPasswordAsync(existingUser, model.Token, model.Password);
                        if (!resetPassword.Succeeded)
                            return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error", Message = "Password Reset Failed." });
                        if (!existingUser.EmailConfirmed)
                        {
                            existingUser.EmailConfirmed = true;
                            _seRepository.UpdateEntity(existingUser);
                            _seRepository.Save();
                        }
                    }
                    return Ok(new ResponseModel { Status = "Success", Message = "Password Reset Successfully." });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in AccountController/ ResetPassword:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());

            }
            return BadRequest();
        }
        [HttpPost(Name = "GetUserDetails")]
        [Route("GetUserDetails")]
        public async Task<IActionResult> GetUserDetails([FromBody] LoginModel model)
        {
            _logger.LogInformation("I am in Get User Details");
            try
            {
                if (ModelState.IsValid)
                {
                    var user = await _userManager.FindByEmailAsync(model.UserEmail);
                    if (user != null && (user.UserStatus ?? 0) == 1)
                    {
                        var result = await _signInManager.CheckPasswordSignInAsync(user, model.Password, false);

                        _logger.LogInformation("I am in Get User Details-1");
                        if (result.Succeeded)
                        {
                            return Ok(new UserModel
                            {
                                Id = user.Id,
                                UserName = user.UserName,
                                Email = user.Email,
                                FirstName = user.FirstName,
                                LastName = user.LastName,
                                UserType = ((UserType)user.UserType).GetDescription(),
                                UserTypeId = user.UserType,
                                UserZone = user.UserZone,
                                Address = user.Address,
                                EmployeeCode = user.EmployeeCode,
                                CSSCode = user.CSSCode,
                                BusinessUnit = user.BusinessUnit
                            });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in AccountController /GetUserDetails:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());

            }
            return BadRequest();
        }
        [HttpPost(Name = "ResetPasswordTokenWOE")]
        [Route("ResetPasswordTokenWOE")]
        public async Task<IActionResult> ResetPasswordTokenWOE([FromBody] ResetPasswordTokenModel model)
        {
            AccountController accountController = this;
            try
            {
                if (accountController.ModelState.IsValid)
                {
                    StoreUser byEmailAsync = await accountController._userManager.FindByEmailAsync(model.Email);
                    if (byEmailAsync != null)
                    {
                        string passwordResetTokenAsync = await accountController._userManager.GeneratePasswordResetTokenAsync(byEmailAsync);
                        return (IActionResult)accountController.Ok((object)new ResponseModelToken()
                        {
                            Token = passwordResetTokenAsync
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                LoggerExtensions.LogError((ILogger)accountController._logger, "Error in AccountController / ResetPasswordToken:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString(), Array.Empty<object>());
                return (IActionResult)accountController.BadRequest();
            }
            return (IActionResult)accountController.BadRequest();
        }
        [HttpGet("ConfirmPasswordChanged")]
        [Route("ConfirmPasswordChanged")]
        public async Task<IActionResult> ConfirmPasswordChanged(string userId = "")
        {
            AccountController accountController = this;
            try
            {
                StoreUser byNameAsync = await accountController._signInManager.UserManager.FindByNameAsync(userId);
                if (byNameAsync == null)
                    return (IActionResult)accountController.StatusCode(400, (object)new ResponseModel()
                    {
                        Status = "Error",
                        Message = "Invalid User Email/Code."
                    });
                if (((IdentityUser<string>)byNameAsync).Email.ToLower().Equals(userId) && !((IdentityUser<string>)byNameAsync).EmailConfirmed)
                    return (IActionResult)accountController.StatusCode(200, (object)new ResponseModel()
                    {
                        Status = "False",
                        Message = "Password Yet to be changed"
                    });
                return (IActionResult)accountController.StatusCode(200, (object)new ResponseModel()
                {
                    Status = "True",
                    Message = "Password changed"
                });
            }
            catch (Exception ex)
            {
                LoggerExtensions.LogError((ILogger)accountController._logger, "Error in AccountController / Confirm:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString(), Array.Empty<object>());
                return (IActionResult)accountController.StatusCode(400, (object)new ResponseModel()
                {
                    Status = "Error",
                    Message = ex.InnerException?.ToString()
                });
            }
        }
    }
}
