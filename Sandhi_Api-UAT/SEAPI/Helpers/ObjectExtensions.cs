using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;

namespace SE.API.Helpers
{
    public static class ObjectExtensions
    {

        public static ExpandoObject ShapeData<TSource>
            (this TSource source, string fields)
        {
            if (source == null)
            {
                throw new ArgumentNullException(nameof(source));
            }



            var propertyInfoList = new List<PropertyInfo>();

            if (string.IsNullOrEmpty(fields))
            {
                var propertyInfos = typeof(TSource)
                    .GetProperties(BindingFlags.Public | BindingFlags.Instance);

                propertyInfoList.AddRange(propertyInfos);
            }
            else
            {
                var fieldsAfterSplit = fields.Split(',');
                foreach (string field in fieldsAfterSplit)
                {
                    var propName = field.Trim();

                    var propInfo = typeof(TSource)
                        .GetProperty(propName,
                        BindingFlags.IgnoreCase | BindingFlags.Public | BindingFlags.Instance);

                    if (propInfo == null)
                    {
                        throw new Exception($"Property {propName} wasn't found on {typeof(TSource)}");
                    }

                    propertyInfoList.Add(propInfo);
                }
            }


            
                var dataShapedObj = new ExpandoObject();
                foreach (var propInfo in propertyInfoList)
                {
                    var propValue = propInfo.GetValue(source);
                    ((IDictionary<string, object>)dataShapedObj)
                        .Add(propInfo.Name, propValue);
                }

                


            return dataShapedObj;
        }
    }
}