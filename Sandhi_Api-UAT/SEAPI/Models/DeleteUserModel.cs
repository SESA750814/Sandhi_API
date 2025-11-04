using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class DeleteUserModel
    {
        [Required(ErrorMessage = "User Id is Required")]
        public string UserId { get; set; }
    }
}
