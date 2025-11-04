namespace SE.API.Services
{
    public interface IPropertyCheckerService
    {
        bool TypeHasProperties<TSource>(string fields);
    }
}