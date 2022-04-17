using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace BasicAuth.CustomAttributes
{
    public class AuthorizeBasicAuthAttribute : AuthorizeAttribute, IAuthorizationFilter
    {
        public void OnAuthorization(AuthorizationFilterContext context)
        {
            if (context.HttpContext.Items["BasicAuth"] is not true)
            {
                context.Result = new UnauthorizedResult();
                return;
            }
        }
    }
}
