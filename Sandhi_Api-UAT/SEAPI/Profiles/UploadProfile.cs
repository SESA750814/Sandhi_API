using AutoMapper;
using SE.API.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Profiles
{
    public class UploadProfile : Profile
    {
        public UploadProfile()
        {
            CreateMap<Entities.UploadErrors, Models.UploadErrorsModel>();
            CreateMap<Models.UploadErrorsModel, Entities.UploadErrors>();

        }
    }
}
