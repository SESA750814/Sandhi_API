using AutoMapper;
using SE.API.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Profiles
{
    public class NotificationProfile : Profile
    {
        public NotificationProfile()
        {
            CreateMap<Entities.Notification, Models.NotificationModel>();
            CreateMap<Models.NotificationModel, Entities.Notification>();

        }
    }
}
