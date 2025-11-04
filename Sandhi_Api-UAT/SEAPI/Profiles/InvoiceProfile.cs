using AutoMapper;
using SE.API.Entities;
using SE.API.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Profiles
{
    public class InvoiceProfile : Profile
    {
        public InvoiceProfile()
        {
            CreateMap<Entities.Invoice, Models.InvoiceModel>()
                .ForMember(
                    dest => dest.CSS_Code,
                    opt => opt.MapFrom(src => src.CSS.CSS_Code)
                ).ForMember(
                    dest => dest.CSS_Name,
                    opt => opt.MapFrom(src => src.CSS.CSS_Name_in_bFS_to_be_referred)
                ).ForMember(
                    dest => dest.CSS_Short_Name,
                    opt => opt.MapFrom(src => src.CSS.CSS_Name_as_per_Oracle_SAP)
                ).ForMember(
                    dest => dest.Region,
                    opt => opt.MapFrom(src => src.CSS.Region)
                ).ForMember(
                    dest => dest.Email_ID,
                    opt => opt.MapFrom(src => src.CSS.Email_ID)
                ).ForMember(
                    dest => dest.PO_NO,
                    opt => opt.MapFrom(src => src.PurchaseOrder.PO_NO)
                ).ForMember(
                    dest => dest.PO_Date,
                    opt => opt.MapFrom(src => src.PurchaseOrder.PO_Date)
                ).ForMember(
                    dest => dest.Vendor_Code,
                    opt => opt.MapFrom(src => src.CSS.Vendor_Code)
                ).ForMember(
                    dest => dest.CSS_Name_as_per_Oracle_SAP,
                    opt => opt.MapFrom(src => src.CSS.CSS_Name_as_per_Oracle_SAP)
                ).ForMember(
                    dest => dest.WorkOrderStatuses,
                    opt => opt.MapFrom(src =>
                        src.WorkOrders != null && src.WorkOrders.Any()
                            ? src.WorkOrders
                                .Where(wo => wo != null && wo.WorkOrderStatuses != null)
                                .SelectMany(wo => wo.WorkOrderStatuses)
                                .Where(status => status != null && !string.IsNullOrEmpty(status.Remarks))
                                .ToList()
                            : new List<WorkOrderStatus>())
                );
            CreateMap<Models.InvoiceModel, Entities.Invoice>();



            CreateMap<Entities.InvoiceDetail, Models.InvoiceDetailModel>();
            CreateMap<Models.InvoiceDetailModel, Entities.InvoiceDetail>();



            CreateMap<Entities.PurchaseOrder, Models.PurchaseOrderModel>()
                .ForMember(
                    dest => dest.CSS_Code,
                    opt => opt.MapFrom(src => src.CSS.CSS_Code)
                ).ForMember(
                    dest => dest.CSS_Name,
                    opt => opt.MapFrom(src => src.CSS.CSS_Name_in_bFS_to_be_referred)
                );
            CreateMap<Models.PurchaseOrderModel, Entities.PurchaseOrder>();
            CreateMap<WorkOrderStatus, WorkOrderStatusModel>();
            CreateMap<WorkOrder, WorkOrderModel>();


        }
    }
}
