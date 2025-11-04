using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
namespace SE.API.Entities
{
    public class StoreUser : IdentityUser
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }

        public int? UserType { get; set; }
        public int? UserStatus { get; set; }

        public string UserZone { get; set; }

        public string Address { get; set; }

        public string EmployeeCode { get; set; }

        public string CSSCode { get; set; }

        public string BusinessUnit { get; set; }
    }

    public enum UserType
    {
        Admin = 0,
        [Description("Central User")]
        CentralUser = 1,
        [Description("CSS Manager")]
        CSSManager = 2,
        [Description("CSS User")]
        CSSUser = 3,
        [Description("Finance User")]
        FinanceUser = 4,
        [Description("SCM User")]
        SCMUser = 5,
        [Description("Super Admin")]
        SuperAdmin = 6,
    }
}
