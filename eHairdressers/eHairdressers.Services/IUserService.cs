using AutoMapper;
using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services
{
    public interface IUserService : ICRUDService<Model.User, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        public Task<Model.User> Login(string username, string password);
       // public Task<Model.Appointments> CheckFreeAppointments(AppointmentsSearchObject appointmentsSearchObject);
    }
}
