using AutoMapper;
using SE.API.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Profiles
{
    public class ApprovedDataProfile : Profile
    {
        public ApprovedDataProfile()
        {
            CreateMap<Entities.ApprovedData, Models.ApprovedDataModel>();
            CreateMap<Models.ApprovedDataModel, Entities.ApprovedData>();
            CreateMap<Entities.ApprovedDataWorkOrder, Models.ApprovedDataWorkOrderModel>();
            CreateMap<Models.ApprovedDataWorkOrderModel, Entities.ApprovedDataWorkOrder>();

        }
    }
}
