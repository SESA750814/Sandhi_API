using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class UserModel
    {
        public string Id { get; set; }
        public string UserName { get; set; }
        public string Email { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string UserType { get; set; }
        public int? UserTypeId { get; set; }
        public int? UserStatus { get; set; }
        public string UserZone { get; set; }
        public string Address { get; set; }
        public string EmployeeCode { get; set; }
        public string CSSCode { get; set; }
        public string CSSName { get; set; }
        public string CSSRegion { get; set; }
        public string BusinessUnit { get; set; }

        public string UserRoleName { get; set; }
        public string UserRoleId { get; set; }
    }
}
