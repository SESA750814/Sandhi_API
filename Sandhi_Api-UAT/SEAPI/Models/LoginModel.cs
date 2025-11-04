using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class LoginModel
    {
        public string UserEmail { get; set; }
        public string Password { get; set; }
        public string Method { get; set; }
    }
}
