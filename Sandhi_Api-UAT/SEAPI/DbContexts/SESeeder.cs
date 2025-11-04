using SE.API.Entities;
using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.DbContexts
{
    public class SESeeder
    {
        private SEDBContext _ctx;
        private UserManager<StoreUser> _userManager;

        public SESeeder(SEDBContext ctx, UserManager<StoreUser> userManager)
        {
            _ctx = ctx;
            _userManager = userManager;
        }

        public async Task Seed()
        {
           
            StoreUser user = await _userManager.FindByEmailAsync("test@test.com");
            if (user == null)
            {
                user = new StoreUser()
                {
                    FirstName = "TEST",
                    LastName = "test",
                    UserName = "test@test.com",
                    Email = "test@test.com",
                    EmailConfirmed = true
                };
                var result = await _userManager.CreateAsync(user, "P@ssw0rd!");
                if (result != IdentityResult.Success)
                    throw new InvalidOperationException("Coudlnt create");
            }

        }
    }

}
