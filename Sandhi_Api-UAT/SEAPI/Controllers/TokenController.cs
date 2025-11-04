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
using Microsoft.Extensions.Configuration;
using System.Text;
using Microsoft.AspNetCore.Http;

namespace SE.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [ResponseCache(CacheProfileName = "240SecsCacheProfile")]
    //[Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public class TokenController : ControllerBase
    {
        private IWorkOrderRepository _seRepository;
        private IMapper _mapper;
        private IPropertyCheckerService _propChecker;
        private UserManager<StoreUser> _userManager;
        private SignInManager<StoreUser> _signInManager;
        private readonly IConfiguration _config;

        private ILogger<WorkOrderRepository> _logger;
        // Sorting  is ignored here if needed look at ways to do it...
        // think sorting can be achieved by extension method
        // implementing shaping

        public TokenController(UserManager<StoreUser> userManager, SignInManager<StoreUser> signInManager,
            IWorkOrderRepository libraryRepository, IMapper mapper, IPropertyCheckerService propertyChecker,
            ILogger<WorkOrderRepository> logger, IConfiguration config)
        {
            _seRepository = libraryRepository ?? throw new ArgumentNullException(nameof(libraryRepository));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _mapper = mapper ?? throw new ArgumentNullException(nameof(mapper));
            _propChecker = propertyChecker ?? throw new ArgumentNullException(nameof(propertyChecker));
            _userManager = userManager;
            _signInManager = signInManager;
            _config = config;
        }

        [HttpPost(Name = "CreateToken")]
        [Route("CreateToken")]
        public async Task<IActionResult> CreateToken(LoginViewModel model)
        {
            try
            {
                _logger.LogInformation("I am in" + model.UserEmail + model.Password);
                _logger.LogError("I am in");
                _logger.LogError("ModelState"+ ModelState.IsValid.ToString());
                _logger.LogError("This.ModelState" + this.ModelState.IsValid.ToString());
                _logger.LogInformation("Current UTC Time" + DateTime.UtcNow);


                if (ModelState.IsValid)
                {
                    _logger.LogError("UserEmail" + model.UserEmail);
                    var user = await _userManager.FindByNameAsync(model.UserEmail);
                    _logger.LogError("User" + user);

                    if (user != null)
                    {
                        var result = await _signInManager.CheckPasswordSignInAsync(user, model.Password, false);
                        if (result.Succeeded)
                        {
                            _logger.LogError("Check password is successful");
                            var claims = new[]
                            {
                            new Claim(JwtRegisteredClaimNames.Sub, user.Email),
                            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                            new Claim(JwtRegisteredClaimNames.UniqueName, user.UserName)
                        };

                            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Tokens:Key"]));

                            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

                            var token = new JwtSecurityToken(
                                _config["Tokens:Issuer"],
                                _config["Tokens:Audience"],
                                claims,
                                signingCredentials: creds,
                                expires: DateTime.UtcNow.AddMinutes(Convert.ToInt32(_config["Tokens:Minutes"])));
                            _logger.LogError("token: " + token);                          
                            var retUser = await _userManager.FindByNameAsync(model.UserEmail);
                            _logger.LogError("retUser: " + retUser);
                            var userModel = new UserModel();
                            if (retUser != null)
                            {
                                userModel = new UserModel
                                {
                                    Id = retUser.Id,
                                    UserName = retUser.UserName,
                                    Email = retUser.Email,
                                    UserRoleName = "central",
                                    UserRoleId = "7",
                                    FirstName = retUser.FirstName,
                                    LastName = retUser.LastName,
                                    UserType = ((UserType)retUser.UserType).GetDescription(),
                                    UserTypeId = retUser.UserType,
                                    UserZone = retUser.UserZone,
                                    Address = retUser.Address,
                                    EmployeeCode = retUser.EmployeeCode,
                                    CSSCode = retUser.CSSCode,
                                    BusinessUnit = retUser.BusinessUnit
                                };
                            }
                            return Created("", new
                            {
                            status = StatusCode(StatusCodes.Status200OK),
                                token = new JwtSecurityTokenHandler().WriteToken(token),
                                expiration = token.ValidTo,
                                UserData = userModel
                            });
                        }
                        else
                        {

                            return Created("", new
                            {
                                status = StatusCode(StatusCodes.Status400BadRequest)
                            });
                        }
                    }
                }
                return StatusCode(StatusCodes.Status400BadRequest);
            }
            catch(Exception ex)
            {
                _logger.LogError("Error in TokenController Get Token:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString() + ex.StackTrace);
               
                return StatusCode(StatusCodes.Status500InternalServerError);
            }
        }
    }
}
