using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;

namespace SE.API.Services
{
    public class PropertyCheckerService : IPropertyCheckerService
    {
        public bool TypeHasProperties<TSource>(string fields)
        {
            if (string.IsNullOrEmpty(fields))
            {
                return true;
            }
            var fieldsAfterSplit = fields.Split(',');
            foreach (string field in fieldsAfterSplit)
            {
                var propName = field.Trim();

                var propInfo = typeof(TSource)
                    .GetProperty(propName,
                    BindingFlags.IgnoreCase | BindingFlags.Public | BindingFlags.Instance);

                if (propInfo == null)
                {
                    return false;
                }

            }
            return true;
        }
    }
}
