using AutoMapper;
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
    public class BaseCRUDService<T, TDb, TSearch, TInsert,TUpdate> : BaseService<T, TDb, TSearch> where T: class where TDb : class where TSearch:BaseSearchObject
    {
        public BaseCRUDService(eHairdressersContext context, IMapper mapper) : base(context, mapper)
        {
        }
        public virtual async Task BeforeInsert(TDb entity, TInsert insert)
        {

        }

        public virtual async Task<T> Insert (TInsert insert)
        {
            var set = _context.Set<TDb>();

            TDb entity = _mapper.Map<TDb>(insert);
          /*  if (entity is Appointment && insert is AppointmentInsertRequest)
            {
                var appointmentEntity = entity as Appointment;
                var appointmentInsert = insert as AppointmentInsertRequest;

                // Assuming the desired format is "yyyy-MM-dd HH:mm:ss"
                appointmentEntity.AppointmentDateTime = appointmentInsert.AppointmentDateTime.ToString("dd.MM.yyyy");
            }*/

            set.Add(entity);
            await BeforeInsert(entity, insert);

            await _context.SaveChangesAsync();

            return _mapper.Map<T>(entity);
        }

        public virtual async Task<T> Update(int id,TUpdate update)
        {
            var set = _context.Set<TDb>();

            var entity = await set.FindAsync(id);

            _mapper.Map(update, entity);
          
            await _context.SaveChangesAsync();

            return _mapper.Map<T>(entity);
        }

        public virtual async Task<T> Delete(int id)
        {
            var set = _context.Set<TDb>();

            var entity = await set.FindAsync(id);

            set.Remove(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<T>(entity);
        }


    }
}
