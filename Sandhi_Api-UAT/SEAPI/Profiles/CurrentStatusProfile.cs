using AutoMapper;
using SE.API.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Profiles
{
    public class CurrentStatusProfile : Profile
    {
        public CurrentStatusProfile()
        {
            CreateMap<Entities.CurrentStatus, Models.CurrentStatusModel>();
            CreateMap<Models.CurrentStatusModel, Entities.CurrentStatus>();

        }
    }
}
