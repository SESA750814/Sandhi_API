using AutoMapper;
using SE.API.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Profiles
{
    public class GradationProfile : Profile
    {
        public GradationProfile()
        {
            CreateMap<Entities.Gradation, Models.GradationModel>();
            CreateMap<Models.GradationModel, Entities.Gradation>();

            CreateMap<Entities.GradationDetail, Models.GradationDetailModel>();
            CreateMap<Models.GradationDetailModel, Entities.GradationDetail>();
        }
    }
}
