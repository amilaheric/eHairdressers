using AutoMapper;
using eHairdressers.Model.Requests;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.Globalization;
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
            CreateMap<Database.User, Model.User>()
                .ForMember(dest => dest.UserRoles, opt => opt.MapFrom(src => src.UserRoles));
            CreateMap<Database.UserRole, Model.UserRole>()
                .ForMember(dest => dest.Role, opt => opt.MapFrom(src => src.Role));
            CreateMap<Database.Role, Model.Role>()
                .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.Name));
            CreateMap<Database.Appointment, Model.Appointment>()
                .ForMember(dest => dest.ServiceName, opt => opt.MapFrom(src => src.Service != null ? src.Service.ServiceName : null))
                .ForMember(dest => dest.Username, opt => opt.MapFrom(src => src.User != null ? src.User.Username : null))
                .ForMember(dest => dest.EmployeeName, opt => opt.MapFrom(src => src.Employee != null ? src.Employee.Name : null));
            CreateMap<Database.Service, Model.Service>();
            CreateMap<Database.Employees, Model.Employees>();

            CreateMap<Database.Orders, Model.Orders>()
                .ForMember(dest => dest.OrderNumber, opt => opt.MapFrom(src => src.OrderNumber))
                .ForMember(dest => dest.Status, opt => opt.MapFrom(src => src.Status ? "Completed" : "Pending"))
                .ForMember(dest => dest.TotalWithVAT, opt => opt.MapFrom(src => src.TotalPrice))
                .ForMember(dest => dest.TotalWithoutVAT, opt => opt.MapFrom(src => src.TotalPrice * 0.8))

                .ForMember(dest => dest.OrderItems, opt => opt.Ignore());
            CreateMap<Model.Requests.OrdersInsertRequest, Database.Orders>()
                .ForMember(dest => dest.OrderDate, opt => opt.MapFrom(src => src.Date ?? DateTime.Now))
                .ForMember(dest => dest.Status, opt => opt.MapFrom(src => src.Status))
                .ForMember(dest => dest.OrderNumber, opt => opt.MapFrom(src => src.OrderNumber ?? $"ORD-{DateTime.Now.Ticks}"))
                .ForMember(dest => dest.UserId, opt => opt.Ignore()) 
                .ForMember(dest => dest.TotalPrice, opt => opt.Ignore());
            CreateMap<Model.Requests.OrdersUpdateRequest, Database.Orders>()
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
            CreateMap<Database.Payment, Model.Payment>();
            CreateMap<Model.Requests.PaymentInsertRequest, Database.Payment>()
                .ForMember(dest => dest.PaymentDate, opt => opt.MapFrom(src => DateTime.Now))
                .ForMember(dest => dest.PaymentStatus, opt => opt.MapFrom(src => "Pending"));
            CreateMap<Model.Requests.PaymentUpdateRequest, Database.Payment>()
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
            CreateMap<Database.OrderItems, Model.OrderItems>();
            CreateMap<Model.Requests.OrderItemsInsertRequest, Database.OrderItems>()
                .ForMember(dest => dest.OrderItemId, opt => opt.Ignore()); 
            CreateMap<Model.Requests.OrderItemsUpdateRequest, Database.OrderItems>()
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));








            CreateMap<Model.Requests.ProductInsertRequest, Database.Products>();
            CreateMap<Model.Requests.AppointmentInsertRequest, Database.Appointment>()
                .ForMember(dest => dest.EmployeeId, opt => opt.MapFrom(src => src.EmployeeId))
                .ForMember(dest => dest.UserId, opt => opt.MapFrom(src => src.UserId))
                .ForMember(dest => dest.ServiceId, opt => opt.MapFrom(src => src.ServiceId))
                .ForMember(dest => dest.AppointmentDate, opt => opt.MapFrom(src => src.AppointmentDate))
                .ForMember(dest => dest.AppointmentTime, opt => opt.MapFrom(src => TimeSpan.Parse(src.AppointmentTime)))
                .ForMember(dest => dest.Comment, opt => opt.MapFrom(src => src.Comment));

          


            CreateMap<Model.Requests.AppointmentUpdateRequest, Database.Appointment>();
         

            CreateMap<Model.Requests.ProductUpdateRequest, Database.Products>()
                 .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
            CreateMap<Model.Requests.UserInsertRequest, Database.User>()
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));              
            CreateMap<Model.Requests.UserUpdateRequest, Database.User>();

           
            CreateMap<Database.Reviews, Model.Review>();
            CreateMap<Model.Requests.ReviewInsertRequest, Database.Reviews>();
            CreateMap<Model.Requests.ReviewUpdateRequest, Database.Reviews>()
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));


            CreateMap<Database.ChatRoom, Model.ChatRoom>();
            CreateMap<Database.Message, Model.Message>();
            CreateMap<Model.Requests.ChatRoomInsertRequest, Database.ChatRoom>();
            CreateMap<Model.Requests.MessageInsertRequest, Database.Message>();

            CreateMap<Model.Requests.CreateEmployeeRequest, Database.User>();
            CreateMap<Model.Requests.CreateEmployeeRequest, Database.Employees>();

        }
      
    
}
}
