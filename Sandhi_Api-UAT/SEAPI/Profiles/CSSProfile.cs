using AutoMapper;
using SE.API.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Profiles
{
    public class CSSProfile : Profile
    {
        public CSSProfile()
        {
            CreateMap<Entities.CSS, Models.CSSModel>();
            CreateMap<Models.CSSModel, Entities.CSS>();



            CreateMap<Entities.CSS, Models.WorkOrderByCSSModel>()
                .ForMember(
                    dest => dest.CSS_Name,
                    opt => opt.MapFrom(src => src.CSS_Name_as_per_Oracle_SAP)
                )
                .ForMember(
                    dest => dest.WorkOrderCount,
                    opt => opt.MapFrom(src => src.WorkOrders.Count())
                )
                .ForMember(
                    dest => dest.Submitted_Date,
                    opt => opt.MapFrom(src =>
                    (src.WorkOrders.Count() > 0 ? src.WorkOrders.GroupBy(t => 1).Select(x => new { submittedDate = x.Max(p => p.CSS_Approved_Date) }).FirstOrDefault().submittedDate : null)
                    )
                )

                .ForMember(
                    dest => dest.Month_Name,
                    opt => opt.MapFrom(src =>
                    (src.WorkOrders.Count() > 0 ? src.WorkOrders.First().Month_Name : "")
                    )
                );





            CreateMap<Entities.CSS, Models.GradationByCSSModel>()
                .ForMember(
                    dest => dest.CSS_Name,
                    opt => opt.MapFrom(src => src.CSS_Name_as_per_Oracle_SAP)
                )
                 .ForMember(
                    dest => dest.Grade,
                    opt => opt.MapFrom(src => src.Gradations.Count() > 0 ? src.Gradations.First().FINAL_GRADE : "No Grade")
                )
                  .ForMember(
                    dest => dest.IsEligible,
                    opt => opt.MapFrom(src => src.Gradations.Count() > 0 ? src.Gradations.First().GradationEligibility : "No")
                )
                ;


            //CreateMap<Entities.WorkOrder, Models.WorkOrderByCSSModel>()

            //    .ForMember(
            //        dest => dest.Id,
            //        opt => opt.MapFrom(src => src.CSS.Id)
            //    )
            //    .ForMember(
            //        dest => dest.CSS_Code,
            //        opt => opt.MapFrom(src => src.CSS.CSS_Code)
            //    )
            //    .ForMember(
            //        dest => dest.CSS_Name,
            //        opt => opt.MapFrom(src => src.CSS.CSS_Name_in_bFS_to_be_referred)
            //    )
            //    .ForMember(
            //        dest => dest.Region,
            //        opt => opt.MapFrom(src => src.CSS.Region)
            //    )
            //    .ForMember(
            //        dest => dest.Vendor_Code,
            //        opt => opt.MapFrom(src => src.CSS.Vendor_Code)
            //    )
            //    .ForMember(
            //        dest => dest.Email_ID,
            //        opt => opt.MapFrom(src => src.CSS.Email_ID)
            //    )
            //    .ForMember(
            //        dest => dest.Business_Unit,
            //        opt => opt.MapFrom(src => src.CSS.Business_Unit)
            //    )
            //    .ForMember(
            //        dest => dest.City_Location,
            //        opt => opt.MapFrom(src => src.CSS.City_Location)
            //    );

        }
    }
}
