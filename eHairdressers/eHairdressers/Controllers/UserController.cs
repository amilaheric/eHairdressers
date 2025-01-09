using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : BaseCRUDController<Model.User, UserSearchObject, UserInsertRequest,UserUpdateRequest>
    {
        public UserController(ILogger<BaseController<User, UserSearchObject>> logger,IUserService service) : base(logger, service)
        {
        }

        public override Task<User> Insert([FromBody] UserInsertRequest insert)
        {
            return base.Insert(insert);
        }

        //[HttpGet("CheckFreeAppointments")]
        //public async Task<Appointments> GetFreeAppointemnts([FromBody] AppointmentsSearchObject searchObject)
        //{
        //    var freeAppointemnts = 
        //    return freeAppointemnts;
        //}

    }
}
