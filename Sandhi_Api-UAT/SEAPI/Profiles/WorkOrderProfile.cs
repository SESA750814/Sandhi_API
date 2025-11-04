using AutoMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Profiles
{
    public class WorkOrderProfile : Profile
    {
        public WorkOrderProfile()
        {
            CreateMap<Entities.WorkOrder, Models.WorkOrderModel>()
                .ForMember(
                    dest => dest.CSS_Code,
                    opt => opt.MapFrom(src => src.CSS.CSS_Code)
                ).ForMember(
                    dest => dest.CSS_Name,
                    opt => opt.MapFrom(src => src.CSS.CSS_Name_as_per_Oracle_SAP)
                ).ForMember(
                    dest => dest.Grade,
                    opt => opt.MapFrom(src => src.CSS.Grade)
                ).ForMember(
                    dest => dest.Base_Payout_Percentage,
                    opt => opt.MapFrom(src => src.CSS.Base_Payout_Percentage)
                ).ForMember(
                    dest => dest.Incentive_Percentage,
                    opt => opt.MapFrom(src => src.CSS.Incentive_Percentage)
                );
            CreateMap<Models.WorkOrderModel, Entities.WorkOrder>();
            CreateMap<Entities.WorkOrderStatus, Models.WorkOrderStatusModel>();
            CreateMap<Models.WorkOrderStatusModel, Entities.WorkOrderStatus>();
        }
    }
}
