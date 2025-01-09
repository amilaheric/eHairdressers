using AutoMapper;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace eHairdressers.Services
{
    public class Mapper:Profile
    {
        public Mapper()
        {
            CreateMap<Database.Products,Model.Products>();
            CreateMap<Database.Category, Model.Category>();
            CreateMap<Database.Brand, Model.Brand>();
            CreateMap<Database.User, Model.User>();
            CreateMap<Database.UserRole, Model.UserRole>();
            CreateMap<Database.Role, Model.Role>();
            CreateMap<Database.Appointment, Model.Appointment>();
            CreateMap<Database.Service, Model.Service>();

            CreateMap<Model.Requests.ProductInsertRequest, Database.Products>();
            CreateMap<Model.Requests.AppointmentInsertRequest, Database.Appointment>();
            CreateMap<Model.Requests.AppointmentUpdateRequest, Database.Appointment>();
            CreateMap<Model.Requests.ProductUpdateRequest, Database.Products>()
                 .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));// da mogu i null vrijednosti
            CreateMap<Model.Requests.UserInsertRequest, Database.User>()
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));// da mogu i null vrijednosti
            CreateMap<Model.Requests.UserUpdateRequest, Database.User>();

        }
    }
}
