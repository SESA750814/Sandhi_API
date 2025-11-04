using SE.API.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.ValidationAttributes
{
    public class OrganisationCannotBeBlank : ValidationAttribute
    {
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            //var obj = (UniversityForManipulationDTO)value;
            //if (string.IsNullOrEmpty(obj.OrganisationId.ToString()))
            //{
            //    return new ValidationResult(ErrorMessage, new[] { nameof(UniversityForManipulationDTO) });
            //}

            return ValidationResult.Success;
        }
    }
}
