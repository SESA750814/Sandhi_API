using AutoMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Profiles
{
    public class ProductCategoryProfile : Profile
    {
        public ProductCategoryProfile()
        {
            CreateMap<Entities.ProductCategoryPPI, Models.ProductCategoryPPIModel>();
            CreateMap<Models.ProductCategoryPPIModel, Entities.ProductCategoryPPI>();
            CreateMap<Entities.ProductCategoryHBN, Models.ProductCategoryHBNModel>();
            CreateMap<Models.ProductCategoryHBNModel, Entities.ProductCategoryHBN>();
            CreateMap<Entities.ProductCategoryCooling, Models.ProductCategoryCoolingModel>();
            CreateMap<Models.ProductCategoryCoolingModel, Entities.ProductCategoryCooling>();

            CreateMap<Entities.Cooling_Rate_Card, Models.RateCardCoolingModel>();
            CreateMap<Entities.HBN_Rate_Card, Models.RateCardHBNModel>();
            CreateMap<Entities.PSI_Rate_Card, Models.RateCardPPIModel>();
        }
    }
}
