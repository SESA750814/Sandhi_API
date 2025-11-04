using SE.API.Models;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Controllers
{
    [ApiController]
    [Route("/api")]
    public class RootController : ControllerBase
    {
        [HttpGet(Name ="GetRoot")]
        public IActionResult Get()
        {
            var links = new List<LinkDTO>();

            links.Add(
                new LinkDTO(Url.Link("GetRoot", new { }),
                "self",
                "GET")
                );

            //links.Add(
            //    new LinkDTO(Url.Link("GetOrganisation", new { }),
            //    "Organisation",
            //    "GET")
            //    );

            return Ok(links);
        }
    }
}
