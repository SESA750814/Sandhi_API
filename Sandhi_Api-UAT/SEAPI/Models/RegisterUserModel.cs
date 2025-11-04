using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class RegisterUserModel
    {
        [Required(ErrorMessage = "First Name is Required")]
        public string FirstName { get; set; }

        [Required(ErrorMessage = "Last Name is Required")]
        public string LastName { get; set; }

        [Required(ErrorMessage = "User Name is Required")]
        public string UserName { get; set; }

        [Required(ErrorMessage = "Password is Required")]
        public string Password { get; set; }

        [Required(ErrorMessage = "Email is Required")]
        public string Email { get; set; }

        public string UserType { get; set; }
        public int? UserTypeId { get; set; }

        public string UserZone { get; set; }

        public string UserRole { get; set; }

        public string Address { get; set; }

        public string EmployeeCode { get; set; }

        public string CSSCode { get; set; }

        public string BusinessUnit { get; set; }
    }
}
